//
//  NSTextView+SoftWrap.h
//  SSH Logwatch
//
//  Created by Christian Mittendorf on 26/09/14.
//  Copyright (c) 2014 Christian Mittendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (SoftWrap)

- (void)setWrapsText:(BOOL)wraps;

@end
