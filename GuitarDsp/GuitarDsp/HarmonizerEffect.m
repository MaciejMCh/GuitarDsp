//
//  HarmonizerEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 17.03.2017.
//
//

#import "HarmonizerEffect.h"
#import "PhaseVocoder.h"

@interface HarmonizerEffect ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, strong) PhaseVocoder *phaseVocoder;

@end

@implementation HarmonizerEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.phaseVocoder = [PhaseVocoder new];
    self.shift = 0.5;
    self.volume = 1.0;
    self.fftLength = 1024;
    self.overlapLength = 32;
    return self;
}


- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float *shiftedBuffer = malloc(self.samplingSettings.packetByteSize);
    
    [self.phaseVocoder smbPitchShift:self.shift
                   numSampsToProcess:self.samplingSettings.framesPerPacket
                        fftFrameSize:self.fftLength
                               osamp:self.overlapLength
                          sampleRate:self.samplingSettings.framesPerPacket
                              indata:inputSample.amp
                             outdata:shiftedBuffer];
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i ++) {
        outputBuffer[i] = inputSample.amp[i] + (shiftedBuffer[i] * self.volume);
    }
}


@end
