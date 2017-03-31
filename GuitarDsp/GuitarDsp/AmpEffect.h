//
//  AmpEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 31.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface AmpEffect : NSObject <Effect>

@property (nonatomic, assign) float gain;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
