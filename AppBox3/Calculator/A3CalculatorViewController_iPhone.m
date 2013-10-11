//
//  A3CalculatorViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorViewController_iPhone.h"
#import "HTCopyableLabel.h"
#import "A3CalcKeyboardView_iPhone.h"
#import "FXPageControl.h"
#import "common.h"
#import "A3Expression.h"
#import "UIViewController+A3Addition.h"

@interface A3CalculatorViewController_iPhone () <UIScrollViewDelegate, A3CalcKeyboardViewDelegate>

@property (nonatomic, strong) HTCopyableLabel *expressionLabel;
@property (nonatomic, strong) HTCopyableLabel *evaluatedResultLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FXPageControl *pageControl;
@property (nonatomic, strong) A3CalcKeyboardView_iPhone *keyboardView;
@property (nonatomic, strong) A3Expression *expression;

@end

@implementation A3CalculatorViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.expression = [A3Expression new];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
	self.title = @"Calculator";
	[self leftBarButtonAppsButton];
	[self rightButtonMoreButton];

	[self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_scrollView.contentOffset = CGPointMake(320, 0);
}

- (void)setupSubviews {
	self.view.backgroundColor = [UIColor whiteColor];

	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];

	[self.view addSubview:self.scrollView];
	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.height.equalTo(@324);
		make.bottom.equalTo(self.view.bottom).with.offset(-20);
	}];
	_keyboardView = [[A3CalcKeyboardView_iPhone alloc] initWithFrame:CGRectMake(0,0,640,324)];
	_keyboardView.delegate = self;
	[_scrollView addSubview:_keyboardView];

	[self.view addSubview:self.pageControl];
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom);
		make.height.equalTo(@20);
	}];

	[self.view addSubview:self.evaluatedResultLabel];
	[_evaluatedResultLabel makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(15);
		make.right.equalTo(self.view.right).with.offset(-15);
		make.bottom.equalTo(_scrollView.top);
		make.height.equalTo(screenBounds.size.height == 480 ? @70 : @116);
	}];

	if (screenBounds.size.height > 480) {
		[self.view addSubview:self.expressionLabel];
		[_expressionLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(15);
			make.right.equalTo(self.view.right).with.offset(-15);
			make.height.equalTo(@44);
			make.top.equalTo(self.view.top).with.offset(64);
		}];
	}

	[self.view layoutIfNeeded];

}

- (HTCopyableLabel *)expressionLabel {
	if (!_expressionLabel) {
		_expressionLabel = [HTCopyableLabel new];
		_expressionLabel.backgroundColor = [UIColor whiteColor];
		_expressionLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-M3" size:18];
		_expressionLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
		_expressionLabel.textAlignment = NSTextAlignmentRight;
		_expressionLabel.text = @"24.97 x 8.75 =";
	}
	return _expressionLabel;
}

- (HTCopyableLabel *)evaluatedResultLabel {
	if (!_evaluatedResultLabel) {
		CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
		_evaluatedResultLabel = [HTCopyableLabel new];
		_evaluatedResultLabel.backgroundColor = [UIColor whiteColor];
		_evaluatedResultLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:screenBounds.size.height == 480 ? 60 : 83];
		_evaluatedResultLabel.textColor = [UIColor blackColor];
		_evaluatedResultLabel.textAlignment = NSTextAlignmentRight;
		_evaluatedResultLabel.text = @"218.48";
		_evaluatedResultLabel.adjustsFontSizeToFitWidth = YES;
		_evaluatedResultLabel.minimumScaleFactor = 0.2;
	}
	return _evaluatedResultLabel;
}

- (UIScrollView *)scrollView {
	if (!_scrollView) {
		_scrollView = [UIScrollView new];
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.directionalLockEnabled = YES;
        _scrollView.bounces = NO;
		_scrollView.contentSize = CGSizeMake(640, 324);
		_scrollView.delegate = self;
	}
	return _scrollView;
}

- (FXPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [[FXPageControl alloc] init];
		_pageControl.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:223.0/255.0 blue:226.0/255.0 alpha:1.0];
		_pageControl.numberOfPages = 2;
		_pageControl.dotColor = [UIColor colorWithRed:128.0 / 255.0 green:128.0 / 255.0 blue:128.0 / 255.0 alpha:1.0];
		_pageControl.selectedDotColor = [UIColor blackColor];
		_pageControl.dotSpacing = 9;
		_pageControl.currentPage = 1;
		[_pageControl addTarget:self action:@selector(pageControlValueChanged) forControlEvents:UIControlEventValueChanged];
	}
	return _pageControl;
}

- (void)pageControlValueChanged {
	[_scrollView setContentOffset:CGPointMake(_pageControl.currentPage * 320, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	_pageControl.currentPage = (NSInteger) ceil(_scrollView.contentOffset.x / 320.0);
}

#pragma mark KeyboardButton handler

- (void)keyboardButtonPressed:(NSUInteger)key {
	[self.expression keyboardInput:(A3ExpressionKind)key];
	_expressionLabel.attributedText = [self.expression mutableAttributedString];
	FNLOG(@"%@", self.expression);
}

@end
