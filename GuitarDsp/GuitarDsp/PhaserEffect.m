//
//  PhaserEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "PhaserEffect.h"

@interface PhaserEffect () {
    float _dmin, _dmax; //range
    float _fb; //feedback
    float _lfoPhase;
    float _lfoInc;
    float _depth;
    
    float _zm1;
}

@property (nonatomic, assign, readwrite) float rangeFmin;
@property (nonatomic, assign, readwrite) float rangeFmax;
@property (nonatomic, assign, readwrite) float rate;
@property (nonatomic, assign, readwrite) float feedback;
@property (nonatomic, assign, readwrite) float depth;

@property (nonatomic, strong) NSArray<AllPassDelay *> *_alps;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation PhaserEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [super init];
    self.samplingSettings = samplingSettings;
    
    _fb = .7f;
    _lfoPhase = 0.f;
    _depth = 1.f;
    _zm1 = 0.f;
    self._alps = @[[AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new]];
    [self updateRangeFmin:440.0 fMax:1600.0];
    [self updateRate:0.5];
    
    return self;
}

- (void)updateRangeFmin:(float)fMin fMax:(float)fMax { // Hz
    self.rangeFmin = fMin;
    self.rangeFmax = fMax;
    _dmin = fMin / (self.samplingSettings.frequency/2.f);
    _dmax = fMax / (self.samplingSettings.frequency/2.f);
}

- (void)updateRate:(float)rate { // cps
    self.rate = rate;
    _lfoInc = 2.f * M_PI * (rate / self.samplingSettings.frequency);
}

- (void)updateFeedback:(float)fb { // 0 -> <1.
    self.feedback = fb;
    _fb = fb;
}

- (void)updateDepth:(float)depth {  // 0 -> 1.
    self.depth = depth;
    _depth = depth;
}

- (float)update:(float)inSamp {
    //calculate and update phaser sweep lfo...
    float d  = _dmin + (_dmax-_dmin) * ((sin( _lfoPhase ) +
                                         1.f)/2.f);
    _lfoPhase += _lfoInc;
    if( _lfoPhase >= M_PI * 2.f )
        _lfoPhase -= M_PI * 2.f;
    
    //update filter coeffs
    for( int i=0; i<6; i++ ) {
        [self._alps[i] delay:d];
    }
    
    //calculate output
    float y =
    [self._alps[0] update:
     [self._alps[1] update:
      [self._alps[2] update:
       [self._alps[3] update:
        [self._alps[4] update:
         [self._alps[5] update:inSamp + _zm1 * _fb]]]]]];
    _zm1 = y;
    
    return inSamp + y * _depth;
}

@end


@interface AllPassDelay () {
    float _a1;
    float _zm1;
}

@end

@implementation AllPassDelay

- (instancetype)init {
    self = [super init];
    _a1 = 0.f;
    _zm1 = 0.f;
    return self;
}

- (void)delay:(float)delay { //sample delay time
    _a1 = (1.f - delay) / (1.f + delay);
}

- (float)update:(float)inSamp {
    float y = inSamp * -_a1 + _zm1;
    _zm1 = y * _a1 + inSamp;
    
    return y;
}

@end
