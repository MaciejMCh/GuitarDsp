//
//  LooperViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 20.03.2017.
//
//

#import "LooperViewController.h"

@implementation LooperViewController

+ (LooperViewController *)withLooperEffect:(LooperEffect *)looperEffect {
    LooperViewController *me = [[NSStoryboard storyboardWithName:@"Looper" bundle:nil] instantiateInitialController];
    me.looperEffect = looperEffect;
    return me;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    for (NSView *bankView in [self bankViews]) {
        bankView.wantsLayer = YES;
        bankView.layer.borderWidth = 5;
    }
    [self updateViews];
}

- (IBAction)toggleAction:(NSClickGestureRecognizer *)sender {
    [self toggleIndex:[self index: sender.view]];
    [self updateViews];
}

- (IBAction)recordAction:(NSClickGestureRecognizer *)sender {
    [self recordIndex:[self index: sender.view]];
    [self updateViews];
}

- (void)recordIndex:(int)index {
    if (self.looperEffect.looperBanks[index].state == Record) {
        [self.looperEffect finishRecording];
    } else {
        [self.looperEffect record:self.looperEffect.looperBanks + index];
    }
}

- (void)toggleIndex:(int)index {
    if (self.looperEffect.looperBanks[index].state == On) {
        self.looperEffect.looperBanks[index].state = Off;
    } else if (self.looperEffect.looperBanks[index].state == Off) {
        self.looperEffect.looperBanks[index].state = On;
    }
}

- (int)index:(NSView *)ofBankView {
    if (ofBankView == self.bankView1) {
        return 0;
    }
    if (ofBankView == self.bankView2) {
        return 1;
    }
    if (ofBankView == self.bankView3) {
        return 2;
    }
    if (ofBankView == self.bankView4) {
        return 3;
    }
    return -1;
}

- (NSArray *)bankViews {
    return @[self.bankView1, self.bankView2, self.bankView3, self.bankView4];
}

- (void)updateViews {
    for (int i = 0; i < 4; i++) {
        struct LooperBank looperBank = self.looperEffect.looperBanks[i];
        NSView *view = [self bankViews][i];
        NSColor *bankColor = [NSColor blueColor];
        switch (looperBank.state) {
            case On:
                bankColor = [NSColor greenColor];
                break;
            case Off:
                bankColor = [NSColor grayColor];
                break;
            case Record:
                bankColor = [NSColor orangeColor];
                break;
        }
        view.layer.borderColor = [bankColor colorWithAlphaComponent:0.5].CGColor;
    }
}

@end
