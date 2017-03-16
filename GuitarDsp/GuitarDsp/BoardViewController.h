//
//  BoardViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import "EffectNodesFactory.h"
#import "Effect.h"

@interface BoardViewController : NSViewController

@property (nonatomic, copy) void (^updateEffects)(NSArray<id<Effect>> *);

+ (BoardViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory;

@end
