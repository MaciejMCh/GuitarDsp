//
//  DelayViewController.h
//  PassThrough
//
//  Created by Maciej Chmielewski on 08.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "DelayEffect.h"

@interface DelayViewController : NSViewController

@property (nonatomic, strong) DelayEffect *delayEffect;

@end
