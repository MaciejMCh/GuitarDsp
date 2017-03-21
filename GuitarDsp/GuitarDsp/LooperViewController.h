//
//  LooperViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 20.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import "LooperEffect.h"

@interface LooperViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSView *bankView1;
@property (nonatomic, weak) IBOutlet NSView *bankView2;
@property (nonatomic, weak) IBOutlet NSView *bankView3;
@property (nonatomic, weak) IBOutlet NSView *bankView4;

@property (nonatomic, strong) LooperEffect *looperEffect;

+ (LooperViewController *)withLooperEffect:(LooperEffect *)looperEffect;

@end
