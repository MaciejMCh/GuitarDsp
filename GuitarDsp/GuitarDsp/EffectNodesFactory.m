//
//  EffectNodesFactory.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "EffectNodesFactory.h"

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

- (GridEntity * _Nonnull)delay {
    NSView *view = [NSView new];
    view.wantsLayer = YES;
    view.layer.borderColor = [NSColor blackColor].CGColor;
    view.layer.borderWidth = 2.0;
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    textField.stringValue = @"delay";
    [view addSubview:textField];
    GridEntity *entity = [GridEntity new];
    entity.view = view;
    entity.model = [self.effectsFactory newDelayEffect];
    return entity;
}

- (GridEntity * _Nonnull)phaseVocoder {
    NSView *view = [NSView new];
    view.wantsLayer = YES;
    view.layer.borderColor = [NSColor blackColor].CGColor;
    view.layer.borderWidth = 2.0;
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    textField.stringValue = @"phase vocoder";
    [view addSubview:textField];
    GridEntity *entity = [GridEntity new];
    entity.view = view;
    entity.model = [self.effectsFactory newPhaseVocoderEffect];
    return entity;
}

@end
