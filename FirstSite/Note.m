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
    NSUInteger noteIndex = [@{@"C":@0, @"D":@1, @"E":@2, @"F":@3, @"G":@4, @"A":@5, @"B":@6}[self.note] integerValue];
  
  return (self.octave * 7) + noteIndex;
}

- (NSUInteger)clefOffset:(enum Clef)clef;
{
  return clef == ClefBass ? 19 : 0;
}


- (BOOL)isEqual:(Note *)testNote
{
    //if(self.index == testNote.index && self.accidental == testNote.accidental) {
    if ([self.note isEqual:testNote.note]) {
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
