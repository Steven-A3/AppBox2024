//
//  A3AbbreviationCopiedViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationCopiedViewController.h"
#import "A3AbbreviationCopiedTransitionDelegate.h"

extern NSString *const A3AbbreviationKeyAbbreviation;

@interface A3AbbreviationCopiedViewController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) A3AbbreviationCopiedTransitionDelegate *customTransitionDelegate;

@end

@implementation A3AbbreviationCopiedViewController

+ (A3AbbreviationCopiedViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Abbreviation" bundle:nil];
	A3AbbreviationCopiedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = [viewController customTransitionDelegate];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	_titleLabel.text = _titleString;
}

- (A3AbbreviationCopiedTransitionDelegate *)customTransitionDelegate {
	if (!_customTransitionDelegate) {
		_customTransitionDelegate = [A3AbbreviationCopiedTransitionDelegate new];
	}
	return _customTransitionDelegate;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)gesture {
	[self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTitleString:(NSString *)titleString {
	_titleString = [titleString copy];

	_titleLabel.text = titleString;
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	[pasteboard setString:titleString];
}

@end
