//
//  DelayEffect.h
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"
#import "Timing.h"
#import "Sample.h"
#import "Effect.h"

@interface DelayEffect : NSObject <Effect, TempoUser>

@property (nonatomic, assign) float fadingFunctionA;
@property (nonatomic, assign) float fadingFunctionB;
@property (nonatomic, assign, readonly) int echoesCount;

@property (nonatomic, assign, readonly) struct SamplingSettings samplingSettings;
@property (nonatomic, assign, readonly) struct Timing timing;

- (instancetype)initWithFadingFunctionA:(float)fadingFunctionA
                        fadingFunctionB:(float)fadingFunctionB
                            echoesCount:(int)echoesCount
                       samplingSettings:(struct SamplingSettings)samplingSettings
                                 timing:(struct Timing) timing;

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer;

- (void)updateEchoesCount:(int)echoesCount;
- (void)updateTact:(TactPart)tackPart;
- (void)updateTempo:(float)tempo;

@end
