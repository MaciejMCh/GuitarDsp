//
//  Comb.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 25.03.2017.
//
//

#import "Comb.h"
#import "denormals.h"

@implementation Comb

- (instancetype)init {
    self = [super init];
    filterstore = 0;
    bufidx = 0;
    return self;
}

- (void)setbuffer:(float *)buf size:(int)size {
    buffer = buf;
    bufsize = size;
}

- (void)mute {
    for (int i=0; i<bufsize; i++) {
        buffer[i]=0;
    }
}

- (void)setdamp:(float)val {
    damp1 = val;
    damp2 = 1-val;
}

- (float)getdamp {
    return damp1;
}

- (void)setfeedback:(float)val {
    feedback = val;
}

- (float)getfeedback {
    return feedback;
}

- (float)process:(float)input {
    float output;
    
    output = buffer[bufidx];
    undenormalise(output);
    
    filterstore = (output*damp2) + (filterstore*damp1);
    undenormalise(filterstore);
    
    buffer[bufidx] = input + (filterstore*feedback);
    
    if(++bufidx>=bufsize) bufidx = 0;
    
    return output;
}

@end
