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
@property (nonatomic, strong) UIView *redLineGlassView;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) UILabel *centimeterLabel;
@property (nonatomic, strong) UILabel *inchLabel;
@property (assign) CGFloat resetPosition;
@property (nonatomic, strong) UIButton *advanceButton;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *appsButton;
@property (assign) CGFloat redLineWidth;
@property (assign) BOOL needSnapToInteger;
@property (assign) BOOL resetRedLinePosition;
@property (nonatomic, strong) UIImageView *fingerDragView;
@property (nonatomic, strong) UIPanGestureRecognizer *fingerDragViewGestureRecognizer;
@property (nonatomic, strong) UIImageView *rulerDragView;

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

	self.automaticallyAdjustsScrollViewInsets = NO;
	
	UIImage *image = [[UIImage alloc] init];
	[self.navigationController.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES];

	self.view.backgroundColor = [UIColor whiteColor];
	
	[self setupBasicMeasureForInterfaceOrientation:IS_PORTRAIT];
	[self setupSubviews];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerStateChanged) name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
}

- (void)mainMenuDidHide {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)drawerStateChanged {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3DrawerStateChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		[self removeObserver];
	}
}

- (void)prepareClose {
	[self removeObserver];
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

- (void)setupBasicMeasureForInterfaceOrientation:(BOOL)toPortrait {
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
		_redLineWidth = 0.5;
		if ([model isEqualToString:@"iPhone 4"] || [model isEqualToString:@"iPhone 4s"]) {
			_resetPosition = 6.0;
		} else {
			_resetPosition = 8.0;
		}
	} else if ([model isEqualToString:@"iPhone 6"]) {
		CGFloat pixelsInInch = 327.5;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1334.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1334.0) * pixelsInInch;
		_resetPosition = 9.5;
		_redLineWidth = 0.5;
	} else if ([model isEqualToString:@"iPhone 6 Plus"]) {
		CGFloat pixelsInInch = 403.5;	// Original value = 401
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
		_resetPosition = 11.0;
		_redLineWidth = 0.5;
	} else if ([model isEqualToString:@"iPad 2"] || [model isEqualToString:@"iPad 2 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 132.7;	// Announced PPI: 132
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
		_resetPosition = 18.0;
		_redLineWidth = 1.0;
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
		_resetPosition = 18.0;
		_redLineWidth = 0.5;
	} else if ([model isEqualToString:@"iPad mini"] || [model isEqualToString:@"iPad mini (Wi-Fi)"]) {
		CGFloat pixelsInInch = 163;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
		_resetPosition = 14.0;
		_redLineWidth = 1.0;
	} else if ([model isEqualToString:@"iPad mini with Retina display"]
			|| [model isEqualToString:@"iPad mini with Retina display (Wi-Fi)"]
			|| [model isEqualToString:@"iPad mini 3"]
			|| [model isEqualToString:@"iPad mini 3 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 326;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 2048.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 2048.0) * pixelsInInch;
		_resetPosition = 14.0;
		_redLineWidth = 0.5;
	} else {
		// Simulator
//		CGFloat pixelsInInch = 401;
//		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
//		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
//		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
//		_resetPosition = 10.0;
//		_redLineWidth = 0.5;
		// iPhone 6
		CGFloat pixelsInInch = 327.5;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1334.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1334.0) * pixelsInInch;
		_resetPosition = 9.5;
		_redLineWidth = 0.5;
	}

	CGRect screenBounds = [[UIScreen mainScreen] bounds];

	if ((IS_PORTRAIT && toPortrait) || (IS_LANDSCAPE && !toPortrait)) {
		_screenWidth = screenBounds.size.width;
		_screenHeight = screenBounds.size.height;
		
	} else {
		_screenWidth = screenBounds.size.height;
		_screenHeight = screenBounds.size.width;
	}
	if (toPortrait) {
		_numberOfCentimetersInScreen = floor(_screenHeight / _centimeterAsPoints) + 2;
		_numberOfInchesInScreen = floor(_screenHeight) / _inchAsPoints + 2;
	} else {
		_numberOfCentimetersInScreen = floor(_screenWidth / _centimeterAsPoints) + 2;
		_numberOfInchesInScreen = floor(_screenWidth) / _inchAsPoints + 2;
	}
	_markingsWidth = _centimeterAsPoints;

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
	[self setupScrollViewContentSizeToInterfaceOrientation:IS_PORTRAIT];
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

		[_inchLabels addObject:markLabel];
	}

	_redLineView = [UIView new];
	_redLineView.backgroundColor = [UIColor redColor];
	[self.view addSubview:_redLineView];
	[self resetRedLinePositionForInterfaceOrientation:IS_PORTRAIT];

	_redLineGlassView = [UIView new];
	_redLineGlassView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:128.0/255.0 blue:1.0/255.0 alpha:0.3];
	_redLineGlassView.layer.borderWidth = 1.0;
	_redLineGlassView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
	[self.view addSubview:_redLineGlassView];

	_centimeterLabel = [UILabel new];
	_centimeterLabel.font = [UIFont systemFontOfSize:18.0];
	_centimeterLabel.textAlignment = NSTextAlignmentRight;
	_centimeterLabel.textColor = [UIColor blackColor];
	[_redLineView addSubview:_centimeterLabel];

	_inchLabel = [UILabel new];
	_inchLabel.font = [UIFont systemFontOfSize:18.0];
	_inchLabel.textAlignment = NSTextAlignmentRight;
	_inchLabel.textColor = [UIColor blackColor];
	[_redLineView addSubview:_inchLabel];

	[self updateLabelsForInterfaceOrientation:IS_PORTRAIT];

	_fingerDragView = [UIImageView new];
	if (IS_IOS7) {
		UIImage *image = [[UIImage imageNamed:@"finger_drag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_fingerDragView.image = image;
	} else {
		_fingerDragView.image = [UIImage imageNamed:@"finger_drag"];
	}
	[self.view addSubview:_fingerDragView];

	_fingerDragViewGestureRecognizer = [UIPanGestureRecognizer new];
	[_fingerDragViewGestureRecognizer addTarget:self action:@selector(handleDrag:)];
	[_redLineGlassView addGestureRecognizer:_fingerDragViewGestureRecognizer];

	_rulerDragView = [UIImageView new];
	if (IS_IOS7) {
		UIImage *image = [[UIImage imageNamed:@"horizontal_drag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_rulerDragView.image = image;
	} else {
		_rulerDragView.image = [UIImage imageNamed:@"horizontal_drag"];
	}

	[_rulerScrollView addSubview:_rulerDragView];
	[self layoutRulerDragViewToInterfaceOrientation:IS_PORTRAIT];

	[self addButtons];

	[self layoutMarkingsToInterfaceOrientation:IS_PORTRAIT];
}

- (void)setupScrollViewContentSizeToInterfaceOrientation:(BOOL)toPortrait {
	if (toPortrait) {
		_rulerScrollView.contentSize = CGSizeMake(_screenWidth, [self rulerSize]);
	} else {
		_rulerScrollView.contentSize = CGSizeMake([self rulerSize], _screenHeight);
	}
}

- (CGFloat)rulerSize {
	return _centimeterAsPoints * 100;
}

- (CGFloat)hiddenSpace {
	if (IS_PORTRAIT) {
		return ([self rulerSize] - _screenHeight) - _rulerScrollView.contentOffset.y;
	} else {
		return _rulerScrollView.contentOffset.x;
	}
}

- (void)setHiddenSpace:(CGFloat)hiddenSpace interfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		_rulerScrollView.contentOffset = CGPointMake(0, [self rulerSize] - _screenHeight - hiddenSpace);
	} else {
		_rulerScrollView.contentOffset = CGPointMake(hiddenSpace, 0);
	}
}

- (void)moveRedLineToCentimeter:(double)centimeter interfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		CGFloat y;
//		y = _screenHeight - centimeter * _centimeterAsPoints - [self hiddenSpace];
		y = _rulerScrollView.contentSize.height - centimeter * _centimeterAsPoints - _rulerScrollView.contentOffset.y + 0.5;
		_redLineView.frame = CGRectMake(0, y, _screenWidth, _redLineWidth);
		_fingerDragView.frame = CGRectMake(_screenWidth * 0.6, _redLineView.frame.origin.y - 21.0, 42.0, 42.0);
	} else {
		CGFloat x = centimeter * _centimeterAsPoints - _rulerScrollView.contentOffset.x - 1.0;
		_redLineView.frame = CGRectMake(x, 0, _redLineWidth, _screenHeight);
		_fingerDragView.frame = CGRectMake(_redLineView.frame.origin.x - 21.0, _screenHeight * 0.6, 42.0, 42.0);
	}
}

- (void)resetRedLinePositionForInterfaceOrientation:(BOOL)isPortrait {
	// moveRedLineToCentimeter 와 거의 유사하지만 portrait 일 때 hiddenSpace (scrollView.contentOffset)을 고려하지 않는 점이 다르다.
	// 초기화할때 scrollView 의 contentOffset 을 변경하는데, animation 이 함께 일어나는 경우, offset 이 정확하지 않아 초기화 위치를 얻을 수가 없어
	// 별도로 고려하지 않는 멤버를 추가했다. 물론 원래의 멤버에 옵션을 주는 방법도 있었지만, 복잡도를 낮추기 위해서 중복을 감수했다.
	if (isPortrait) {
		CGFloat y;
//		y = _screenHeight - _resetPosition * _centimeterAsPoints;
		y = _rulerScrollView.contentSize.height - _resetPosition * _centimeterAsPoints - _rulerScrollView.contentOffset.y + 0.5;
//		NSString *deviceModel = [A3UIDevice platformString];
//		if ([deviceModel isEqualToString:@"iPad 2"] || [deviceModel isEqualToString:@"iPad 2 (Wi-Fi)"]) {
//			y -= 0.5;
//		}
		_redLineView.frame = CGRectMake(0, y, _screenWidth, _redLineWidth);
		FNLOGRECT(_redLineView.frame);
	} else {
		CGFloat x = _resetPosition * _centimeterAsPoints - 1.0;
		_redLineView.frame = CGRectMake(x, 0, _redLineWidth, _screenHeight);
	}
	[self updateLabelsForInterfaceOrientation:isPortrait];
}

- (CGFloat)currentCentimeterForInterfaceOrientation:(BOOL)isPortrait {
	if (isPortrait) {
		return (_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight) + (_screenHeight - _redLineView.frame.origin.y) + 0.5) / _centimeterAsPoints;
	} else {
 		return (_rulerScrollView.contentOffset.x + _redLineView.frame.origin.x + 1.0) / _centimeterAsPoints;
	}
}

- (void)handleDrag:(UIPanGestureRecognizer *)gestureRecognizer {
	CGPoint location = [gestureRecognizer locationInView:self.view];

	if (IS_PORTRAIT) {
		_redLineView.frame = CGRectMake(0, location.y, _screenWidth, _redLineWidth);
	} else {
		_redLineView.frame = CGRectMake(location.x, 0, _redLineWidth, _screenHeight);
	}

	[self updateLabelsForInterfaceOrientation:IS_PORTRAIT];
}

- (void)updateLabelsForInterfaceOrientation:(BOOL)isPortrait {
	CGFloat centimeter = [self currentCentimeterForInterfaceOrientation:isPortrait];
	_centimeterLabel.text = [NSString stringWithFormat:@"%@ cm",
					[_numberFormatter stringFromNumber:@(centimeter)]];
	double inch = centimeter / 2.54;
	double fraction = inch - floor(inch);
	NSString *inchFractionString = [self fractionForInches:fraction];
	if ([inchFractionString length]) {
		inchFractionString = [NSString stringWithFormat:@"(%@)", inchFractionString];
	}
	_inchLabel.text = [NSString stringWithFormat:@"%@%@ %@",
					[_numberFormatter stringFromNumber:@(inch)],
					inchFractionString,
					NSLocalizedStringFromTable(@"inches", @"unit", nil)];

	if (isPortrait) {
		_centimeterLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		_inchLabel.transform = CGAffineTransformMakeRotation(-M_PI / 2);
		_fingerDragView.transform = CGAffineTransformMakeRotation(-M_PI / 2);

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
		_fingerDragView.frame = CGRectMake(_screenWidth * 0.6, _redLineView.frame.origin.y - 21.0, 42.0, 42.0);

		[_redLineGlassView remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(@-1);
			make.centerY.equalTo(_redLineView.centerY);
			make.width.equalTo(@(_screenWidth + 2.0));
			make.height.equalTo(@(_centimeterAsPoints));
		}];
	} else {
		_centimeterLabel.transform = CGAffineTransformIdentity;
		_inchLabel.transform = CGAffineTransformIdentity;
		_fingerDragView.transform = CGAffineTransformIdentity;

		if (_redLineView.frame.origin.x <= _screenWidth / 2.0) {
			CGFloat x = 5;
			_centimeterLabel.frame = CGRectMake(x, _screenHeight / 2 - 25, 240, 24);
			_centimeterLabel.textAlignment = NSTextAlignmentLeft;

			_inchLabel.frame = CGRectMake(x, _screenHeight / 2, 240, 24);
			_inchLabel.textAlignment = NSTextAlignmentLeft;
		} else {
			CGFloat x = -240 - 5;
			_centimeterLabel.frame = CGRectMake(x, _screenHeight / 2 - 25, 240, 24);
			_centimeterLabel.textAlignment = NSTextAlignmentRight;

			_inchLabel.frame = CGRectMake(x, _screenHeight / 2, 240, 24);
			_inchLabel.textAlignment = NSTextAlignmentRight;
		}
		_fingerDragView.frame = CGRectMake(_redLineView.frame.origin.x - 21.0, _screenHeight * 0.6, 42, 42);

		[_redLineGlassView remakeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(_redLineView.centerX);
			make.top.equalTo(@(-1));
			make.width.equalTo(@(_centimeterAsPoints));
			make.height.equalTo(@(_screenHeight + 2.0));
		}];
	}
}

- (void)layoutMarkingsToInterfaceOrientation:(BOOL)toPortrait {
	NSInteger centimeterStartIndex;
	if (toPortrait) {
		centimeterStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _centimeterAsPoints);
	} else {
		centimeterStartIndex = floor(_rulerScrollView.contentOffset.x / _centimeterAsPoints);
	}

//	FNLOG(@"Centimeter Start Index = %ld", (long)centimeterStartIndex);
	
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		if (toPortrait) {
			markingsView.frame = CGRectMake(_screenWidth - _centimeterAsPoints, _rulerScrollView.contentSize.height - (idx + centimeterStartIndex) * _centimeterAsPoints - _centimeterAsPoints + 2, _markingsWidth, _centimeterAsPoints);
		} else {
			markingsView.frame = CGRectMake(_centimeterAsPoints * (idx + centimeterStartIndex) - 2, _screenHeight - _markingsWidth, _centimeterAsPoints, _markingsWidth);
		}
#ifdef DEBUG2
		if (((idx + centimeterStartIndex) % (NSInteger)_resetPosition) == 0) {
			FNLOG(@"******************* %ld", (long)idx + centimeterStartIndex);
			FNLOGRECT(markingsView.frame);
			FNLOGRECT(_redLineView.frame);
			FNLOG(@"*******************");
		}
#endif
	}];

	[_centimeterLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			[label remakeConstraints:^(MASConstraintMaker *make) {
				make.top.equalTo(label.superview.top);
				make.left.equalTo(label.superview.left);
			}];
		} else {
			[label remakeConstraints:^(MASConstraintMaker *make) {
				make.top.equalTo(label.superview.top);
				make.right.equalTo(label.superview.right);
			}];
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + centimeterStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];

	NSInteger inchStartIndex;
	if (toPortrait) {
		inchStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _inchAsPoints);
	} else {
		inchStartIndex = floor(_rulerScrollView.contentOffset.x / _inchAsPoints);
	}
	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.drawPortrait = toPortrait;
		if (toPortrait) {
			markingsView.frame = CGRectMake(0, _rulerScrollView.contentSize.height - (idx + inchStartIndex) * _inchAsPoints - _inchAsPoints + 2, _markingsWidth, _inchAsPoints);
		} else {
			markingsView.frame = CGRectMake((idx + inchStartIndex) * _inchAsPoints - 2, 0, _inchAsPoints, _markingsWidth);
		}
	}];

	[_inchLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
		if (toPortrait) {
			[label remakeConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(label.superview.right);
				make.top.equalTo(label.superview.top);
			}];
		} else {
			[label remakeConstraints:^(MASConstraintMaker *make) {
				make.right.equalTo(label.superview.right);
				make.bottom.equalTo(label.superview.bottom);
			}];
		}
		label.text = [NSString stringWithFormat:@"%ld", (long)(idx + inchStartIndex + 1)];
		label.transform = !toPortrait ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(-M_PI / 2);
	}];
}

#pragma mark -- UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self layoutMarkingsToInterfaceOrientation:IS_PORTRAIT];
	[self updateLabelsForInterfaceOrientation:IS_PORTRAIT];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	BOOL isPortrait = IS_PORTRAIT;
	if (_needSnapToInteger) {
		_needSnapToInteger = NO;
		CGFloat currentCentimeter = [self currentCentimeterForInterfaceOrientation:isPortrait];
		currentCentimeter = roundf(currentCentimeter * 10.0) / 10.0;
		FNLOG(@"%f", currentCentimeter);
		[self moveRedLineToCentimeter:currentCentimeter interfaceOrientation:isPortrait];
		[self updateLabelsForInterfaceOrientation:isPortrait];
	} else if (_resetRedLinePosition) {
		_resetRedLinePosition = NO;
		[self resetRedLinePositionForInterfaceOrientation:isPortrait];
		[self updateLabelsForInterfaceOrientation:isPortrait];
	}
}

- (NSString *)fractionForInches:(double)fraction {
	NSArray *results = @[@"", @"1/16", @"1/8", @"3/16", @"1/4", @"5/16", @"3/8", @"7/16", @"1/2", @"9/16", @"5/8", @"11/16", @"3/4", @"13/16", @"7/8", @"15/16"];

	NSInteger idx = floor(fraction * 100 / (100.0 / 16.0) );
	return results[idx];
}

- (void)addButtons {
	// Apps, Accumulate, Reset
	_advanceButton = [self buttonWithTitle:NSLocalizedString(@"Advance", @"Advance") topOffset:_screenHeight * 0.8];
	[_advanceButton addTarget:self action:@selector(advanceButtonAction) forControlEvents:UIControlEventTouchUpInside];
	
	_resetButton = [self buttonWithTitle:NSLocalizedString(@"Reset", @"Reset") topOffset:_screenHeight * 0.55];
	[_resetButton addTarget:self action:@selector(resetButtonAction) forControlEvents:UIControlEventTouchUpInside];

	_appsButton = [self buttonWithTitle:NSLocalizedString(@"Apps", @"Apps") topOffset:_screenHeight * 0.3];
	[_appsButton addTarget:self action:@selector(appsButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	[self layoutButtonsToInterfaceOrientation:IS_PORTRAIT];
}

- (void)layoutRulerDragViewToInterfaceOrientation:(BOOL)toPortrait {
	if (toPortrait) {
		_rulerDragView.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
		CGFloat positionStartFrom;
		if (IS_IPHONE) {
			positionStartFrom = _rulerScrollView.contentSize.height - _screenHeight * 0.3 - 64.0;
		} else {
			positionStartFrom = _rulerScrollView.contentSize.height - _screenHeight / 2.0 - 64.0;
		}
		_rulerDragView.frame = CGRectMake(_screenWidth * 0.7 - 64.0, positionStartFrom, 128, 128);
	} else {
		// iPhone은 Landscape를 지원하지 않는다.
		_rulerDragView.transform = CGAffineTransformIdentity;
		CGFloat positionFromStart;
		positionFromStart = _screenWidth / 2.0 - 64.0;
		_rulerDragView.frame = CGRectMake(positionFromStart, _screenHeight * 0.7 - 64.0, 128, 128);
	}
}

- (void)layoutButtonsToInterfaceOrientation:(BOOL)toPortrait {
	CGFloat halfButtonHeight = 30.0/2.0;
	if (IS_IPHONE) {
		[self setButton:_advanceButton constraintAt:_screenHeight * 0.75 - halfButtonHeight];
		[self setButton:_resetButton constraintAt:_screenHeight * 0.5 - halfButtonHeight];
		[self setButton:_appsButton constraintAt:_screenHeight * 0.25 - halfButtonHeight];

		[self applyTransformToButtons:CGAffineTransformMakeRotation(-M_PI / 2)];
	} else {	// IS_IPAD
		if (toPortrait) {
			CGFloat leftOffset = 100.0;
			[_advanceButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(leftOffset);
				make.top.equalTo(self.view.top).with.offset(_screenHeight * 0.75 - halfButtonHeight);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];
			[_resetButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(leftOffset);
				make.top.equalTo(self.view.top).with.offset(_screenHeight * 0.5 - halfButtonHeight);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];
			[_appsButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(leftOffset);
				make.top.equalTo(self.view.top).with.offset(_screenHeight * 0.25 - halfButtonHeight);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];

			[self applyTransformToButtons:CGAffineTransformMakeRotation(-M_PI / 2)];
		} else {
			CGFloat topOffset = 100.0 + 45.0;
			CGFloat halfButtonWidth = 120.0/2.0;
			[_advanceButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(_screenWidth * 0.25 - halfButtonWidth);
				make.top.equalTo(self.view.top).with.offset(topOffset);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];
			[_resetButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(_screenWidth * 0.5 - halfButtonWidth);
				make.top.equalTo(self.view.top).with.offset(topOffset);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];
			[_appsButton remakeConstraints:^(MASConstraintMaker *make) {
				make.left.equalTo(self.view.left).with.offset(_screenWidth * 0.75 - halfButtonWidth);
				make.top.equalTo(self.view.top).with.offset(topOffset);
				make.width.equalTo(@120);
				make.height.equalTo(@30);
			}];

			[self applyTransformToButtons:CGAffineTransformIdentity];
		}
	}
}

- (void)applyTransformToButtons:(CGAffineTransform)transform {
	_advanceButton.transform = transform;
	_resetButton.transform = transform;
	_appsButton.transform = transform;
}

- (void)setButton:(UIButton *)button constraintAt:(CGFloat)position {
	if (IS_IOS7) {
		button.frame = CGRectMake(40.0, position, 120, 30);
	} else {
		[button remakeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left).with.offset(40.0);
			make.top.equalTo(self.view.top).with.offset(position);
			make.width.equalTo(@120);
			make.height.equalTo(@30);
		}];
	}
}

- (void)resetButtonAction {
	BOOL isPortrait = IS_PORTRAIT;
	if (isPortrait) {
		[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentSize.height - _screenHeight) animated:YES];
		if (_rulerScrollView.contentOffset.y == _rulerScrollView.contentSize.height - _screenHeight) {
			[self resetRedLinePositionForInterfaceOrientation:isPortrait];
			[self updateLabelsForInterfaceOrientation:isPortrait];
		} else {
			_resetRedLinePosition = YES;
		}
	} else {
		[_rulerScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
		if (_rulerScrollView.contentOffset.x == 0) {
			// 이미 animation 이 필요없는 경우에는 animation 끝난후에 didEndScrollingAnimation 이 호출되지 않는다.
			[self resetRedLinePositionForInterfaceOrientation:isPortrait];
			[self updateLabelsForInterfaceOrientation:isPortrait];
		} else {
			// animation 필요한 경우에는 animation 이 종료된 후에야 contentOffset 의 값이 변하므로 그 이후에 처리한다.
			_resetRedLinePosition = YES;
		}
	}
}

- (void)advanceButtonAction {
	_needSnapToInteger = YES;
	if (IS_PORTRAIT) {
		[_rulerScrollView setContentOffset:CGPointMake(0, _rulerScrollView.contentOffset.y - (_screenHeight - _redLineView.frame.origin.y)) animated:YES];
	} else {
		[_rulerScrollView setContentOffset:CGPointMake(_rulerScrollView.contentOffset.x + _redLineView.frame.origin.x, 0) animated:YES];
	}
}

- (UIButton *)buttonWithTitle:(NSString *)title topOffset:(CGFloat)offset {
	UIButton *button = [UIButton new];
	button.layer.borderWidth = 0.5;
	button.layer.cornerRadius = 15;
	button.layer.borderColor = [[A3AppDelegate instance] themeColor].CGColor;
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[[A3AppDelegate instance] themeColor] forState:UIControlStateNormal];

	[self.view addSubview:button];
	
	return button;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView setAnimationsEnabled:NO];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	CGFloat hiddenSpace = [self hiddenSpace];
	// currentCentimeter는 현재 오리엔테이션 기준으로 측정해야 함
	CGFloat currentCentimeter = [self currentCentimeterForInterfaceOrientation:IS_PORTRAIT];

	BOOL toPortrait = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
	FNLOG(@"hidden space = %f, currentCentimeter = %f, %ld", hiddenSpace, currentCentimeter, (long)IS_PORTRAIT);

	[self setupBasicMeasureForInterfaceOrientation:toPortrait];

	[self setupScrollViewContentSizeToInterfaceOrientation:toPortrait];
	[self setHiddenSpace:hiddenSpace interfaceOrientation:toPortrait];

	[self layoutMarkingsToInterfaceOrientation:toPortrait];
	[self layoutRulerDragViewToInterfaceOrientation:toPortrait];
	[self layoutButtonsToInterfaceOrientation:toPortrait];

	[_inchesMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *view, NSUInteger idx, BOOL *stop) {
		view.drawPortrait = toPortrait;
		[view setNeedsDisplay];
	}];
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *view, NSUInteger idx, BOOL *stop) {
		view.drawPortrait = toPortrait;
		[view setNeedsDisplay];
	}];

	[self moveRedLineToCentimeter:currentCentimeter interfaceOrientation:toPortrait];
	[self updateLabelsForInterfaceOrientation:toPortrait];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[UIView setAnimationsEnabled:YES];
}

@end
