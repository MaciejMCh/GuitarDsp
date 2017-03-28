//
//  EffectNodesFactory.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Foundation/Foundation.h>
#import <BoardUI/BoardUI.h>
#import <GuitarDsp/GuitarDsp.h>

@protocol EffectsFactory <NSObject>

- (DelayEffect * _Nonnull)newDelayEffect;
- (PhaseVocoderEffect * _Nonnull)newPhaseVocoderEffect;
- (HarmonizerEffect * _Nonnull)newHarmonizerEffect;
- (LooperEffect * _Nonnull)newLooperEffect;
- (ReverbEffect * _Nonnull)newReverbEffect;

@end


@interface EffectNodesFactory : NSObject

- (instancetype _Nonnull)initWithEffectsFactory:(id<EffectsFactory> _Nonnull)effectsFactory;

- (NSArray<GridEntity *> * _Nonnull)all;

- (GridEntity * _Nonnull)delay;
- (GridEntity * _Nonnull)phaseVocoder;
- (GridEntity * _Nonnull)harmonizer;
- (GridEntity * _Nonnull)looper;
- (GridEntity * _Nonnull)reverb;

@end


@interface Processor (EffectNodesFactory) <EffectsFactory>

@end
