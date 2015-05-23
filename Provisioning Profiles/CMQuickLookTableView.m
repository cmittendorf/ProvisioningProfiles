//
//  CMQuickLookTableView.m
//  Provisioning Profiles
//
//  Created by Christian Mittendorf on 23/05/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

#import "CMQuickLookTableView.h"
#import "AppDelegate.h"

@implementation CMQuickLookTableView

- (void)keyDown:(NSEvent *)theEvent {
    NSString *key = [theEvent charactersIgnoringModifiers];
    if ([key isEqual:@" "]) {
        [[NSApp delegate] quicklookSelectedProfile:self];
    } else {
        [super keyDown:theEvent];
    }
}

@end
