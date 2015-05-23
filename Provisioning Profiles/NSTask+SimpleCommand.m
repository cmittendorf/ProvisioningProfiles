//
//  NSTask+SimpleCommand.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import "NSTask+SimpleCommand.h"

@implementation NSTask (SimpleCommand)

+ (NSData *)runCommand:(NSString *)command withArguments:(NSArray *)args {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setStandardOutput:newPipe];
    [task setStandardError:newPipe];
    [task launch];
    return [readHandle readDataToEndOfFile];
}

@end
