//
//  FftTestEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 09.03.2017.
//
//

#import "FftTestEffect.h"
#import <Accelerate/Accelerate.h>

@interface FftTestEffect () {
    DSPSplitComplex A;
}

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
//@property (nonatomic, assign) DSPSplitComplex A;
@property (nonatomic, assign) FFTSetup fftSetup;
@property (nonatomic, assign) float *displayData;

@property (nonatomic, assign) int xD;

@end

@implementation FftTestEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    [self setupFft];
    return self;
}

- (void)setupFft {
    float sampleRate = self.samplingSettings.frequency;
    float bufferSize = self.samplingSettings.framesPerPacket;
    int peakIndex = 0;
    float frequency = 0.f;
    uint32_t maxFrames = self.samplingSettings.framesPerPacket;
    self.displayData = (float*)malloc(maxFrames*sizeof(float));
    bzero(self.displayData, maxFrames*sizeof(float));
    int log2n = log2f(maxFrames);
    int n = 1 << log2n;
    assert(n == maxFrames);
    float nOver2 = maxFrames/2;
    
//    DSPSplitComplex A;
    A.realp = (float*)malloc(nOver2 * sizeof(float));
    A.imagp = (float*)malloc(nOver2 * sizeof(float));
//    self.A = A;
    
    FFTSetup fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    self.fftSetup = fftSetup;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
    
//    if (_xD++ % 100 < 50) {
//        memcpy(outputBuffer, inputSample.amp, self.samplingSettings.packetByteSize);
//        return;
//    }
    
    float *real = inputSample.amp;
    float *imaginary = malloc(self.samplingSettings.packetByteSize);
    DSPSplitComplex splitComplex;
    splitComplex.realp = real;
    splitComplex.imagp = imaginary;
    
    vDSP_Length length = (long)floor(log2(self.samplingSettings.framesPerPacket));
    
    vDSP_fft_zip(self.fftSetup, &splitComplex, 1, length, FFT_FORWARD);
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        if (i < 50) {
            continue;
        }
        splitComplex.realp[i] = 0;
        splitComplex.imagp[i] = 0;
    }
    
    vDSP_fft_zip(self.fftSetup, &splitComplex, 1, length, FFT_INVERSE);
    
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        splitComplex.realp[i] /= (float)self.samplingSettings.framesPerPacket;
    }
    
    memcpy(outputBuffer, splitComplex.realp, self.samplingSettings.packetByteSize);
    
}

@end
