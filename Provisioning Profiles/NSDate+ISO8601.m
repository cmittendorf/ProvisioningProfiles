//
//  NSDate+ISO8601.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import "NSDate+ISO8601.h"
#include <time.h>
#include <xlocale.h>

@implementation NSDate (ISO8601)

- (NSString *)ISO8601 {
    return [[NSDate dateFormatter] stringFromDate:self];
}

+ (NSDate *)dateFromISO8601:(NSString *)string {
    if (!string) return nil;
    if (![string isKindOfClass:[NSString class]]) return nil;
    return [[NSDate dateFormatter] dateFromString:string];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return dateFormatter;
}

@end
