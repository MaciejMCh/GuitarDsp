//
//  TimingCalc.h
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timing.h"
#import "SamplingSettings.h"

@interface TimingCalc : NSObject

+ (int)sampleTime:(struct Timing)timing settings:(struct SamplingSettings)settings;

@end
