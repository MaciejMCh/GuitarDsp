//
//  LooperEffect.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 20.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Effect.h"
#import "Timing.h"
#import "SamplingSettings.h"

typedef NS_ENUM(NSUInteger, BankState) {
    On = 1,
    Off = 2,
    Record = 3
};

struct LooperBank {
    float **packetsBuffer;
    BankState state;
};

@interface LooperEffect : NSObject <Effect>

@property (nonatomic, assign) struct LooperBank *looperBanks;
@property (nonatomic, assign) BOOL playMetronome;
@property (nonatomic, assign, readonly) int tactsCount;
@property (nonatomic, assign, readonly) float tempo;
@property (nonatomic, assign, readonly) float durationInSeconds;
@property (nonatomic, copy) void (^loopDidBegin)(LooperEffect * _Nonnull looperEffect);

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings banksCount:(int)banksCount tempo:(float)tempo tactsCount:(int)tactsCount;
- (void)record:(struct LooperBank *)looperBank;
- (void)finishRecording;
- (void)updateTactsCount:(int)tactsCount;
- (void)updateTempo:(float)tempo;

@end
