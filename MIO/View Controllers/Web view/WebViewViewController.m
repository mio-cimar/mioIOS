//
//  WebViewViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/9/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "WebViewViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewViewController () <WKUIDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) NSString *viewControllerTitle;
@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsAirPlayForMediaPlayback = YES;
    configuration.requiresUserActionForMediaPlayback = YES;
    self.webView = [[WKWebView alloc] initWithFrame:self.webViewContainer.frame configuration:configuration];
    self.webView.UIDelegate = self;
    [self.webViewContainer addSubview: self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.webView.topAnchor constraintEqualToAnchor:self.webViewContainer.topAnchor] setActive:YES];
    [[self.webView.bottomAnchor constraintEqualToAnchor:self.webViewContainer.bottomAnchor] setActive:YES];
    [[self.webView.leadingAnchor constraintEqualToAnchor:self.webViewContainer.leadingAnchor] setActive:YES];
    [[self.webView.trailingAnchor constraintEqualToAnchor:self.webViewContainer.trailingAnchor] setActive:YES];
    NSURL *url = [NSURL URLWithString:self.webURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    if(_viewControllerTitle != nil && [_viewControllerTitle isEqualToString:@""] == false) {
        _titleLabel.text = _viewControllerTitle;
    } else {
        [_titleLabel removeFromSuperview];
    }
}
@end
