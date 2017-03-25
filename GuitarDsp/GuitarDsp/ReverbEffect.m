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
    memcpy(self.ampsBuffer,
           self.ampsBuffer + self.samplingSettings.framesPerPacket,
           self.samplingSettings.packetByteSize * (self.ampsBufferLengthInPackets - 1));
    
    memcpy(self.ampsBuffer + self.samplingSettings.framesPerPacket * (self.ampsBufferLengthInPackets - 2), inputSample.amp, self.samplingSettings.packetByteSize);
    
    
    memcpy(outputBuffer, self.ampsBuffer + 100, self.samplingSettings.packetByteSize);
}


- (void)freeBuffers {
    free(self.ampsBuffer);
}

@end
