//
//  Board.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 16.03.2017.
//
//

#import <Foundation/Foundation.h>
#import "Effect.h"

@interface Board : NSObject

@property (nonatomic, strong) NSArray<id<Effect>> *effects;

@end
