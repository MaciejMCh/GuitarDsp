//
//  WoEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 11.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "WoEffect.h"
#import "mathUtilities.h"

@interface WoEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float *buffer;
@property (nonatomic, assign) int bufferLengthInFrames;
@property (nonatomic, assign) int time;

@end

@implementation WoEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.bufferLengthInFrames = 4;
    self.buffer = malloc(self.samplingSettings.packetByteSize * self.bufferLengthInFrames);
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float speed = 0.15 * (1.0 / 128.0);
    float depth = 60.0;
    
    float *invertedInputSample = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        invertedInputSample[i] = inputSample.amp[self.samplingSettings.framesPerPacket - 1 - i];
    }
    
    memcpy(self.buffer + self.samplingSettings.framesPerPacket, self.buffer, self.samplingSettings.packetByteSize * (self.bufferLengthInFrames - 1));
    memcpy(self.buffer, invertedInputSample, self.samplingSettings.packetByteSize);
    float *invertedOutputBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        float sine = (sin((double)self.time * speed) + 1.0) * 0.5;
        float shift = depth * sine;
        
        float topSamplePower = shift - floor(shift);
        float bottomSamplePower = 1.0 - topSamplePower;
        
        int bottomSampleIndex = i + (int)floor(shift);
        int topSampleIndex = bottomSampleIndex + 1;
        
        invertedOutputBuffer[i] = (self.buffer[bottomSampleIndex] * bottomSamplePower) + (self.buffer[topSampleIndex] * topSamplePower);
        self.time += 1;
    }
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = invertedOutputBuffer[self.samplingSettings.framesPerPacket - i - 1];
    }
}

@end
