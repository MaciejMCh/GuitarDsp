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
#import "Revmodel.h"

@interface ReverbEffect ()

@property (nonatomic, assign, readwrite) int echoesCount;
@property (nonatomic, assign, readwrite) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) int ampsBufferLengthInPackets;
@property (nonatomic, assign) float * ampsBuffer;
@property (nonatomic, assign) unsigned long int packetsTime;
@property (nonatomic, strong) NSMutableString *stringxD;
@property (nonatomic, assign) float *b;
@property (nonatomic, assign) float *bb;
@property (nonatomic, assign) float *bbb;
@property (nonatomic, strong) Revmodel *rev;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation ReverbEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    
    self.samplingSettings = samplingSettings;
    [self calculateTiming];
    [self setupBuffers];
    self.stringxD = [NSMutableString new];
    
    self.b = malloc(sizeof(float) * 10000);
    bzero(self.b, sizeof(float) * 10000);
    self.bb = malloc(sizeof(float) * 10000);
    bzero(self.bb, sizeof(float) * 10000);
    self.bbb = malloc(sizeof(float) * 10000);
    bzero(self.bbb, sizeof(float) * 10000);
    
    self.rev = [Revmodel new];
    
    self.data = [[NSMutableData alloc] init];
    
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
    //    memcpy(self.ampsBuffer,
    //           self.ampsBuffer + self.samplingSettings.framesPerPacket,
    //           self.samplingSettings.packetByteSize * (self.ampsBufferLengthInPackets - 1));
    //
    //    memcpy(self.ampsBuffer + self.samplingSettings.framesPerPacket * (self.ampsBufferLengthInPackets - 2), inputSample.amp, self.samplingSettings.packetByteSize);
    //
    //
    //    memcpy(outputBuffer, self.ampsBuffer + 100, self.samplingSettings.packetByteSize);
    //
    //
    //
    //
    //    int samplesCount = 1000000;
    //
    //    float *inl = (float *)malloc(sizeof(float *) * samplesCount);
    //    float *inr = (float *)malloc(sizeof(float *) * samplesCount);
    //    float *outl = (float *)malloc(sizeof(float *) * samplesCount);
    //    float *outr = (float *)malloc(sizeof(float *) * samplesCount);
    //
    //    bzero(inl, sizeof(float *) * samplesCount);
    //    bzero(inr, sizeof(float *) * samplesCount);
    //    for (int i = 0; i < 100000; i ++) {
    //        inl[i] = sin(i * 0.01);
    //        //        inr[i] = sin(i * 0.01);
    //    }
    
    [self.rev processmix:inputSample.amp
                  inputR:self.bb
                 outputL:self.b
                 outputR:self.bbb
              numsamples:self.samplingSettings.framesPerPacket
                    skip:1];
    
    
    memcpy(outputBuffer, self.b, self.samplingSettings.packetByteSize);
    
    //    NSMutableString *xd = [NSMutableString new];
//        for (int i = 0; i < samplesCount; i++) {
    //        [xd appendString:[NSString stringWithFormat:@"%f", outl[i]]];
    //    }
    [self.data appendBytes:self.b length:self.samplingSettings.packetByteSize];
//    NSData *d = [[NSData alloc] initWithBytes:self.b length:self.samplingSettings.packetByteSize];
//    [d writeToFile:@"/Users/maciejchmielewski/Desktop/xd.raw" atomically:YES];
    
    
}


- (void)freeBuffers {
    free(self.ampsBuffer);
}

@end
