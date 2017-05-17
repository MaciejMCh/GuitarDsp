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

@interface PhaseVocoderEffect : NSObject <Effect>

@property (nonatomic, assign) float shift;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

@end
