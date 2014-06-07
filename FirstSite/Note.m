//
//  Note.m
//  FirstSite
//
//  Created by Daren David Taylor on 24/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "Note.h"

@implementation Note

- (NSUInteger)index
{
    NSUInteger noteIndex = [@{@"A":@0, @"B":@1, @"C":@2, @"D":@3, @"E":@4, @"F":@5, @"G":@6}[self.note] integerValue];
  
  return (self.octave * 7) + noteIndex;
}

- (NSUInteger)clefOffset:(enum Clef)clef;
{
  return clef == ClefBass ? 12 : 0;
}


- (BOOL)isEqual:(Note *)testNote
{
    if(self.index == testNote.index && self.accidental == testNote.accidental) {
        return YES;
    }
 
    return NO;
}

- (NSString *)description
{
    NSString *accidentalString = @"";
    
    if (self.accidental == AccidentalFlat) accidentalString = @"Flat";
    if (self.accidental == AccidentalSharp) accidentalString = @"Sharp";
    
    return [NSString stringWithFormat:@"%@%lu%@", self.note, (unsigned long)self.octave, accidentalString];
}

@end
