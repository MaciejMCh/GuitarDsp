//
//  BoardViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import "EffectNodesFactory.h"

@interface BoardViewController : NSViewController

+ (BoardViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory;

@end
