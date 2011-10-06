//
//  PickerView.h
//  BabelPicker
//
//  Created by Nino on 2010-05-05.
//  Copyright 2010 Babel Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BabelColorPickerAppDelegate;

struct pixel {
    unsigned char r, g, b, a;
};

@interface PickerView : NSView {
	NSImage *backgroundImage;
	NSImage *capturedImage;
	NSColor *pickedColor;
	BOOL showsImage;
}
@property (assign) NSImage *capturedImage;
@property (assign) NSColor *pickedColor;

- (void)createScreenShot;

@end
