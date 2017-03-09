//
//  Timing.h
//  Novocaine
//
//  Created by Maciej Chmielewski on 07.03.2017.
//  Copyright © 2017 Datta Lab, Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TactPart) {
    Whole = 1,
    Half = 2,
    Quater = 4,
};

struct Timing {
    TactPart tactPart;
    float tempo;
};
