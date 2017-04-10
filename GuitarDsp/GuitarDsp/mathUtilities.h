//
//  mathUtilities.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 10.04.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#define roundTo(x, r)   floorf(x / r) * r
#define dB(p0, p)   log10(p / p0) * 10
