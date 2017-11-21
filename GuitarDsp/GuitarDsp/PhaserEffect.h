//
//  PhaserEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"

@interface PhaserEffect : NSObject

@property (nonatomic, assign, readonly) float rangeFmin;
@property (nonatomic, assign, readonly) float rangeFmax;
@property (nonatomic, assign, readonly) float rate;
@property (nonatomic, assign, readonly) float feedback;
@property (nonatomic, assign, readonly) float depth;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;
- (float)update:(float)inSamp;
- (void)updateRangeFmin:(float)fMin fMax:(float)fMax; // Hz
- (void)updateRate:(float)rate; // cps
- (void)updateFeedback:(float)fb; // 0 -> <1.
- (void)updateDepth:(float)depth; // 0 -> 1.

@end

@interface AllPassDelay : NSObject

- (void)delay:(float)delay;
- (float)update:(float)inSamp;

@end
