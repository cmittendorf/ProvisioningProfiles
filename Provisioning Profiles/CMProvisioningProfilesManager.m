//
//  PPProvisioningProfilesManager.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import "CMProvisioningProfilesManager.h"
#import "CMProvisioningProfile.h"

NSString * const kCMProvisioningProfilesPath = @"kCMProvisioningProfilesPath";

@interface CMProvisioningProfilesManager ()
@end

@implementation CMProvisioningProfilesManager

+ (CMProvisioningProfilesManager *)sharedManager {
    static CMProvisioningProfilesManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMProvisioningProfilesManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{kCMProvisioningProfilesPath : @"~/Library/MobileDevice/Provisioning Profiles/"}];
        self.profiles = @[];
    }
    return self;
}

- (void)reloadProfiles {
    [self.delegate startUpdatingProfiles:self];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *path = [[[NSUserDefaults standardUserDefaults] objectForKey:kCMProvisioningProfilesPath] stringByExpandingTildeInPath];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pathExtension == 'mobileprovision' || self.pathExtension == 'provisionprofile'"];
        NSArray *files = [[fm contentsOfDirectoryAtPath:path error:nil] filteredArrayUsingPredicate:predicate];
        NSUInteger total = [files count];
        
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:total];

        // I tried to run this block concurrently, but that does make your system run amok
        // due to the shell commands executed, which do not like to be run simultanously.
        [files enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate workingOnProfile:idx ofTotal:total];
            });
            
            NSString *profilePath = [path stringByAppendingPathComponent:filename];
            CMProvisioningProfile *profile = [CMProvisioningProfile provisioningProfilesWithPath:profilePath];
            
            [array addObject:profile];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self willChangeValueForKey:@"profiles"];
            self.profiles = array;
            [self didChangeValueForKey:@"profiles"];

            [self.delegate profilesUpdateComplete:self];
        });
    });
}

@end
