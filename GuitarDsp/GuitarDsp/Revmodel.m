//
//  Revmodel.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 25.03.2017.
//
//

#import "Revmodel.h"

@implementation Revmodel

- (instancetype)init {
    self = [super init];
    
    combL = [NSMutableArray new];
    combR = [NSMutableArray new];
    for (int i = 0; i < numcombs; i++) {
        [combL addObject:[Comb new]];
        [combR addObject:[Comb new]];
    }
    
    allpassL = [NSMutableArray new];
    allpassR = [NSMutableArray new];
    for (int i = 0; i < numallpasses; i++) {
        [allpassL addObject:[Allpass new]];
        [allpassR addObject:[Allpass new]];
    }
    
    [combL[0] setbuffer:bufcombL1 size:combtuningL1];
    [combR[0] setbuffer:bufcombR1 size:combtuningR1];
    [combL[1] setbuffer:bufcombL2 size:combtuningL2];
    [combR[1] setbuffer:bufcombR2 size:combtuningR2];
    [combL[2] setbuffer:bufcombL3 size:combtuningL3];
    [combR[2] setbuffer:bufcombR3 size:combtuningR3];
    [combL[3] setbuffer:bufcombL4 size:combtuningL4];
    [combR[3] setbuffer:bufcombR4 size:combtuningR4];
    [combL[4] setbuffer:bufcombL5 size:combtuningL5];
    [combR[4] setbuffer:bufcombR5 size:combtuningR5];
    [combL[5] setbuffer:bufcombL6 size:combtuningL6];
    [combR[5] setbuffer:bufcombR6 size:combtuningR6];
    [combL[6] setbuffer:bufcombL7 size:combtuningL7];
    [combR[6] setbuffer:bufcombR7 size:combtuningR7];
    [combL[7] setbuffer:bufcombL8 size:combtuningL8];
    [combR[7] setbuffer:bufcombR8 size:combtuningR8];
    
    [allpassL[0] setbuffer:bufallpassL1 size:allpasstuningL1];
    [allpassR[0] setbuffer:bufallpassR1 size:allpasstuningR1];
    [allpassL[1] setbuffer:bufallpassL2 size:allpasstuningL2];
    [allpassR[1] setbuffer:bufallpassR2 size:allpasstuningR2];
    [allpassL[2] setbuffer:bufallpassL3 size:allpasstuningL3];
    [allpassR[2] setbuffer:bufallpassR3 size:allpasstuningR3];
    [allpassL[3] setbuffer:bufallpassL4 size:allpasstuningL4];
    [allpassR[3] setbuffer:bufallpassR4 size:allpasstuningR4];
    
    // Set default values
    [allpassL[0] setfeedback: 0.5f];
    [allpassR[0] setfeedback: 0.5f];
    [allpassL[1] setfeedback: 0.5f];
    [allpassR[1] setfeedback: 0.5f];
    [allpassL[2] setfeedback: 0.5f];
    [allpassR[2] setfeedback: 0.5f];
    [allpassL[3] setfeedback: 0.5f];
    [allpassR[3] setfeedback: 0.5f];
    
    [self setwet:initialwet];
    [self setroomsize:initialroom];
    [self setdry:initialdry];
    [self setdamp:initialdamp];
    [self setwidth:initialwidth];
    [self setmode:initialmode];
    
    // Buffer will be full of rubbish - so we MUST mute them
    [self mute];
    
    return self;
}

- (void)mute {
    if ([self getmode] >= freezemode) {
        return;
    }
    
    for (int i=0;i<numcombs;i++) {
        [combL[i] mute];
        [combR[i] mute];
    }
    for (int i=0;i<numallpasses;i++) {
        [allpassL[i] mute];
        [allpassR[i] mute];
    }
}

- (void)processmix:(float *)inputL inputR:(float *)inputR outputL:(float *)outputL outputR:(float *)outputR numsamples:(long)numsamples skip:(int)skip {
    float outL,outR,input;
    
    while(numsamples-- > 0) {
        outL = outR = 0;
        input = (*inputL + *inputR) * gain;
        
        // Accumulate comb filters in parallel
        for(int i=0; i<numcombs; i++) {
            outL += [combL[i] process:input];
            outR += [combR[i] process:input];
        }
        
        // Feed through allpasses in series
        for(int i=0; i<numallpasses; i++) {
            outL = [allpassL[i] process:outL];
            outR = [allpassR[i] process:outR];
        }
        
        // Calculate output MIXING with anything already there
        *outputL += outL*wet1 + outR*wet2 + *inputL*dry;
        *outputR += outR*wet1 + outL*wet2 + *inputR*dry;
        
        // Increment sample pointers, allowing for interleave (if any)
        inputL += skip;
        inputR += skip;
        outputL += skip;
        outputR += skip;
    }
}

- (void)update {
    int i;
    
    wet1 = wet*(width/2 + 0.5f);
    wet2 = wet*((1-width)/2);
    
    if (mode >= freezemode) {
        roomsize1 = 1;
        damp1 = 0;
        gain = muted;
    } else {
        roomsize1 = roomsize;
        damp1 = damp;
        gain = fixedgain;
    }
    
    for(i=0; i<numcombs; i++) {
        [combL[i] setfeedback:roomsize1];
        [combR[i] setfeedback:roomsize1];
    }
    
    for(i=0; i<numcombs; i++) {
        [combL[i] setdamp:damp1];
        [combR[i] setdamp:damp1];
    }
}

- (void)setroomsize:(float)value {
    roomsize = (value*scaleroom) + offsetroom;
    [self update];
}

- (float)getroomsize {
    return (roomsize-offsetroom)/scaleroom;
}

- (void)setdamp:(float)value {
    damp = value*scaledamp;
    [self update];
}

- (float)getdamp {
    return damp/scaledamp;
}

- (void)setwet:(float)value {
    wet = value*scalewet;
    [self update];
}

- (float)getwet {
    return wet/scalewet;
}

- (void)setdry:(float)value {
    dry = value*scaledry;
}

- (float)getdry {
    return dry/scaledry;
}

- (void)setwidth:(float)value {
    width = value;
    [self update];
}

- (float)getwidth {
    return width;
}

- (void)setmode:(float)value {
    mode = value;
    [self update];
}

- (float)getmode {
    if (mode >= freezemode) {
        return 1;
    } else {
        return 0;
    }
}

@end
