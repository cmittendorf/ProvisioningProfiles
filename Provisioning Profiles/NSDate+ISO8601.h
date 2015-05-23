//
//  NSDate+ISO8601.h
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601)
- (NSString *)ISO8601;
+ (NSDate *)dateFromISO8601:(NSString *)string;
@end
