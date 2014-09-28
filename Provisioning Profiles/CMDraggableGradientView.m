//
//  PVGradientView.m
//  Pixvent
//
//  Created by Christian Mittendorf on 31.08.12.
//  Copyright (c) 2012 Christian Mittendorf. All rights reserved.
//

#import "CMDraggableGradientView.h"

#define START_COLOR_GRAY	[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]
#define END_COLOR_GRAY		[NSColor colorWithCalibratedWhite:0.80 alpha:1.0]
#define BORDER_COLOR		[NSColor colorWithCalibratedWhite:0.69 alpha:1.0]
#define BORDER_WIDTH		1.0

@implementation CMDraggableGradientView

- (void)awakeFromNib {
    [[self window] setMovableByWindowBackground:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor lightGrayColor] set];
    NSRectFill(self.bounds);

    // Draw gradient background.
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:START_COLOR_GRAY
                                                         endingColor:END_COLOR_GRAY];
	[gradient drawInRect:[self bounds] angle:90.0];
	
	// Draw border.
	NSRect lineRect = [self bounds];
    lineRect.origin.y += lineRect.size.height - BORDER_WIDTH;
	lineRect.size.height = BORDER_WIDTH;
	[BORDER_COLOR set];
	NSRectFill(lineRect);
}

- (BOOL)mouseDownCanMoveWindow {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

@end
