//
//  IndicatorNoteBlock.h
//  FirstSite
//
//  Created by Daren David Taylor on 17/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MusicDefines.h"

@class Note;

@interface IndicatorNoteBlock : UIView

@property (nonatomic, strong) Note *note;
@property (nonatomic, assign) enum Clef clef;

// used while animating
- (void)hideNote;
- (void)showNote;

@end
