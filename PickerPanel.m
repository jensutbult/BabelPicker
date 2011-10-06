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

- (BOOL) canBecomeKeyWindow { 
    return YES; 
}

/*- (void)windowDidMove:(NSNotification *)window {
	NSLog(@"Window did move: %@", window);
}*/

- (IBAction)toggleWindowOnTop:(id)sender {
	if (self.level == NSNormalWindowLevel)
		self.level = NSFloatingWindowLevel;
	else
		self.level = NSNormalWindowLevel;
}


#pragma mark - NSMenuValidation Protocol methods

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
	if([anItem action] == @selector(toggleWindowOnTop:)){
		if (self.level == NSFloatingWindowLevel)
			[(NSMenuItem*)anItem setState:NSOnState];
		else [(NSMenuItem*)anItem setState:NSOffState];
	}
	return YES;
}


@end