//
//  FrequencyDomainProcessing.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 24.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"

@interface FrequencyDomainProcessing : NSObject

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings
                            fftFrameSize:(long)fftFrameSize
                                   osamp:(long)osamp;

- (void)processWithIndata:(float *)indata outdata:(float *)outdata processing:(void (^)(int fftLength,
                                                                                        float *analysisMagnitudes,
                                                                                        float *analysisFrequencies,
                                                                                        float *syntesisMagnitudes,
                                                                                        float *synthesisFrequencies))processing;

- (void)pitchShift:(float *)indata outdata:(float *)outdata shift:(float)shift;

@end
