//
//  A3ImageCropperViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ImageCropperViewController.h"
#import "common.h"
#import "UIView+Screenshot.h"

@interface A3ImageCropperViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation A3ImageCropperViewController

- (BOOL)usesFullScreenInLandscape {
	return YES;
}

- (instancetype)initWithImage:(UIImage *)image withHudView:(UIView *)hudView {
	self = [super init];
	if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
		_scrollView = [UIScrollView new];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.frame = self.view.bounds;
		_scrollView.delegate = self;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.maximumZoomScale = 2.0;

		_imageView = [[UIImageView alloc] initWithImage:image];

		_scrollView.contentSize = _imageView.frame.size;
		_scrollView.minimumZoomScale = MAX(_scrollView.frame.size.width / _imageView.frame.size.width, _scrollView.frame.size.height / _imageView.frame.size.height);
		_scrollView.zoomScale = _scrollView.minimumZoomScale;

		[_scrollView addSubview:_imageView];

		[self.view addSubview:_scrollView];

        if (hudView) {
            hudView.userInteractionEnabled = NO;
            [self.view addSubview:hudView];
        }
    }
	return self;
}

- (void)cancelCropping {
	[_delegate imageCropperDidCancel:self];
}

- (void)finishCropping {
//	float zoomScale = 1.0 / [_scrollView zoomScale];
//
//	CGRect rect;
//	rect.origin.x = [_scrollView contentOffset].x * zoomScale;
//	rect.origin.y = [_scrollView contentOffset].y * zoomScale;
//	rect.size.width = [_scrollView bounds].size.width * zoomScale;
//	rect.size.height = [_scrollView bounds].size.height * zoomScale;
//
//	CGImageRef cr = CGImageCreateWithImageInRect([[_imageView image] CGImage], rect);
//
//	UIImage *cropped = [UIImage imageWithCGImage:cr];
//
//	CGImageRelease(cr);
    UIImage *cropped = [self.view imageByRenderingView];
    FNLOG(@"%f, %f", cropped.size.width, cropped.size.height);

	[_delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.title = NSLocalizedString(@"Move and Scale", @"Move and Scale");

    [self setValuePrefersStatusBarHidden:YES];
    [self setNeedsStatusBarAppearanceUpdate];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCropping)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishCropping)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
