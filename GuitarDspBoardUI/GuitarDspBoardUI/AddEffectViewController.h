//
//  AddEffectViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import <BoardUI/BoardUI.h>
#import "EffectNodesFactory.h"

@interface AddEffectViewController : NSViewController

+ (AddEffectViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory;

@property (nonatomic, copy) void(^completion)(GridEntity *);

@end
