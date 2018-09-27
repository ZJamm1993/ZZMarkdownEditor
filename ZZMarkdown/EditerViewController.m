//
//  EditerViewController.m
//  IE-mac
//
//  Created by dabby on 2018/9/25.
//  Copyright © 2018年 Jam. All rights reserved.
//

#import "EditerViewController.h"
#import <WebKit/WebKit.h>

@interface EditerViewController()<WKNavigationDelegate>

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign, readonly) BOOL edited;

@end

@implementation EditerViewController {
    
    __weak IBOutlet WKWebView *webView;
    __unsafe_unretained IBOutlet NSTextView *textView;
    
    NSString *originFileContent;
}

#pragma mark - file urls

- (void)setFileURL:(NSURL *)fileURL {
    _fileURL = fileURL;
    [self somethingDidChanged];
}

- (void)somethingDidChanged {
    NSWindow *win = [self.view window];
    NSURL *url = self.fileURL;
    win.title = url ? [url.absoluteString stringByRemovingPercentEncoding] : @"未命名.md";
    if (self.edited) {
        win.title = [NSString stringWithFormat:@"(已编辑)%@", win.title];
    }
}

- (void)openFileUrl:(NSURL *)url {
    self.fileURL = url;
    NSString *fileContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    self->textView.string = [fileContent copy];
    self->originFileContent = [fileContent copy];
    [self performSelector:@selector(analyseString:) withObject:fileContent afterDelay:1];
}

- (void)saveFileUrl:(NSURL *)url {
    self.fileURL = url;
    originFileContent = [textView.string copy];
    
    [originFileContent writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self somethingDidChanged];
}

- (BOOL)edited {
    return ![textView.string isEqualToString:originFileContent];
}

#pragma mark - view texts

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
}

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
    __weak EditerViewController *editerVC = self;
    NSLog(@"save URL: %@", editerVC.fileURL);
    if (editerVC.fileURL) {
        [editerVC saveFileUrl:editerVC.fileURL];
    } else {
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        savePanel.allowedFileTypes = @[@"md"];
        savePanel.allowsOtherFileTypes = NO;
        [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
            if (result == NSModalResponseOK) {
                [editerVC saveFileUrl:savePanel.URL];
            }
        }];
    }
}


@end
