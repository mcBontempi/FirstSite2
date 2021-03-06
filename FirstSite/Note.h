//
//  Note.h
//  FirstSite
//
//  Created by Daren David Taylor on 24/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicDefines.h"

@interface Note : NSObject

@property (nonatomic, assign) enum Accidental accidental;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, assign) NSUInteger octave;

- (NSUInteger)index;
- (NSUInteger)clefOffset:(enum Clef)clef;

@end
