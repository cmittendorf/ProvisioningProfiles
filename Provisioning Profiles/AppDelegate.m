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


@interface AppDelegate () <NSTableViewDelegate, FNProvisioningProfilesManagerDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTextField *summaryLabel;
@property (assign) IBOutlet NSArrayController *profilesController;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton *reloadProfilesButton;

@property (nonatomic) FNProvisioningProfilesManager *provisioningProfilesManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.textView setWrapsText:NO];

    // use the new yosemite title hidden feature
    if ([self.window respondsToSelector:@selector(setTitleVisibility:)]) {
        [self.window setTitleVisibility:NSWindowTitleHidden];
    }
    
    self.provisioningProfilesManager = [FNProvisioningProfilesManager sharedManager];
    self.provisioningProfilesManager.delegate = self;
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
    self.textView.string = profile ? [profile description] : @"";
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

- (IBAction)updateColumnVisibility:(id)sender {
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    menuItem.state = menuItem.state == NSOnState ? NSOffState : NSOnState;
    for (NSTableColumn *column in [self.tableView tableColumns]) {
        if ([column.title isEqualToString:menuItem.title]) {
            column.hidden = (menuItem.state != NSOnState);
            break;
        }
    }
}

- (IBAction)reloadProfiles:(id)sender {
    [self.provisioningProfilesManager reloadProfiles];
}

- (void)updateUIStatusDisabled:(BOOL)disabled {
    [self.summaryLabel setHidden:disabled];
    [self.progressIndicator setHidden:!disabled];
    [self.reloadProfilesButton setEnabled:!disabled];
}

#pragma mark - FNProvisioningProfilesManagerDelegate

- (void)startUpdatingProfiles:(FNProvisioningProfilesManager *)provisioningProfilesManager {
    [self updateUIStatusDisabled:YES];
}

- (void)workingOnProfile:(NSUInteger)currentProfil ofTotal:(NSUInteger)totalProfiles {
    self.progressIndicator.minValue = 0;
    self.progressIndicator.maxValue = totalProfiles;
    [self.progressIndicator setDoubleValue:currentProfil];
}

- (void)profilesUpdateComplete:(FNProvisioningProfilesManager *)provisioningProfilesManager {
    [self updateUIStatusDisabled:NO];
}

@end
