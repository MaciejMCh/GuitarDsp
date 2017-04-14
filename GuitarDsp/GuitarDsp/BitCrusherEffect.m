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
    self.samplingReduction = 8;
    self.wet = 1.0;
    self.dry = 0.0;
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float *wet = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        int index = roundTo(i, self.samplingReduction);
        wet[i] = roundTo(inputSample.amp[i], 0.03);
    }
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = wet[i] * self.wet + inputSample.amp[i] * self.dry;
    }
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        [self record:inputSample.amp[i] forSerie:@"input"];
        [self record:outputBuffer[i] forSerie:@"output"];
    }
}

- (void)record:(float)data forSerie:(NSString *)serie {
    if (!self.data) {
        self.data = [NSMutableDictionary new];
    }
    if (!self.data[serie]) {
        self.data[serie] = [NSMutableArray new];
    }
    [self.data[serie] addObject:[NSNumber numberWithFloat:data]];
}

@end
