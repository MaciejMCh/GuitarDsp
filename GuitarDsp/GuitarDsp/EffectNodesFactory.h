//
//  EffectNodesFactory.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 15.03.2017.
//
//

#import <Foundation/Foundation.h>
#import <BoardUI/BoardUI.h>

@interface EffectNodesFactory : NSObject

+ (NSArray<GridEntity *> * _Nonnull)all;

+ (GridEntity * _Nonnull)delay;
+ (GridEntity * _Nonnull)phaseVocoder;

@end
