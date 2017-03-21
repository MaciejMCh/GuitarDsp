//
//  LooperEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 20.03.2017.
//
//

#import "LooperEffect.h"

@interface LooperEffect () {
    float **recordingBuffer;
}

@property (nonatomic, assign) struct Timing;
@property (nonatomic, assign) int bankLengthInPackets;
@property (nonatomic, assign) int currentPacketPointer;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) int banksCount;
@property (nonatomic, assign) struct LooperBank *recordingBank;

@end

@implementation LooperEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings BanksCount:(int)banksCount {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.banksCount = banksCount;
    [self calculateTimings];
    [self setupBuffers];
    return self;
}

- (void)calculateTimings {
    self.bankLengthInPackets = 300;
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
    if (self.recordingBank) {
        memcpy(recordingBuffer[self.currentPacketPointer], inputSample.amp, self.samplingSettings.packetByteSize);
    }
    
    float *output = malloc(self.samplingSettings.packetByteSize);
    memcpy(output, inputSample.amp, self.samplingSettings.packetByteSize);
    
    for (int i = 0; i < self.banksCount; i++) {
        struct LooperBank looperBank = self.looperBanks[i];
        if (looperBank.state == On) {
            for (int j = 0; j < self.samplingSettings.framesPerPacket; j++) {
                output[j] += looperBank.packetsBuffer[self.currentPacketPointer][j];
            }
        }
    }
    
    self.currentPacketPointer = (self.currentPacketPointer + 1) % self.bankLengthInPackets;
    memcpy(outputBuffer, output, self.samplingSettings.packetByteSize);
}

@end
