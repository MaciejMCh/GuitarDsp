//
//  DistortionEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 17.05.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "DistortionEffect.h"
#import <Accelerate/Accelerate.h>
#import "mathUtilities.h"

@interface DistortionEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation DistortionEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.treshold = 0.01;
    self.level = 2;
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = [self processFrame:inputSample.amp[i]];
    }
}

- (float)processFrame:(float)input {
    input = input / self.treshold;
    input = [self shapingFunction:input];
    return input * self.treshold * self.level;
}

- (float)shapingFunction:(float)input {
    return [self smoothShapingFunction:input];
}

- (float)smoothShapingFunction:(float)input {
    return input / (1 + ABS(input));
}

- (float)sharpShapingFunction:(float)input {
    if (input > 0) {
        return MIN(input, 1);
    } else {
        return MAX(-1, input);
    }
}

@end
