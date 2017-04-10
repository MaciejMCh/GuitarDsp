//
//  BitCrusherEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 10.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"

@interface BitCrusherEffect : NSObject <Effect>

@property (nonatomic, assign) float samplingReduction;
@property (nonatomic, assign) float wet;
@property (nonatomic, assign) float dry;

- (instancetype _Nonnull)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
