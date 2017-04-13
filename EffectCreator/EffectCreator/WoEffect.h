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

@interface WoEffect : NSObject <Effect>

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
