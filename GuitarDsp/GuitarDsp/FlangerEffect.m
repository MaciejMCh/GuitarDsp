//
//  FlangerEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 14.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "FlangerEffect.h"
#import "mathUtilities.h"

@interface FlangerEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float *buffer;
@property (nonatomic, assign) int delayLengthInFrames;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) float offset;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float width;

@end

@implementation FlangerEffect

- (void)setFrequency:(float)frequency {
    _frequency = frequency;
    self.speed = frequency / self.samplingSettings.frequency;
}

- (void)setWidth:(float)width {
    _width = width;
    self.offset = self.width / 2.0;
}

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.delayLengthInFrames = 10000;
    self.buffer = malloc(sizeof(float) * self.delayLengthInFrames);
    bzero(self.buffer, sizeof(float) * self.delayLengthInFrames);
    self.depth = 1.0;
    self.frequency = 1.0;
    self.width = 320.0;
    return self;
}

- (float)processFrame:(float)frame {
    
    memcpy(self.buffer + 1, self.buffer, sizeof(float) * (self.delayLengthInFrames - 1));
    memcpy(self.buffer, &frame, sizeof(float));
    
    float sine = (sin((double)self.time * self.speed) + 1.0) * 0.5;
    float shift = self.width * sine;
    float topSamplePower = shift - floor(shift);
    float bottomSamplePower = 1.0 - topSamplePower;
    
    int bottomSampleIndex = (int)floor(shift);
    int topSampleIndex = bottomSampleIndex + 1;
    
    self.time += 1;
    
    float oscilating = (self.buffer[bottomSampleIndex] * bottomSamplePower) + (self.buffer[topSampleIndex] * topSamplePower);
    float dry = self.buffer[(int)self.offset];
    
    return dry + (oscilating * self.depth);
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = [self processFrame:inputSample.amp[i]];
    }
}

@end
