//
//  A3SharePopupViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupViewController.h"

@interface A3SharePopupViewController ()

@property (nonatomic, strong) UIView *effectView;

@end

@implementation A3SharePopupViewController

+ (A3SharePopupViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
	return [storyboard instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
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

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureHandler {
	[self.view removeFromSuperview];
	[_effectView removeFromSuperview];
	_effectView = nil;
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

@end
