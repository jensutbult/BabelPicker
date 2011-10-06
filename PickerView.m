//
//  PickerView.m
//  BabelPicker
//
//  Created by Nino on 2010-05-05.
//  Copyright 2010 Babel Studios. All rights reserved.
//

#import "PickerView.h"
#import "PickerPanel.h"

#define kCaptureSize 6

@implementation PickerView

@synthesize pickedColor, capturedImage;
@dynamic previewMode;

- (void)awakeFromNib 
{
	NSString *imageName = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"];
	backgroundImage = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	// TODO: Save state
	colorMode = ColorModeUIColor;
	
	[[self window] setInitialFirstResponder:self];
	[[self window] makeFirstResponder:self];
}

- (PreviewMode)previewMode { 
    return previewMode;
}

- (void)setPreviewMode:(PreviewMode)newMode 
{	
	[[self window] setInitialFirstResponder:self];
	[[self window] makeFirstResponder:self];
	
	[self createScreenShot];
	
	previewMode = newMode;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect 
{
	if (previewMode == PreviewModePixels) {
		// Create the path and add the shapes
		NSBezierPath* clipPath = [NSBezierPath bezierPath];
		
		CGSize imageSize = CGSizeMake(70, 70);
		
		NSRect fromRect = NSMakeRect(self.window.frame.origin.x + self.window.frame.size.width/2 - (kCaptureSize / 2), 
									 self.window.frame.origin.y - (kCaptureSize / 2) + 3, kCaptureSize, kCaptureSize);
		
		NSRect imageRect = NSMakeRect((rect.size.width/2)-(imageSize.width/2), 
									  ((rect.size.height)/2)-(imageSize.height/2), imageSize.width, imageSize.height);
		
		[clipPath appendBezierPathWithOvalInRect:NSMakeRect(12, 21, 59, 59)];
		[clipPath addClip];
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort]; 
		CGContextSetInterpolationQuality(context, kCGInterpolationNone);
		[capturedImage drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0];
		[clipPath removeAllPoints];
		[clipPath appendBezierPathWithRect:rect];
		[clipPath setClip];
	} else {
		[self.pickedColor set];
		NSBezierPath* oval = [NSBezierPath bezierPath];
		[oval appendBezierPathWithOvalInRect:NSMakeRect(12, 21, 59, 59)];
		[oval fill];
	}
	
    [backgroundImage drawInRect:self.bounds fromRect:self.bounds operation:NSCompositeSourceOver fraction:1.0];
	
}

-(void)getPixel 
{
	CGFloat screenHeight = [NSScreen mainScreen].frame.size.height;
	CGRect grabRect = CGRectMake(self.window.frame.origin.x + self.window.frame.size.width / 2 - (kCaptureSize / 2), 
								 screenHeight - self.window.frame.origin.y - (kCaptureSize / 2) - 3, kCaptureSize, kCaptureSize);
    
    // Just the center pixel
	CGRect pixelRect = CGRectInset(grabRect, (grabRect.size.width/2) - .5, (grabRect.size.height/2) - .5);
	
	// Grab the pixel
	CGImageRef pixelImage = CGWindowListCreateImage(pixelRect, kCGWindowListOptionOnScreenBelowWindow, 
													[self.window windowNumber], kCGWindowImageDefault);
	
	// Get color from center of image
	struct pixel* pixels = (struct pixel*) calloc(1, sizeof(struct pixel));
	if (pixels != nil) {
		// Create a new bitmap
		CGContextRef context = CGBitmapContextCreate((void*) pixels, 1, 1, 8, 4,
													 CGImageGetColorSpace(pixelImage),
													 kCGImageAlphaPremultipliedLast);
		if (context != NULL) {
			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 1, 1), pixelImage);
			// Set the color
			CGFloat red     = (CGFloat)pixels->r;
			CGFloat green   = (CGFloat)pixels->g;
			CGFloat blue    = (CGFloat)pixels->b;
			self.pickedColor = [NSColor colorWithDeviceRed:red / 255 green:green / 255 blue:blue / 255 alpha:1];
			
			[self copyColorToPasteboardFromRed:red green:green blue:blue];
			
			CGContextRelease(context);
		}
		//free(pixels);
	}
	CGImageRelease(pixelImage);
}

- (void)copyColorToPasteboardFromRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue 
{
	NSString *colorString;
	
	switch (colorMode) {
		case ColorModeRGB:
			colorString = [NSString stringWithFormat:@"%d, %d, %d", (int)red, (int)green, (int)blue];
			break;
		case ColorModeHEX:
			colorString = [NSString stringWithFormat:@"#%02X%02X%02X", (int)red, (int)green, (int)blue];
			break;
		case ColorModeUIColor:
			colorString = [NSString stringWithFormat:@"[UIColor colorWithRed:%f green:%f blue:%f alpha:1.0]", red/255, green/255, blue/255];
			break;
		case ColorModeNSColor:
			colorString = [NSString stringWithFormat:@"[NSColor colorWithRed:%f green:%f blue:%f alpha:1.0]", red/255, green/255, blue/255];
			break;
	}
    
	// Copy to clipboard
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pb declareTypes:types owner:self];
	[pb setString: colorString forType:NSStringPboardType];
}

- (IBAction)setMode:(NSMenuItem*)sender
{
	colorMode = sender.tag;
	[self getPixel];
}

- (IBAction)changePreviewMode:(NSMenuItem*)sender
{
	self.previewMode = sender.tag;
}

- (void)togglePreviewMode 
{
	if (self.previewMode == PreviewModeColor) {
		self.previewMode = PreviewModePixels;
	} else {
		self.previewMode = PreviewModeColor;
	}
}

- (void)createScreenShot 
{
	CGRect screenRect = NSRectToCGRect([NSScreen mainScreen].frame);

	// Grab the image
	CGImageRef windowImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenBelowWindow, 
													 [self.window windowNumber], kCGWindowImageDefault);
	
	// Create a bitmap rep from the image
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
	
    // Create an NSImage and add the bitmap rep to it
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:bitmapRep];
	[bitmapRep release];
    
	// Set the output view to the new NSImage.
	self.capturedImage = image;
	[image release];
	
	CGImageRelease(windowImage);
}


#pragma - Mouse handling

- (void)mouseUp:(NSEvent *)theEvent 
{
	if ([theEvent clickCount] == 1) {
		[self togglePreviewMode];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
    // Get the center pixel
	[self getPixel];
	[self setNeedsDisplay:YES];
}


#pragma mark - Keyboard handling

-(void)keyDown:(NSEvent*)event 
{
    // The user can move the picker with the arrow keys
    switch([event keyCode]) {
        case 126: // Up arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x, [self window].frame.origin.y + 1)];
			break;
        case 125: // down arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x, [self window].frame.origin.y - 1)];
			break;
        case 124: // Right arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x + 1, [self window].frame.origin.y)];
			break;
        case 123: // Left arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x - 1, [self window].frame.origin.y)];
			break;
        default:
			// Let through the rest of the keys to the default handler
			[super keyDown:event];
            
            // Don't get pixels if we did not move
            return;
			break;
    }
	[self getPixel];
	[self setNeedsDisplay:YES];
}


#pragma mark - NSMenuValidation Protocol methods

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem 
{
	if([anItem action] == @selector(setMode:)){
		if ([anItem tag] == colorMode)
			[(NSMenuItem*)anItem setState:NSOnState];
		else [(NSMenuItem*)anItem setState:NSOffState];
	}
	else if([anItem action] == @selector(changePreviewMode:)){
		if ([anItem tag] == previewMode)
			[(NSMenuItem*)anItem setState:NSOnState];
		else [(NSMenuItem*)anItem setState:NSOffState];
	}
	return YES;
}

@end
