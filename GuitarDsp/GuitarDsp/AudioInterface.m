//
//  AudioInterface.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "AudioInterface.h"
@import EZAudio;

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

- (void)setup {
    [self setupSamplingSettings];
    [self setupEzAudio];
}

- (void)setupSamplingSettings {
    struct SamplingSettings samplingSettings;
    samplingSettings.frequency = [EZMicrophone sharedMicrophone].audioStreamBasicDescription.mSampleRate;
    samplingSettings.framesPerPacket = [EZMicrophone sharedMicrophone].framesPerPacket;
    samplingSettings.packetByteSize = sizeof(float) * samplingSettings.framesPerPacket;
    self.samplingSettings = samplingSettings;
}

- (void)setupEzAudio {
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

- (void)useProcessor:(Processor *)processor {
    self.processor = processor;
}

@end
