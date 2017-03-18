//
//  ReverbEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 18.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"

@interface ReverbEffect : NSObject <Effect>

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer;

@end
