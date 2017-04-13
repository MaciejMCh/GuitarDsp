//
//  DelayEffect.m
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import "DelayEffect.h"
#import "Sample.h"
#import "TimingCalc.h"

@interface DelayEffect ()

@property (nonatomic, assign, readwrite) int echoesCount;
@property (nonatomic, assign, readwrite) struct SamplingSettings samplingSettings;
@property (nonatomic, assign, readwrite) struct Timing timing;

@property (nonatomic, assign) int delaySampleTime;
@property (nonatomic, assign) float **packetsRingBuffer;
@property (nonatomic, assign) int ringBufferSize;

@property (nonatomic, copy) void (^configuration)(void);

@end

@implementation DelayEffect

- (instancetype)initWithFadingFunctionA:(float)fadingFunctionA
                        fadingFunctionB:(float)fadingFunctionB
                            echoesCount:(int)echoesCount
                       samplingSettings:(struct SamplingSettings)samplingSettings
                                 timing:(struct Timing)timing {
    self = [super init];
    
    self.fadingFunctionA = fadingFunctionA;
    self.fadingFunctionB = fadingFunctionB;
    self.echoesCount = echoesCount;
    self.samplingSettings = samplingSettings;
    self.timing = timing;
    [self calculateTiming];
    [self setupBuffers];
    
    return self;
}

- (void)calculateTiming {
    self.delaySampleTime = [TimingCalc sampleTime:self.timing settings:self.samplingSettings];
    self.ringBufferSize = self.delaySampleTime * (self.echoesCount + 1);
}

- (void)setupBuffers {
    self.packetsRingBuffer = malloc(sizeof(float *) * self.ringBufferSize);
    for (int i = 0; i < self.ringBufferSize; i++) {
        self.packetsRingBuffer[i] = malloc(self.samplingSettings.packetByteSize);
        for (int j = 0; j < self.samplingSettings.framesPerPacket; j++) {
            self.packetsRingBuffer[i][j] = 0;
        }
    }
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = self.ringBufferSize - 1; i >= 1; i--) {
        memcpy(self.packetsRingBuffer[i], self.packetsRingBuffer[i - 1], self.samplingSettings.packetByteSize);
    }
    memcpy(self.packetsRingBuffer[0], inputSample.amp, self.samplingSettings.packetByteSize);
    
    float *finalBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        finalBuffer[i] = self.packetsRingBuffer[0][i];
        float fadeFactor = self.fadingFunctionA;
        for (int j = 1; j < (self.echoesCount + 1); j++) {
            finalBuffer[i] += self.packetsRingBuffer[j * self.delaySampleTime][i] * fadeFactor;
            fadeFactor *= self.fadingFunctionB;
        }
    }
    
    memcpy(outputBuffer, finalBuffer, self.samplingSettings.packetByteSize);
    free(finalBuffer);
    
    if (self.configuration) {
        self.configuration();
        self.configuration = nil;
    }
}

- (void)updateEchoesCount:(int)echoesCount {
    __weak typeof(self) wSelf = self;
    [self updateConfiguration:^{
        wSelf.echoesCount = echoesCount;
    }];
}

- (void)updateTact:(TactPart)tactPart {
    struct Timing timing;
    timing.tactPart = tactPart;
    timing.tempo = self.timing.tempo;
    
    __weak typeof(self) wSelf = self;
    [self updateConfiguration:^{
        wSelf.timing = timing;
    }];
}

- (void)updateTempo:(float)tempo {
    struct Timing timing;
    timing.tactPart = self.timing.tactPart;
    timing.tempo = tempo;
    
    __weak typeof(self) wSelf = self;
    [self updateConfiguration:^{
        wSelf.timing = timing;
    }];
}

- (void)updateConfiguration:(void (^)(void))setup {
    __weak typeof(self) wSelf = self;
    void (^currentConfiguration)(void) = self.configuration;
    [self setConfiguration:^{
        if (currentConfiguration) {
            currentConfiguration();
        }
        [wSelf freeBuffers];
        setup();
        [wSelf calculateTiming];
        [wSelf setupBuffers];
    }];
}

- (void)freeBuffers {
    for (int i = 0; i < self.ringBufferSize; i++) {
        free(self.packetsRingBuffer[i]);
    }
    free(self.packetsRingBuffer);
}

@end
