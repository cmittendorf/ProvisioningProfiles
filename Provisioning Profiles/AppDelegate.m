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
#import "NSDictionary+JSON.h"
#import "NSTask+SimpleCommand.h"


@interface AppDelegate () <NSTableViewDelegate, CMProvisioningProfilesManagerDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSTextField *summaryLabel;
@property (assign) IBOutlet NSArrayController *profilesController;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton *reloadProfilesButton;

@property (nonatomic) CMProvisioningProfilesManager *provisioningProfilesManager;
@property (strong) QLPreviewPanel *previewPanel;

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

- (IBAction)quicklookSelectedProfile:(id)sender {
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
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


#pragma mark - Quick Look panel support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    self.previewPanel = panel;
    self.previewPanel.delegate = self;
    self.previewPanel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
    self.previewPanel = nil;
}

#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    return [[self.profilesController selectedObjects] firstObject];
}

#pragma mark - QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    // redirect all key down events to the table view
    if ([event type] == NSKeyDown) {
        [self.tableView keyDown:event];
        return YES;
    }
    return NO;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item {
    NSInteger index = [[self.profilesController arrangedObjects] indexOfObject:item];
    if (index == NSNotFound) {
        return NSZeroRect;
    }
    
    NSRect rowRect = [self.tableView rectOfRow:index];
    NSRect visibleRect = [self.tableView visibleRect];
    
    if (!NSIntersectsRect(visibleRect, rowRect)) {
        return NSZeroRect;
    }

    NSRect rect = [self.tableView convertRect:rowRect toView:nil];
    return [self.window convertRectToScreen:rect];
}

@end
