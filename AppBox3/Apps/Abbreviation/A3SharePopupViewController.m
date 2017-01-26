//
//  A3SharePopupViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupViewController.h"
#import "A3SharePopupTransitionDelegate.h"
#import "UIViewController+A3Addition.h"
#import "AbbreviationFavorite+CoreDataProperties.h"
#import "NSManagedObject+extension.h"

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyMeaning;

@interface A3SharePopupViewController ()
<UIActivityItemSource>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *roundedRectView;
@property (nonatomic, strong) A3SharePopupTransitionDelegate *customTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *middleLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *secondLineHeightConstraint;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, weak) IBOutlet UILabel *shareTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *shareImageView;
@property (nonatomic, weak) IBOutlet UILabel *favoriteTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *favoriteImageView;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;

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

	_middleLineHeightConstraint.constant = 0.7;
	_secondLineHeightConstraint.constant = 0.7;
	_roundedRectView.layer.cornerRadius = 10;

	_shareImageView.tintColor = [[A3AppDelegate instance] themeColor];
	_favoriteImageView.tintColor = [[A3AppDelegate instance] themeColor];
	_shareTitleLabel.textColor = [[A3AppDelegate instance] themeColor];
	_favoriteTitleLabel.textColor = [[A3AppDelegate instance] themeColor];
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	_titleLabel.text = _contents[A3AbbreviationKeyAbbreviation];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self setupMaskToFavoriteButton];
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
	return NSLocalizedString(@"Abbreviation Reference on the AppBox Pro", nil);
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
	return [NSString stringWithFormat:@"%@ means %@", _contents[A3AbbreviationKeyAbbreviation], _contents[A3AbbreviationKeyMeaning]];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Abbreviation reference using AppBox Pro", nil);
	}
	
	return @"";
}

- (IBAction)favoriteButtonAction:(id)sender {
	[self makeAbbreviationFavorite];
}

- (void)setContents:(NSDictionary *)contents {
	_contents = [contents copy];
	_titleLabel.text = _contents[A3AbbreviationKeyAbbreviation];
}

- (void)setupMaskToFavoriteButton {
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_favoriteButton.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.frame = _favoriteButton.bounds;
	maskLayer.fillColor = [[A3AppDelegate instance] themeColor].CGColor;
	maskLayer.path = maskPath.CGPath;
	
	_favoriteButton.layer.mask = maskLayer;
}

- (BOOL)contentIsFavorite {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", _contents[A3AbbreviationKeyAbbreviation]];
	NSArray *result = [AbbreviationFavorite MR_findAllWithPredicate:predicate];
	return [result count] > 0;
}

- (void)makeAbbreviationFavorite {
	if ([self contentIsFavorite]) {
		return;
	}

	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	AbbreviationFavorite *favorite = [AbbreviationFavorite MR_createEntityInContext:savingContext];
	favorite.uniqueID = _contents[A3AbbreviationKeyAbbreviation];
	[favorite assignOrderAsLastInContext:savingContext];
	[savingContext MR_saveToPersistentStoreAndWait];
}

- (void)removeAbbreviationFromFavorite {
	NSManagedObjectContext *savingContext = [NSManagedObjectContext MR_rootSavingContext];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", _contents[A3AbbreviationKeyAbbreviation]];
	NSArray *result = [AbbreviationFavorite MR_findAllWithPredicate:predicate inContext:savingContext];
	if ([result count]) {
		for (AbbreviationFavorite *favorite in result) {
			[favorite MR_deleteEntityInContext:savingContext];
		}
		[savingContext MR_saveToPersistentStoreAndWait];
	}
	
	
}

@end
