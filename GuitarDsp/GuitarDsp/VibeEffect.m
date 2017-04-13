//
//  WoEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 11.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "VibeEffect.h"
#import "mathUtilities.h"

@interface VibeEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float *buffer;
@property (nonatomic, assign) int delayLengthInFrames;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) float speed;

@end

@implementation VibeEffect

- (void)setFrequency:(float)frequency {
    _frequency = frequency;
    self.speed = frequency / self.samplingSettings.frequency;
}

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.delayLengthInFrames = 10000;
    self.buffer = malloc(sizeof(float) * self.delayLengthInFrames);
    bzero(self.buffer, sizeof(float) * self.delayLengthInFrames);
    self.frequency = 30;
    self.depth = 160.0;
    return self;
}

- (float)processFrame:(float)frame {
    memcpy(self.buffer + 1, self.buffer, sizeof(float) * (self.delayLengthInFrames - 1));
    memcpy(self.buffer, &frame, sizeof(float));
    
    float sine = (sin((double)self.time * self.speed) + 1.0) * 0.5;
    float shift = self.depth * sine;
    float topSamplePower = shift - floor(shift);
    float bottomSamplePower = 1.0 - topSamplePower;
    
    int bottomSampleIndex = (int)floor(shift);
    int topSampleIndex = bottomSampleIndex + 1;
    
    self.time += 1;
    
    float output = (self.buffer[bottomSampleIndex] * bottomSamplePower) + (self.buffer[topSampleIndex] * topSamplePower);
    
    return output;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = [self processFrame:inputSample.amp[i]];
    }
}

@end
