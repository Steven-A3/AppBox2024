//
//  A3SharePopupViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupViewController.h"
#import "UIViewController+A3Addition.h"
#import "AbbreviationFavorite+CoreDataProperties.h"
#import "A3SharePopupPresentationController.h"

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyMeaning;

@interface A3SharePopupViewController ()
<UIActivityItemSource, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *roundedRectView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *middleLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondLineHeightConstraint;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, weak) IBOutlet UILabel *shareTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *shareImageView;
@property (nonatomic, weak) IBOutlet UILabel *favoriteTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *favoriteImageView;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;

// Custom transition
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *currentInteractionController;
@property (nonatomic, strong) A3SharePopupPresentationController *presentationController;
@property (nonatomic, assign) CGFloat currentTransitionProgress;
@property (nonatomic, assign) BOOL insertBlurViewWhileTransition;

@property (nonatomic, strong) MBProgressHUD *hudView;

@end

@implementation A3SharePopupViewController

+ (A3SharePopupViewController *)storyboardInstanceWithBlurBackground:(BOOL)insertBlurView {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([self class]) bundle:nil];
	A3SharePopupViewController *viewController = [storyboard instantiateInitialViewController];
	viewController.insertBlurViewWhileTransition = insertBlurView;
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = viewController;
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	_middleLineHeightConstraint.constant = 0.7;
	_secondLineHeightConstraint.constant = 0.7;
	_roundedRectView.layer.cornerRadius = 10;

	_shareImageView.tintColor = [[A3AppDelegate instance] themeColor];
	_favoriteImageView.tintColor = [[A3AppDelegate instance] themeColor];
	_shareTitleLabel.textColor = [[A3AppDelegate instance] themeColor];
	_favoriteTitleLabel.textColor = [[A3AppDelegate instance] themeColor];
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	_titleLabel.text = _titleString;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setupFavoriteButton];
}

- (void)setupFavoriteButton {
	if ([self contentIsFavorite]) {
		_favoriteButton.backgroundColor = [[A3AppDelegate instance] themeColor];
		_favoriteImageView.tintColor = [UIColor whiteColor];
		_favoriteTitleLabel.textColor = [UIColor whiteColor];
	} else {
		_favoriteButton.backgroundColor = [UIColor whiteColor];
		_favoriteImageView.tintColor = [[A3AppDelegate instance] themeColor];
		_favoriteTitleLabel.textColor = [[A3AppDelegate instance] themeColor];
	}
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureHandler {
	[self dismissViewController];
}

- (void)dismissViewController {
	if ([_delegate respondsToSelector:@selector(sharePopupViewControllerWillDismiss:)]) {
		[_delegate sharePopupViewControllerWillDismiss:self];
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInteractiveTransitionProgress:(CGFloat)interactiveTransitionProgress {
	_interactiveTransitionProgress = interactiveTransitionProgress;
	[_currentInteractionController updateInteractiveTransition:interactiveTransitionProgress];
}

- (void)completeCurrentInteractiveTransition {
	[_currentInteractionController finishInteractiveTransition];
}

- (void)cancelCurrentInteractiveTransition {
	[_currentInteractionController cancelInteractiveTransition];
}

#pragma mark - Share button action

- (IBAction)touchesDownShareButton:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		_shareTitleLabel.alpha = 0.2;
		_shareImageView.alpha = 0.2;
	}];
}

- (IBAction)touchesUpShareButton:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		_shareTitleLabel.alpha = 1.0;
		_shareImageView.alpha = 1.0;
	}];
}

- (IBAction)touchesDownFavoriteButton:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		_favoriteTitleLabel.alpha = 0.2;
		_favoriteImageView.alpha = 0.2;
	}];
}

- (IBAction)touchesUpFavoriteButton:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		_favoriteTitleLabel.alpha = 1.0;
		_favoriteImageView.alpha = 1.0;
	}];
}

- (IBAction)shareButtonAction:(id)sender {
	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
		[popoverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		_popoverController = popoverController;
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	if ([_dataSource respondsToSelector:@selector(placeholderForShare:)]) {
		return [_dataSource placeholderForShare:_titleString];
	}
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a information with you.", nil)
									   contents:[self stringForShare]
										   tail:NSLocalizedString(@"You can find more in the AppBox Pro.", nil)];
	}
	else {
		return [self stringForShare];
	}
}

- (NSString *)stringForShare {
	if ([_dataSource respondsToSelector:@selector(stringForShare:)]) {
		return [_dataSource stringForShare:_titleString];
	}
	return @"";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([_dataSource respondsToSelector:@selector(subjectForActivityType:)]) {
		return [_dataSource subjectForActivityType:_titleString];
	}

	return @"";
}

- (IBAction)favoriteButtonAction:(id)sender {
	_hudView = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
	_hudView.square = YES;
	_hudView.mode = MBProgressHUDModeCustomView;
	UIImage *image = [[UIImage imageNamed:@"Favorites"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_hudView.customView = [[UIImageView alloc] initWithImage:image];

	__weak typeof(self) weakSelf = self;
	_hudView.completionBlock = ^{
		[weakSelf dismissViewController];
	};

	if ([self contentIsFavorite]) {
		_hudView.label.text = @"Removed from Favorites";
		[self removeFromFavorites];
	} else {
		_hudView.label.text = @"Added to Favorites";
		[self addToFavorites];
	}

	self.view.hidden = YES;
	[_hudView hideAnimated:YES afterDelay:1.5];
}

- (void)setTitleString:(NSString *)titleString {
	_titleString = [titleString copy];
	_titleLabel.text = _titleString;
}

- (BOOL)contentIsFavorite {
	if ([_dataSource respondsToSelector:@selector(isMemberOfFavorites:)]) {
		return [_dataSource isMemberOfFavorites:_titleString];
	}
	return NO;
}

- (void)addToFavorites {
	if ([self contentIsFavorite]) {
		return;
	}

	if ([_dataSource respondsToSelector:@selector(addToFavorites:)]) {
		[_dataSource addToFavorites:_titleString];
	}
}

- (void)removeFromFavorites {
	if (![self contentIsFavorite]) {
		return;
	}

	if ([_dataSource respondsToSelector:@selector(removeFromFavorites:)]) {
		[_dataSource removeFromFavorites:_titleString];
	}
}

#pragma mark -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
	if (_presentationIsInteractive) {
		_currentInteractionController = [UIPercentDrivenInteractiveTransition new];
		_currentInteractionController.completionSpeed = 0.5;
		return _currentInteractionController;
	}
	return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
	return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
	if (_insertBlurViewWhileTransition) {
		_presentationController = [[A3SharePopupPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
		return _presentationController;
	}
	return nil;
}

- (void)setCurrentTransitionProgress:(CGFloat)currentTransitionProgress {
	_currentTransitionProgress = currentTransitionProgress;
	if (_currentInteractionController) {
		[_currentInteractionController updateInteractiveTransition:currentTransitionProgress];
	}
}

- (A3SharePopupPresentationController *)presentationController {
	if (!_presentationController) {
		_presentationController = [A3SharePopupPresentationController new];
	}
	return _presentationController;
}

@end
