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
    
    float *signal;
    float *filter;
    float *result;
    float *overlap;
    float *output;
    
    int signalLength;
    int filterLength;
    int resultLength;
    int overlapLength;
}

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
//@property (nonatomic, assign) DSPSplitComplex A;
@property (nonatomic, assign) FFTSetup fftSetup;
@property (nonatomic, assign) float *displayData;

@property (nonatomic, assign) int xD;

@property (nonatomic, assign) int k;


@property (nonatomic, assign) float *circularBuffer;
//@property (nonatomic, assign) int circularBufferSize;

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
    self.k = 0;
    
    //    DSPSplitComplex A;
    A.realp = (float*)malloc(nOver2 * sizeof(float));
    A.imagp = (float*)malloc(nOver2 * sizeof(float));
    //    self.A = A;
    
    FFTSetup fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    self.fftSetup = fftSetup;
    
    
    
    
    
    
    signalLength = self.samplingSettings.framesPerPacket;
    filterLength = 3;
    overlapLength = filterLength - 1;
    resultLength = signalLength + overlapLength;
    
    signal = malloc(sizeof(float) * resultLength);
    bzero(signal, sizeof(float) * filterLength - 1);
    
    filter = malloc(sizeof(float) * filterLength);
    [self setupFilter];
    
    overlap = malloc(sizeof(float) * overlapLength);
    bzero(overlap, sizeof(float) * overlapLength);
    
    result = malloc(sizeof(float) * resultLength);
    output = malloc(sizeof(float) * signalLength);
}

- (void)setupFilter {
    bzero(filter, sizeof(float) * filterLength);
    filter[0] = 2;
    filter[1] = 1;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
    memcpy(signal + filterLength - 1, inputSample.amp, sizeof(float) * signalLength);
    vDSP_conv(signal, 1, filter + filterLength - 1, -1,
              result, 1, resultLength, filterLength);
    
    memcpy(output, result, sizeof(float) * signalLength);
    
    for (int i = 0; i < overlapLength; i++) {
        output[i] += overlap[i];
    }
    
    
    memcpy(overlap, result + resultLength - overlapLength, sizeof(float) * overlapLength);
    
    memcpy(outputBuffer, output, self.samplingSettings.packetByteSize);
    //    [self printResult];
}

- (void)printResult {
    NSMutableString *signalString = [@"S: " mutableCopy];
    for (int i = 0; i < resultLength; i++) {
        [signalString appendString:[NSString stringWithFormat:@"%.1f ", signal[i]]];
    }
    NSMutableString *filterString = [@"F: " mutableCopy];
    for (int i = 0; i < filterLength; i++) {
        [filterString appendString:[NSString stringWithFormat:@"%.1f ", filter[i]]];
    }
    NSMutableString *resultString = [@"R: " mutableCopy];
    for (int i = 0; i < resultLength; i++) {
        [resultString appendString:[NSString stringWithFormat:@"%.1f ", result[i]]];
    }
    NSMutableString *outputString = [@"O: " mutableCopy];
    for (int i = 0; i < signalLength; i++) {
        [outputString appendString:[NSString stringWithFormat:@"%.1f ", output[i]]];
    }
    NSMutableString *overlapString = [@"L: " mutableCopy];
    for (int i = 0; i < overlapLength; i++) {
        [overlapString appendString:[NSString stringWithFormat:@"%.1f ", overlap[i]]];
    }
    
    NSLog(@"\n%@\n%@\n%@\n%@\n%@\n", signalString, filterString, resultString, outputString, overlapString);
}

@end
