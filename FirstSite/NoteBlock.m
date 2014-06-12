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
const NSUInteger offsetFromBottomOfScreen = 15;


@implementation NoteBlock {
    
    __weak IBOutlet UIView *_noteView;
    __weak IBOutlet UIView *_accidentalView;
    __weak IBOutlet UIImageView *_quarterUp;
    __weak IBOutlet UIImageView *_quarterDown;
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
    
    
    CGFloat topOfLedger = (self.frame.size.height - ((_note.index + [_note clefOffset:self.clef] - offsetFromBottomOfScreen) * KSpacing) ) + 175;
    
    
    CGFloat topOfStave = (self.frame.size.height - ((38 - offsetFromBottomOfScreen) * KSpacing) ) + 175;
    CGFloat bottomOfStave = (self.frame.size.height - ((30 - offsetFromBottomOfScreen) * KSpacing) ) + 175;
    
    if(topOfLedger < topOfStave) {
        
        do {
            
            CGRect ledgerFrame = _noteView.frame;
            ledgerFrame.origin.y =  topOfStave;
            ledgerFrame.size.height = 4;
            
            UIView *ledgerLine = [[UIView alloc] initWithFrame:ledgerFrame];
            ledgerLine.backgroundColor = [UIColor blackColor];
            
            [self addSubview:ledgerLine];
            
            topOfStave -= KSpacing*2;
            
        } while (topOfStave >= topOfLedger);
    }
    else if(topOfLedger > bottomOfStave) {
        
        do {
            
            CGRect ledgerFrame = _noteView.frame;
            ledgerFrame.origin.y =  bottomOfStave;
            ledgerFrame.size.height = 4;
            
            UIView *ledgerLine = [[UIView alloc] initWithFrame:ledgerFrame];
            ledgerLine.backgroundColor = [UIColor blackColor];
            
            [self addSubview:ledgerLine];
            
            bottomOfStave += KSpacing*2;
            
        } while (bottomOfStave <= topOfLedger);
    }
    
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat noteBottom = self.frame.size.height - ((_note.index + [_note clefOffset:self.clef] - offsetFromBottomOfScreen) * KSpacing);
    
    CGRect noteFrame = _noteView.frame;
    noteFrame.origin.y =  noteBottom;
    _noteView.frame = noteFrame;
    
    BOOL down = _note.index < (35 - [_note clefOffset:self.clef]);
    
    _quarterUp.hidden = !down;
    _quarterDown.hidden = down;
    
    _accidentalView.hidden = _note.accidental == AccidentalNone ? YES : NO;
}


@end
