//
//  FftTestEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 09.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface FftTestEffect : NSObject <Effect>

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
