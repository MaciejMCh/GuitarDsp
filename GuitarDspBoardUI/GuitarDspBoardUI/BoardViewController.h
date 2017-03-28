//
//  BoardViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import <GuitarDsp/GuitarDsp.h>
#import "EffectNodesFactory.h"

@interface BoardViewController : NSViewController

@property (nonatomic, copy) void (^updateEffects)(NSArray<id<Effect>> *);

+ (BoardViewController *)withEffectNodesFactory:(EffectNodesFactory *)effectNodesFactory;

@end
