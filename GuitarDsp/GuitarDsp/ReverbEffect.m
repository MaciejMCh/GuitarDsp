//
//  ReverbEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 18.03.2017.
//
//

#import "ReverbEffect.h"
#import "Sample.h"
#import "TimingCalc.h"

@interface ReverbEffect ()

@property (nonatomic, assign, readwrite) int echoesCount;
@property (nonatomic, assign, readwrite) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) int ampsBufferLengthInPackets;
@property (nonatomic, assign) float * ampsBuffer;

@property (nonatomic, strong) NSMutableString *stringxD;

@end

@implementation ReverbEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    
    self.samplingSettings = samplingSettings;
    [self calculateTiming];
    [self setupBuffers];
    self.stringxD = [NSMutableString new];
    return self;
}

- (void)calculateTiming {
    self.ampsBufferLengthInPackets = 200;
}

- (void)setupBuffers {
    self.ampsBuffer = malloc(sizeof(float) * self.ampsBufferLengthInPackets * self.samplingSettings.packetByteSize);
    bzero(self.ampsBuffer, sizeof(float) * self.ampsBufferLengthInPackets * self.samplingSettings.packetByteSize);
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    
//    float *inverseInput = malloc(self.samplingSettings.packetByteSize);
//    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
//        inverseInput[i] = inputSample.amp[self.samplingSettings.framesPerPacket - i - 1];
//    }
//    memcpy(inputSample.amp, inverseInput, self.samplingSettings.packetByteSize);
    
    
    [self.stringxD appendFormat: @"%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f ", inputSample.amp[0], inputSample.amp[10], inputSample.amp[20], inputSample.amp[30], inputSample.amp[40], inputSample.amp[50], inputSample.amp[60], inputSample.amp[70], inputSample.amp[80], inputSample.amp[90], inputSample.amp[100], inputSample.amp[110], inputSample.amp[120]];
    
//    float *reverseInputSample = malloc(self.samplingSettings.packetByteSize);
//    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
//        reverseInputSample[i] = inputSample.amp[self.samplingSettings.framesPerPacket - i - 1];
//    }
//    memcpy(self.ampsBuffer + self.samplingSettings.packetByteSize,
//           self.ampsBuffer,
//           self.samplingSettings.packetByteSize * (self.ampsBufferLengthInPackets - 1));
//    
//    memcpy(self.ampsBuffer, reverseInputSample, self.samplingSettings.packetByteSize);
//    
////    float *finalBuffer = malloc(self.samplingSettings.packetByteSize);
////    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
////        finalBuffer[i] = self.samplesRingBuffer[0].amp[i];
////        float fadeFactor = self.fadingFunctionA;
////        for (int j = 1; j < (self.echoesCount + 1); j++) {
////            finalBuffer[i] += self.samplesRingBuffer[j * self.delaySampleTime].amp[i] * fadeFactor;
////        }
////    }
//    
//    float *reverseOutputSample = malloc(self.samplingSettings.packetByteSize);
//    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
//        reverseOutputSample[i] = self.ampsBuffer[(self.samplingSettings.framesPerPacket * 4) + i - 0 + (0)];
//    }
//    
//    
//    memcpy(outputBuffer, reverseOutputSample, self.samplingSettings.packetByteSize);
    
//    memcpy(outputBuffer, inputSample.amp, self.samplingSettings.packetByteSize);
    
//    free(finalBuffer);
    
}


- (void)freeBuffers {
    free(self.ampsBuffer);
}

@end
