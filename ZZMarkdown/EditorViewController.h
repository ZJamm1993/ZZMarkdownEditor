//
//  EditorViewController.h
//  IE-mac
//
//  Created by dabby on 2018/9/25.
//  Copyright © 2018年 Jam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EditorViewController : NSViewController

+ (NSWindowController *)defaultEditorWindowController;

- (void)openFileUrl:(NSURL *)url;

@end

