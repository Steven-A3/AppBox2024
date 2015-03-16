//
//  A3RulerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 23..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import "A3RulerViewController.h"
#import "A3MarkingsView.h"

@interface A3RulerViewController () <UIScrollViewDelegate>

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

@end

@implementation A3RulerViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	_rulerScrollView.contentSize = CGSizeMake(screenBounds.size.width, _centimeterAsPoints * 30);
	_rulerScrollView.contentOffset = CGPointMake(0, _rulerScrollView.contentSize.height - screenBounds.size.height);
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

	[self layoutMarkings];
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
	} else if ([model isEqualToString:@"iPhone 6"]) {
		CGFloat pixelsInInch = 327.5;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1334.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1334.0) * pixelsInInch;
	} else if ([model isEqualToString:@"iPhone 6 Plus"]) {
		CGFloat pixelsInInch = 403.5;	// Original value = 401
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
	} else if ([model isEqualToString:@"iPad 2"] || [model isEqualToString:@"iPad 2 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 132;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
	} else if ([model isEqualToString:@"iPad (3rd generation)"]
			|| [model isEqualToString:@"iPad (3rd generation, Wi-Fi)"]
			|| [model isEqualToString:@"iPad (4th generation)"]
			|| [model isEqualToString:@"iPad (4th generation, Wi-Fi)"]
			|| [model isEqualToString:@"iPad Air"]
			|| [model isEqualToString:@"iPad Air (Wi-Fi)"]
			|| [model isEqualToString:@"iPad Air 2"]
			|| [model isEqualToString:@"iPad Air 2 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 264;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 2048.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 2048.0) * pixelsInInch;
	} else if ([model isEqualToString:@"iPad mini"] || [model isEqualToString:@"iPad mini (Wi-Fi)"]) {
		CGFloat pixelsInInch = 163;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 1024.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 1024.0) * pixelsInInch;
	} else if ([model isEqualToString:@"iPad mini with Retina display"]
			|| [model isEqualToString:@"iPad mini with Retina display (Wi-Fi)"]
			|| [model isEqualToString:@"iPad mini 3"]
			|| [model isEqualToString:@"iPad mini 3 (Wi-Fi)"]) {
		CGFloat pixelsInInch = 326;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (1024.0 / 2048.0) * pixelsInCentimeter;
		_inchAsPoints = (1024.0 / 2048.0) * pixelsInInch;
	} else {
		// Simulator
		CGFloat pixelsInInch = 401;
		CGFloat pixelsInCentimeter = pixelsInInch / 2.54;
		_centimeterAsPoints = (568.0 / 1920.0) * pixelsInCentimeter;
		_inchAsPoints = (568.0 / 1920.0) * pixelsInInch;
	}

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	_screenWidth = screenBounds.size.width;
	_screenHeight = screenBounds.size.height;
	_markingsWidth = _centimeterAsPoints;
	_numberOfCentimetersInScreen = floor(_screenHeight / _centimeterAsPoints) + 2;
	_numberOfInchesInScreen = floor(_screenHeight) / _inchAsPoints + 2;
	
	FNLOG(@"centimeter in points = %f, inch in points = %f", _centimeterAsPoints, _inchAsPoints);
}

- (void)layoutMarkings {
	FNLOG(@"%f, %f", _rulerScrollView.contentSize.height, _rulerScrollView.contentOffset.y);
	
	NSInteger centimeterStartIndex = floor((_rulerScrollView.contentSize.height - (_rulerScrollView.contentOffset.y + _screenHeight)) / _centimeterAsPoints);
	[_centimetersMarkingViews enumerateObjectsUsingBlock:^(A3MarkingsView *markingsView, NSUInteger idx, BOOL *stop) {
		markingsView.frame = CGRectMake(_screenWidth - _centimeterAsPoints, _rulerScrollView.contentSize.height - (idx + centimeterStartIndex) * _centimeterAsPoints - _centimeterAsPoints + 1, _markingsWidth, _centimeterAsPoints);
		FNLOGRECT(markingsView.frame);
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
}

@end
