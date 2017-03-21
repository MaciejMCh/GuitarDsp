//
//  TimingCalc.m
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import "TimingCalc.h"

@implementation TimingCalc

+ (int)sampleTime:(struct Timing)timing settings:(struct SamplingSettings)settings {
    return floor(settings.frequency / settings.framesPerPacket / timing.tactPart * 60 / timing.tempo * 4);
}

@end
