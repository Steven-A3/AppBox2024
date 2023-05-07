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
#import "A3AppDelegate.h"
#import "A3UserDefaults+A3Addition.h"

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyMeaning;

@interface A3SharePopupViewController ()
<UIViewControllerTransitioningDelegate>

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

    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale == 1) {
        _middleLineHeightConstraint.constant = 1.0;
        _secondLineHeightConstraint.constant = 1.0;
    } else if (scale > 2)  {
        _middleLineHeightConstraint.constant = 0.7;
        _secondLineHeightConstraint.constant = 0.6;
    }
	_roundedRectView.layer.cornerRadius = 10;

    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
    _shareImageView.tintColor = themeColor;
    _favoriteImageView.tintColor = themeColor;
    _shareTitleLabel.textColor = themeColor;
    _favoriteTitleLabel.textColor = themeColor;
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	_titleLabel.text = _titleString;
    _shareTitleLabel.text = NSLocalizedString(@"Share", nil);
    _favoriteTitleLabel.text = NSLocalizedString(@"Favorite", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
     [self dismissViewController];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setupFavoriteButton];
}

- (void)setupFavoriteButton {
    UIColor *themeColor = [[A3UserDefaults standardUserDefaults] themeColor];
	if ([self contentIsFavorite]) {
        _favoriteButton.backgroundColor = themeColor;
		_favoriteImageView.tintColor = [UIColor whiteColor];
		_favoriteTitleLabel.textColor = [UIColor whiteColor];
	} else {
		_favoriteButton.backgroundColor = [UIColor whiteColor];
        _favoriteImageView.tintColor = themeColor;
        _favoriteTitleLabel.textColor = themeColor;
	}
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGestureHandler {
	[self dismissViewController];
}

- (void)dismissViewController {
	[self dismissViewControllerAnimated:YES completion:^{
		if ([_delegate respondsToSelector:@selector(sharePopupViewControllerDidDismiss:didTapShareButton:)]) {
			[_delegate sharePopupViewControllerDidDismiss:self didTapShareButton:NO];
		}
	}];
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
    if ([_delegate respondsToSelector:@selector(sharePopupViewControllerWillDismiss:didTapShareButton:)]) {
        [_delegate sharePopupViewControllerWillDismiss:self didTapShareButton:YES];
    }
	[self dismissViewControllerAnimated:YES completion:^{
		if ([_delegate respondsToSelector:@selector(sharePopupViewControllerDidDismiss:didTapShareButton:)]) {
            [_delegate sharePopupViewControllerDidDismiss:self didTapShareButton:YES];
		}
	}];
	return;
}

- (IBAction)favoriteButtonAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([_delegate respondsToSelector:@selector(sharePopupViewControllerDidDismiss:didTapShareButton:)]) {
            [_delegate sharePopupViewControllerDidDismiss:self didTapShareButton:NO];
        }
    }];
    
	_hudView = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
	_hudView.square = YES;
	_hudView.mode = MBProgressHUDModeCustomView;
	UIImage *image = [[UIImage imageNamed:@"Favorites"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_hudView.customView = [[UIImageView alloc] initWithImage:image];

	if ([self contentIsFavorite]) {
		_hudView.label.text = NSLocalizedString(@"Removed from Favorites", @"Removed from Favorites");
		[self removeFromFavorites];
	} else {
		_hudView.label.text = NSLocalizedString(@"Added to Favorites", @"Added to Favorites");
		[self addToFavorites];
	}

    if ([_delegate respondsToSelector:@selector(sharePopupViewControllerContentsModified)]) {
        [_delegate sharePopupViewControllerContentsModified];
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

//- (A3SharePopupPresentationController *)presentationController {
//	if (!_presentationController) {
//		_presentationController = [A3SharePopupPresentationController new];
//	}
//	return _presentationController;
//}

@end
