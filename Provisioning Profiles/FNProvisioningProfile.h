//
//  FNProvisioningProfile.h
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNProvisioningProfile : NSObject

+ (NSDictionary *)provisioningProfilesWithPath:(NSString *)path;

@end
