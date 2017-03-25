//
//  Comb.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 25.03.2017.
//
//

#import <Foundation/Foundation.h>

@interface Comb : NSObject {
    float	feedback;
    float	filterstore;
    float	damp1;
    float	damp2;
    float	*buffer;
    int		bufsize;
    int		bufidx;
}

- (void)setbuffer:(float *)buf size:(int)size;
- (float)process:(float)inp;
- (void)mute;
- (void)setdamp:(float)val;
- (float)getdamp;
- (void)setfeedback:(float)val;
- (float)getfeedback;

@end
