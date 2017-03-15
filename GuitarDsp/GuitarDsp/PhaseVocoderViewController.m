//
//  PhaseVocoderViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 14.03.2017.
//
//

#import "PhaseVocoderViewController.h"

@implementation PhaseVocoderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
}

- (void)updateViews {
    self.shiftTextField.stringValue = [NSString stringWithFormat:@"%f", self.phaseVocoderEffect.shift];
    self.fftLengthTextField.stringValue = [NSString stringWithFormat:@"%d", self.phaseVocoderEffect.fftLength];
    self.overlapLengthTextField.stringValue = [NSString stringWithFormat:@"%d", self.phaseVocoderEffect.overlapLength];
}

- (IBAction)shiftTextFieldAction:(NSTextField *)sender {
    self.phaseVocoderEffect.shift = [sender.stringValue floatValue];
    [self updateViews];
}

- (IBAction)fftLengthTextFieldAction:(NSTextField *)sender {
    self.phaseVocoderEffect.fftLength = [sender.stringValue intValue];
    [self updateViews];
}

- (IBAction)overlapLengthTextFieldAction:(NSTextField *)sender {
    self.phaseVocoderEffect.overlapLength = [sender.stringValue intValue];
    [self updateViews];
}

@end
