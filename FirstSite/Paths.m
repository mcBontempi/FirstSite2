//
//  Paths.m
//  FirstSite
//
//  Created by Daren taylor on 06/03/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "Paths.h"

@implementation Paths

+ (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
