//
//  PhaseVocoder.h
//  GuitarDsp
//
//  Created by Maciej Chmielewski on 14.03.2017.
//
//

#import <Foundation/Foundation.h>

@interface PhaseVocoder : NSObject

- (void)smbPitchShift:(float)pitchShift
    numSampsToProcess:(long)numSampsToProcess
         fftFrameSize:(long)fftFrameSize
                osamp:(long)osamp
           sampleRate:(float)sampleRate
               indata:(float *)indata
              outdata:(float *)outdata;

@end
