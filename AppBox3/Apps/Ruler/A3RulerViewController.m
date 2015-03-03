//
//  A3RulerViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2015. 2. 23..
//  Copyright (c) 2015년 ALLABOUTAPPS. All rights reserved.
//

#import "A3RulerViewController.h"
#import "A3MarkingsView.h"

@interface A3RulerViewController ()

@property (nonatomic, strong) NSMutableArray *centimetersMarkingViews;
@property (nonatomic, strong) NSMutableArray *inchesMarkingViews;
@property (nonatomic, strong) UIScrollView *rulerScrollView;

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
	[_rulerScrollView setContentSize:CGSizeMake(screenBounds.size.width, screenBounds.size.height * 10)];
	[self.view addSubview:_rulerScrollView];
	[_rulerScrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	// 326 ppi in iPhone 6
	// 326 pixel / 2.54 cm = x pixel / 1 cm
	// x = 326 / 2.54 x 1
	// 1 cm = 128.34 pixel
	// pixel in screen = screenBounds.size.height *
	
//	CGFloat pixelPerCentimeter = PPI / 2.54;
//	CGFloat pixelInScreen = screenBounds.size.height * [UIScreen mainScreen].scale;
	
	
	_centimetersMarkingViews = [NSMutableArray new];
//	for (NSInteger idx; idx < )
//	A3MarkingsView *;

	_inchesMarkingViews = [NSMutableArray new];

}

@end
