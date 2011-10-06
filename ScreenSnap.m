//
//  Screensnap.m
//
//  Created by Ben Haller on 6 Aug 2005.
//
//  This code is hereby released into the public domain.  Do with it as you wish.
//  Thanks to Ryan Bates for much of this code; it is published with his permission.
//

// A few notes:
//
//  - This code returns an NSBitmapImageRep because that's what my app wanted; if you're happy with an
//    NSPICTImageRep, you could just return pictImageRep, or if you wanted an NSImage, return image.
//
//  - Ryan says that CopyBits has been deprecated in 10.4, so this code may stop working at some point.
//    The reason he and I wrote it was that the old Cocoa way of getting a screenshot, using
//    NSBitmapImageRep's -initWithFocusedViewRect: method in a transparent window, stopped working in
//    10.4 due to changes in the video architecture; folks at Apple say that is not likely to be fixed,
//    as they do not consider it a bug.  (Apparently the fact that it ever worked was serendipitous
//    and undocumented).  Therefore:
//
//  - If anybody has code that takes a screenshot of an arbitrary global rect, with multimonitor
//    compatibility, without using either of these methods and without reading pixels directly from
//    the video buffer (which is too hard to get right these days, and too fragile, in my opinion),
//    please contact me!  There is presumably an avenue through GL, or CoreImage, or CoreGraphics,
//    but Ryan and I don't know those APIs well enough...
//

#import "ScreenSnap.h"


Rect SSQDRectFromNSRect(NSRect cocoaRect, NSRect primaryScreenFrame)
{
	Rect rect;
	
	// Flip the "y" coordinants for QuickDraw
	cocoaRect.origin.y = primaryScreenFrame.size.height - cocoaRect.origin.y - cocoaRect.size.height;
	
	SetRect(&rect, NSMinX(cocoaRect), NSMinY(cocoaRect), NSMaxX(cocoaRect), NSMaxY(cocoaRect));
	
	return rect;
}


@implementation Screensnap

+ (NSBitmapImageRep *)bitmapImageRepForScreenRect:(NSRect)cocoaRect
{
	NSScreen *primaryScreen = [[NSScreen screens] objectAtIndex:0];
	NSRect primaryScreenFrame = [primaryScreen frame];
	NSRect bounds = NSMakeRect(0, 0, cocoaRect.size.width, cocoaRect.size.height);
	PicHandle picHandle;
	GDHandle device;
	Rect qdRect;
	NSPICTImageRep *pictImageRep;
	NSBitmapImageRep *bitmapImageRep;
	NSImage *image;
	
	// Convert NSRect to Rect
	qdRect = SSQDRectFromNSRect(cocoaRect, primaryScreenFrame);
	
	// It seems the PixMap of the main device is used for all monitors
	device = GetMainDevice();
	
#if 1
	// Capture the screen into the PicHandle.  We have to loop through all our monitors because of a bug in CopyBits().  BCH 8/6/05
	picHandle = OpenPicture(&qdRect);
	
	{
		NSArray *screens = [NSScreen screens];
		int screenCount = [screens count];
		int screenIndex;
		
		for (screenIndex = 0; screenIndex < screenCount; ++screenIndex)
		{
			NSScreen *screen = [screens objectAtIndex:screenIndex];
			NSRect screenFrame = [screen frame];
			NSRect intersectedScreenFrame = NSIntersectionRect(screenFrame, cocoaRect);
			
			if (!NSIsEmptyRect(intersectedScreenFrame))
			{
				qdRect = SSQDRectFromNSRect(intersectedScreenFrame, primaryScreenFrame);
				
				CopyBits((BitMap *)*(**device).gdPMap, (BitMap *)*(**device).gdPMap, &qdRect, &qdRect, srcCopy, 0l);
			}
		}
	}
	
	ClosePicture();
#else
	// Capture the screen into the PicHandle.  This should work, I believe, but does not; a bug has been logged on Apple.  BCH 8/6/05
	picHandle = OpenPicture(&qdRect);
	CopyBits((BitMap *)*(**device).gdPMap, (BitMap *)*(**device).gdPMap, &qdRect, &qdRect, srcCopy, 0l);
	ClosePicture();
#endif
	
	// Convert the PicHandle into an NSImage
	HLock((Handle)picHandle);
	pictImageRep = [NSPICTImageRep imageRepWithData:[NSData dataWithBytes:(*picHandle) length:GetHandleSize((Handle)picHandle)]];
	HUnlock((Handle)picHandle);
	
	// Release the PicHandle now that we're done with it
	KillPicture(picHandle);
	
	// Convert the pict image rep into a bitmap image rep
	image = [[NSImage alloc] initWithSize:bounds.size];
	[image lockFocus];
	
	[pictImageRep drawInRect:bounds];
	
	bitmapImageRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:bounds];
	
	[image unlockFocus];
	[image release];
	
	return [bitmapImageRep autorelease];
}

@end
