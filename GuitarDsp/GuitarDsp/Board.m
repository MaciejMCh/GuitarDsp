//
//  Board.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 16.03.2017.
//
//

#import "Board.h"

@implementation Board

- (NSArray<id<Effect>> *)effects {
    if (!_effects) {
        _effects = [NSArray new];
    }
    return _effects;
}

@end
