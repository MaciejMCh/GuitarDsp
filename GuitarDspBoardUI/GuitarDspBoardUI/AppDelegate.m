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
#import <GuitarDsp/GuitarDsp.h>
#import "BoardViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) Processor *processor;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    struct SamplingSettings samplingSettings = [AudioInterface sharedInterface].samplingSettings;
    self.processor = [[Processor alloc] initWithSamplingSettings:samplingSettings tempo:120];
    [[AudioInterface sharedInterface] useProcessor:self.processor];
    
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
    
    [NSApplication sharedApplication].windows.firstObject.contentViewController = boardViewController;
}

@end
