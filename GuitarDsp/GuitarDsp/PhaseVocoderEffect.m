//
//  FftTestEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 09.03.2017.
//
//

#import "PhaseVocoderEffect.h"
//#import "PhaseVocoder.h"
#import "FrequencyDomainProcessing.h"

@interface PhaseVocoderEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, strong) FrequencyDomainProcessing *frequencyDomainProcessing;

@end

@implementation PhaseVocoderEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.shift = 0.5;
    
    __weak typeof(self) wSelf = self;
    self.frequencyDomainProcessing = [[FrequencyDomainProcessing alloc] initWithSamplingSettings:self.samplingSettings fftFrameSize:1024 osamp:32 processing:^(int fftLength, float *analysisMagnitudes, float *analysisFrequencies, float *syntesisMagnitudes, float *synthesisFrequencies) {
        for (int k = 0; k <= fftLength; k++) {
            int index = k * self.shift;
            if (index <= fftLength) {
                syntesisMagnitudes[index] += analysisMagnitudes[k];
                synthesisFrequencies[index] = analysisFrequencies[k] * wSelf.shift;
            }
        }
    }];
    
    return self;
}


- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    [self.frequencyDomainProcessing processWithIndata:inputSample.amp outdata:outputBuffer];
}

@end
