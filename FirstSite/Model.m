//
//  Model.m
//  FirstSite
//
//  Created by Daren David Taylor on 14/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "Model.h"
#import "Paths.h"
#import <CHCSVParser/CHCSVParser.h>
#import "Excercise.h"
#import "Note.h"
#import "MusicDefines.h"

@implementation Model

- (void)createDefaultExcercise
{
    NSString *file = [[Paths applicationDocumentsDirectory].path stringByAppendingPathComponent:@"Excercise.csv"];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:file];
    
    if (!fileExists) {
        UIAlertView *noInputAlert =
		[[UIAlertView alloc] initWithTitle:@"No CSV file present"
								   message:@"Use iTunes file sharing to configure FirstSite, then quit and restart the app."
								  delegate:self
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		
		[noInputAlert show];
    }
    else {
        NSArray *fields = [NSArray arrayWithContentsOfCSVFile:file options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];
        
        if (fields) {
            
            NSLog(@"%@", fields);
            
            _excercise = [[Excercise alloc] init];
            
            _excercise.timeToAnswer = [fields[0][1] intValue];
            
            _excercise.tolerance = [fields[1][1] intValue];
            
            _excercise.notesPerPage = [fields[2][1] intValue];
            
            NSMutableArray *mutableRawNotes = [fields[3] mutableCopy];
            [mutableRawNotes removeObjectAtIndex:0];
            
            NSMutableArray *mutableNotes = [[NSMutableArray alloc] init];
            
            [mutableRawNotes enumerateObjectsUsingBlock:^(NSString *rawNote, NSUInteger idx, BOOL *stop) {
                
                Note *newNote = [[Note alloc] init];
                
                newNote.accidental = AccidentalNone;
                newNote.note = [rawNote substringWithRange:NSMakeRange(0,1)];
                newNote.octave = [[rawNote substringWithRange:NSMakeRange(rawNote.length-1,1)] intValue];
                
                if (rawNote.length ==3) {
                    NSString *rawAccidental = [rawNote substringWithRange:NSMakeRange(1,1)];
                    
                    if ([rawAccidental isEqual:@"S"]) {
                        newNote.accidental = AccidentalSharp;
                    }
                    else if ([rawAccidental isEqual:@"F"]) {
                        newNote.accidental = AccidentalFlat;
                    }
                    else {
                        assert(0);
                    }
                }
                
                [mutableNotes addObject:newNote];
            }];
            
            _excercise.noteSequence = [mutableNotes copy];
            
            NSString *clefString = fields[4][1];
            
            if ([clefString isEqual:@"Treble"]) {
                _excercise.clef = ClefTreble;
            }
            else {
                _excercise.clef = ClefBass;
            }
        }
    }
}

@end
