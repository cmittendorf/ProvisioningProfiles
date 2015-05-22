//
//  PPProvisioningProfilesManager.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import "CMProvisioningProfilesManager.h"
#import "CMProvisioningProfile.h"

@interface CMProvisioningProfilesManager ()
@property (nonatomic) NSString *path;
@property (nonatomic) dispatch_queue_t concurrent_queue;
@property (nonatomic) dispatch_queue_t background_queue;
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
        self.concurrent_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.background_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        self.path = [@"~/Library/MobileDevice/Provisioning Profiles/" stringByExpandingTildeInPath];
        self.profiles = @[];
    }
    return self;
}

- (void)reloadProfiles {
    [self.delegate startUpdatingProfiles:self];
    dispatch_async(self.background_queue, ^{
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *files = [[fm contentsOfDirectoryAtPath:self.path error:nil] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension == 'mobileprovision' || self.pathExtension == 'provisionprofile'"]];
        
        NSMutableArray *array = [NSMutableArray array];
        [files enumerateObjectsWithOptions:NSEnumerationConcurrent
                                usingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate workingOnProfile:idx ofTotal:[files count]];
            });
            
            NSString *path = [self.path stringByAppendingPathComponent:filename];
            CMProvisioningProfile *profile = [CMProvisioningProfile provisioningProfilesWithPath:path];
            
            dispatch_barrier_async(self.concurrent_queue, ^{
                [array addObject:profile];
            });
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
