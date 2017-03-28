//
//  AudioInterface.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 28.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Processor.h"
#import "SamplingSettings.h"

@interface AudioInterface : NSObject

@property (nonatomic, assign, readonly) struct SamplingSettings samplingSettings;

+ (AudioInterface *)sharedInterface;

- (void)useProcessor:(Processor *)processor;

@end
