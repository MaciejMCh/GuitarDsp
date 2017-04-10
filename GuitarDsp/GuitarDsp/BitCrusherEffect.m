//
//  BitCrusherEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 10.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "BitCrusherEffect.h"
#import "SamplingSettings.h"
#import "mathUtilities.h"

@interface BitCrusherEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation BitCrusherEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.samplingReduction = 16;
    self.wet = 1.0;
    self.dry = 0.0;
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float *wet = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        int index = roundTo(i, self.samplingReduction);
        wet[i] = inputSample.amp[index];
    }
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = wet[i] * self.wet + inputSample.amp[i] * self.dry;
    }
}

@end
