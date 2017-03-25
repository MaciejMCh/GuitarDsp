//
//  Allpass.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 24.03.2017.
//
//

#import "Allpass.h"

@implementation Allpass

- (instancetype)init {
    self = [super init];
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

- (void)setfeedback:(float)val {
    feedback = val;
}

- (float)getfeedback {
    return feedback;
}

- (float)process:(float)input {
    float output;
    float bufout;
    
    bufout = buffer[bufidx];
    undenormalise(bufout);
    
    output = -input + bufout;
    buffer[bufidx] = input + (bufout*feedback);
    
    if(++bufidx>=bufsize) bufidx = 0;
    
    return output;
}

@end
