//
//  RawAudioReader.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 21.03.2017.
//
//

#import "RawAudioPlayer.h"

@interface RawAudioPlayer ()

@property (nonatomic, assign, readwrite) RawAudioPlayerStatus status;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) struct RawAudio rawAudio;
@property (nonatomic, assign) int rawAudioBufferPointer;

@end

@implementation RawAudioPlayer

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings data:(NSData *)data {
    self = [super init];
    
    self.samplingSettings = samplingSettings;
    
    int dataLength = data.length / sizeof(float);
    int zeroPaddingCount = self.samplingSettings.framesPerPacket - (dataLength % self.samplingSettings.framesPerPacket);
    struct RawAudio rawAudio;
    rawAudio.buffer = malloc(sizeof(float) * (dataLength + zeroPaddingCount));
    bzero(rawAudio.buffer, sizeof(float) * (dataLength + zeroPaddingCount));
    memcpy(rawAudio.buffer, data.bytes, data.length);
    rawAudio.length = dataLength;
    self.rawAudio = rawAudio;
    
    return self;
}

- (void)play {
    self.rawAudioBufferPointer = 0;
    self.status = Playing;
}

- (float *)next {
    if (self.status != Playing) {
        return nil;
    }
    
    float *result = self.rawAudio.buffer + self.rawAudioBufferPointer;
    self.rawAudioBufferPointer += self.samplingSettings.framesPerPacket;
    if (self.rawAudioBufferPointer >= self.rawAudio.length) {
        self.status = Ready;
    }
    return result;
}

@end
