//
//  FNProvisioningProfile.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 freenet.de GmbH. All rights reserved.
//

#import "FNProvisioningProfile.h"

NSString * const START_CERT = @"-----BEGIN CERTIFICATE-----";
NSString * const END_CERT = @"-----END CERTIFICATE-----";

@interface FNProvisioningProfile ()
@end

@implementation FNProvisioningProfile

+ (NSDictionary *)provisioningProfilesWithPath:(NSString *)path {
    NSString *command = @"/usr/bin/security";
    NSArray *arguments = @[@"cms", @"-D", @"-i", path];
    NSMutableDictionary *dict = [[FNProvisioningProfile dictionaryFromCommand:command
                                                                withArguments:arguments] mutableCopy];
    [dict setObject:path forKey:@"path"];
    [dict setObject:[path lastPathComponent] forKey:@"filename"];

    NSError *error = nil;
    
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"Subject: (UID=.*?)$"
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:nil];
    
    NSMutableArray *certificates = [NSMutableArray array];
    for (NSData *data in [dict objectForKey:@"DeveloperCertificates"]) {
        NSString *pem = [NSString stringWithFormat:@"%@\n%@\n%@\n", START_CERT,
                         [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength], END_CERT];
        NSString *fileName = [NSString stringWithFormat:@"%@.pem", [[NSUUID UUID] UUIDString]];
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [pem writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&error];
        command = @"/usr/bin/openssl";
        arguments = @[@"x509", @"-text", @"-in", path];
        NSString *cert = [FNProvisioningProfile stringFromCommand:command
                                                    withArguments:arguments];
        
        NSMutableDictionary *certDict = [NSMutableDictionary dictionary];
        [certDict setObject:cert
                     forKey:@"cert"];

        NSTextCheckingResult *match = [regEx firstMatchInString:cert options:0 range:NSMakeRange(0, [cert length])];
        if (match.range.location != NSNotFound && match.numberOfRanges == 2) {
            [certDict setObject:[cert substringWithRange:[match rangeAtIndex:1]]
                         forKey:@"subject"];
        }

        [certificates addObject:certDict];
    }
    [dict setObject:certificates forKey:@"DeveloperCertificates"];
    return dict;
}

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

+ (NSDictionary *)dictionaryFromCommand:(NSString *)command withArguments:(NSArray *)args {
    NSData *data = [FNProvisioningProfile runCommand:command withArguments:args];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *dict = (NSDictionary*)[NSPropertyListSerialization
                                         propertyListFromData:data
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:&format
                                         errorDescription:&errorDesc];
    return dict;
}

+ (NSString *)stringFromCommand:(NSString *)command withArguments:(NSArray *)args {
    NSData *data = [FNProvisioningProfile runCommand:command withArguments:args];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
