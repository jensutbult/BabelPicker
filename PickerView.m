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

- (void)awakeFromNib {
	NSString *imageName = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"];
	backgroundImage = [[NSImage alloc] initWithContentsOfFile:imageName];
	
	[[self window] setInitialFirstResponder:self];
	[[self window] makeFirstResponder:self];
}

- (void)drawRect:(NSRect)rect {
	if (showsImage) {
		// Create the path and add the shapes
		NSBezierPath* clipPath = [NSBezierPath bezierPath];
		
		CGSize imageSize = CGSizeMake(70, 70);
		
		CGRect fromRect = CGRectMake(self.window.frame.origin.x + self.window.frame.size.width/2 - (kCaptureSize / 2), 
									 self.window.frame.origin.y - (kCaptureSize / 2) + 3, kCaptureSize, kCaptureSize);
		
		CGRect imageRect = CGRectMake((rect.size.width/2)-(imageSize.width/2), 
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

-(void)getPixel {
	CGFloat screenHeight = [NSScreen mainScreen].frame.size.height;
	CGRect grabRect = CGRectMake(self.window.frame.origin.x + self.window.frame.size.width/2 - (kCaptureSize / 2), 
								 screenHeight - self.window.frame.origin.y - (kCaptureSize / 2) - 3, kCaptureSize, kCaptureSize);
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
			CGFloat red = (CGFloat)pixels->r/255;
			CGFloat green = (CGFloat)pixels->g/255;
			CGFloat blue = (CGFloat)pixels->b/255;
			self.pickedColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1];
			
			// Copy to clipboard
			NSString *colorString = [NSString stringWithFormat:@"[UIColor colorWithRed:%f green:%f blue:%f alpha:1.0]", red, green, blue];
			NSPasteboard *pb = [NSPasteboard generalPasteboard];
			NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
			[pb declareTypes:types owner:self];
			[pb setString: colorString forType:NSStringPboardType];
			
			CGContextRelease(context);
		}
		//free(pixels);
	}
	
	CGImageRelease(pixelImage);
	
}

-(void)createScreenShot {
	CGRect screenRect = NSRectToCGRect([NSScreen mainScreen].frame);

	// Grab the image
	CGImageRef windowImage = CGWindowListCreateImage(screenRect, kCGWindowListOptionOnScreenBelowWindow, 
													 [self.window windowNumber], kCGWindowImageDefault);

	
	// Create a bitmap rep from the image...
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
	// Create an NSImage and add the bitmap rep to it...
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:bitmapRep];
	[bitmapRep release];
	// Set the output view to the new NSImage.
	//[imageView setImage:image];
	self.capturedImage = image;
	[image release];
	
	CGImageRelease(windowImage);
}

// Click
- (void)mouseUp:(NSEvent *)theEvent {
	if ([theEvent clickCount] == 1) 
	{
		[[self window] setInitialFirstResponder:self];
		[[self window] makeFirstResponder:self];

		[self createScreenShot];
		
		showsImage = !showsImage;
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[self getPixel];
	[self setNeedsDisplay:YES];
}

-(void)keyDown:(NSEvent*)event
{   
    // I added these based on the addition to your question :)
	
    switch( [event keyCode] ) {
        case 126: // up arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x, [self window].frame.origin.y + 1)];
			break;
        case 125: // down arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x, [self window].frame.origin.y - 1)];
			break;
        case 124: // right arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x + 1, [self window].frame.origin.y)];
			break;
        case 123: // left arrow
			[[self window] setFrameOrigin:NSMakePoint([self window].frame.origin.x - 1, [self window].frame.origin.y)];
			break;
        default:
			// Let through the rest of the keys to the default handler
			[super keyDown:event];
			break;
    }
	[self getPixel];
	[self setNeedsDisplay:YES];
}

@end
