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

+ (Slider *)linearWithName:(NSString *)name valueUpdate:(void (^)(Slider *slider))valueUpdate valuesFrom:(float)startValue to:(float)endValue step:(float)step current:(float)currentValue {
    NSMutableArray<NSString *> *values = [NSMutableArray new];
    
    float leastDistance = endValue - startValue;
    int leastDistanceIndex = 0;
    float iValue = startValue;
    while (iValue < endValue) {
        [values addObject:[NSString stringWithFormat:@"%f", iValue]];
        
        if (fabsf(iValue - currentValue) < leastDistance) {
            leastDistance = fabsf(iValue - currentValue);
            leastDistanceIndex += 1;
        }
        
        iValue += step;
    }
    leastDistanceIndex -= 1;
    
    return [[Slider alloc] initWithName:name values:values selectedIndex:leastDistanceIndex valueUpdate:valueUpdate];
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

#pragma mark -
#pragma mark - PhaseVocoder

+ (NSArray<Slider *> *)phaseVocoderSlidersWithShiftSetter:(void (^)(float newValue))shiftSetter {
    Slider *shiftsSlider = [[Slider alloc] initWithName:@"shift" values:@[@0.25, @0.5, @1, @2, @4] selectedIndex:2 valueUpdate:^(Slider *slider) {
        shiftSetter([slider.selectedValue floatValue]);
    }];
    
    NSMutableArray<NSString *> *semitoneValuesArray = [NSMutableArray new];
    for (int i = -24; i <= 24; i++) {
        [semitoneValuesArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    Slider *semitonesSlider = [[Slider alloc] initWithName:@"semitone" values:semitoneValuesArray selectedIndex:24 valueUpdate:^(Slider *slider) {
        shiftSetter(1.0 + ((float)[slider.selectedValue integerValue] / (float)12));
    }];
    
    return @[shiftsSlider, semitonesSlider];
}

+ (NSArray<Slider *> *)phaseVocoderSliders:(PhaseVocoderEffect *)phaseVocoderEffect {
    __weak PhaseVocoderEffect * wPhaseVocoderEffect = phaseVocoderEffect;
    return [self phaseVocoderSlidersWithShiftSetter:^(float newValue) {
        wPhaseVocoderEffect.shift = newValue;
    }];
}

#pragma mark -
#pragma mark - Harmonizer

+ (NSArray<Slider *> *)harmonizerSliders:(HarmonizerEffect *)harmonizerEffect {
    __weak HarmonizerEffect * wHarmonizerEffect = harmonizerEffect;
    
    NSMutableArray *values = [NSMutableArray new];
    float value = 0.0;
    int currentValueIndex = 0;
    while (value < 1.0) {
        [values addObject:[NSNumber numberWithFloat:value]];
        value += 0.01;
        
        if (!currentValueIndex && harmonizerEffect.volume < value) {
            currentValueIndex = values.count;
        }
    }
    Slider *volumeSlider = [[Slider alloc] initWithName:@"volume" values:values selectedIndex:currentValueIndex valueUpdate:^(Slider *slider) {
        wHarmonizerEffect.volume = [slider.selectedValue floatValue];
    }];
    
    return [[self phaseVocoderSlidersWithShiftSetter:^(float newValue) {
        wHarmonizerEffect.shift = newValue;
    }] arrayByAddingObject:volumeSlider];
}

#pragma mark -
#pragma mark - Reverb

+ (NSArray<Slider *> *)reverbSliders:(ReverbEffect *)reverbEffect {
    __weak ReverbEffect *wReverbEffect = reverbEffect;
    
    Slider *damp = [self linearWithName:@"damp" valueUpdate:^(Slider *slider) {
        [wReverbEffect.rev setdamp:[slider.selectedValue floatValue]];
    } valuesFrom:0 to:1 step:0.01 current:reverbEffect.rev.getdamp];
    
    Slider *roomsize = [self linearWithName:@"room size" valueUpdate:^(Slider *slider) {
        [wReverbEffect.rev setroomsize:[slider.selectedValue floatValue]];
    } valuesFrom:0 to:1 step:0.01 current:reverbEffect.rev.getroomsize];
    
    Slider *dry = [self linearWithName:@"dry" valueUpdate:^(Slider *slider) {
        [wReverbEffect.rev setdry:[slider.selectedValue floatValue]];
    } valuesFrom:0 to:1 step:0.01 current:reverbEffect.rev.getdry];
    
    Slider *wet = [self linearWithName:@"wet" valueUpdate:^(Slider *slider) {
        [wReverbEffect.rev setwet:[slider.selectedValue floatValue]];
    } valuesFrom:0 to:1 step:0.01 current:reverbEffect.rev.getwet];
    
    Slider *width = [self linearWithName:@"width" valueUpdate:^(Slider *slider) {
        [wReverbEffect.rev setwidth:[slider.selectedValue floatValue]];
    } valuesFrom:0 to:1 step:0.01 current:reverbEffect.rev.getwidth];
    
    return @[damp, roomsize, dry, wet, width];
}

@end
