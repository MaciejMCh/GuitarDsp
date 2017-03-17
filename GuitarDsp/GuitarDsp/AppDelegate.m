//
//  AppDelegate.m
//  PassThrough
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AppDelegate.h"
#import "Processor.h"
#import "SamplingSettings.h"
#import "TimeDomainSignalViewController.h"
#import "BoardViewController.h"
#import "Board.h"

@interface AppDelegate ()

@property (nonatomic, strong) Processor *processor;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation AppDelegate

//------------------------------------------------------------------------------
#pragma mark - Customize the Audio Plot
//------------------------------------------------------------------------------

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    struct SamplingSettings samplingSettings;
    samplingSettings.frequency = [EZMicrophone sharedMicrophone].audioStreamBasicDescription.mSampleRate;
    samplingSettings.framesPerPacket = [EZMicrophone sharedMicrophone].framesPerPacket;
    samplingSettings.packetByteSize = sizeof(float) * samplingSettings.framesPerPacket;
    self.samplingSettings = samplingSettings;
    
    self.processor = [Processor shared];
    
    [EZMicrophone sharedMicrophone].delegate = self;
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
    
    //
    // Print out the input device being used
    //
    NSLog(@"Using input device: %@", [[EZMicrophone sharedMicrophone] device]);
    
    //
    // Use the microphone as the EZOutputDataSource
    //
    [[EZMicrophone sharedMicrophone] setOutput:[EZOutput sharedOutput]];
    
    [[EZMicrophone sharedMicrophone] setDsp:^(float *buffer, int size) {
        [self.processor processBuffer:buffer];
        memcpy(buffer, self.processor.outputBuffer, self.samplingSettings.packetByteSize);
    }];
    
    /**
     Start the output
     */
    [[EZOutput sharedOutput] startPlayback];
    
    Board *board = [Board new];
    self.processor.activeBoard = board;
    
    BoardViewController *boardViewController = [BoardViewController withEffectNodesFactory:[[EffectNodesFactory alloc] initWithEffectsFactory:self.processor]];
    __weak Board *wBoard = board;
    [boardViewController setUpdateEffects:^(NSArray<id<Effect>> *effects) {
        wBoard.effects = effects;
    }];
    [NSApplication sharedApplication].windows.firstObject.contentViewController = boardViewController;
    
    CGAssociateMouseAndMouseCursorPosition(false);
    CGDisplayHideCursor(kCGNullDirectDisplay);
}

//------------------------------------------------------------------------------
#pragma mark - Actions
//------------------------------------------------------------------------------

- (void)changePlotType:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegment];
    switch(selectedSegment)
    {
        case 0:
            [self drawBufferPlot];
            break;
        case 1:
            [self drawRollingPlot];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------

- (void)toggleMicrophone:(id)sender
{
    switch([sender state])
    {
        case NSOffState:
            [[EZMicrophone sharedMicrophone] stopFetchingAudio];
            break;
        case NSOnState:
            [[EZMicrophone sharedMicrophone] startFetchingAudio];
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Action Extensions
//------------------------------------------------------------------------------

//
// Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input example)
//
- (void)drawBufferPlot
{
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldMirror = NO;
    self.audioPlot.shouldFill = NO;
}

//------------------------------------------------------------------------------

//
// Give the classic mirrored, rolling waveform look
//
- (void)drawRollingPlot
{
    self.audioPlot.plotType = EZPlotTypeRolling;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
}

//------------------------------------------------------------------------------
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedPlayingState:(BOOL)isPlaying
{
    NSString *title = isPlaying ? @"Microphone On" : @"Microphone Off";
    [self setTitle:title forButton:self.microphoneSwitch];
}

//------------------------------------------------------------------------------

-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.audioPlot updateBuffer:buffer[0]
                          withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

- (void)setTitle:(NSString *)title forButton:(NSButton *)button
{
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [NSColor whiteColor] };
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:attributes];
    button.attributedTitle = attributedTitle;
    button.attributedAlternateTitle = attributedTitle;
}

@end
