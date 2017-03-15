//
//  SlidersFactory.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Foundation/Foundation.h>
#import <BoardUI/BoardUI.h>
#import "DelayEffect.h"

@interface SlidersFactory : NSObject

+ (NSArray<Slider *> *)delaySliders:(DelayEffect *)delayEffect;

@end
