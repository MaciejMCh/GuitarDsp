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

// Temporary
#import "FftTestEffect.h"

@interface Processor ()

@property (nonatomic, strong) NSMutableArray *effects;

@end

@implementation Processor

#pragma mark - 
#pragma mark - Init

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo {
    self = [super init];
    self.samplingSettings = samplingSettings;
    _tempo = tempo;
    [self setupBuffers];
    [self setupDelay];
    [self setupMetronome];
    [self setupEffects];
    return self;
}

+ (Processor *)shared {
    static Processor *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct SamplingSettings samplingSettings;
        samplingSettings.frequency = [EZMicrophone sharedMicrophone].audioStreamBasicDescription.mSampleRate;
        samplingSettings.framesPerPacket = [EZMicrophone sharedMicrophone].framesPerPacket;
        samplingSettings.packetByteSize = sizeof(float) * samplingSettings.framesPerPacket;
        _shared = [[Processor alloc] initWithSamplingSettings:samplingSettings tempo:135];
    });
    return _shared;
}


#pragma mark -
#pragma mark - Setup

- (void)setupEffects {
    self.effects = [NSMutableArray new];
//    [self.effects addObject:self.delayEffect];
//    [self.effects addObject:self.metronomeEffect];
    [self.effects addObject:[[FftTestEffect alloc] initWithSamplingSettings:self.samplingSettings]];
}

- (void)setupDelay {
    struct Timing delayTiming;
    delayTiming.tactPart = Half;
    delayTiming.tempo = self.tempo;
    
    self.delayEffect = [[DelayEffect alloc] initWithFadingFunctionA:0.2
                                                    fadingFunctionB:0.2
                                                        echoesCount:2
                                                   samplingSettings:self.samplingSettings
                                                             timing:delayTiming];
}

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
    
    for (id<Effect> effect in self.effects) {
        [effect processSample:inputSample intoBuffer:self.outputBuffer];
    }
}

#pragma mark -
#pragma mark - Accessors

- (void)setTempo:(float)tempo {
    _tempo = tempo;
    for (id effect in self.effects) {
        if ([effect conformsToProtocol:@protocol(TempoUser)]) {
            [((id<TempoUser>)effect) updateTempo:self.tempo];
        }
    }
}

@end
