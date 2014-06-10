//
//  clefBlock.m
//  FirstSite
//
//  Created by Daren David Taylor on 17/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "clefBlock.h"

@implementation ClefBlock {
    
    __weak IBOutlet UIImageView *_bassCleffImageView;
    __weak IBOutlet UIImageView *_trebleCleffImageView;
}

- (void)setClef:(enum Clef)clef
{
    _clef = clef;
    
    _bassCleffImageView.hidden = self.clef == ClefTreble;
    _trebleCleffImageView.hidden= self.clef == ClefBass;
}

@end
