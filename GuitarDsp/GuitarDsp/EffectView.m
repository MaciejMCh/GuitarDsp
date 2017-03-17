//
//  EfectView.m
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 17.03.2017.
//
//

#import "EffectView.h"

@implementation EffectView

+ (EffectView *)instance {
    NSArray *nibContents;
    [[NSBundle bundleForClass:[EffectView class]] loadNibNamed:@"Effect" owner:nil topLevelObjects:&nibContents];
    for (id element in nibContents) {
        if ([element isKindOfClass:[EffectView class]]) {
            [element setWantsLayer:YES];
            return element;
        }
    }
    return nil;
}

@end
