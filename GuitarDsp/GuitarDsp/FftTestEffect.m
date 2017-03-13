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
    int frameSize;
    int fftSize;
    float *windowBuffer;
}

@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation FftTestEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    [self setupFft];
    return self;
}

- (void)setupFft {
    frameSize = self.samplingSettings.framesPerPacket;
    fftSize = frameSize * 2;
    
    windowBuffer = malloc(sizeof(float) * frameSize);
    vDSP_hann_window(windowBuffer, frameSize, 0);
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
    float *windowedFrameBuffer = malloc(sizeof(float) * frameSize);
    for (int i = 0; i < frameSize; i++) {
        windowedFrameBuffer[i] = inputSample.amp[i] * windowBuffer[i];
    }
    
    float *shiftedFrameBuffer = malloc(sizeof(float) * fftSize);
    bzero(shiftedFrameBuffer, sizeof(float) * fftSize);
    memcpy(shiftedFrameBuffer + ((fftSize - frameSize) / 2), windowedFrameBuffer, sizeof(float) * frameSize);
    
    
    memcpy(outputBuffer, windowedFrameBuffer, self.samplingSettings.packetByteSize);
    
    NSLog(@"");
}

@end
