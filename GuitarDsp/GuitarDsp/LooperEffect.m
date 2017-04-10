//
//  LooperEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 20.03.2017.
//
//

#import "LooperEffect.h"
#import "RawAudioPlayer.h"
#import "TimingCalc.h"

@interface LooperEffect () {
    float **recordingBuffer;
}

@property (nonatomic, assign) float tempo;
@property (nonatomic, assign, readwrite) int tactsCount;
@property (nonatomic, assign) int bankLengthInPackets;
@property (nonatomic, assign) int currentPacketPointer;
@property (nonatomic, assign) int tactSizeInPackets;
@property (nonatomic, assign) int quaterTactSizeInPackets;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) int banksCount;
@property (nonatomic, assign) struct LooperBank *recordingBank;
@property (nonatomic, strong) RawAudioPlayer *tactAudioPlayer;
@property (nonatomic, strong) RawAudioPlayer *quaterTactAudioPlayer;
@property (nonatomic, assign, readwrite) float durationInSeconds;
@property (nonatomic, copy) void (^configuration)(void);

@end

@implementation LooperEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings banksCount:(int)banksCount tempo:(float)tempo tactsCount:(int)tactsCount {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.banksCount = banksCount;
    self.tempo = tempo;
    self.tactsCount = tactsCount;
    self.playMetronome = YES;
    [self setupAudioPlayers];
    [self calculateTimings];
    [self setupBuffers];
    return self;
}

- (void)setupAudioPlayers {
    self.tactAudioPlayer = [[RawAudioPlayer alloc] initWithSamplingSettings:self.samplingSettings data:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[LooperEffect class]] pathForResource:@"snare" ofType:@"raw"]]];
    self.quaterTactAudioPlayer = [[RawAudioPlayer alloc] initWithSamplingSettings:self.samplingSettings data:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[LooperEffect class]] pathForResource:@"hihat" ofType:@"raw"]]];
}

- (void)calculateTimings {
    struct Timing timing;
    timing.tactPart = Whole;
    timing.tempo = self.tempo;
    
    self.tactSizeInPackets = [TimingCalc sampleTime:timing settings:self.samplingSettings];
    self.quaterTactSizeInPackets = self.tactSizeInPackets / 4;
    self.bankLengthInPackets = self.tactSizeInPackets * self.tactsCount;
    self.durationInSeconds = self.bankLengthInPackets / (self.samplingSettings.frequency / self.samplingSettings.framesPerPacket);
    self.currentPacketPointer = 0;
}

- (void)setupBuffers {
    self.looperBanks = malloc(sizeof(struct LooperBank) * self.banksCount);
    for (int i = 0; i < self.banksCount; i++) {
        self.looperBanks[i].state = Off;
        self.looperBanks[i].packetsBuffer = malloc(sizeof(float *) * self.bankLengthInPackets);
        for (int j = 0; j < self.bankLengthInPackets; j++) {
            self.looperBanks[i].packetsBuffer[j] = malloc(self.samplingSettings.packetByteSize);
            bzero(self.looperBanks[i].packetsBuffer[j], self.samplingSettings.packetByteSize);
        }
    }
    
    recordingBuffer = malloc(sizeof(float *) * self.bankLengthInPackets);
    for (int i = 0; i < self.bankLengthInPackets; i ++) {
        recordingBuffer[i] = malloc(self.samplingSettings.packetByteSize);
        bzero(recordingBuffer[i], self.samplingSettings.packetByteSize);
    }
}

- (void)freeBuffers {
    for (int i = 0; i < self.bankLengthInPackets; i ++) {
        free(recordingBuffer[i]);
    }
    free(recordingBuffer);
    
    for (int i = 0; i < self.banksCount; i++) {
        for (int j = 0; j < self.bankLengthInPackets; j++) {
            free(self.looperBanks[i].packetsBuffer[j]);
        }
        free(self.looperBanks[i].packetsBuffer);
    }
    
    free(self.looperBanks);
}

- (void)record:(struct LooperBank *)looperBank {
    looperBank->state = Record;
    self.recordingBank = looperBank;
}

- (void)finishRecording {
    if (self.recordingBank) {
        self.recordingBank->state = On;
        self.recordingBank = nil;
    }
}

- (void)copyRecordToBank {
    if (self.recordingBank) {
        for (int i = 0; i < self.bankLengthInPackets; i++) {
            memcpy(self.recordingBank->packetsBuffer[i], recordingBuffer[i], self.samplingSettings.packetByteSize);
        }
    }
}

- (void)updateTactsCount:(int)tactsCount {
    __weak typeof(self) wSelf = self;
    [self setConfiguration:^{
        [wSelf freeBuffers];
        wSelf.tactsCount = tactsCount;
        [wSelf calculateTimings];
        [wSelf setupBuffers];
    }];
}

- (void)updateTempo:(float)tempo {
    __weak typeof(self) wSelf = self;
    [self setConfiguration:^{
        [wSelf freeBuffers];
        wSelf.tempo = tempo;
        [wSelf calculateTimings];
        [wSelf setupBuffers];
    }];
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
    // Record
    memcpy(recordingBuffer[self.currentPacketPointer], inputSample.amp, self.samplingSettings.packetByteSize);
    
    // Mix current
    float *output = malloc(self.samplingSettings.packetByteSize);
    memcpy(output, inputSample.amp, self.samplingSettings.packetByteSize);
    
    // Mix banks
    for (int i = 0; i < self.banksCount; i++) {
        struct LooperBank looperBank = self.looperBanks[i];
        if (looperBank.state == On) {
            for (int j = 0; j < self.samplingSettings.framesPerPacket; j++) {
                output[j] += looperBank.packetsBuffer[self.currentPacketPointer][j];
            }
        }
    }
    
    // Mix metronome
    if (self.playMetronome) {
        if (self.currentPacketPointer % self.tactSizeInPackets == 0) {
            [self.tactAudioPlayer play];
        } else if (self.currentPacketPointer % self.quaterTactSizeInPackets == 0) {
            [self.quaterTactAudioPlayer play];
        }
        
        if (self.tactAudioPlayer.status == Playing) {
            float *metronomeBuffer = [self.tactAudioPlayer next];
            for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
                output[i] += metronomeBuffer[i] * 0.1;
            }
        }
        if (self.quaterTactAudioPlayer.status == Playing) {
            float *metronomeBuffer = [self.quaterTactAudioPlayer next];
            for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
                output[i] += metronomeBuffer[i] * 0.1;
            }
        }
    }
    
    // Begin loop callback
    [self callLoopDidBegin];
    
    // Increment packet pointer
    self.currentPacketPointer = (self.currentPacketPointer + 1) % self.bankLengthInPackets;
    
    // Finish processing
    memcpy(outputBuffer, output, self.samplingSettings.packetByteSize);
    
    // Save recorded
    if (self.currentPacketPointer == self.bankLengthInPackets - 1) {
        [self copyRecordToBank];
    }
    
    // Apply configuration
    if (self.configuration) {
        self.configuration();
        self.configuration = nil;
        [self callLoopDidBegin];
    }
}

- (void)callLoopDidBegin {
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.currentPacketPointer == 0) {
            if (self.loopDidBegin) {
                self.loopDidBegin(wSelf);
            }
        }
    });
}

@end
