//
//  IndicatorNoteBlock.m
//  FirstSite
//
//  Created by Daren David Taylor on 17/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "IndicatorNoteBlock.h"
#import "Note.h"

const NSUInteger KIndicatorSpacing = 25;

@implementation IndicatorNoteBlock {
  
  __weak IBOutlet UIView *_noteView;
  __weak IBOutlet UIImageView *_accidentalImageView;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      _noteView.alpha = 0.0;
  }
  return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _noteView.alpha = 0.0;
}

- (void)hideNote
{
    _noteView.hidden = YES;
    _accidentalImageView.hidden = YES;
}
- (void)showNote
{
    _noteView.hidden = NO;
    _accidentalImageView.hidden = NO;
}
 -(void)setNote:(Note *)note
{
    _note = note;
    
    NSUInteger offsetFromBottomOfScreen = 15;
    
    CGFloat noteBottom = self.frame.size.height - ((_note.index + [_note clefOffset:self.clef] - offsetFromBottomOfScreen) * KIndicatorSpacing);
    
    CGRect noteFrame = _noteView.frame;
    noteFrame.origin.y =  noteBottom;
    _noteView.frame = noteFrame;
    
    _noteView.alpha = 1.0;

    _accidentalImageView.hidden = _note.accidental == AccidentalNone ? YES : NO;
    
    _accidentalImageView.image = [UIImage imageNamed: _note.accidental == AccidentalFlat ? @"flat" : @"sharp"];

    
    [UIView animateWithDuration:2.5
                     animations:^{_noteView.alpha = 0.0;}];
    
}

@end
