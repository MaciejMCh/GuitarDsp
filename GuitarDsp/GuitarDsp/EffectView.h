//
//  EfectView.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 17.03.2017.
//
//

#import <Cocoa/Cocoa.h>

@interface EffectView : NSView

+ (EffectView *)instance;

@property (nonatomic, weak) IBOutlet NSTextField *nameTextField;

@end
