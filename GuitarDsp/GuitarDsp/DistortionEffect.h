//
//  DistortionEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 17.05.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface DistortionEffect : NSObject <Effect>

@property (nonatomic, assign) float treshold;
@property (nonatomic, assign) float level;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
