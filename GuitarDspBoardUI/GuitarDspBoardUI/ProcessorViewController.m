//
//  ProcessorViewController.m
//  PassThrough
//
//  Created by Maciej Chmielewski on 08.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import "ProcessorViewController.h"
#import "Processor.h"
#import "DelayViewController.h"

@interface ProcessorViewController ()

@property (nonatomic, strong) Processor *processor;

@property (nonatomic, weak) IBOutlet NSTextField *tempoTextField;

@end

@implementation ProcessorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
}

- (IBAction)tempoChanged:(NSTextField *)textField {
    self.processor.tempo = [textField.stringValue floatValue];
    [self updateViews];
}

- (void)updateViews {
    self.tempoTextField.stringValue = [NSString stringWithFormat:@"%.1f", self.processor.tempo];
}

@end
