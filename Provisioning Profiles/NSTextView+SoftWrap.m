//
//  NSTextView+SoftWrap.m
//  SSH Logwatch
//
//  Created by Christian Mittendorf on 31.05.12.
//  Copyright (c) 2012 Freenet AG. All rights reserved.
//

#import "NSTextView+SoftWrap.h"

@implementation NSTextView (SoftWrap)

- (void)setWrapsText:(BOOL)wraps
{
	if(wraps == NO)
    {
		NSSize bigSize = NSMakeSize(FLT_MAX, FLT_MAX);
        
		[[self enclosingScrollView] setHasHorizontalScroller:YES];
		[self setHorizontallyResizable:YES];
		[self setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        
		[[self textContainer] setContainerSize:bigSize];
		[[self textContainer] setWidthTracksTextView:NO];
	}
}

@end
