//
//  PhaserEffect.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "PhaserEffect.h"

#define SR (44100.f)  //sample rate
#define F_PI (3.14159f)

@interface PhaserEffect () {
    float _dmin, _dmax; //range
    float _fb; //feedback
    float _lfoPhase;
    float _lfoInc;
    float _depth;
    
    float _zm1;
}

@property (nonatomic, strong) NSArray<AllPassDelay *> *_alps;
@property (nonatomic, assign) struct SamplingSettings samplingSettings;

@end

@implementation PhaserEffect

- (instancetype)initWithSamplingSettings:(struct SamplingSettings)samplingSettings {
    self = [self init];
    self.samplingSettings = samplingSettings;
    return self;
}

- (instancetype)init {
    self = [super init];
    _fb = .7f;
    _lfoPhase = 0.f;
    _depth = 1.f;
    _zm1 = 0.f;
    self._alps = @[[AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new], [AllPassDelay new]];
    [self Range:440.0 fMax:1600.0];
    [self Rate:0.5];
    
    return self;
}

- (void)processSample:(struct Sample)inputSample intoBuffer:(float *)outputBuffer {
    for (int i = 0; i < self.samplingSettings.framesPerPacket; i++) {
        outputBuffer[i] = [self Update:inputSample.amp[i]];
    }
}

- (void)Range:(float)fMin fMax:(float)fMax { // Hz
    _dmin = fMin / (SR/2.f);
    _dmax = fMax / (SR/2.f);
}

- (void)Rate:(float)rate { // cps
    _lfoInc = 2.f * F_PI * (rate / SR);
}

- (void)Feedback:(float)fb { // 0 -> <1.
    _fb = fb;
}

- (void)Depth:(float)depth {  // 0 -> 1.
    _depth = depth;
}

- (float)Update:(float)inSamp {
    //calculate and update phaser sweep lfo...
    float d  = _dmin + (_dmax-_dmin) * ((sin( _lfoPhase ) +
                                         1.f)/2.f);
    _lfoPhase += _lfoInc;
    if( _lfoPhase >= F_PI * 2.f )
        _lfoPhase -= F_PI * 2.f;
    
    //update filter coeffs
    for( int i=0; i<6; i++ ) {
        [self._alps[i] Delay:d];
    }
    
    //calculate output
    float y =
    [self._alps[0] Update:
     [self._alps[1] Update:
      [self._alps[2] Update:
       [self._alps[3] Update:
        [self._alps[4] Update:
         [self._alps[5] Update:inSamp + _zm1 * _fb]]]]]];
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

- (void)Delay:(float)delay { //sample delay time
    _a1 = (1.f - delay) / (1.f + delay);
}

- (float)Update:(float)inSamp {
    float y = inSamp * -_a1 + _zm1;
    _zm1 = y * _a1 + inSamp;
    
    return y;
}

@end
