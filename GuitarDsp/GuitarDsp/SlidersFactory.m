//
//  SlidersFactory.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "SlidersFactory.h"

@implementation SlidersFactory

+ (NSArray<Slider *> *)delaySliders:(DelayEffect *)delayEffect {
    NSMutableArray *echoesValues = [NSMutableArray new];
    int echoValueIndex;
    for (int i = 1; i < 20; i ++) {
        [echoesValues addObject:[NSString stringWithFormat:@"%d", i]];
        if (delayEffect.echoesCount == i) {
            echoValueIndex = echoesValues.count - 1;
        }
    }
    
    Slider *echoesCountSlider = [[Slider alloc] initWithName:@"delay"
                                                      values:echoesValues
                                               selectedIndex:echoValueIndex
                                                 valueUpdate:nil];
    __weak DelayEffect *wDelayEffect = delayEffect;
    __weak Slider *wEchoesCountSlider = echoesCountSlider;
    [echoesCountSlider setValueUpdate:^{
        [wDelayEffect updateEchoesCount:[[wEchoesCountSlider selectedValue] intValue]];
    }];
    
    return @[echoesCountSlider];
}

@end
