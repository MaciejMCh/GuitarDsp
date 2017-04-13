//
//  WoEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 11.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface VibeEffect : NSObject <Effect>

@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) float depth;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
