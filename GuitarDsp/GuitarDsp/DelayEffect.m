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
@property (nonatomic, assign) struct Sample *samplesRingBuffer;
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
    self.samplesRingBuffer = malloc(sizeof(struct Sample) * self.ringBufferSize);
    for (int i = 0; i < self.ringBufferSize; i++) {
        struct Sample sample;
        sample.amp = malloc(self.samplingSettings.packetByteSize);
        for (int j = 0; j < self.samplingSettings.framesPerPacket; j++) {
            sample.amp[j] = 0;
        }
        self.samplesRingBuffer[i] = sample;
    }
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    free(self.samplesRingBuffer[self.ringBufferSize - 1].amp);
    memcpy(&self.samplesRingBuffer[1], &self.samplesRingBuffer[0], sizeof(struct Sample) * (self.ringBufferSize - 1));
    memcpy(self.samplesRingBuffer, &inputSample, sizeof(struct Sample));
    
    float *finalBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        finalBuffer[i] = self.samplesRingBuffer[0].amp[i];
        float fadeFactor = self.fadingFunctionA;
        for (int j = 1; j < (self.echoesCount + 1); j++) {
            finalBuffer[i] += self.samplesRingBuffer[j * self.delaySampleTime].amp[i] * fadeFactor;
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
    [self setConfiguration:^{
        [wSelf freeBuffers];
        wSelf.echoesCount = echoesCount;
        [wSelf calculateTiming];
        [wSelf setupBuffers];
    }];
}

- (void)updateTact:(TactPart)tactPart {
    struct Timing timing;
    timing.tactPart = tactPart;
    timing.tempo = self.timing.tempo;
    
    __weak typeof(self) wSelf = self;
    [self setConfiguration:^{
        [wSelf freeBuffers];
        wSelf.timing = timing;
        [wSelf calculateTiming];
        [wSelf setupBuffers];
    }];
}

- (void)updateTempo:(float)tempo {
    struct Timing timing;
    timing.tactPart = self.timing.tactPart;
    timing.tempo = tempo;
    
    __weak typeof(self) wSelf = self;
    [self setConfiguration:^{
        [wSelf freeBuffers];
        wSelf.timing = timing;
        [wSelf calculateTiming];
        [wSelf setupBuffers];
    }];
}

- (void)freeBuffers {
    for (int i = 0; i < self.ringBufferSize; i++) {
        free(self.samplesRingBuffer[i].amp);
    }
    free(self.samplesRingBuffer);
}

@end
