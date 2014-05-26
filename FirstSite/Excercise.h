//
//  Excercise.h
//  FirstSite
//
//  Created by Daren David Taylor on 14/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MusicDefines.h"

@interface Excercise : NSObject

@property (nonatomic, assign) NSTimeInterval timeToAnswer;
@property (nonatomic, assign) CGFloat tolerance;
@property (nonatomic, assign) NSUInteger notesPerPage;
@property (nonatomic, strong) NSArray *noteSequence;
@property (nonatomic, assign) enum Clef clef;


@end
