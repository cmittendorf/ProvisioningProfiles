//
//  FNProvisioningProfilesManager.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 freenet.de GmbH. All rights reserved.
//

#import "FNProvisioningProfilesManager.h"
#import "FNProvisioningProfile.h"

@interface FNProvisioningProfilesManager ()
@property (nonatomic) NSString *path;
@end

@implementation FNProvisioningProfilesManager

+ (FNProvisioningProfilesManager *)sharedManager {
    static FNProvisioningProfilesManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FNProvisioningProfilesManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.path = [@"~/Library/MobileDevice/Provisioning Profiles/" stringByExpandingTildeInPath];
        self.profiles = @[];
    }
    return self;
}

- (void)reloadProfiles {
    [self.delegate startUpdatingProfiles:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [fm contentsOfDirectoryAtPath:self.path error:nil];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *filename in files) {
            if ([[filename pathExtension] isEqualToString:@"mobileprovision"] ||
                [[filename pathExtension] isEqualToString:@"provisionprofile"]) {
                NSString *path = [self.path stringByAppendingPathComponent:filename];
                NSDictionary *profile = [FNProvisioningProfile provisioningProfilesWithPath:path];
                [array addObject:profile];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self willChangeValueForKey:@"profiles"];
            self.profiles = array;
            [self didChangeValueForKey:@"profiles"];

            [self.delegate profilesUpdateComplete:self];
        });
    });
}

@end
