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

@implementation Model

- (void)createExcercise
{
    NSString *file = [[Paths applicationDocumentsDirectory].path stringByAppendingPathComponent:@"Excercise.csv"];
    
	NSArray *fields = [NSArray arrayWithContentsOfCSVFile:file options:CHCSVParserOptionsRecognizesBackslashesAsEscapes];

    NSLog(@"%@", fields);
}

@end
