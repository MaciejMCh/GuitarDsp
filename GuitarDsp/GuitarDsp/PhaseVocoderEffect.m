//
//  FftTestEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 09.03.2017.
//
//

#import "PhaseVocoderEffect.h"
#import "PhaseVocoder.h"

@interface PhaseVocoderEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, strong) PhaseVocoder *phaseVocoder;

@end

@implementation PhaseVocoderEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.phaseVocoder = [PhaseVocoder new];
    self.shift = 0.5;
    self.fftLength = 1024;
    self.overlapLength = 32;
    return self;
}


- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    [self.phaseVocoder smbPitchShift:self.shift
                   numSampsToProcess:self.samplingSettings.framesPerPacket
                        fftFrameSize:self.fftLength
                               osamp:self.overlapLength
                          sampleRate:self.samplingSettings.framesPerPacket
                              indata:inputSample.amp
                             outdata:outputBuffer];
}

@end
