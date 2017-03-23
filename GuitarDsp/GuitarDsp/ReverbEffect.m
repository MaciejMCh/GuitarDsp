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
@property (nonatomic, assign) unsigned long int packetsTime;
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
    float *inverted = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        memcpy(inverted + i, inputSample.amp + (self.samplingSettings.framesPerPacket - i - 1), sizeof(float));
    }
    memcpy(self.ampsBuffer + self.samplingSettings.framesPerPacket,
           self.ampsBuffer,
           self.samplingSettings.packetByteSize * (self.ampsBufferLengthInPackets - 1));
    
    memcpy(self.ampsBuffer, inverted, self.samplingSettings.packetByteSize);
    
    float *invertedDelayed = malloc(self.samplingSettings.packetByteSize);
    memcpy(invertedDelayed,
           self.ampsBuffer + 10000,
           self.samplingSettings.packetByteSize);
    
    
    float *reinverted = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        memcpy(reinverted + i, invertedDelayed + (self.samplingSettings.framesPerPacket - i - 1), sizeof(float));
    }
    
    memcpy(outputBuffer,
           reinverted,
           self.samplingSettings.packetByteSize);
    
    
    
    NSMutableString *log = [NSMutableString new];
    for (int i = 0; i < self.samplingSettings.framesPerPacket * 3; i++) {
        [log appendString:[NSString stringWithFormat:@"%f\n", self.ampsBuffer[i]]];
    }
}


- (void)freeBuffers {
    free(self.ampsBuffer);
}

@end
