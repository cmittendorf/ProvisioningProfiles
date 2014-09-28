//
//  FNProvisioningProfile.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 freenet.de GmbH. All rights reserved.
//

#import "FNProvisioningProfile.h"

@interface FNProvisioningProfile ()
@end

@implementation FNProvisioningProfile

+ (NSDictionary *)provisioningProfileWithPath:(NSString *)path {

    static dispatch_once_t onceToken;
    static NSString *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[NSBundle mainBundle] pathForResource:@"dump-ios-mobileprovision" ofType:@""];
    });

    NSMutableDictionary *dict = [[FNProvisioningProfile runCommand:helper withArguments:@[path]] mutableCopy];
    [dict setObject:path forKey:@"path"];
    [dict setObject:[path lastPathComponent] forKey:@"filename"];

    return dict;
}

+ (NSDictionary *)runCommand:(NSString *)command withArguments:(NSArray *)args
{
    NSTask *task = [[NSTask alloc] init];
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setStandardOutput:newPipe];
    [task setStandardError:newPipe];
    [task launch];

    NSData *inData = [readHandle readDataToEndOfFile];

    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *dict = (NSDictionary*)[NSPropertyListSerialization
                                         propertyListFromData:inData
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:&format
                                         errorDescription:&errorDesc];

    return dict;
}

@end
