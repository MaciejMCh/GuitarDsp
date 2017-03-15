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

@interface BoardViewController ()

@property (nonatomic, weak) IBOutlet GridView *gridView;

@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) wSelf = self;
    [self.gridView setBlankGridFactory:^GridEntity * _Nonnull{
        return [wSelf blankEntity];
    }];
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
    AddEffectViewController *addEffectViewController = [[NSStoryboard storyboardWithName:@"AddEffect" bundle:nil] instantiateInitialController];
    
    __weak typeof(self) wSelf = self;
    __weak GridEntity *wBlank = fromBlankEntity;
    __weak AddEffectViewController *wAddEffectViewController = addEffectViewController;
    [addEffectViewController setCompletion:^(GridEntity *newEffectEntity) {
        [wSelf.gridView replaceEntity:wBlank withEntity:newEffectEntity];
        [wSelf dismissViewController:wAddEffectViewController];
    }];
    
    [self presentViewControllerAsModalWindow:addEffectViewController];
//    [self transitionFromViewController:self toViewController:addEffectViewController options:NSViewControllerTransitionCrossfade completionHandler:nil];
}

@end
