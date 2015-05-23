//
//  NSDictionary+JSON.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import "NSDictionary+JSON.h"
#import "NSDate+ISO8601.h"

@implementation NSDictionary (JSON)

- (NSString *)asJSONString {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[NSDictionary processParsedObject:self]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

/**
 * Make sure that the dictionary contains only JSON compatible objects.
 **/
+ (id)processParsedObject:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[(NSDictionary *)object count]];
        for (NSString *key in [object allKeys]) {
            id child = [object objectForKey:key];
            [dict setObject:[self processParsedObject:child]
                     forKey:key];
        }
        return dict;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[(NSArray *)object count]];
        for(id child in object){
            [array addObject:[self processParsedObject:child]];
        }
        return array;
    } else {
        if ([object isKindOfClass:[NSDate class]]) {
            return [(NSDate *)object ISO8601];
        } else {
            return object;
        }
    }
}

@end
