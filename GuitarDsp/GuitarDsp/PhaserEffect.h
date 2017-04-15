//
//  PhaserEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface PhaserEffect : NSObject <Effect>

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end

@interface AllPassDelay : NSObject

- (void)Delay:(float)delay;
- (float)Update:(float)inSamp;

@end
