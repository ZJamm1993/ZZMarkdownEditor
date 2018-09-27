//
//  AppDelegate.m
//  IE-mac
//
//  Created by dabby on 2018/9/25.
//  Copyright © 2018年 Jam. All rights reserved.
//

#import "AppDelegate.h"
#import "EditerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - menu action

- (void)openDocument:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canCreateDirectories = YES;
    panel.canChooseDirectories = NO;
    panel.canChooseFiles = YES;
    panel.allowsMultipleSelection = NO;
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSURL *first = panel.URLs.firstObject;
            NSLog(@"%@", first);
            NSWindowController *editerWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialController];
            [(EditerViewController *)(editerWC.contentViewController) openFileUrl:first];
            [editerWC showWindow:nil];
        }
    }];
}

- (void)newDocument:(id)sender {
    NSWindowController *editerWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialController];
    [editerWC showWindow:nil];
}

@end
