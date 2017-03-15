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
#import "DelayEffect.h"
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
    
    self.view.frame = [NSScreen mainScreen].frame;
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
    if ([gridEntity.model isKindOfClass:[DelayEffect class]]) {
        __weak DelayEffect *wDelayEffect = gridEntity.model;
        [gridEntity setAction:^{
            SlidersStackViewController *controller = [SlidersStackViewController withSliders:[SlidersFactory delaySliders:wDelayEffect]];
            [self presentViewControllerAsModalWindow:controller];
        }];
    }
}

@end
