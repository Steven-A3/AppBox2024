//
//  A3BasicWebViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BasicWebViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "A3ActivitySafari.h"
#import "A3UIDevice.h"

@interface A3BasicWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) UIWebView * webView;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@end

@implementation A3BasicWebViewController
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    //[self makeBackButtonEmptyArrow];
    [self makeBackButtonEmptyArrow];
    self.title = @"Information";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    
    // WebView & Progress
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.delegate = self;
    _webView.delegate = _progressProxy;
    _webView.scalesPageToFit =  YES; // 100% 이상의 스케일에 대하여, http://stackoverflow.com/questions/16418645/uiwebview-pinch-zoom-not-working-beyond-a-certain-limit
    
    [self.view addSubview:_webView];
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    
    // 페이지 로드
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [_webView loadRequest:request];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _webView.frame = self.view.frame;
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareAction
{
    NSArray *items = [NSArray arrayWithObjects:_url, nil];
    NSArray *activities = @[[[A3ActivitySafari alloc] init]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                     applicationActivities:activities];
    
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:activityController];
        self.popoverVC.delegate = self;
		[self.popoverVC presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                               animated:YES];
	}
}

#pragma mark - WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    FNLOG(@"request : %@", _url);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    FNLOG(@"webViewDidStartLoad : %@", _url);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     FNLOG(@"webViewDidFinishLoad : %@", _url);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    FNLOG(@"%@", error);
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    //self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
