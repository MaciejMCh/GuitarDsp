//
//  DelayViewController.m
//  PassThrough
//
//  Created by Maciej Chmielewski on 08.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import "DelayViewController.h"

@interface DelayViewController ()

@property (nonatomic, strong) IBOutlet NSTextField *echoesCountTextField;
@property (nonatomic, strong) IBOutlet NSTextField *tactPartTextField;
@property (nonatomic, strong) IBOutlet NSTextField *fadingFunctionATextField;
@property (nonatomic, strong) IBOutlet NSTextField *fadingFunctionBTextField;

@end

@implementation DelayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
}

- (IBAction)echoesCountTextFieldChanged:(NSTextField *)textField {
    [self.delayEffect updateEchoesCount:[textField.stringValue integerValue]];
}

- (IBAction)tactPartTextFieldChanged:(NSTextField *)textField {
    [self.delayEffect updateTact:[textField.stringValue integerValue]];
}

- (IBAction)fadingFunctionATextFieldChanged:(NSTextField *)textField {
    self.delayEffect.fadingFunctionA = [textField.stringValue floatValue];
}

- (IBAction)fadingFunctionBTextFieldChanged:(NSTextField *)textField {
    self.delayEffect.fadingFunctionB = [textField.stringValue floatValue];
}

- (void)updateViews {
    self.echoesCountTextField.stringValue = [NSString stringWithFormat:@"%d", self.delayEffect.echoesCount];
    self.tactPartTextField.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.delayEffect.timing.tactPart];
    self.fadingFunctionATextField.stringValue = [NSString stringWithFormat:@"%f", self.delayEffect.fadingFunctionA];
    self.fadingFunctionBTextField.stringValue = [NSString stringWithFormat:@"%f", self.delayEffect.fadingFunctionB];
}

@end
