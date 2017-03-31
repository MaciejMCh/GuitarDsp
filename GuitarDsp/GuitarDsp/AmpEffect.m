//
//  AmpEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 31.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "AmpEffect.h"

@interface AmpEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation AmpEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.gain = 1.0;
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = inputSample.amp[i] * self.gain;
    }
}

@end
