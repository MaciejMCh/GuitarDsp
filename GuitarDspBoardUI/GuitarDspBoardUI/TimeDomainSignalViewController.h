//
//  TimeDomainSignalViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 13.03.2017.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
 

@interface TimeDomainSignalView : NSView

@property (nonatomic, assign) float *buffer;
@property (nonatomic, assign) int length;

@end


@interface TimeDomainSignalViewController : NSViewController

@property (nonatomic, strong) IBOutlet TimeDomainSignalView *buffer0View;
@property (nonatomic, strong) IBOutlet TimeDomainSignalView *buffer1View;
@property (nonatomic, strong) IBOutlet TimeDomainSignalView *buffer2View;

@property (nonatomic, assign) float *buffer0;
@property (nonatomic, assign) float *buffer1;
@property (nonatomic, assign) float *buffer2;
@property (nonatomic, assign) int length;

@property (nonatomic, assign) BOOL toggle;

- (void)newBuffer:(float *)newBuffer;

@end


@interface Sta : NSObject

@property (nonatomic, strong) TimeDomainSignalViewController *timeDomainSignalViewController;

+ (Sta *)tic;

@end
