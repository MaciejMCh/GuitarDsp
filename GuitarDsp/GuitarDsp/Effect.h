//
//  Effect.h
//  PassThrough
//
//  Created by Maciej Chmielewski on 08.03.2017.
//  Copyright © 2017 Syed Haris Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sample.h"

@protocol Effect <NSObject>

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer;

@end


@protocol TempoUser <NSObject>

- (void)updateTempo:(float)tempo;


@end
