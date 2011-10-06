//
//  PickerView.h
//  BabelPicker
//
//  Created by Nino on 2010-05-05.
//  Copyright 2010 Babel Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum ColorMode {
	ColorModeRGB = 0, 
	ColorModeHEX, 
	ColorModeUIColor, 
	ColorModeNSColor
} ColorMode;

typedef enum PreviewMode {
	PreviewModeColor = 0,
	PreviewModePixels
} PreviewMode;

struct pixel {
    unsigned char r, g, b, a;
};

@interface PickerView : NSView {
	NSImage *backgroundImage;
	NSImage *capturedImage;
	NSColor *pickedColor;
	ColorMode colorMode;
	PreviewMode previewMode;
}
@property (assign) NSImage *capturedImage;
@property (assign) NSColor *pickedColor;
@property (readwrite) PreviewMode previewMode;

- (IBAction)setMode:(id)sender;
- (IBAction)changePreviewMode:(id)sender;

- (void)createScreenShot;
- (void)togglePreviewMode;
- (void)copyColorToPasteboardFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
