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
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    float *input = malloc(sizeof(float) * 10);
    for (int i = 0; i < 10; i ++) {
        input[i] = i + 1;
    }
    
    
    
    const vDSP_Stride
    SignalStride = 1,
    FilterStride = 1,
    ResultStride = 1;
    
    vDSP_Length
    FilterLength = 3,
    SignalLength = 5,
    ResultLength = SignalLength + FilterLength - 1;
    
    
    float *Signal, *Filter, *Result;
    
    Signal = malloc(ResultLength * SignalStride * sizeof *Signal);
    Filter = malloc(FilterLength * FilterStride * sizeof *Filter);
    Result = malloc(ResultLength * ResultStride * sizeof *Result);
    
    bzero(Signal, SignalStride * sizeof *Signal);
    memcpy(&Signal[FilterLength - 1], input, sizeof(float) * SignalLength);
    
    for (int i = 0; i < FilterLength; i++) {
        Filter[i*FilterStride] = 0.0;
    }
    Filter[0*FilterStride] = 1.0;
    Filter[1*FilterStride] = 1.0;
    
    
//    [self convSignal:Signal signalLength:SignalLength filter:Filter filterLength:FilterLength output:Result];
    vDSP_conv(Signal, SignalStride, Filter + FilterLength - 1, -1,
              Result, ResultStride, ResultLength, FilterLength);
    
    
    NSMutableString *signalString = [@"S: " mutableCopy];
    for (int i = 0; i < ResultLength; i++) {
        [signalString appendString:[NSString stringWithFormat:@"%.1f ", Signal[i]]];
    }
    NSMutableString *filterString = [@"F: " mutableCopy];
    for (int i = 0; i < FilterLength; i++) {
        [filterString appendString:[NSString stringWithFormat:@"%.1f ", Filter[i]]];
    }
    NSMutableString *resultString = [@"R: " mutableCopy];
    for (int i = 0; i < ResultLength; i++) {
        [resultString appendString:[NSString stringWithFormat:@"%.1f ", Result[i]]];
    }
    
    NSLog(@"\n%@\n%@\n%@\n", signalString, filterString, resultString);
}

- (void)convSignal:(float *)signal signalLength:(int)signalLength
            filter:(float *)filter filterLength:(int)filterLength
            output:(float *)output {
    int resultLength = signalLength + filterLength - 1;
    
    bzero(output, sizeof(float) * resultLength);
    
    for (int i = 0; i < signalLength; i++) {
        for (int j = 0; j < filterLength; j++) {
            output[i + j] += signal[i] * filter[j];
        }
    }
    
}

@end

