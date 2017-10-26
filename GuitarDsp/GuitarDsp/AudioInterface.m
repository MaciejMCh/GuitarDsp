//
//  AudioInterface.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "AudioInterface.h"

#if TARGET_OS_OSX
@import EZAudio;
#endif

#if TARGET_OS_IOS
@import Novocaine;
#endif

@interface AudioInterface ()

@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, strong) Processor *processor;

@end

@implementation AudioInterface

+ (AudioInterface *)sharedInterface {
    static AudioInterface *interface;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        interface = [[AudioInterface alloc] init];
    });
    return interface;
}

- (instancetype)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)useProcessor:(Processor *)processor {
    self.processor = processor;
}

#if TARGET_OS_OSX
- (void)setup {
    struct SamplingSettings samplingSettings;
    samplingSettings.frequency = [EZMicrophone sharedMicrophone].audioStreamBasicDescription.mSampleRate;
    samplingSettings.framesPerPacket = [EZMicrophone sharedMicrophone].framesPerPacket;
    samplingSettings.packetByteSize = sizeof(float) * samplingSettings.framesPerPacket;
    self.samplingSettings = samplingSettings;
    
    
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
    NSLog(@"Using input device: %@", [[EZMicrophone sharedMicrophone] device]);
    
    [[EZMicrophone sharedMicrophone] setOutput:[EZOutput sharedOutput]];
    
    __weak typeof(self) wSelf = self;
    [[EZMicrophone sharedMicrophone] setDsp:^(float *buffer, int size) {
        if (wSelf.processor) {
            [wSelf.processor processBuffer:buffer];
            memcpy(buffer, wSelf.processor.outputBuffer, wSelf.samplingSettings.packetByteSize);
        }
    }];
    
    [[EZOutput sharedOutput] startPlayback];
}
#endif

#if TARGET_OS_IOS
- (void)setup {
    struct SamplingSettings samplingSettings;
    samplingSettings.frequency = [Novocaine audioManager].samplingRate;
    samplingSettings.framesPerPacket = 1024;
    samplingSettings.packetByteSize = sizeof(float) * samplingSettings.framesPerPacket;
    self.samplingSettings = samplingSettings;
    
    __weak typeof(self) wSelf = self;
    [[Novocaine audioManager] setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
         if (wSelf.processor) {
             [wSelf.processor processBuffer:data];
             for (int i = 0; i < numFrames; i++) {
                 float sample = wSelf.processor.outputBuffer[i];
                 data[i * 2] = sample;
                 data[(i * 2) + 1] = sample;
             }
         }
     }];
    [[Novocaine audioManager] play];
}
#endif

@end
