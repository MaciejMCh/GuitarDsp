//
//  BoardViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "BoardViewController.h"
#import <BoardUI/BoardUI.h>
#import "AddEffectViewController.h"
#import "SlidersFactory.h"
#import "SlidersStackViewController.h"

@interface BoardViewController ()

@property (nonatomic, strong) EffectNodesFactory *effectNodesFactory;
@property (nonatomic, weak) IBOutlet GridView *gridView;

@end

@implementation BoardViewController

+ (BoardViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory {
    BoardViewController *me = [[NSStoryboard storyboardWithName:@"Board" bundle:nil] instantiateInitialController];
    me.effectNodesFactory = effectNodesFactory;
    return me;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) wSelf = self;
    [self.gridView setBlankGridFactory:^GridEntity * _Nonnull{
        return [wSelf blankEntity];
    }];
    [self.gridView setGridUpdated:^{
        [wSelf effectsUpdated];
    }];
    
    self.view.frame = [NSScreen mainScreen].frame;
}

- (void)effectsUpdated {
    NSMutableArray<id<Effect>> *effects = [NSMutableArray new];
    for (GridEntity *entity in self.gridView.entities) {
        if ([entity.model conformsToProtocol:@protocol(Effect)]) {
            [effects addObject:entity.model];
        }
    }
    self.updateEffects(effects);
}

- (GridEntity *)blankEntity {
    NSView *view = [NSView new];
    view.wantsLayer = YES;
    view.layer.borderColor = [NSColor blackColor].CGColor;
    view.layer.borderWidth = 2.0;
    
    GridEntity *blank = [GridEntity new];
    blank.view = view;
    blank.model = @"blank";
    
    __weak typeof(self) wSelf = self;
    __weak GridEntity *wBlank = blank;
    [blank setAction:^{
        [wSelf navigateToAddEffectScreen:wBlank];
    }];
    
    return blank;
}

- (void)navigateToAddEffectScreen:(GridEntity *)fromBlankEntity {
    AddEffectViewController *addEffectViewController = [AddEffectViewController withEffectNodesFactory:self.effectNodesFactory];
    
    __weak typeof(self) wSelf = self;
    __weak GridEntity *wBlank = fromBlankEntity;
    __weak AddEffectViewController *wAddEffectViewController = addEffectViewController;
    [addEffectViewController setCompletion:^(GridEntity *newEffectEntity) {
        [wSelf.gridView replaceEntity:wBlank withEntity:newEffectEntity];
        [wSelf dismissViewController:wAddEffectViewController];
        [wSelf setupNewEntityAction:newEffectEntity];
    }];
    
    [self presentViewControllerAsModalWindow:addEffectViewController];
}

- (void)setupNewEntityAction:(GridEntity *)gridEntity {
    __weak typeof(self) wSelf = self;
    if ([gridEntity.model isKindOfClass:[DelayEffect class]]) {
        __weak DelayEffect *wDelayEffect = gridEntity.model;
        [gridEntity setAction:^{
            SlidersStackViewController *controller = [SlidersStackViewController withSliders:[SlidersFactory delaySliders:wDelayEffect]];
            __weak SlidersStackViewController *wController = controller;
            [controller setDismiss:^{
                [wSelf dismissViewController:wController];
            }];
            [wSelf presentViewControllerAsModalWindow:controller];
        }];
    }
    
    if ([gridEntity.model isKindOfClass:[PhaseVocoderEffect class]]) {
        __weak PhaseVocoderEffect *wPhaseVocoderEffectEffect = gridEntity.model;
        [gridEntity setAction:^{
            SlidersStackViewController *controller = [SlidersStackViewController withSliders:[SlidersFactory phaseVocoderSliders:wPhaseVocoderEffectEffect]];
            __weak SlidersStackViewController *wController = controller;
            [controller setDismiss:^{
                [wSelf dismissViewController:wController];
            }];
            [wSelf presentViewControllerAsModalWindow:controller];
        }];
    }
}

@end
