//
//  Processor.m
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import "Processor.h"
#import "Sample.h"
#import "Effect.h"
#import <EZAudio/EZAudio.h>

@interface Processor ()

@end

@implementation Processor

#pragma mark - 
#pragma mark - Init

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo {
    self = [super init];
    self.samplingSettings = samplingSettings;
    _tempo = tempo;
    [self setupBuffers];
//    [self setupMetronome];
    return self;
}

#pragma mark -
#pragma mark - Setup


- (void)setupMetronome {
    self.metronomeEffect = [[MetronomeEffect alloc] initWithSamplingSettings:self.samplingSettings tempo:self.tempo];
}

- (void)setupBuffers {
    free(self.outputBuffer);
    self.outputBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        self.outputBuffer[i] = 0;
    }
}

#pragma mark -
#pragma mark - Interface

- (void)processBuffer:(float *)buffer {
//    memcpy(self.outputBuffer, buffer, self.samplingSettings.packetByteSize);
    
    struct Sample inputSample;
    inputSample.amp = malloc(self.samplingSettings.packetByteSize);
    memcpy(inputSample.amp, buffer, self.samplingSettings.packetByteSize);
    
    for (id<Effect> effect in self.activeBoard.effects) {
        [effect processSample:inputSample intoBuffer:self.outputBuffer];
        memcpy(inputSample.amp, self.outputBuffer, self.samplingSettings.packetByteSize);
    }
    
    free(inputSample.amp);
}

#pragma mark -
#pragma mark - Accessors

- (void)setTempo:(float)tempo {
    _tempo = tempo;
    for (id effect in self.activeBoard.effects) {
        if ([effect conformsToProtocol:@protocol(TempoUser)]) {
            [((id<TempoUser>)effect) updateTempo:self.tempo];
        }
    }
}

@end
