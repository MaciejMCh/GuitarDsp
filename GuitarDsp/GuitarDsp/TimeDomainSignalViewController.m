//
//  TimeDomainSignalViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 13.03.2017.
//
//

#import "TimeDomainSignalViewController.h"

@implementation TimeDomainSignalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (!self.buffer) {
        return;
    }
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    float yOffset = 50;
    float yScale = 500;
    
    [line moveToPoint:NSMakePoint(0, (self.buffer[0] * yScale) + yOffset)];
    for (int i = 0; i < self.length; i++) {
        [line lineToPoint:NSMakePoint(i, (self.buffer[i] * yScale) + yOffset)];
    }
    
    [line setLineWidth:0.5];
    [line stroke];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end


@implementation Sta
+ (Sta *)tic {
    static Sta *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [Sta new];
    });
    return _shared;
}
@end


@implementation TimeDomainSignalViewController

- (void)viewDidLoad {
    [Sta tic].timeDomainSignalViewController = self;
}

- (void)newBuffer:(float *)newBuffer {
    self.buffer2 = self.buffer1;
    self.buffer1 = self.buffer0;
    self.buffer0 = newBuffer;
    
    self.buffer0View.buffer = self.buffer0;
    self.buffer1View.buffer = self.buffer1;
    self.buffer2View.buffer = self.buffer2;
    
    self.buffer0View.length = self.length;
    self.buffer1View.length = self.length;
    self.buffer2View.length = self.length;
    
    if (self.toggle) {
        [self.buffer0View setNeedsDisplay:YES];
        [self.buffer1View setNeedsDisplay:YES];
        [self.buffer2View setNeedsDisplay:YES];
    }
}

- (IBAction)toggleButton:(id)sender {
    self.toggle = !self.toggle;
}

@end
