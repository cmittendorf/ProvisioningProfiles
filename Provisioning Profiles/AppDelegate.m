//
//  AppDelegate.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 freenet.de GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "FNProvisioningProfilesManager.h"
#import "FNProvisioningProfile.h"
#import "NSTextView+SoftWrap.h"


@interface AppDelegate () <NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSArrayController *profilesController;

@property (nonatomic) FNProvisioningProfilesManager *provisioningProfilesManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.textView setWrapsText:NO];

    self.provisioningProfilesManager = [FNProvisioningProfilesManager sharedManager];
    [self.provisioningProfilesManager reloadProfiles];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // clean up
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    self.textView.font = [NSFont fontWithName:@"Menlo" size:11];
    NSDictionary *profile = [[self.profilesController selectedObjects] firstObject];
    self.textView.string = [profile description];
}

- (IBAction)showSelectedProfileInFinder:(id)sender {
    NSDictionary *profile = [[self.profilesController selectedObjects] firstObject];
    NSString *path = profile[@"path"];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

- (IBAction)moveSelectedProfileToTrash:(id)sender {
    NSDictionary *profile = [[self.profilesController selectedObjects] firstObject];
    NSURL *url = [NSURL fileURLWithPath:profile[@"path"]];
    [[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:nil];
    [self.profilesController removeObject:profile];
}

- (IBAction)reloadProfiles:(id)sender {
    [self.provisioningProfilesManager reloadProfiles];
}

@end
