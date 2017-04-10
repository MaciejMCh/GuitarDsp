//
//  CompressorEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 10.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface CompressorEffect : NSObject <Effect>

@property (nonatomic, assign) float noiseLevel;

- (instancetype _Nonnull)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
