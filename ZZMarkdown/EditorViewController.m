//
//  EditorViewController.m
//  IE-mac
//
//  Created by dabby on 2018/9/25.
//  Copyright © 2018年 Jam. All rights reserved.
//

#import "EditorViewController.h"
#import <WebKit/WebKit.h>

@interface EditorViewController()<WKNavigationDelegate, NSWindowDelegate>

@property (nonatomic, assign, readonly) BOOL edited;

@end

@implementation EditorViewController {
    
    __weak IBOutlet WKWebView *webView;
    __unsafe_unretained IBOutlet NSTextView *textView;
    
    NSString *lastFileContent;
}

+ (NSWindowController *)defaultEditorWindowController {
    return [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"EditorWindowController"];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self.className);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textView.automaticQuoteSubstitutionEnabled = NO;
    textView.automaticDashSubstitutionEnabled = NO;
    textView.font = [NSFont systemFontOfSize:15];
    
    [self loadHtmlString];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [self somethingDidChanged];
    self.view.window.delegate =self;
}

#pragma mark - file urls

- (void)setFileURL:(NSURL *)fileURL {
    _fileURL = fileURL;
    [self somethingDidChanged];
}

- (void)openFileUrl:(NSURL *)url {
    self.fileURL = url;
    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    textView.string = [fileContent copy];
    lastFileContent = [fileContent copy];
    [self performSelector:@selector(analyseString:) withObject:fileContent afterDelay:1];
}

- (void)saveFileUrl:(NSURL *)url {
    if (self.fileURL == nil) {
        self.fileURL = url;
    }
    lastFileContent = [textView.string copy];
    
    [lastFileContent writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self somethingDidChanged];
}

#pragma mark - edit state

- (void)somethingDidChanged {
    NSWindow *win = [self.view window];
    NSURL *url = self.fileURL;
    win.title = url ? [url.lastPathComponent stringByRemovingPercentEncoding] : @"Untitled.md";
    if (self.edited) {
        win.title = [NSString stringWithFormat:@"* %@", win.title];
    }
}

- (BOOL)edited {
    if (textView.string.length == 0 && lastFileContent.length == 0) {
        return NO;
    }
    return ![textView.string isEqualToString:lastFileContent];
}

#pragma mark - view texts

- (void)loadHtmlString {
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [currentPath stringByAppendingPathComponent:@"Contents/Resources/test.html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    [self analyseString:textView.string.copy];
}

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == textView) {
        NSString *string = [textView.string copy];
        [self somethingDidChanged];
        [self analyseString:string];
    }
}

- (void)analyseString:(NSString *)string {
    NSString *base64String = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *js = [NSString stringWithFormat:@"convert('%@')", base64String];
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

#pragma mark - Window delegate

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (self.edited) {
        __weak typeof(self) weakself = self;
        // please save first
        [self showSavePanelCompletionHandler:^(NSModalResponse result, NSURL *url) {
            if (result == NSModalResponseCancel) {
                
            } else {
                if (result == NSModalResponseOK) {
                    [weakself saveFileUrl:url];
                }
                [weakself.view.window close];
            }
        }];
        return NO;
    }
    return YES;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = navigationAction.request.URL.absoluteString;
    if ([urlString containsString:[[NSBundle mainBundle] bundlePath]]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
        [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
    }
}

#pragma mark - document saving

- (void)saveDocument:(id)sender {
    if (self.fileURL) {
        [self saveFileUrl:self.fileURL];
    } else {
        [self saveDocumentAs:sender];
    }
}

- (void)saveDocumentAs:(id)sender {
//    BOOL isAs = [NSStringFromSelector([(NSMenuItem *)sender action]) isEqualToString:@"saveDocumentAs:"] ;
    
    __weak EditorViewController *EditorVC = self;
    
    [self showSavePanelCompletionHandler:^(NSModalResponse result, NSURL *url) {
        if (result == NSModalResponseOK) {
            [EditorVC saveFileUrl:url];
        }
    }];
}

- (void)showSavePanelCompletionHandler:(void (^)(NSModalResponse result, NSURL *url))handler {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.allowedFileTypes = @[@"md"];
    savePanel.allowsOtherFileTypes = NO;
    if (self.fileURL) {
        NSMutableArray *pathComponents = [[self.fileURL pathComponents] mutableCopy];;
        [pathComponents removeLastObject];
        savePanel.directoryURL = [NSURL fileURLWithPathComponents:pathComponents];
        savePanel.nameFieldStringValue = [self.fileURL lastPathComponent];
    }
    __weak typeof(savePanel) weakPanel = savePanel;
    [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        NSLog(@"save: %@", weakPanel.URL);
        if (handler) {
            handler(result, weakPanel.URL);
        }
    }];
}

@end
