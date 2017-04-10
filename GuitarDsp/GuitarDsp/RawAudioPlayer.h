//
//  RawAudioReader.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 21.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"

struct RawAudio {
    float *buffer;
    int length;
};

typedef NS_ENUM(NSUInteger, RawAudioPlayerStatus) {
    Ready,
    Playing
};

@interface RawAudioPlayer : NSObject

@property (nonatomic, assign, readonly) RawAudioPlayerStatus status;
@property (nonatomic, assign, readonly) struct RawAudio rawAudio;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings data:(NSData *)data;
- (void)play;
- (float *)next;

@end
