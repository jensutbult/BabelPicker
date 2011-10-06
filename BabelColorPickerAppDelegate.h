//
//  BabelColorPickerAppDelegate.h
//  BabelColorPicker
//
//  Created by Nino on 2010-05-05.
//  Copyright 2010 Babel Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PickerPanel;

@interface BabelColorPickerAppDelegate : NSObject <NSApplicationDelegate> {
    PickerPanel *window;
}

@property (assign) IBOutlet PickerPanel *window;

@end
