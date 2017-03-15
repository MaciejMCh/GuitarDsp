//
//  AddEffectViewController.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import "AddEffectViewController.h"

@interface AddEffectViewController ()

@property (nonatomic, strong) EffectNodesFactory *effectNodesFactory;
@property (nonatomic, weak) IBOutlet GridView *gridView;

@end

@implementation AddEffectViewController

+ (AddEffectViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory {
    AddEffectViewController *me = [[NSStoryboard storyboardWithName:@"AddEffect" bundle:nil] instantiateInitialController];
    me.effectNodesFactory = effectNodesFactory;
    return me;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wSelf = self;
    for (GridEntity *entity in [self.effectNodesFactory all]) {
        __weak GridEntity *wEntity = entity;
        [entity setAction:^{
            [wSelf didSelectEntity:wEntity];
        }];
        [self.gridView addEntity:entity];
    }
    self.view.frame = [NSScreen mainScreen].frame;
}

- (void)didSelectEntity:(GridEntity *)entity {
    self.completion(entity);
}

@end
