//
//  AddEffectViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Cocoa/Cocoa.h>
#import <BoardUI/BoardUI.h>

@interface AddEffectViewController : NSViewController

@property (nonatomic, copy) void(^completion)(GridEntity *);

@end
