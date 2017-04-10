//
//  CompressorEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 10.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "CompressorEffect.h"
#import <Accelerate/Accelerate.h>
#import "mathUtilities.h"

@interface CompressorEffect () {
    float rmsLevel;
}

@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation CompressorEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    rmsLevel = 0;
    self.noiseLevel = 26;
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float rms = 0;
    vDSP_rmsqv(inputSample.amp, 1, &rms, self.samplingSettings.framesPerPacket);
    
    float feedback = 0.1;
    rmsLevel = rmsLevel * (1.0 - feedback) + (rms * feedback);
    
    float level = 0.005;
    float scale = dB(rmsLevel, level);
    NSLog(@"%f", scale);
    float gain = level / rmsLevel;
    
    if (scale > self.noiseLevel) {
        gain = 1.0;
    }
    vDSP_vsmul(inputSample.amp, 1, &gain, outputBuffer, 1, self.samplingSettings.framesPerPacket);
}

@end
