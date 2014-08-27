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
  return clef == ClefBass ? 12 : 7;
}

- (NSString *)alternateNote
{
    return @{@"C":@"D", @"D":@"E", @"F":@"G", @"G":@"A", @"A":@"B"}[self.note];
}

- (BOOL)isEqual:(Note *)testNote
{
    
    if ([testNote.note isEqual:@"G"] && testNote.accidental == AccidentalFlat) {
        
        
    }
    
    if (self.octave == testNote.octave) {
    
    if (([self.note isEqual:testNote.note] && self.accidental == testNote.accidental) ||
        (self.accidental == AccidentalSharp && testNote.accidental == AccidentalFlat && [testNote.note isEqual:self.alternateNote])
        
        ) {
    return YES;
    }
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
