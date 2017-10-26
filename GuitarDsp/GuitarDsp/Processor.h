//
//  Processor.h
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"
#import "Board.h"

@interface Processor : NSObject

@property (nonatomic, strong) Board *activeBoard;
@property (nonatomic, assign) float *outputBuffer;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;
@property (nonatomic, assign) float tempo;

- (instancetype _Nonnull)initWithSamplingSettings:(struct SamplingSettings)samplingSettings tempo:(float)tempo;

- (void)processBuffer:(float *)buffer;

@end
