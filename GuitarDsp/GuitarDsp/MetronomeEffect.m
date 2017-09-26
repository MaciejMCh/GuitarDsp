//
//  MetronomeEffect.m
//  PassThrough
//
//  Created by Maciej Chmielewski on 09.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import "MetronomeEffect.h"
@import EZAudio;

@interface MetronomeEffect () <EZAudioFileDelegate>

@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float tempo;
@property (nonatomic, assign) float *tickBuffer;

@end

@implementation MetronomeEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo {
    self = [super init];
    self.samplingSettings = samplingSettings;
    self.tempo = tempo;
    [self setupTickBuffer];
    return self;
}

- (void)setupTickBuffer {
    self.tickBuffer = malloc(self.samplingSettings.packetByteSize);
    for (int i = 0; i < 10000; i++) {
        self.tickBuffer[i] = 0;
    }
//    [self openFileWithFilePathURL:[[NSBundle mainBundle] URLForResource:@"simple-drum-beat" withExtension:@"wav"]];
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    memcpy(outputBuffer, self.tickBuffer, self.samplingSettings.packetByteSize);
}

- (void)updateTempo:(float)tempo {
    self.tempo = tempo;
}

- (void)     audioFile:(EZAudioFile *)audioFile
             readAudio:(float **)buffer
        withBufferSize:(UInt32)bufferSize
  withNumberOfChannels:(UInt32)numberOfChannels {
    NSLog(@"xD");
    
}

-(void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    //
    // Stop playback
    //
//    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
//    [self.player pause];
    
    //
    // Change back to a buffer plot, but mirror and fill the waveform
    //
//    self.audioPlot.plotType     = EZPlotTypeBuffer;
//    self.audioPlot.shouldFill   = YES;
//    self.audioPlot.shouldMirror = YES;
    
    //
    // Load the audio file and customize the UI
    //
//    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL delegate:self clientFormat:[EZMicrophone sharedMicrophone].audioStreamBasicDescription];
//    self.filePathLabel.stringValue = filePathURL.lastPathComponent;
//    self.positionSlider.minValue = 0.0f;
//    self.positionSlider.maxValue = (double)self.player.audioFile.totalFrames;
//    self.playButton.state = NSOffState;
//    self.plotSegmentControl.selectedSegment = self.audioPlot.plotType;
    
    //
    // Plot the whole waveform
    //
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithNumberOfPoints:1024 completion:^(float **waveformData, int length) {
         [weakSelf appendFileBuffer:waveformData[0] size:length];
     }];
}

- (void)appendFileBuffer:(float *)buffer size:(int)size {
    memcpy(self.tickBuffer, buffer, self.samplingSettings.packetByteSize);
    NSLog(@"xD");
}


@end
