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
@property (nonatomic, assign) int tactsCount;
@property (nonatomic, assign) int bankLengthInPackets;
@property (nonatomic, assign) int currentPacketPointer;
@property (nonatomic, assign) int tactSizeInPackets;
@property (nonatomic, assign) int quaterTactSizeInPackets;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) int banksCount;
@property (nonatomic, assign) struct LooperBank *recordingBank;
@property (nonatomic, strong) RawAudioPlayer *tactAudioPlayer;
@property (nonatomic, strong) RawAudioPlayer *quaterTactAudioPlayer;

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
    self.tactAudioPlayer = [[RawAudioPlayer alloc] initWithSamplingSettings:self.samplingSettings file:@"snare"];
    self.quaterTactAudioPlayer = [[RawAudioPlayer alloc] initWithSamplingSettings:self.samplingSettings file:@"hihat"];
}

- (void)calculateTimings {
    struct Timing timing;
    timing.tactPart = Whole;
    timing.tempo = self.tempo;
    
    self.tactSizeInPackets = [TimingCalc sampleTime:timing settings:self.samplingSettings];
    self.quaterTactSizeInPackets = self.tactSizeInPackets / 4;
    self.bankLengthInPackets = self.tactSizeInPackets * self.tactsCount;
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

- (void)record:(struct LooperBank *)looperBank {
    looperBank->state = Record;
    self.recordingBank = looperBank;
}

- (void)finishRecording {
    if (self.recordingBank) {
        for (int i = 0; i < self.bankLengthInPackets; i++) {
            memcpy(self.recordingBank->packetsBuffer[i], recordingBuffer[i], self.samplingSettings.packetByteSize);
        }
        self.recordingBank->state = On;
        self.recordingBank = nil;
    }
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
    // Record
    if (self.recordingBank) {
        memcpy(recordingBuffer[self.currentPacketPointer], inputSample.amp, self.samplingSettings.packetByteSize);
    }
    
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
                output[i] += metronomeBuffer[i];
            }
        }
        if (self.quaterTactAudioPlayer.status == Playing) {
            float *metronomeBuffer = [self.quaterTactAudioPlayer next];
            for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
                output[i] += metronomeBuffer[i];
            }
        }
    }
    
    self.currentPacketPointer = (self.currentPacketPointer + 1) % self.bankLengthInPackets;
    memcpy(outputBuffer, output, self.samplingSettings.packetByteSize);
}

@end
