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

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (NSApplication.sharedApplication.windows.count == 0) {
            [self newDocument:nil];
        }
    });
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    NSURL *first = urls.firstObject;
    if (!first) {
        return;
    }
    NSArray *windows = application.windows;
    for (NSWindow *win in windows) {
        EditorViewController *edvc = (id)win.contentViewController;
        if ([edvc isKindOfClass:EditorViewController.class]) {
            if ([edvc.fileURL.absoluteString isEqualToString:first.absoluteString]) {
                return;
            }
        }
    }
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
