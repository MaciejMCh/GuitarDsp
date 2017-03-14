//
//  PhaseVocoderViewController.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 14.03.2017.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PhaseVocoderEffect.h"

@interface PhaseVocoderViewController : NSViewController

@property (nonatomic, strong) PhaseVocoderEffect *phaseVocoderEffect;
@property (nonatomic, strong) IBOutlet NSTextField *shiftTextField;
@property (nonatomic, strong) IBOutlet NSTextField *fftLengthTextField;
@property (nonatomic, strong) IBOutlet NSTextField *overlapLengthTextField;;

@end
