//
//  A3NavigationController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3NavigationController.h"
#import "A3UIDevice.h"

@interface A3NavigationController ()

@end

@implementation A3NavigationController

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

	[self setupBorderLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CALayer *)borderLayer {
	if (!_borderLayer) {
		_borderLayer = [CALayer layer];
		[self.view.layer addSublayer:_borderLayer];
		_borderLayer.borderWidth = IS_RETINA ? 0.5 : 1.0;
		_borderLayer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
	}
	return _borderLayer;
}

- (void)setupBorderLayer {
	CGFloat inset = IS_RETINA ? -0.5 : -1.0;
	self.borderLayer.frame = CGRectInset(self.view.bounds, inset, inset);
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	[self setupBorderLayer];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

	_borderLayer.borderColor = [UIColor clearColor].CGColor;

	[coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {

	} completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        self->_borderLayer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
	}];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	_borderLayer.borderColor = [UIColor clearColor].CGColor;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	_borderLayer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
}

@end
