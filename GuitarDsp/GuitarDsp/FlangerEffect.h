//
//  FlangerEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 14.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface FlangerEffect : NSObject <Effect>

@property (nonatomic, assign) float frequency;
@property (nonatomic, assign) float depth;
@property (nonatomic, assign) float offset;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
