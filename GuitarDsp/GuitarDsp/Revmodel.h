//
//  Revmodel.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 25.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Comb.h"
#include "Allpass.h"

@interface Revmodel : NSObject {
    float	gain;
    float	roomsize,roomsize1;
    float	damp,damp1;
    float	wet,wet1,wet2;
    float	dry;
    float	width;
    float	mode;
    
    // The following are all declared inline
    // to remove the need for dynamic allocation
    // with its subsequent error-checking messiness
    
    // Comb filters
    NSMutableArray<Comb *> *combL;
    NSMutableArray<Comb *> *combR;
    
    // Allpass filters
    NSMutableArray<Allpass *> *allpassL;
    NSMutableArray<Allpass *> *allpassR;
    
    // Buffers for the combs
}

- (void)mute;
- (void)processmix:(float *)inputL
            inputR:(float *)inputR
           outputL:(float *)outputL
           outputR:(float *)outputR
        numsamples:(long)numsamples
              skip:(int)skip;

- (void)	processreplace:(float *)inputL
                inputR:(float *)inputR
               outputL:(float *)outputL
               outputR:(float *)outputR
            numsamples:(long)numsamples
                  skip:(int)skip;

- (void)setroomsize:(float)value;
- (float)getroomsize;
- (void)setdamp:(float)value;
- (float)getdamp;
- (void)setwet:(float)value;
- (float)getwet;
- (void)setdry:(float)value;
- (float)getdry;
- (void)setwidth:(float)value;
- (float)getwidth;
- (void)setmode:(float)value;
- (float)getmode;
- (void)update;

@end
