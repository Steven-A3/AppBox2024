//
//  A3RulerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 23..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import "A3RulerViewController.h"
#import "A3MarkingsView.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+A3Addition.h"

@interface A3RulerViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *centimetersMarkingViews;
@property (nonatomic, strong) NSMutableArray *centimeterLabels;
@property (nonatomic, strong) NSMutableArray *inchesMarkingViews;
@property (nonatomic, strong) NSMutableArray *inchLabels;
@property (nonatomic, strong) UIScrollView *rulerScrollView;
@property (assign) CGFloat centimeterAsPoints;
@property (assign) CGFloat inchAsPoints;
@property (assign) CGFloat screenWidth;
@property (assign) CGFloat screenHeight;
@property (assign) CGFloat markingsWidth;
@property (assign) NSInteger numberOfCentimetersInScreen;
@property (assign) NSInteger numberOfInchesInScreen;
@property (nonatomic, strong) UIView *redLineView;
@property (nonatomic, strong) UIImageView *handleView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) UILabel *centimeterLabel;
@property (nonatomic, strong) UILabel *inchLabel;
@property (assign) NSInteger resetPosition;

@end

@implementation A3RulerViewController

- (instancetype)init {
	self = [super init];
	if (self) {
		_numberFormatter = [NSNumberFormatter new];
		[_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[_numberFormatter setMinimumFractionDigits:2];
		[_numberFormatter setMaximumFractionDigits:2];
	}

	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES];

	self.view.backgroundColor = [UIColor whiteColor];
	
	[self setupBasicMeasure];
	[self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self resetButtonAction];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupBasicMeasure {

	NSString *model = [A3UIDevice platformString];

	if	(	   [model isEqualToString:@"iPhone 4"]
			|| [model isEqualToString:@"iPhone 4s"]
			|| [model isEqualToString:@"iPhone 5"]
			|| [model isEqualToString:@"iPhone 5s"]
			|| [model isEqualToString:@"iPod Touch (5th generation)"]
			)
	{
		// 326 PPI, 960 pixels, 480 points
		CGFloat pixelsInInch = 326;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (480.0 / 960.0) * pixelsInCentimeter; // or (568.0 / 1136.0) * pixelsInCentimeter
		_inchAsPoints = (480.0 / 960.0) * pixelsInInch;
		if ([model isEqualToString:@"iPhone 4"] || [model isEqualToString:@"iPhone 4s"]) {
			_resetPosition = 6;
		} else {
			_resetPosition = 8;
		}
	} else if ([model isEqualToString:@"iPhone 6"]) {
		CGFloat pixelsInInch = 327.5;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1334.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1334.0) * pixelsInInch;
		_resetPosition = 10;
	} else if ([model isEqualToString:@"iPhone 6 Plus"]) {
		CGFloat pixelsInInch = 403.5;	// Original value = 401
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
		_resetPosition = 10;
	} else if ([model isEqualToString:@"iPad 2"] || [model isEqualToString:@"iPad 2 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 132;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
		_resetPosition = 10;
	} else if ([model isEqualToString:@"iPad (3rd generation)"]
			|| [model isEqualToString:@"iPad (3rd generation, Wi-Fi)"]
			|| [model isEqualToString:@"iPad (4th generation)"]
			|| [model isEqualToString:@"iPad (4th generation, Wi-Fi)"]
			|| [model isEqualToString:@"iPad Air"]
			|| [model isEqualToString:@"iPad Air (Wi-Fi)"]
			|| [model isEqualToString:@"iPad Air 2"]
			|| [model isEqualToString:@"iPad Air 2 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 265.8;	// Original ppi = 264
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 2048.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 2048.0) * pixelsInInch;
		_resetPosition = 10;
	} else if ([model isEqualToString:@"iPad mini"] || [model isEqualToString:@"iPad mini (Wi-Fi)"]) {
		CGFloat pixelsInInch = 163;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
		_resetPosition = 10;
	} else if ([model isEqualToString:@"iPad mini with Retina display"]
			|| [model isEqualToString:@"iPad mini with Retina display (Wi-Fi)"]
			|| [model isEqualToString:@"iPad mini 3"]
			|| [model isEqualToString:@"iPad mini 3 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 326;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 2048.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 2048.0) * pixelsInInch;
		_resetPosition = 10;
	} else {
		// Simulator
		CGFloat pixelsInInch = 401;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
		_resetPosition = 10;
	}

	CGRect screenBounds = [[UIScreen mainScreen] bounds];

	_screenWidth = screenBounds.size.width;
	_screenHeight = screenBounds.size.height;
	_markingsWidth = _centimeterAsPoints;
	_numberOfCentimetersInScreen = floor(_screenHeight / _centimeterAsPoints) + 2;
	_numberOfInchesInScreen = floor(_screenHeight) / _inchAsPoints + 2;

	FNLOG(@"centimeter in points = %f, inch in points = %f", _centimeterAsPoints, _inchAsPoints);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupSubviews {
	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	_rulerScrollView = [[UIScrollView alloc] initWithFrame:screenBounds];
	_rulerScrollView.scrollsToTop = NO;
	[self setupScrollViewContentSize];
	_rulerScrollView.contentOffset = CGPointMake(0, _rulerScrollView.contentSize.height - _screenHeight);
	_rulerScrollView.delegate = self;
	_rulerScrollView.showsVerticalScrollIndicator = NO;
	_rulerScrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_rulerScrollView];

	[_rulerScrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	_centimetersMarkingViews = [NSMutableArray new];
	_centimeterLabels = [NSMutableArray new];

	for (NSInteger idx = 0; idx < _numberOfCentimetersInScreen; idx++) {
		A3MarkingsView *centimeterMarkingView = [A3MarkingsView new];
		centimeterMarkingView.markingsDirection = A3MarkingsDirectionRight;
		centimeterMarkingView.markingsType = A3MarkingsTypeCentimeters;
		[_rulerScrollView addSubview:centimeterMarkingView];
		[_centimetersMarkingViews addObject:centimeterMarkingView];

		UILabel *markLabel = [UILabel new];
		markLabel.textColor = [UIColor blackColor];
		markLabel.font = [UIFont systemFontOfSize:10.0];
		markLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		[centimeterMarkingView addSubview:markLabel];

		[markLabel makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(centimeterMarkingView.top);
			make.left.equalTo(centimeterMarkingView.left);
		}];
		[_centimeterLabels addObject:markLabel];
	}

	_inchesMarkingViews = [NSMutableArray new];
	_inchLabels = [NSMutableArray new];

	for (NSInteger idx = 0; idx < _numberOfInchesInScreen; idx++) {
		A3MarkingsView *inchMarkingView = [A3MarkingsView new];
		inchMarkingView.markingsDirection = A3MarkingsDirectionLeft;
		inchMarkingView.markingsType = A3MarkingsTypeInches;
		[_rulerScrollView addSubview:inchMarkingView];
		[_inchesMarkingViews addObject:inchMarkingView];

		UILabel *markLabel = [UILabel new];
		markLabel.textColor = [UIColor blackColor];
		markLabel.font = [UIFont systemFontOfSize:10];
		markLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		[inchMarkingView addSubview:markLabel];

		[markLabel makeConstraints:^(MASConstraintMaker *make) {
			make.right.equalTo(inchMarkingView.right);
			make.top.equalTo(inchMarkingView.top);
		}];
		[_inchLabels addObject:markLabel];
	}

	_redLineView = [UIView new];
	_redLineView.backgroundColor = [UIColor redColor];
	[self.view addSubview:_redLineView];
	[self resetRedLineViewFrame];

	_centimeterLabel = [UILabel new];
	_centimeterLabel.font = [UIFont systemFontOfSize:18.0];
	_centimeterLabel.textAlignment = NSTextAlignmentRight;
	_centimeterLabel.textColor = [UIColor blackColor];
	_centimeterLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
	_centimeterLabel.frame = CGRectMake(_screenWidth / 2 - 25, 5, 24, 240);
	[_redLineView addSubview:_centimeterLabel];

	_inchLabel = [UILabel new];
	_inchLabel.font = [UIFont systemFontOfSize:18.0];
	_inchLabel.textAlignment = NSTextAlignmentRight;
	_inchLabel.textColor = [UIColor blackColor];
	_inchLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
	_inchLabel.frame = CGRectMake(_screenWidth / 2, 5, 24, 240);
	[_redLineView addSubview:_inchLabel];

	[self updateLabels];

	_handleView = [UIImageView new];
	_handleView.userInteractionEnabled = YES;
	_handleView.image = [UIImage imageNamed:@"tape_ruler"];
	_handleView.frame = CGRectMake(_screenWidth * 0.6, _redLineView.frame.origin.y + 10.0, 50, 40);
	_handleView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
	[self.view addSubview:_handleView];

	_panGestureRecognizer = [UIPanGestureRecognizer new];
	_panGestureRecognizer.delegate = self;
	[_panGestureRecognizer addTarget:self action:@selector(handlePan:)];
	[_handleView addGestureRecognizer:_panGestureRecognizer];

	[self addButtons];

	[self layoutMarkings];
}

- (void)setupScrollViewContentSize {
	_rulerScrollView.contentSize = CGSizeMake(_screenWidth, _centimeterAsPoints * 100);
}

- (void)resetRedLineViewFrame {
	[self moveRedLineToCentimeter:_resetPosition];
}

- (void)moveRedLineToCentimeter:(double)centimeter {
	_redLineView.frame = CGRectMake(0, _screenHeight - centimeter * _centimeterAsPoints, _screenWidth, 0.5);
	_handleView.frame = CGRectMake(_handleView.frame.origin.x, _redLineView.frame.origin.y + 10.0, 40, 50);
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	CGPoint location = [gestureRecognizer locationInView:self.view];

	FNLOG(@"%f, %f", location.y, _handleView.center.y);

	_redLineView.frame = CGRectMake(0, location.y - 30.0, _screenWidth, 0.5);
	_handleView.frame = CGRectMake(_handleView.frame.origin.x, _redLineView.frame.origin.y + 10.0, 40, 50);

	[self updateLabels];
}

- (double)currentCentimeter {
	return (_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight) + (_screenHeight - _redLineView.frame.origin.y)) / _centimeterAsPoints;
}

- (void)updateLabels {
	double centimeter = [self currentCentimeter];
	_centimeterLabel.text = [NSString stringWithFormat:@"%@ cm", [_numberFormatter stringFromNumber:@(centimeter)]];
	double inch = centimeter / 2.54;
	double fraction = inch - floor(inch);
	NSString *inchFractionString = [self fractionForInches:fraction];
	if ([inchFractionString length]) {
		inchFractionString = [NSString stringWithFormat:@"(%@)", inchFractionString];
	}

	_inchLabel.text = [NSString stringWithFormat:@"%@%@ inches", [_numberFormatter stringFromNumber:@(inch)], inchFractionString];
	if (_redLineView.frame.origin.y > _screenHeight / 2.0) {
		_centimeterLabel.frame = CGRectMake(_screenWidth / 2 - 25, -5 - 240, 24, 240);
		_centimeterLabel.textAlignment = NSTextAlignmentLeft;

		_inchLabel.frame = CGRectMake(_screenWidth / 2, -5 - 240, 24, 240);
		_inchLabel.textAlignment = NSTextAlignmentLeft;
	} else {
		_centimeterLabel.frame = CGRectMake(_screenWidth / 2 - 25, 5, 24, 240);
		_centimeterLabel.textAlignment = NSTextAlignmentRight;

		_inchLabel.frame = CGRectMake(_screenWidth / 2, 5, 24, 240);
		_inchLabel.textAlignment = NSTextAlignmentRight;
	}
}

- (void)layoutMarkings {
	NSInteger centimeterStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _centimeterAsPoints);
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.frame = CGRectMake(_screenWidth - _centimeterAsPoints, _rulerScrollView.contentSize.height - (idx + centimeterStartIndex) * _centimeterAsPoints - _centimeterAsPoints + 1, _markingsWidth, _centimeterAsPoints);
		[markingsView setNeedsDisplay];
	}];

	[_centimeterLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + centimeterStartIndex + 1)];
	}];

	NSInteger inchStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _inchAsPoints);
	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.frame = CGRectMake(0, _rulerScrollView.contentSize.height - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 1, _markingsWidth, _inchAsPoints);
	}];

	[_inchLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + inchStartIndex + 1)];
	}];
}

#pragma mark -- UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self layoutMarkings];
	[self updateLabels];
}

- (NSString *)fractionForInches:(double)fraction {
	NSArray *results = @[@"", @"1/16", @"1/8", @"3/16", @"1/4", @"5/16", @"3/8", @"7/16", @"1/2", @"9/16", @"5/8", @"11/16", @"3/4", @"13/16", @"7/8", @"15/16"];

	NSInteger idx = floor(fraction * 100 / (100.0 / 16.0) );
	return results[idx];
}

- (void)addButtons {
	// Apps, Accumulate, Reset
	UIButton *accumulateButton = [self buttonWithTitle:@"Accumulate" topOffset:_screenHeight * 0.8];
	[accumulateButton addTarget:self action:@selector(accumulateButtonAction) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *resetButton = [self buttonWithTitle:@"Reset" topOffset:_screenHeight * 0.55];
	[resetButton addTarget:self action:@selector(resetButtonAction) forControlEvents:UIControlEventTouchUpInside];

	UIButton *appsButton = [self buttonWithTitle:@"Apps" topOffset:_screenHeight * 0.3];
	[appsButton addTarget:self action:@selector(appsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)resetButtonAction {
	[self resetRedLineViewFrame];
	[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentSize.height - _screenHeight) animated:YES];
	[self updateLabels];
}

- (void)accumulateButtonAction {
	[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentOffset.y - (_screenHeight - _redLineView.frame.origin.y)) animated:YES];
}

- (UIButton *)buttonWithTitle:(NSString *)title topOffset:(CGFloat)offset {
	UIButton *button = [UIButton new];
	button.layer.borderWidth = 0.5;
	button.layer.cornerRadius = 15;
	button.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[[A3AppDelegate instance] themeColor] forState:UIControlStateNormal];

	[self.view addSubview:button];
	
	[button makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left).with.offset(40.0);
		make.top.equalTo(self.view.top).with.offset(offset);
		make.width.equalTo(@120);
		make.height.equalTo(@30);
	}];
	
	button.transform = CGAffineTransformMakeRotation(-M_PI / 2);
	
	return button;
}



@end
