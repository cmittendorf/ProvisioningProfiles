//
//  PPProvisioningProfilesManager.h
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMProvisioningProfilesManager;

@protocol CMProvisioningProfilesManagerDelegate <NSObject>
- (void)startUpdatingProfiles:(CMProvisioningProfilesManager *)provisioningProfilesManager;
- (void)workingOnProfile:(NSUInteger)currentProfil ofTotal:(NSUInteger)totalProfiles;
- (void)profilesUpdateComplete:(CMProvisioningProfilesManager *)provisioningProfilesManager;
@end

@interface CMProvisioningProfilesManager : NSObject

@property (assign) id<CMProvisioningProfilesManagerDelegate> delegate;
@property (nonatomic) NSArray *profiles;

+ (CMProvisioningProfilesManager *)sharedManager;
- (void)reloadProfiles;

@end
