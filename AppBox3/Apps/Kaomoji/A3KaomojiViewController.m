//
//  A3KaomojiViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/4/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3KaomojiDataManager.h"
#import "A3KaomojiCollectionViewCell.h"
#import "A3AbbreviationCopiedViewController.h"
#import "A3SharePopupViewController.h"
#import "A3KaomojiDrillDownViewController.h"
#import "A3KaomojiHelpViewController.h"

@interface A3KaomojiViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPreviewInteractionDelegate,
		A3SharePopupViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *topLineView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) A3KaomojiDataManager *dataManager;
@property (nonatomic, strong) UIPreviewInteraction *previewInteraction;
@property (nonatomic, strong) A3AbbreviationCopiedViewController *copiedViewController;
@property (nonatomic, strong) A3SharePopupViewController *sharePopupViewController;
@property (nonatomic, assign) BOOL sharePopupViewControllerIsPresented;
@property (nonatomic, assign) BOOL previewIsPresented;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIView *previewBottomView;
@property (nonatomic, copy) NSString *selectedKaomoji;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *titleLabelBaselineConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topLineTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLineHeightConstraint;
@property (nonatomic, strong) A3KaomojiHelpViewController *helpViewController;

@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, copy) NSString *selectedStringToShare;
@property (nonatomic, assign) CGRect sourceRectForPopover;
@property (nonatomic, assign) BOOL popoverNeedBackground;

@end

@implementation A3KaomojiViewController

+ (A3KaomojiViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Kaomoji" bundle:nil];
	A3KaomojiViewController *viewController = [storyboard instantiateInitialViewController];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Kaomoji", @"Kaomoji") style:UIBarButtonItemStylePlain target:nil action:nil];
	self.titleLabel.text = NSLocalizedString(@"Kaomoji", @"Kaomoji");
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];

	[self leftBarButtonAppsButton];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"♥︎ %@", NSLocalizedString(@"Favorites", @"Favorites")]
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(favoritesButtonAction:)];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCollectionView:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	tapGestureRecognizer.delegate = self;

	[self.collectionView addGestureRecognizer:tapGestureRecognizer];

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
		_previewInteraction = [[UIPreviewInteraction alloc] initWithView:_collectionView];
		_previewInteraction.delegate = self;
	} else {
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCollectionView:)];
		longPressGestureRecognizer.minimumPressDuration = 0.5;
		longPressGestureRecognizer.delegate = self;
		[self.collectionView addGestureRecognizer:longPressGestureRecognizer];
	}
    [self showHelpView];
    
    if ([[UIScreen mainScreen] scale] == 1) {
        _topLineHeightConstraint.constant = 1.0;
    }
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	// 아래 조사하는 순서는 사용자가 많을 것으로 추정되는 순서대로 작성을 하였다.
	if (IS_IPHONE_4_7_INCH) {
		_collectionViewFlowLayout.itemSize = CGSizeMake(263, 214);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:39 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:39];
		}
	} else if (IS_IPHONE_4_INCH) {
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 182);
		_collectionViewFlowLayout.minimumLineSpacing = 5;
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:33 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:33];
		}
	} else if (IS_IPHONE_5_5_INCH) {
//		_collectionViewFlowLayout.itemSize = CGSizeMake(290, 236);
//		_titleLabel.font = [UIFont systemFontOfSize:42 weight:UIFontWeightHeavy];
//		_tableView.rowHeight = 62;
	} else if (IS_IPHONE_3_5_INCH) {
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 153);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:23];
		}
		[self.view removeConstraints:@[_titleLabelBaselineConstraint, _topLineTopConstraint]];
		
		NSLayoutConstraint *titleLabelBaselineConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
																						attribute:NSLayoutAttributeBaseline
																						relatedBy:NSLayoutRelationEqual
																						   toItem:self.view
																						attribute:NSLayoutAttributeBottom
																					   multiplier:0.17
																						 constant:0];
		NSLayoutConstraint *topLineTopConstraint = [NSLayoutConstraint constraintWithItem:_topLineView
																				attribute:NSLayoutAttributeTop
																				relatedBy:NSLayoutRelationEqual
																				   toItem:self.view
																				attribute:NSLayoutAttributeBottom
																			   multiplier:0.185
																				 constant:0];
		[self.view addConstraints:@[titleLabelBaselineConstraint, topLineTopConstraint]];
		
		_titleLabelBaselineConstraint = titleLabelBaselineConstraint;
		_topLineTopConstraint = topLineTopConstraint;
	} else if (IS_IPAD) {
        BOOL isPortrait  = self.view.bounds.size.width < self.view.bounds.size.height;
		if (IS_IPAD_12_9_INCH) {
			_collectionViewFlowLayout.itemSize = CGSizeMake(314, isPortrait ? 283 : 295);
			_collectionViewFlowLayout.minimumLineSpacing = 15;
			_collectionView.contentInset = UIEdgeInsetsMake(0, 2, 5, 2);
		}
		[self.view removeConstraints:@[_titleLabelBaselineConstraint, _topLineTopConstraint]];
		
		NSLayoutConstraint *titleLabelBaselineConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
																						attribute:NSLayoutAttributeBaseline
																						relatedBy:NSLayoutRelationEqual
																						   toItem:self.view
																						attribute:NSLayoutAttributeBottom
																					   multiplier:isPortrait ? 0.10 : 0.13
																						 constant:0];
		NSLayoutConstraint *topLineTopConstraint = [NSLayoutConstraint constraintWithItem:_topLineView
																				attribute:NSLayoutAttributeTop
																				relatedBy:NSLayoutRelationEqual
																				   toItem:self.view
																				attribute:NSLayoutAttributeBottom
																			   multiplier:isPortrait ? 0.12 : 0.15
																				 constant:0];
		[self.view addConstraints:@[titleLabelBaselineConstraint, topLineTopConstraint]];
		
		_titleLabelBaselineConstraint = titleLabelBaselineConstraint;
		_topLineTopConstraint = topLineTopConstraint;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO];
}

- (void)applicationDidBecomeActive {
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3KaomojiDataManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3KaomojiDataManager instance];
	}
	return _dataManager;
}

- (void)didLongPressCollectionView:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint location = [gestureRecognizer locationInView:self.collectionView];
		NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
		if (!indexPath) {
			return;
		}
		A3KaomojiCollectionViewCell *cell = (A3KaomojiCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
		CGPoint pointInCell = [gestureRecognizer locationInView:cell];
		FNLOG(@"%f, %f", pointInCell.x, pointInCell.y);

		[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		
		if (pointInCell.y < cell.roundedRectView.frame.origin.y) {
			// tag가 선택이 된 경우

			NSDictionary *section = self.dataManager.contentsArray[indexPath.row];

			A3KaomojiDrillDownViewController *viewController = [A3KaomojiDrillDownViewController storyboardInstance];
			viewController.dataManager = self.dataManager;
			viewController.contentsArray = [section[A3KaomojiKeyContents] mutableCopy];
			viewController.contentsTitle = NSLocalizedString(section[A3KaomojiKeyCategory], nil);
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			// 섹션 내 상위 3개의 row 중 하나를 선택한 경우
			CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
			NSInteger idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);

			NSDictionary *section = self.dataManager.contentsArray[indexPath.row];

			A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:YES];
			viewController.delegate = self;
			viewController.dataSource = self.dataManager;
			viewController.titleString = section[A3KaomojiKeyContents][idx];

			_selectedStringToShare = [viewController.titleString copy];
			_sourceRectForPopover = [self.view convertRect:cell.frame fromView:_collectionView];

			[self presentViewController:viewController animated:YES completion:NULL];
			_sharePopupViewController = viewController;
			FNLOG();
		}
	}
}

- (void)didTapCollectionView:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.presentedViewController) {
        return;
    }

    // Collection View에서 UICollectionViewDelegate의 didSelectItemAtIndexPath를 사용하지 않고 UITapGestureRecognizer를
	// 별도로 사용한 이유:
	// 셀 내에서 터치한 영역에 따라 다른 연결 화면으로 이동해야 하기 때문입니다.
	CGPoint location = [gestureRecognizer locationInView:self.collectionView];
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
	if (!indexPath) {
		return;
	}

	[_collectionView scrollToItemAtIndexPath:indexPath
							atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
									animated:YES];

	NSDictionary *section = self.dataManager.contentsArray[indexPath.row];
	
	A3KaomojiDrillDownViewController *viewController = [A3KaomojiDrillDownViewController storyboardInstance];
	viewController.dataManager = self.dataManager;
	viewController.contentsArray = [section[A3KaomojiKeyContents] mutableCopy];
	viewController.contentsTitle = NSLocalizedString(section[A3KaomojiKeyCategory], nil);
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.dataManager.contentsArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	A3KaomojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[A3KaomojiCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *data = self.dataManager.contentsArray[indexPath.row];

	cell.groupTitleLabel.text = NSLocalizedString(data[A3KaomojiKeyCategory], nil);
	NSArray *contents = data[A3KaomojiKeyContents];
	cell.row1TitleLabel.text = contents[0];
	cell.row2TitleLabel.text = contents[1];
	cell.row3TitleLabel.text = contents[2];
	cell.roundedRectView.backgroundColor = self.dataManager.categoryColors[indexPath.row];
	return cell;
}

- (void)favoritesButtonAction:(UIBarButtonItem *)barButton {
	A3KaomojiDrillDownViewController *viewController = [A3KaomojiDrillDownViewController storyboardInstance];
	viewController.dataSource = self.dataManager;
	viewController.isFavoritesList = YES;
	viewController.dataManager = self.dataManager;
	viewController.contentsTitle = NSLocalizedString(@"Favorites", @"Favorites");
	viewController.contentsArray = [[self.dataManager favoritesArray] mutableCopy];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIPreviewInteractionDelegate

- (BOOL)previewInteractionShouldBegin:(UIPreviewInteraction *)previewInteraction {
	CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
	if (indexPath != nil) {
		A3KaomojiCollectionViewCell *cell = (A3KaomojiCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
		CGPoint locationInCollectionView = [previewInteraction locationInCoordinateSpace:cell.roundedRectView];
		return [cell.roundedRectView pointInside:locationInCollectionView withEvent:nil];
	}
	return NO;
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdatePreviewTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
    FNLOG(@"%f, %ld", transitionProgress, (long)ended);
    if (!_previewIsPresented) {
        _previewIsPresented = YES;
        
        _popoverNeedBackground = NO;
        
        CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
        A3KaomojiCollectionViewCell *cell;
        NSInteger idx = NSNotFound;
        if (indexPath) {
            NSDictionary *category = self.dataManager.contentsArray[indexPath.row];
            
            cell = (A3KaomojiCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                CGPoint pointInCell = [previewInteraction locationInCoordinateSpace:cell];
                CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
                idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);
                
                // Prepare Data
                _selectedKaomoji = [category[A3KaomojiKeyContents][idx] copy];
                
                _selectedStringToShare = [category[A3KaomojiKeyContents][idx] copy];
                _sourceRectForPopover = [self.view convertRect:cell.frame fromView:_collectionView];
            }
        }
        
        if (!ended) {
            _blurEffectView = [[UIVisualEffectView alloc] init];
            _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _blurEffectView.frame = self.view.bounds;
            [self.navigationController.view addSubview:_blurEffectView];
            
            _blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            
            _animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveLinear animations:^{
                _blurEffectView.effect = nil;
            }];

            if (cell && idx != NSNotFound) {
                UIView *rowView = cell.rows[idx];
                _previewView = [rowView snapshotViewAfterScreenUpdates:YES];
                _previewView.frame = [self.view convertRect:rowView.frame fromView:cell.roundedRectView];
                [_blurEffectView addSubview:_previewView];
            }
        } else {
            _popoverNeedBackground = YES;
        }
    }

	if (ended) {
		if (_blurEffectView) {
			_animator.fractionComplete = 0.75;
		}
		[self removePreviewView];
	} else {
		_animator.fractionComplete = 1.0 - transitionProgress/4;
	}
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdateCommitTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
    FNLOG(@"%f, %ld", transitionProgress, (long)ended);
	if (!self.sharePopupViewControllerIsPresented) {
		_sharePopupViewControllerIsPresented = YES;
		_sharePopupViewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:_popoverNeedBackground];
		_sharePopupViewController.presentationIsInteractive = YES;
		_sharePopupViewController.delegate = self;
		_sharePopupViewController.dataSource = self.dataManager;
		_sharePopupViewController.titleString = _selectedKaomoji;
		[self presentViewController:_sharePopupViewController animated:YES completion:NULL];
	}
	_sharePopupViewController.interactiveTransitionProgress = transitionProgress;

	if (ended) {
		[_sharePopupViewController completeCurrentInteractiveTransition];
	}
}

- (void)previewInteractionDidCancel:(UIPreviewInteraction *)previewInteraction {
    FNLOG();
	if (!self.presentedViewController) {
		[self removeBlurEffectView];
	}
	[_sharePopupViewController cancelCurrentInteractiveTransition];
	_sharePopupViewControllerIsPresented = NO;
	
	[self removePreviewView];
}

- (void)removePreviewView {
	[_previewView removeFromSuperview];
	_previewView = nil;
	_previewIsPresented = NO;
}

- (void)removeBlurEffectView {
	_animator = nil;
	[_blurEffectView removeFromSuperview];
	_blurEffectView = nil;
}

#pragma mark - A3SharePopupViewControllerDelegate

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController didTapShareButton:(BOOL)didTapShareButton {
    if (didTapShareButton) {
        _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        [_activityViewController view];
    }
}

- (void)sharePopupViewControllerDidDismiss:(A3SharePopupViewController *)viewController didTapShareButton:(BOOL)didTapShareButton {
	_sharePopupViewControllerIsPresented = NO;
	[self removeBlurEffectView];

	if (didTapShareButton) {
		if (IS_IPHONE) {
			[self presentViewController:_activityViewController animated:YES completion:NULL];
		} else {
			UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:_activityViewController];
			[popoverController presentPopoverFromRect:_sourceRectForPopover
											   inView:self.view
							 permittedArrowDirections:UIPopoverArrowDirectionAny
											 animated:YES];
			_sharePopoverController = popoverController;
		}
	}
}

- (IBAction)helpButtonAction:(id)sender {
	if (_helpViewController) {
		return;
	}
	_helpViewController = [A3KaomojiHelpViewController storyboardInstance];
    [self.navigationController addChildViewController:_helpViewController];
	[self.navigationController.view addSubview:_helpViewController.view];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnHelpView)];
	[_helpViewController.view addGestureRecognizer:tapGestureRecognizer];
	
	[_collectionView scrollsToTop];
}

- (void)didTapOnHelpView {
	[_helpViewController.view removeFromSuperview];
	[_helpViewController removeFromParentViewController];

	_helpViewController = nil;
}

- (void)showHelpView {
    NSString *userDefaultKey = [NSString stringWithFormat:@"%@HelpDidShow", NSStringFromClass([self class])];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:userDefaultKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDefaultKey];
        
        [self helpButtonAction:self];
    }
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return [self.dataManager placeholderForShare:nil];
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share information with you.", nil)
									   contents:_selectedStringToShare
										   tail:NSLocalizedString(@"You can find more in the AppBox Pro.", nil)];
	}
	return _selectedStringToShare;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable UIActivityType)activityType {
	return [self.dataManager subjectForActivityType:activityType];
}

@end
