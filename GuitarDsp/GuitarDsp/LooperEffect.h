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

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings BanksCount:(int)banksCount;
- (void)record:(struct LooperBank *)looperBank;
- (void)finishRecording;

@end
