//
//  A3AbbreviationViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/15/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationViewController.h"
#import "A3AbbreviationCollectionViewCell.h"
#import "A3AbbreviationTableViewCell.h"
#import "UIColor+A3Addition.h"
#import "A3AbbreviationDrillDownViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3AbbreviationCopiedViewController.h"
#import "A3AbbreviationHelpViewController.h"

@interface A3AbbreviationViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
		UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIPreviewInteractionDelegate,
		A3SharePopupViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *topLineView;

@property (nonatomic, strong) UIPreviewInteraction *previewInteraction;
@property (nonatomic, strong) A3AbbreviationCopiedViewController *copiedViewController;
@property (nonatomic, strong) A3SharePopupViewController *sharePopupViewController;
@property (nonatomic, assign) BOOL sharePopupViewControllerIsPresented;
@property (nonatomic, assign) BOOL previewIsPresented;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIView *previewBottomView;
@property (nonatomic, copy) NSDictionary *selectedComponent;
@property (nonatomic, strong) A3AbbreviationDataManager *dataManager;

@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *titleLabelBaselineConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topLineTopConstraint;
@property (nonatomic, strong) NSDate *cancelTime3DTouch;
@property (nonatomic, strong) A3AbbreviationHelpViewController *helpViewController;

@end

@implementation A3AbbreviationViewController

+ (A3AbbreviationViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Abbreviation" bundle:nil];
	A3AbbreviationViewController *viewController = [storyboard instantiateInitialViewController];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbreviation", @"Abbreviation") style:UIBarButtonItemStylePlain target:nil action:nil];

	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	
	[self leftBarButtonAppsButton];
	
    _titleLabel.text = NSLocalizedString(@"Abbreviation", @"Abbreviation");
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"♥︎ %@", NSLocalizedString(@"Favorites", @"♥︎ Favorites")]
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(favoritesButtonAction:)];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCollectionView:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	tapGestureRecognizer.delegate = self;
	
	[self.collectionView addGestureRecognizer:tapGestureRecognizer];

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
		_previewInteraction = [[UIPreviewInteraction alloc] initWithView:self.view];
		_previewInteraction.delegate = self;
	} else {
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCollectionView:)];
		longPressGestureRecognizer.minimumPressDuration = 0.5;
		longPressGestureRecognizer.delegate = self;
		[self.collectionView addGestureRecognizer:longPressGestureRecognizer];
		
		UILongPressGestureRecognizer *longPressGestureRecognizerOnTableView = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressTableView:)];
		longPressGestureRecognizerOnTableView.minimumPressDuration = 0.5;
		longPressGestureRecognizer.delegate = self;
		[self.tableView addGestureRecognizer:longPressGestureRecognizerOnTableView];
	}
    [self showHelpView];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	// 아래 조사하는 순서는 사용자가 많을 것으로 추정되는 순서대로 작성을 하였다.
	if (IS_IPHONE_4_7_INCH) {
		_tableView.contentInset = UIEdgeInsetsMake(-38, 0, 0, 0);
		_collectionView.bounds = CGRectMake(0, 0, _tableView.bounds.size.width, 281);
		_collectionViewFlowLayout.itemSize = CGSizeMake(263, 214);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:39 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:39];
		}
		_tableView.rowHeight = 56;
	} else if (IS_IPHONE_4_INCH) {
		_tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
		_collectionView.bounds = CGRectMake(0, 0, _tableView.bounds.size.width, 236);
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 182);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:33 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:33];
		}
		_tableView.rowHeight = 48;
	} else if (IS_IPHONE_5_5_INCH) {
		_tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
		_collectionView.bounds = CGRectMake(0, 0, _tableView.bounds.size.width, 308);
		_collectionViewFlowLayout.itemSize = CGSizeMake(290, 236);
	} else if (IS_IPHONE_3_5_INCH) {
		_tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
		_collectionView.bounds = CGRectMake(0, 0, _tableView.bounds.size.width, 200);
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 153);
		_tableView.tableHeaderView = nil;
		_tableView.tableHeaderView = _collectionView;
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:23];
		}
		_tableView.rowHeight = 48;
		[_tableView layoutIfNeeded];

		[self.view removeConstraints:@[_titleLabelBaselineConstraint, _topLineTopConstraint]];
		
		NSLayoutConstraint *titleLabelBaselineConstraint =
        [NSLayoutConstraint constraintWithItem:_titleLabel
                                     attribute:NSLayoutAttributeBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:0.17
                                      constant:0];
		NSLayoutConstraint *topLineTopConstraint =
        [NSLayoutConstraint constraintWithItem:_topLineView
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
        
		[self.view removeConstraints:@[_titleLabelBaselineConstraint, _topLineTopConstraint]];
		
		NSLayoutConstraint *titleLabelBaselineConstraint =
        [NSLayoutConstraint constraintWithItem:_titleLabel
                                     attribute:NSLayoutAttributeBaseline
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:isPortrait ? 0.10 : 0.13
                                      constant:0];
		NSLayoutConstraint *topLineTopConstraint =
        [NSLayoutConstraint constraintWithItem:_topLineView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:isPortrait ? 0.12 : 0.15
                                      constant:0];
		[self.view addConstraints:@[titleLabelBaselineConstraint, topLineTopConstraint]];
		
		_titleLabelBaselineConstraint = titleLabelBaselineConstraint;
		_topLineTopConstraint = topLineTopConstraint;

		_tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
		_collectionView.bounds = CGRectMake(0, 0, _tableView.bounds.size.width, 308);
		_collectionViewFlowLayout.itemSize = CGSizeMake(310, 236);
	}
}

- (A3AbbreviationDataManager *)dataManager {
	if (!_dataManager) {
		_dataManager = [A3AbbreviationDataManager instance];
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
		[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		
		A3AbbreviationCollectionViewCell *cell = (A3AbbreviationCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
		CGPoint pointInCell = [gestureRecognizer locationInView:cell];
		FNLOG(@"%f, %f", pointInCell.x, pointInCell.y);
		
		if (pointInCell.y < cell.roundedRectView.frame.origin.y) {
			// tag가 선택이 된 경우
			
			NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];
			
			A3AbbreviationDrillDownViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownViewController storyboardID]];
			viewController.dataManager = self.dataManager;
			viewController.contentsArray = [section[A3AbbreviationKeyComponents] mutableCopy];
			viewController.contentsTitle = NSLocalizedString(section[A3AbbreviationKeyTag], nil);
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			// 섹션 내 상위 3개의 row 중 하나를 선택한 경우
			CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
			NSInteger idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);

			NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];

			A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:YES];
			viewController.delegate = self;
			viewController.dataSource = self.dataManager;
			viewController.titleString = section[A3AbbreviationKeyComponents][idx][A3AbbreviationKeyAbbreviation];
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

	[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

	NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];
	A3AbbreviationDrillDownViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownViewController storyboardID]];
	viewController.dataManager = self.dataManager;
	viewController.contentsArray = [section[A3AbbreviationKeyComponents] mutableCopy];
	viewController.contentsTitle = [NSString stringWithFormat:@"#%@", NSLocalizedString(section[A3AbbreviationKeyTag], nil)];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)favoritesButtonAction:(id)sender {
	A3AbbreviationDrillDownViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownViewController storyboardID]];
	viewController.dataSource = self.dataManager;
	viewController.allowsEditing = YES;
	viewController.dataManager = self.dataManager;
	viewController.contentsTitle = NSLocalizedString(@"Favorites", nil);
	viewController.contentsArray = [[self.dataManager favoritesArray] mutableCopy];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataManager.hashTagSections count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[A3AbbreviationCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];

	switch (indexPath.row) {
		case 0:
			cell.roundedRectView.backgroundColor = [UIColor colorFromHexString:@"FFE3E3"];
			break;
		case 1:
			cell.roundedRectView.backgroundColor = [UIColor colorFromHexString:@"FFDEEB"];
			break;
		case 2:
			cell.roundedRectView.backgroundColor = [UIColor colorFromHexString:@"F3D9FA"];
			break;
	}
	
	cell.groupTitleLabel.text = [NSString stringWithFormat:@"#%@", NSLocalizedString(section[A3AbbreviationKeyTag], nil)];
	NSArray *components = section[A3AbbreviationKeyComponents];
	for (NSInteger index = 0; index < 3; index++) {
		NSDictionary *component = components[index];
		switch (index) {
			case 0:
				cell.row1TitleLabel.text = component[A3AbbreviationKeyAbbreviation];
				cell.row1SubtitleLabel.text = component[A3AbbreviationKeyMeaning];
				break;
			case 1:
				cell.row2TitleLabel.text = component[A3AbbreviationKeyAbbreviation];
				cell.row2SubtitleLabel.text = component[A3AbbreviationKeyMeaning];
				break;
			case 2:
				cell.row3TitleLabel.text = component[A3AbbreviationKeyAbbreviation];
				cell.row3SubtitleLabel.text = component[A3AbbreviationKeyMeaning];
				break;
		}
	}
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataManager.alphabetSections count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[A3AbbreviationTableViewCell reuseIdentifier] forIndexPath:indexPath];

	if (indexPath.row == ([_tableView numberOfRowsInSection:0] - 1)) {
		cell.alphabetLabel.text = nil;
		cell.abbreviationLabel.text = nil;
		cell.meaningLabel.text = nil;

		cell.clipToTrapezoid = NO;
		cell.alphabetTopView.backgroundColor = self.dataManager.alphabetBGColors[indexPath.row - 1];
		cell.alphabetBottomView.backgroundColor = [UIColor whiteColor];
		cell.headBGForFirstRow.gradientColors = nil;
		cell.headBGForOtherRow.gradientColors = nil;
		
		cell.bodyBGForFirstRow.gradientColors = nil;
		cell.bodyBGForOtherRow.gradientColors = nil;
		
		cell.customAccessoryView.hidden = YES;
		
		return cell;
	}
	cell.customAccessoryView.hidden = NO;
	
	NSDictionary *section = self.dataManager.alphabetSections[indexPath.row];
	cell.alphabetLabel.text = section[A3AbbreviationKeyLetter];
	NSDictionary *component = section[A3AbbreviationKeyComponents][0];
	cell.abbreviationLabel.text = component[A3AbbreviationKeyAbbreviation];
	cell.meaningLabel.text = component[A3AbbreviationKeyMeaning];

	UIColor *baseColor = self.dataManager.alphabetBGColors[indexPath.row];
	cell.alphabetBottomView.backgroundColor = baseColor;
	CGFloat red, green, blue, alpha;
	[baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
	UIColor *endColor = [UIColor colorWithRed:red - red/10.0 green:green - green/10 blue:blue - blue/10 alpha:1.0];

	if (indexPath.row == 0) {
		cell.alphabetTopView.backgroundColor = [UIColor whiteColor];
		cell.clipToTrapezoid = YES;
		
		cell.headBGForFirstRow.gradientColors = @[(__bridge id)baseColor.CGColor, (__bridge id)endColor.CGColor];
		cell.headBGForOtherRow.gradientColors = nil;
		
		cell.bodyBGForFirstRow.gradientColors = @[(__bridge id)self.dataManager.bodyBGStartColors[indexPath.row].CGColor, (__bridge id)self.dataManager.alphabetBGColors[indexPath.row].CGColor];
		cell.bodyBGForOtherRow.gradientColors = nil;
	} else {
		cell.clipToTrapezoid = NO;
		cell.alphabetTopView.backgroundColor = self.dataManager.alphabetBGColors[indexPath.row - 1];
		
		cell.headBGForFirstRow.gradientColors = nil;
		cell.headBGForOtherRow.gradientColors = @[(__bridge id)baseColor.CGColor, (__bridge id)endColor.CGColor];
		
		cell.bodyBGForFirstRow.gradientColors = nil;
		cell.bodyBGForOtherRow.gradientColors = @[(__bridge id)self.dataManager.bodyBGStartColors[indexPath.row].CGColor, (__bridge id)self.dataManager.alphabetBGColors[indexPath.row].CGColor];
	}

	[cell.bodyBGForFirstRow setNeedsDisplay];
	[cell.bodyBGForOtherRow setNeedsDisplay];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_cancelTime3DTouch && [[NSDate date] timeIntervalSinceDate:_cancelTime3DTouch] < 0.1) {
		// 3D Touch 반응을 시작했다가 취소한 경우 도착한 이벤트는 무시한다.
		return;
	}
	FNLOG();
	if (indexPath.row >= [self tableView:tableView numberOfRowsInSection:0] - 1) {
		return;
	}
	if (!self.presentedViewController) {
		NSArray *contents = self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyComponents];
		A3AbbreviationDrillDownViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownViewController storyboardID]];
		viewController.dataManager = self.dataManager;
		viewController.contentsTitle = NSLocalizedString(self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyLetter], nil);
		viewController.contentsArray = [contents mutableCopy];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didLongPressTableView:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint location = [gestureRecognizer locationInView:_tableView];
		NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:location];
		if (indexPath) {
			A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:YES];
			viewController.delegate = self;
			viewController.dataSource = self.dataManager;
			viewController.titleString = self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyComponents][0][A3AbbreviationKeyAbbreviation];
			[self presentViewController:viewController animated:YES completion:NULL];
			_sharePopupViewController = viewController;
			
			_cancelTime3DTouch = [NSDate date];
		}
	}
}

#pragma mark - UIPreviewInteractionDelegate

- (BOOL)previewInteractionShouldBegin:(UIPreviewInteraction *)previewInteraction {
	if (self.sharePopupViewControllerIsPresented) {
		return NO;
	}
	CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
	if (indexPath != nil) {
		A3AbbreviationCollectionViewCell *cell = (A3AbbreviationCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
		CGPoint locationInCollectionView = [previewInteraction locationInCoordinateSpace:cell.roundedRectView];
		
		return [cell.roundedRectView pointInside:locationInCollectionView withEvent:nil];
	}
	location = [previewInteraction locationInCoordinateSpace:_tableView];

	indexPath = [_tableView indexPathForRowAtPoint:location];
	return (indexPath != nil) && (indexPath.row < ([self tableView:_tableView numberOfRowsInSection:0] - 1));
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdatePreviewTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
//	FNLOG(@"%f, _previewIsPresented = %@, ended = %@", transitionProgress, _previewIsPresented ? @"YES" : @"NO", ended ? @"YES" : @"NO");
	_cancelTime3DTouch = nil;

	if (!_previewIsPresented) {
		_previewIsPresented = YES;
		
		if (!ended) {
			_blurEffectView = [[UIVisualEffectView alloc] init];
			_blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_blurEffectView.frame = self.view.bounds;
			[self.navigationController.view addSubview:_blurEffectView];
			
			_blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			
			_animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveLinear animations:^{
				_blurEffectView.effect = nil;
			}];
			
			CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
			if ([_collectionView pointInside:location withEvent:nil]) {
				// 3D Touch가 시작되면 화면이 스크롤되지 않도록 합니다.
				_collectionView.scrollEnabled = NO;
				
				CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
				FNLOG(@"%f, %f", location.x, location.y);
				NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
				if (indexPath) {
					NSDictionary *hashTagSection = self.dataManager.hashTagSections[indexPath.row];
					
					A3AbbreviationCollectionViewCell *cell = (A3AbbreviationCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
					if (cell) {
						CGPoint pointInCell = [previewInteraction locationInCoordinateSpace:cell];
						CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
						NSInteger idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);
						
						UIView *rowView = cell.rows[idx];
						_previewView = [rowView snapshotViewAfterScreenUpdates:YES];
						_previewView.frame = [self.view convertRect:rowView.frame fromView:cell.roundedRectView];
						[_blurEffectView addSubview:_previewView];
						
						// Prepare data
						_selectedComponent = hashTagSection[A3AbbreviationKeyComponents][idx];
					}
				}
			} else {
				// 3D Touch가 시작되면 화면이 스크롤되지 않도록 합니다.
				_tableView.scrollEnabled = NO;
				
				CGPoint locationInTableView = [previewInteraction locationInCoordinateSpace:_tableView];
				NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:locationInTableView];
				
				if (indexPath) {
					// Save data to use later
					_selectedComponent = [self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyComponents][0] copy];
					
					A3AbbreviationTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
					
					UIColor *originalColor = cell.alphabetTopView.backgroundColor;
					if (indexPath.row != 0) {
						cell.alphabetTopView.backgroundColor = [UIColor clearColor];
					}
					_previewView = [cell snapshotViewAfterScreenUpdates:YES];
					
					cell.alphabetTopView.backgroundColor = originalColor;
					
					_previewView.frame = [self.view convertRect:cell.frame fromView:_tableView];
					[_blurEffectView addSubview:_previewView];
					
					_previewBottomView = [UIView new];
					_previewBottomView.backgroundColor = cell.alphabetBottomView.backgroundColor;
					CGRect frame = [self.view convertRect:cell.alphabetTopView.frame fromView:cell];
					frame.origin.y = _previewView.frame.origin.y + _previewView.frame.size.height;
					_previewBottomView.frame = frame;
					
					[_blurEffectView addSubview:_previewBottomView];
				}
			}
		}
	}

	if (ended) {
		if (!_blurEffectView) {
			[previewInteraction cancelInteraction];
		} else {
			_animator.fractionComplete = 0.75;
		}
		[self removePreviewView];
	} else {
		_animator.fractionComplete = 1.0 - transitionProgress/4;
	}
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdateCommitTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
	FNLOG(@"%f, sharePopupViewControllerIsPresented = %@, ended = %@", transitionProgress, self.sharePopupViewControllerIsPresented ? @"YES" : @"NO", ended ? @"YES" : @"NO");

	if (!self.sharePopupViewControllerIsPresented) {
		_sharePopupViewControllerIsPresented = YES;
		_sharePopupViewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:NO];
		_sharePopupViewController.presentationIsInteractive = YES;
		_sharePopupViewController.delegate = self;
		_sharePopupViewController.dataSource = self.dataManager;
		_sharePopupViewController.titleString = _selectedComponent[A3AbbreviationKeyAbbreviation];
		[self presentViewController:_sharePopupViewController animated:YES completion:NULL];
	}
	_sharePopupViewController.interactiveTransitionProgress = transitionProgress;
	
	if (ended) {
		[_sharePopupViewController completeCurrentInteractiveTransition];
	}
}

- (void)previewInteractionDidCancel:(UIPreviewInteraction *)previewInteraction {
	_cancelTime3DTouch = [NSDate date];
	FNLOG();
	
	if (!self.presentedViewController) {
		[self removeBlurEffectView];
	}
	[_sharePopupViewController cancelCurrentInteractiveTransition];
	_sharePopupViewControllerIsPresented = NO;
	
	[self removePreviewView];
}

- (void)removePreviewView {
	// 3D Touch 동작이 끝나면 스크롤을 활성화 합니다.
	_tableView.scrollEnabled = YES;
	_collectionView.scrollEnabled = YES;
	
	[_previewView removeFromSuperview];
	[_previewBottomView removeFromSuperview];
	_previewView = nil;
	_previewBottomView = nil;
	_previewIsPresented = NO;
}

- (void)removeBlurEffectView {
	_animator = nil;
	[_blurEffectView removeFromSuperview];
	_blurEffectView = nil;
}

#pragma mark - A3SharePopupViewControllerDelegate

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController {
	_sharePopupViewControllerIsPresented = NO;
	[self removeBlurEffectView];
}

- (IBAction)helpButtonAction:(id)sender {
	if (_helpViewController) {
		return;
	}
	A3AbbreviationHelpViewController *viewController = [A3AbbreviationHelpViewController storyboardInstance];
    if (self.navigationController) {
        [self.navigationController addChildViewController:viewController];
        [self.navigationController.view addSubview:viewController.view];
    } else {
        [self.view addSubview:viewController.view];
    }
	_helpViewController = viewController;

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnHelpView)];
	[viewController.view addGestureRecognizer:tapGestureRecognizer];
	
	[_tableView scrollsToTop];
}

- (void)didTapOnHelpView {
	[_helpViewController.view removeFromSuperview];
	[_helpViewController removeFromParentViewController];
	_helpViewController = nil;
}

- (void)showHelpView {
    [self helpButtonAction:self];
    return;
    
	NSString *userDefaultKey = [NSString stringWithFormat:@"%@HelpDidShow", NSStringFromClass([self class])];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:userDefaultKey]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDefaultKey];

		[self helpButtonAction:self];
	}
}

@end
