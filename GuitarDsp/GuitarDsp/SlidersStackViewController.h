//
//  SlidersStackViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import <BoardUI/BoardUI.h>

@interface SlidersStackViewController : NSViewController

@property (nonatomic, weak) IBOutlet SlidersStackView *slidersView;
@property (nonatomic, copy) void (^dismiss)(void);

+ (SlidersStackViewController *)withSliders:(NSArray<Slider *> *)sliders;

@end
