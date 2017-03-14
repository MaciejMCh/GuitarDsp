//
//  FftTestEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 09.03.2017.
//
//

#import "FftTestEffect.h"
#import "PhaseVocoder.h"

@interface FftTestEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, strong) PhaseVocoder *phaseVocoder;

@end

@implementation FftTestEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.phaseVocoder = [PhaseVocoder new];
    return self;
}


- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    [self.phaseVocoder smbPitchShift:0.5
                   numSampsToProcess:self.samplingSettings.framesPerPacket
                        fftFrameSize:1024
                               osamp:32
                          sampleRate:self.samplingSettings.framesPerPacket
                              indata:inputSample.amp
                             outdata:outputBuffer];
}

@end
