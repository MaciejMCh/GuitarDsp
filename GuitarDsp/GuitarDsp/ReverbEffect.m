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
@property (nonatomic, assign) float *b;
@property (nonatomic, assign) float *bb;
@property (nonatomic, assign) float *bbb;

@end

@implementation ReverbEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    
    self.samplingSettings = samplingSettings;
    [self calculateTiming];
    [self setupBuffers];
    
    self.b = malloc(sizeof(float) * 10000);
    bzero(self.b, sizeof(float) * 10000);
    self.bb = malloc(sizeof(float) * 10000);
    bzero(self.bb, sizeof(float) * 10000);
    self.bbb = malloc(sizeof(float) * 10000);
    bzero(self.bbb, sizeof(float) * 10000);
    
    self.rev = [Freeverb new];
    [self.rev setdamp:0.7];
    [self.rev setroomsize:0.3];
    [self.rev setdry:1.0];
    [self.rev setwet:0.5];
    
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
    
    bzero(self.b, self.samplingSettings.packetByteSize);
    bzero(self.bb, self.samplingSettings.packetByteSize);
    bzero(self.bbb, self.samplingSettings.packetByteSize);
    
    [self.rev processmix:inputSample.amp
                 outputL:self.b
              numsamples:self.samplingSettings.framesPerPacket
                    skip:1];
    
    
    memcpy(outputBuffer, self.b, self.samplingSettings.packetByteSize);
    
    
}


- (void)freeBuffers {
    free(self.ampsBuffer);
}

@end
