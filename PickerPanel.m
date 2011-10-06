//
//  PickerPanel.m
//  BabelPicker
//
//  Created by Nino on 2010-05-05.
//  Copyright 2010 Babel Studios. All rights reserved.
//

#import "PickerPanel.h"


@implementation PickerPanel

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(NSUInteger)aStyle 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag
{
	NSLog(@"Panel Init");
	if(self = [super initWithContentRect:contentRect 
							   styleMask:NSBorderlessWindowMask
								 backing:NSBackingStoreBuffered 
								   defer:YES]) {
		[self setMovableByWindowBackground:YES];
		[self setBackgroundColor:[NSColor clearColor]];
		[self setLevel:NSNormalWindowLevel];
		[self setOpaque:NO];
		[self setHasShadow:NO];
	}
	return self;
}

- (BOOL) canBecomeKeyWindow { return YES; }

- (void)windowDidMove:(NSNotification *)window {
	
	NSLog(@"did move");
}

@end