//
//  MetronomeEffect.h
//  PassThrough
//
//  Created by Maciej Chmielewski on 09.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface MetronomeEffect : NSObject <Effect, TempoUser>

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo;

@end
