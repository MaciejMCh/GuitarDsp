//
//  AddEffectViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "AddEffectViewController.h"
#import "EffectNodesFactory.h"

@interface AddEffectViewController ()

@property (nonatomic, weak) IBOutlet GridView *gridView;

@end

@implementation AddEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wSelf = self;
    for (GridEntity *entity in [EffectNodesFactory all]) {
        __weak GridEntity *wEntity = entity;
        [entity setAction:^{
            [wSelf didSelectEntity:wEntity];
        }];
        [self.gridView addEntity:entity];
    }
}

- (void)didSelectEntity:(GridEntity *)entity {
    self.completion(entity);
}

@end
