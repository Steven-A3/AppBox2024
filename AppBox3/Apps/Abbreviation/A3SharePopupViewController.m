//
//  A3SharePopupViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupViewController.h"
#import "A3SharePopupTransitionDelegate.h"

extern NSString *const A3AbbreviationKeyAbbreviation;

@interface A3SharePopupViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *roundedRectView;
@property (nonatomic, strong) A3SharePopupTransitionDelegate *customTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *middleLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondLineHeightConstraint;

@end

@implementation A3SharePopupViewController

+ (A3SharePopupViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
	A3SharePopupViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = [viewController customTransitionDelegate];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	/*
	if (IS_IOS_GREATER_THAN_7) {
		UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
		UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		blurView.alpha = 0.95;
		[self.view insertSubview:blurView atIndex:0];
		
		[blurView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.view);
		}];
		_effectView = blurView;
	} else {
		UIView *darkView = [UIView new];
		darkView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
		[self.view insertSubview:darkView atIndex:0];

		[darkView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.view);
		}];
		_effectView = darkView;
	}
	 */

	CGFloat scale = [[UIScreen mainScreen] scale];
	_middleLineHeightConstraint.constant = 0.7;
	_secondLineHeightConstraint.constant = 0.7;
	_roundedRectView.layer.cornerRadius = 10;
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	_titleLabel.text = _contents[A3AbbreviationKeyAbbreviation];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureHandler {
	if ([_delegate respondsToSelector:@selector(sharePopupViewControllerWillDismiss:)]) {
		[_delegate sharePopupViewControllerWillDismiss:self];
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3SharePopupTransitionDelegate *)customTransitionDelegate {
	if (!_customTransitionDelegate) {
		_customTransitionDelegate = [A3SharePopupTransitionDelegate new];
	}
	return _customTransitionDelegate;
}

- (void)setPresentationIsInteractive:(BOOL)presentationIsInteractive {
	_presentationIsInteractive = presentationIsInteractive;
	_customTransitionDelegate.presentationIsInteractive = presentationIsInteractive;
}

- (void)setInteractiveTransitionProgress:(CGFloat)interactiveTransitionProgress {
	_interactiveTransitionProgress = interactiveTransitionProgress;
	_customTransitionDelegate.currentTransitionProgress = interactiveTransitionProgress;
}

- (void)completeCurrentInteractiveTransition {
	[_customTransitionDelegate completeCurrentInteractiveTransition];
}

- (void)cancelCurrentInteractiveTransition {
	[_customTransitionDelegate cancelCurrentInteractiveTransition];
}

- (IBAction)shareButtonAction:(id)sender {
	
}

- (IBAction)favoriteButtonAction:(id)sender {
	
}

- (void)setContents:(NSDictionary *)contents {
	_contents = [contents copy];
	_titleLabel.text = _contents[A3AbbreviationKeyAbbreviation];
}

@end
