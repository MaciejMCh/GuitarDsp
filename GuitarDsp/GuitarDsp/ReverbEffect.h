//
//  ReverbEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 18.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "SamplingSettings.h"
#import "Revmodel.h"

@interface ReverbEffect : NSObject <Effect>

@property (nonatomic, strong) Revmodel *rev;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings;


@end
