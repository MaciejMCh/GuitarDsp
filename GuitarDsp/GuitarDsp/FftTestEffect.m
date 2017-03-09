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
    
    int bufferSize = self.samplingSettings.framesPerPacket;
    int numFrames = self.samplingSettings.framesPerPacket;
    float ln = log2f(numFrames);
    
    //vDSP autocorrelation
    
    //convert real input to even-odd
    vDSP_ctoz((COMPLEX*)inputSample.amp, 2, &A, 1, numFrames/2);
    memset(inputSample.amp, 0, self.samplingSettings.packetByteSize);
    //fft
    vDSP_fft_zrip(self.fftSetup, &A, 1, ln, FFT_FORWARD);
    
    // Absolute square (equivalent to mag^2)
    vDSP_zvmags(&A, 1, A.realp, 1, numFrames/2);
    bzero(A.imagp, (numFrames/2) * sizeof(float));
    
    // Inverse FFT
    vDSP_fft_zrip(self.fftSetup, &A, 1, ln, FFT_INVERSE);
    
    //convert complex split to real
    vDSP_ztoc(&A, 1, (COMPLEX*)self.displayData, 2, numFrames/2);
    
    memcpy(outputBuffer, self.displayData, self.samplingSettings.packetByteSize);
    
    // Normalize
    float scale = 1.f/self.displayData[0];
    vDSP_vsmul(self. displayData, 1, &scale, self.displayData, 1, numFrames);
    
    // Naive peak-pick: find the first local maximum
    int peakIndex = 0;
    for (size_t ii=1; ii < numFrames-1; ++ii) {
        if ((self.displayData[ii] > self.displayData[ii-1]) && (self.displayData[ii] > self.displayData[ii+1])) {
            peakIndex = ii;
            break;
        }
    }
    
    
    // Calculate frequency
//    float frequency = sampleRate / peakIndex + quadInterpolate(&self.displayData[peakIndex-1]);
//    
//    bufferSize = numFrames;
//    
//    for (int ii=0; ii<ioData->mNumberBuffers; ++ii) {
//        bzero(ioData->mBuffers[ii].mData, ioData->mBuffers[ii].mDataByteSize);
//    }
    
}

@end
