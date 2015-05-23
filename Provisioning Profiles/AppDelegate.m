//
//  AppDelegate.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import "AppDelegate.h"
#import "CMProvisioningProfilesManager.h"
#import "CMProvisioningProfile.h"
#import "NSTextView+SoftWrap.h"


@interface AppDelegate () <NSTableViewDelegate, CMProvisioningProfilesManagerDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTextField *summaryLabel;
@property (assign) IBOutlet NSArrayController *profilesController;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton *reloadProfilesButton;

@property (nonatomic) CMProvisioningProfilesManager *provisioningProfilesManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.textView setWrapsText:NO];

    // use the new yosemite title hidden feature
    if ([self.window respondsToSelector:@selector(setTitleVisibility:)]) {
        [self.window setTitleVisibility:NSWindowTitleHidden];
    }
    
    self.provisioningProfilesManager = [CMProvisioningProfilesManager sharedManager];
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
    self.textView.font = [NSFont fontWithName:@"Menlo" size:12];
    CMProvisioningProfile *profile = [[self.profilesController selectedObjects] firstObject];
    self.textView.string = [profile.dict asJSONString];
}

- (IBAction)showSelectedProfileInFinder:(id)sender {
    CMProvisioningProfile *profile = [[self.profilesController selectedObjects] firstObject];
    NSString *path = [profile valueForKey:@"path"];
    [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
}

- (IBAction)moveSelectedProfileToTrash:(id)sender {
    CMProvisioningProfile *profile = [[self.profilesController selectedObjects] firstObject];
    NSURL *url = [NSURL fileURLWithPath:[profile valueForKey:@"path"]];
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

    if (disabled) {
        self.progressIndicator.minValue = 0;
        self.progressIndicator.maxValue = 0;
        [self.window beginSheet:self.progressWindow completionHandler:nil];
    } else {
        [self.window endSheet:self.progressWindow];
    }

    [self.reloadProfilesButton setEnabled:!disabled];
}

#pragma mark - FNProvisioningProfilesManagerDelegate

- (void)startUpdatingProfiles:(CMProvisioningProfilesManager *)provisioningProfilesManager {
    [self updateUIStatusDisabled:YES];
}

- (void)workingOnProfile:(NSUInteger)currentProfil ofTotal:(NSUInteger)totalProfiles {
    self.progressIndicator.maxValue = totalProfiles;
    self.progressIndicator.doubleValue = currentProfil;
}

- (void)profilesUpdateComplete:(CMProvisioningProfilesManager *)provisioningProfilesManager {
    [self updateUIStatusDisabled:NO];
}

@end
