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
    __weak IBOutlet UIView *_sharpView;
    __weak IBOutlet UIView *_flatView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setNote:(Note *)note
{
    _note = note;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect noteFrame = _noteView.frame;
    
    noteFrame.origin.y = self.frame.size.height - (_note.index * KSpacing);
    
    _noteView.frame = noteFrame;


}

@end
