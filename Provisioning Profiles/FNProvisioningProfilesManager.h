//
//  FNProvisioningProfilesManager.h
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FNProvisioningProfilesManager;

@protocol FNProvisioningProfilesManagerDelegate <NSObject>
- (void)startUpdatingProfiles:(FNProvisioningProfilesManager *)provisioningProfilesManager;
- (void)profilesUpdateComplete:(FNProvisioningProfilesManager *)provisioningProfilesManager;
@end

@interface FNProvisioningProfilesManager : NSObject

@property (assign) id<FNProvisioningProfilesManagerDelegate> delegate;
@property (nonatomic) NSArray *profiles;

+ (FNProvisioningProfilesManager *)sharedManager;
- (void)reloadProfiles;

@end
