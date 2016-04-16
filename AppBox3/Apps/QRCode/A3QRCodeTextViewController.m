//
//  A3QRCodeTextViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeTextViewController.h"
#import "UIViewController+A3Addition.h"

@interface A3QRCodeTextViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation A3QRCodeTextViewController {
	BOOL _viewWillAppearDidRun;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = NSLocalizedString(@"Text", @"Text");
	
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(shareButtonAction:)];
	self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	if (!_viewWillAppearDidRun) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDQRCode
								keywords:@[@"Low Price", @"Shopping", @"Marketing"]
								  gender:kGADGenderUnknown
								  adSize:IS_IPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextView *)textView {
	if (!_textView) {
		_textView = [UITextView new];
		_textView.font = [UIFont systemFontOfSize:17];
		_textView.editable = NO;
		[self.view addSubview:_textView];

		UIView *superview = self.view;
		[_textView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left).with.offset(10);
			make.top.equalTo(superview.top);
			make.right.equalTo(superview.right).with.offset(-10);
			make.bottom.equalTo(superview.bottom);
		}];
	}
	return _textView;
}

- (void)setText:(NSString *)text {
	_text = [text copy];
	self.textView.text = text;
}

#pragma mark - AdMob

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view addSubview:bannerView];
	
	UIView *superview = self.view;
	[bannerView remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom);
		make.height.equalTo(@(bannerView.bounds.size.height));
	}];
	
	UIEdgeInsets contentInset = self.textView.contentInset;
	contentInset.bottom = bannerView.bounds.size.height;
	self.textView.contentInset = contentInset;
	
	[self.view layoutIfNeeded];
}

#pragma mark - ShareButtonAction

- (void)shareButtonAction:(id)sender {
	[self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender completionHandler:nil];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"QR Codes on AppBox Pro", @"QR Codes on AppBox Pro");
	}
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	return _textView.text;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(A3AppName_QRCode, nil);
}

@end
