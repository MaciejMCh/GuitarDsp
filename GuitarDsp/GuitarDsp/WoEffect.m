//
//  WoEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 11.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "WoEffect.h"

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
    float speed = 0.2;
    float depth = 60.0;
    
    float sine = (sin((double)self.time * speed) + 1.0) * 0.5;
    int shift = (int)(depth * sine);
    
    NSLog(@"%d", shift);
    
    self.time += 1;
    
    float *invertedInputSample = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        invertedInputSample[i] = inputSample.amp[self.samplingSettings.framesPerPacket - 1 - i];
    }
    
    memcpy(self.buffer + self.samplingSettings.framesPerPacket, self.buffer, self.samplingSettings.packetByteSize * (self.bufferLengthInFrames - 1));
    memcpy(self.buffer, invertedInputSample, self.samplingSettings.packetByteSize);
    float *reinvertedOutputBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        reinvertedOutputBuffer[i] = self.buffer[shift + self.samplingSettings.framesPerPacket - 1 - i];
    }
    
    memcpy(outputBuffer, reinvertedOutputBuffer, self.samplingSettings.packetByteSize);
    
}

@end
