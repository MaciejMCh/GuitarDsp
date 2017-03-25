//
//  Allpass.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 24.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "denormals.h"


@interface Allpass : NSObject {
    float	feedback;
    float	*buffer;
    int		bufsize;
    int		bufidx;
}

- (void)setbuffer:(float *)buf size:(int)size;
- (float)process:(float)inp;
- (void)mute;
- (void)setfeedback:(float)val;
- (float)getfeedback;

@end
