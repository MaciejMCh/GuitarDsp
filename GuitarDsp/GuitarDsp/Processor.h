//
//  Processor.h
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"
#import "EffectNodesFactory.h"

// Temporary
#import "PhaseVocoderEffect.h"
#import "DelayEffect.h"
#import "MetronomeEffect.h"

@interface Processor : NSObject <EffectsFactory>

@property (nonatomic, strong) DelayEffect *delayEffect;
@property (nonatomic, strong) MetronomeEffect *metronomeEffect;
@property (nonatomic, strong) PhaseVocoderEffect *phaseVocoderEffect;

@property (nonatomic, assign) float *outputBuffer;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float tempo;

+ (Processor *)shared;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo;

- (void)processBuffer:(float *)buffer;

@end
