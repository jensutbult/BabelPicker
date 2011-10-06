//
//  Screensnap.h
//
//  Created by Ben Haller on 6 Aug 2005.
//
//  This code is hereby released into the public domain.  Do with it as you wish.
//  Thanks to Ryan Bates for much of this code; it is published with his permission.
//

#import <AppKit/AppKit.h>


@interface ScreenSnap : NSObject

+ (NSBitmapImageRep *)bitmapImageRepForScreenRect:(NSRect)cocoaRect;

@end