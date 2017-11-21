//
//  PhaserEffect+Effect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 21.11.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "PhaserEffect+Effect.h"

@interface PhaserEffect ()

@property (nonatomic, readonly) struct SamplingSettings samplingSettings;

@end

@implementation PhaserEffect (Effect)

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        outputBuffer[i] = [self update:inputSample.amp[i]];
    }
}

@end
