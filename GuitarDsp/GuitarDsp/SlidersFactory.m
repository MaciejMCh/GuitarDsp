//
//  SlidersFactory.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "SlidersFactory.h"

@implementation SlidersFactory

#pragma mark - 
#pragma mark - Common

+ (Slider *)tactPartSlider:(TactPart)currentTactPart sliderName:(NSString *)sliderName valueUpdate:(void (^)(Slider *slider))valueUpdate {
    NSArray *values = @[@1, @2, @4, @8, @16];
    return [[Slider alloc] initWithName:sliderName
                                 values:values
                          selectedIndex:[values indexOfObject:@(currentTactPart)]
                            valueUpdate:valueUpdate];
}

#pragma mark -
#pragma mark - Delay
+ (NSArray<Slider *> *)delaySliders:(DelayEffect *)delayEffect {
    return @[[self echoesCountSlider: delayEffect],
             [self functionASlider:delayEffect],
             [self functionBSlider:delayEffect],
             [self delayTactPartSlider:delayEffect]];
}

+ (Slider *)delayTactPartSlider:(DelayEffect *)delayEffect {
    __weak DelayEffect *wDelayEffect = delayEffect;
    return [self tactPartSlider:delayEffect.timing.tactPart sliderName:@"tack part" valueUpdate:^(Slider *slider) {
        [wDelayEffect updateTact:[slider.selectedValue integerValue]];
    }];
}

+ (Slider *)echoesCountSlider:(DelayEffect *)delayEffect {
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
    [echoesCountSlider setValueUpdate:^(Slider *slider) {
        [wDelayEffect updateEchoesCount:[[slider selectedValue] intValue]];
    }];
    return echoesCountSlider;
}

+ (Slider *)functionASlider:(DelayEffect *)delayEffect {
    NSMutableArray *values = [NSMutableArray new];
    
    float value = 0.0;
    int currentValueIndex = 0;
    while (value < 1.0) {
        [values addObject:[NSNumber numberWithFloat:value]];
        value += 0.01;
        
        if (!currentValueIndex && delayEffect.fadingFunctionA < value) {
            currentValueIndex = values.count;
        }
    }
    
    Slider *slider = [[Slider alloc] initWithName:@"A"
                                           values:values
                                    selectedIndex:currentValueIndex
                                      valueUpdate:nil];
    __weak DelayEffect *wDelayEffect = delayEffect;
    [slider setValueUpdate:^(Slider *slider) {
        wDelayEffect.fadingFunctionA = [[slider selectedValue] floatValue];
    }];
    
    return slider;
}

+ (Slider *)functionBSlider:(DelayEffect *)delayEffect {
    NSMutableArray *values = [NSMutableArray new];
    
    float value = 0.0;
    int currentValueIndex = 0;
    while (value < 1.0) {
        [values addObject:[NSNumber numberWithFloat:value]];
        value += 0.01;
        
        if (!currentValueIndex && delayEffect.fadingFunctionA < value) {
            currentValueIndex = values.count;
        }
    }
    
    Slider *slider = [[Slider alloc] initWithName:@"B"
                                           values:values
                                    selectedIndex:currentValueIndex
                                      valueUpdate:nil];
    __weak DelayEffect *wDelayEffect = delayEffect;
    [slider setValueUpdate:^(Slider *slider) {
        wDelayEffect.fadingFunctionB = [[slider selectedValue] floatValue];
    }];
    
    return slider;
}

@end
