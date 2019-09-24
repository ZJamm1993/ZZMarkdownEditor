//
//  AppDelegate.m
//  IE-mac
//
//  Created by dabby on 2018/9/25.
//  Copyright © 2018年 Jam. All rights reserved.
//

#import "AppDelegate.h"
#import "EditorViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    [self newDocument:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    NSURL *first = urls.firstObject;
//    if (!first) {
//        return;
//    }
//    NSArray *windows = application.windows;
//    for (NSWindow *win in windows) {
//        if (win.) {
//            statements
//        }
//        EditorViewController *edvc = (id)win.contentViewController;
//        if ([edvc isKindOfClass:EditorViewController.class]) {
//            if ([edvc.fileURL.absoluteString isEqualToString:first.absoluteString]) {
//                return;
//            }
//        }
//    }
    NSWindowController *EditorWC = [EditorViewController defaultEditorWindowController];
    [(EditorViewController *)(EditorWC.contentViewController) openFileUrl:first];
    [EditorWC showWindow:nil];
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
            NSError *error;
            [NSString stringWithContentsOfURL:first encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
                return;
            }
            NSWindowController *EditorWC = [EditorViewController defaultEditorWindowController];
            [(EditorViewController *)(EditorWC.contentViewController) openFileUrl:first];
            [EditorWC showWindow:nil];
        }
    }];
}

- (void)newDocument:(id)sender {
    NSWindowController *EditorWC = [EditorViewController defaultEditorWindowController];
    [EditorWC showWindow:nil];
}

@end
