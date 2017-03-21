//
//  RawAudioReader.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 21.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "SamplingSettings.h"

typedef NS_ENUM(NSUInteger, RawAudioPlayerStatus) {
    Ready,
    Playing
};

@interface RawAudioPlayer : NSObject

@property (nonatomic, assign, readonly) RawAudioPlayerStatus status;

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings file:(NSString *)name;
- (void)play;
- (float *)next;

@end
