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
  return clef == ClefBass ? 12 : 0;
}

@end
