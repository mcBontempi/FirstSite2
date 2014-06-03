//
//  NoteBlock.m
//  FirstSite
//
//  Created by Daren David Taylor on 17/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "NoteBlock.h"
#import "Note.h"

const NSUInteger KSpacing = 25;

@implementation NoteBlock {
  
  __weak IBOutlet UIView *_noteView;
  __weak IBOutlet UIView *_accidentalView;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

 -(void)setNote:(Note *)note

{
    _note = note;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  NSUInteger offsetFromBottomOfScreen = 21;
  
  CGFloat noteBottom = self.frame.size.height - ((_note.index + [_note clefOffset:self.clef] - offsetFromBottomOfScreen) * KSpacing);
  
  CGRect noteFrame = _noteView.frame;
  noteFrame.origin.y =  noteBottom;
  _noteView.frame = noteFrame;
  
  CGRect accidentalFrame = _accidentalView.frame;
  accidentalFrame.origin.y =  noteBottom;
  _accidentalView.frame = accidentalFrame;
  
  _accidentalView.hidden = _note.accidental == AccidentalNone ? YES : NO;
}


@end
