//
//  EffectNodesFactory.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "EffectNodesFactory.h"
#import "EffectView.h"

@interface EffectNodesFactory ()

@property (nonatomic, weak) id<EffectsFactory> effectsFactory;

@end

@implementation EffectNodesFactory

- (instancetype)initWithEffectsFactory:(id<EffectsFactory>)effectsFactory {
    self = [super init];
    self.effectsFactory = effectsFactory;
    return self;
}

- (NSArray<GridEntity *> *)all {
    return @[[self delay], [self phaseVocoder], [self harmonizer], [self looper], [self reverb]];
}

- (NSView *)effectGridEntityView:(NSString *)effectName {
    EffectView *effectView = [EffectView instance];
    effectView.wantsLayer = YES;
    effectView.layer.borderColor = [NSColor blackColor].CGColor;
    effectView.layer.borderWidth = 2.0;
    effectView.nameTextField.stringValue = effectName;
    return effectView;
}

- (GridEntity * _Nonnull)delay {
    GridEntity *entity = [GridEntity new];
    entity.view = [self effectGridEntityView:@"delay"];
    entity.model = [self.effectsFactory newDelayEffect];
    return entity;
}

- (GridEntity * _Nonnull)phaseVocoder {
    GridEntity *entity = [GridEntity new];
    entity.view = [self effectGridEntityView:@"phase vocoder"];
    entity.model = [self.effectsFactory newPhaseVocoderEffect];
    return entity;
}

- (GridEntity *)harmonizer {
    GridEntity *entity = [GridEntity new];
    entity.view = [self effectGridEntityView:@"harmonizer"];
    entity.model = [self.effectsFactory newHarmonizerEffect];
    return entity;
}

- (GridEntity *)looper {
    GridEntity *entity = [GridEntity new];
    entity.view = [self effectGridEntityView:@"looper"];
    entity.model = [self.effectsFactory newLooperEffect];
    return entity;
}

- (GridEntity *)reverb {
    GridEntity *entity = [GridEntity new];
    entity.view = [self effectGridEntityView:@"reverb"];
    entity.model = [self.effectsFactory newReverbEffect];
    return entity;
}

@end


@implementation Processor (EffectNodesFactory)

#pragma mark -
#pragma mark - EffectsFactory

- (ReverbEffect *)newReverbEffect {
    return [[ReverbEffect alloc] initWithSamplingSettings:self.samplingSettings];
}

- (LooperEffect *)newLooperEffect {
    return [[LooperEffect alloc] initWithSamplingSettings:self.samplingSettings banksCount:4 tempo:140 tactsCount:2];
}

- (PhaseVocoderEffect *)newPhaseVocoderEffect {
    return [[PhaseVocoderEffect alloc] initWithSamplingSettings:self.samplingSettings];
}

- (DelayEffect *)newDelayEffect {
    struct Timing delayTiming;
    delayTiming.tactPart = Half;
    delayTiming.tempo = self.tempo;
    
    return [[DelayEffect alloc] initWithFadingFunctionA:0.2
                                        fadingFunctionB:0.2
                                            echoesCount:2
                                       samplingSettings:self.samplingSettings
                                                 timing:delayTiming];
}

- (HarmonizerEffect *)newHarmonizerEffect {
    return [[HarmonizerEffect alloc] initWithSamplingSettings:self.samplingSettings];
}

@end
