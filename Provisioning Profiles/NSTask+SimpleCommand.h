//
//  NSTask+SimpleCommand.h
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (SimpleCommand)

+ (NSData *)runCommand:(NSString *)command withArguments:(NSArray *)args;

@end
