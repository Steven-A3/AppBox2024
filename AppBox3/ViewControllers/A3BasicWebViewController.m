//
//  A3BasicWebViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BasicWebViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "A3ActivitySafari.h"
#import "A3AppDelegate+appearance.h"

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

	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    if (_titleString) {
        self.title = _titleString;
    }
    else {
        self.title = NSLocalizedString(@"Information", @"Information");
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];

    // WebView & Progress
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webView.delegate = self;
    _webView.delegate = _progressProxy;
    _webView.scalesPageToFit =  YES; // 100% 이상의 스케일에 대하여, http://stackoverflow.com/questions/16418645/uiwebview-pinch-zoom-not-working-beyond-a-certain-limit
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    [self.view addSubview:_webView];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [_webView loadRequest:request];
}

- (void)doneAction {
	if ([self.navigationController.viewControllers count] == 1) {
		[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	FNLOG();

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _webView.frame = self.view.frame;

	if (_showDoneButton || [self.navigationController.viewControllers count] == 1) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
	}
	if ([self isMovingToParentViewController]) {
		CGFloat progressBarHeight = 2.5f;
		CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
		CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
		_progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progressBarView.backgroundColor = [A3AppDelegate instance].themeColor;
		[self.navigationController.navigationBar addSubview:_progressView];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    self.popoverVC.delegate = nil;
    [self.popoverVC dismissPopoverAnimated:YES];

    [_progressView removeFromSuperview];
}

- (void)viewDidLayoutSubviews {
	CGFloat progressBarHeight = 2.5f;
	CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
	CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
	_progressView.frame = barFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)shareAction
{
    NSArray *items = [NSArray arrayWithObjects:_url, nil];
    NSArray *activities = @[[[A3ActivitySafari alloc] init]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                     applicationActivities:activities];
	if (IS_IPHONE) {
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
		[self.navigationController presentViewController:activityController animated:YES completion:NULL];
        
        activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        };
	} else {
		[self.navigationItem.leftBarButtonItem setEnabled:NO];
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
        activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        };

		self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:activityController];
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
//    [_progressView setProgress:0.0 animated:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Internet Connection is not avaiable" delegate:self cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
//    [alert show];
}


#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    //self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
