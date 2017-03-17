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
    return @[[self delay], [self phaseVocoder]];
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

@end
