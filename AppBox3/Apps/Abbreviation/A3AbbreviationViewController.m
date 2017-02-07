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
#import "A3AbbreviationDrillDownTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3AbbreviationCopiedViewController.h"

@interface A3AbbreviationViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
		UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIPreviewInteractionDelegate,
		A3SharePopupViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray<UIColor *> *headStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *alphabetBGColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGEndColors;

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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewHeightContraint;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;

@end

@implementation A3AbbreviationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Abbreviation", @"Abbreviation") style:UIBarButtonItemStylePlain target:nil action:nil];

	[self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];
	
	[self leftBarButtonAppsButton];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"♥︎ Favorites"
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
	}
}

- (BOOL)hidesNavigationBar {
	return YES;
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
		_tableView.rowHeight = 56;
	} else if (IS_IPHONE_4_INCH) {
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 182);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:33 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:33];
		}
		_tableView.rowHeight = 48;
	} else if (IS_IPHONE_5_5_INCH) {
//		_collectionViewFlowLayout.itemSize = CGSizeMake(290, 236);
//		_titleLabel.font = [UIFont systemFontOfSize:42 weight:UIFontWeightHeavy];
//		_tableView.rowHeight = 62;
	} else if (IS_IPHONE_3_5_INCH) {
		_collectionViewFlowLayout.itemSize = CGSizeMake(224, 153);
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.2")) {
			_titleLabel.font = [UIFont systemFontOfSize:33 weight:UIFontWeightHeavy];
		} else {
			_titleLabel.font = [UIFont boldSystemFontOfSize:33];
		}
		_tableView.rowHeight = 48;
	} else if (IS_IPAD) {

	} else if (IS_IPAD_12_9_INCH) {

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
		A3AbbreviationCollectionViewCell *cell = (A3AbbreviationCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
		CGPoint pointInCell = [gestureRecognizer locationInView:cell];
		FNLOG(@"%f, %f", pointInCell.x, pointInCell.y);
		
		if (pointInCell.y < cell.roundedRectView.frame.origin.y) {
			// tag가 선택이 된 경우
			
			NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];
			
			A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
			viewController.dataManager = self.dataManager;
			viewController.contentsArray = [section[A3AbbreviationKeyComponents] mutableCopy];
			viewController.contentsTitle = section[A3AbbreviationKeyTag];
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			// 섹션 내 상위 3개의 row 중 하나를 선택한 경우
			CGPoint pointInRoundedRect = [gestureRecognizer locationInView:cell.roundedRectView];
			NSInteger index = pointInRoundedRect.y / cell.roundedRectView.bounds.size.height / 3;

			NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];

			A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:YES];
			viewController.delegate = self;
			viewController.dataSource = self.dataManager;
			viewController.titleString = section[A3AbbreviationKeyComponents][index][A3AbbreviationKeyAbbreviation];
			[self presentViewController:viewController animated:YES completion:NULL];
			_sharePopupViewController = viewController;
			FNLOG();
		}
	}
}

- (void)didTapCollectionView:(UITapGestureRecognizer *)gestureRecognizer {
	// Collection View에서 UICollectionViewDelegate의 didSelectItemAtIndexPath를 사용하지 않고 UITapGestureRecognizer를
	// 별도로 사용한 이유:
	// 셀 내에서 터치한 영역에 따라 다른 연결 화면으로 이동해야 하기 때문입니다.
	CGPoint location = [gestureRecognizer locationInView:self.collectionView];
	NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:location];
	if (!indexPath) {
		return;
	}
	
	A3AbbreviationCollectionViewCell *cell = (A3AbbreviationCollectionViewCell *) [_collectionView cellForItemAtIndexPath:indexPath];
	CGPoint pointInCell = [gestureRecognizer locationInView:cell];
	FNLOG(@"%f, %f", pointInCell.x, pointInCell.y);

	if (pointInCell.y < cell.roundedRectView.frame.origin.y) {
		NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];
		
		A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
		viewController.dataManager = self.dataManager;
		viewController.contentsArray = [section[A3AbbreviationKeyComponents] mutableCopy];
		viewController.contentsTitle = [NSString stringWithFormat:@"#%@", section[A3AbbreviationKeyTag]];
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		[_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
		
		NSDictionary *section = self.dataManager.hashTagSections[indexPath.row];

		CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
		NSInteger idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);
		NSArray *components = section[A3AbbreviationKeyComponents];

		[self removeBlurEffectView];
		
		A3AbbreviationCopiedViewController *viewController = [A3AbbreviationCopiedViewController storyboardInstance];
		viewController.titleString = components[idx][A3AbbreviationKeyAbbreviation];
		[self presentViewController:viewController animated:YES completion:NULL];
		_copiedViewController = viewController;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)favoritesButtonAction:(id)sender {
	A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
	viewController.dataSource = self.dataManager;
	viewController.allowsEditing = YES;
	viewController.dataManager = self.dataManager;
	viewController.contentsTitle = @"Favorites";
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

	cell.groupTitleLabel.text = [NSString stringWithFormat:@"#%@", section[A3AbbreviationKeyTag]];
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
    return [self.dataManager.alphabetSections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[A3AbbreviationTableViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *section = self.dataManager.alphabetSections[indexPath.row];
	cell.alphabetLabel.text = section[A3AbbreviationKeyLetter];
	NSDictionary *component = section[A3AbbreviationKeyComponents][0];
	cell.abbreviationLabel.text = component[A3AbbreviationKeyAbbreviation];
	cell.meaningLabel.text = component[A3AbbreviationKeyMeaning];

	UIColor *baseColor = self.alphabetBGColors[indexPath.row];
	cell.alphabetBottomView.backgroundColor = baseColor;
	CGFloat red, green, blue, alpha;
	[baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
	UIColor *endColor = [UIColor colorWithRed:red - red/10.0 green:green - green/10 blue:blue - blue/10 alpha:1.0];


	if (indexPath.row > 0) {
		cell.clipToTrapezoid = NO;
		cell.alphabetTopView.backgroundColor = self.alphabetBGColors[indexPath.row - 1];

		cell.headBGForFirstRow.gradientColors = nil;
		cell.headBGForOtherRow.gradientColors = @[(__bridge id)baseColor.CGColor, (__bridge id)endColor.CGColor];
		
		cell.bodyBGForFirstRow.gradientColors = nil;
		cell.bodyBGForOtherRow.gradientColors = @[(__bridge id)self.bodyBGStartColors[indexPath.row].CGColor, (__bridge id)self.alphabetBGColors[indexPath.row].CGColor];
	} else {
		cell.alphabetTopView.backgroundColor = [UIColor whiteColor];
		cell.clipToTrapezoid = YES;

		cell.headBGForFirstRow.gradientColors = @[(__bridge id)baseColor.CGColor, (__bridge id)endColor.CGColor];
		cell.headBGForOtherRow.gradientColors = nil;
		
		cell.bodyBGForFirstRow.gradientColors = @[(__bridge id)self.bodyBGStartColors[indexPath.row].CGColor, (__bridge id)self.alphabetBGColors[indexPath.row].CGColor];
		cell.bodyBGForOtherRow.gradientColors = nil;
	}

	[cell.bodyBGForFirstRow setNeedsDisplay];
	[cell.bodyBGForOtherRow setNeedsDisplay];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.presentedViewController) {
		NSArray *contents = self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyComponents];
		A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
		viewController.dataManager = self.dataManager;
		viewController.contentsTitle = self.dataManager.alphabetSections[indexPath.row][A3AbbreviationKeyLetter];
		viewController.contentsArray = [contents mutableCopy];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - Data Management

- (NSArray *)headStartColors {
	if (!_headStartColors) {
		_headStartColors = @[
				[UIColor colorFromHexString:@"F03E3E"],	// A
				[UIColor colorFromHexString:@"D6336C"],	// B
				[UIColor colorFromHexString:@"AE3EC9"],	// C
				[UIColor colorFromHexString:@"7048E8"],	// D
				[UIColor colorFromHexString:@"4263E8"],	// E
				[UIColor colorFromHexString:@"1C7CD6"],	// F
				[UIColor colorFromHexString:@"1098AD"],	// G
				[UIColor colorFromHexString:@"0CA678"],	// H
				[UIColor colorFromHexString:@"37B24D"],	// I
				[UIColor colorFromHexString:@"74B816"],	// J
				[UIColor colorFromHexString:@"F59F00"],	// K
				[UIColor colorFromHexString:@"F76707"],	// L
				[UIColor colorFromHexString:@"F03E3E"],	// M
				[UIColor colorFromHexString:@"D6336C"],	// N
				[UIColor colorFromHexString:@"AE3EC9"],	// O
				[UIColor colorFromHexString:@"7048E8"],	// P
				[UIColor colorFromHexString:@"4263E8"],	// Q
				[UIColor colorFromHexString:@"1C7CD6"],	// R
				[UIColor colorFromHexString:@"1098AD"],	// S
				[UIColor colorFromHexString:@"0CA678"],	// T
				[UIColor colorFromHexString:@"37B24D"],	// U
				[UIColor colorFromHexString:@"74B816"],	// V
				[UIColor colorFromHexString:@"F59F00"],	// W
				[UIColor colorFromHexString:@"F76707"],	// X
				[UIColor colorFromHexString:@"F03E3E"],	// Y
				[UIColor colorFromHexString:@"D6336C"],	// Z
		];
	}
	return _headStartColors;
}

- (NSArray *)alphabetBGColors {
	if (!_alphabetBGColors) {
		_alphabetBGColors = @[
				[UIColor colorFromHexString:@"F03E3E"],	// A
				[UIColor colorFromHexString:@"D6336C"],	// B
				[UIColor colorFromHexString:@"AE3EC9"],	// C
				[UIColor colorFromHexString:@"7048E8"],	// D
				[UIColor colorFromHexString:@"4263E8"],	// E
				[UIColor colorFromHexString:@"1C7CD6"],	// F
				[UIColor colorFromHexString:@"1098AD"],	// G
				[UIColor colorFromHexString:@"0CA678"],	// H
				[UIColor colorFromHexString:@"37B24D"],	// I
				[UIColor colorFromHexString:@"74B816"],	// J
				[UIColor colorFromHexString:@"F59F00"],	// K
				[UIColor colorFromHexString:@"F76707"],	// L
				[UIColor colorFromHexString:@"F03E3E"],	// M
				[UIColor colorFromHexString:@"D6336C"],	// N
				[UIColor colorFromHexString:@"AE3EC9"],	// O
				[UIColor colorFromHexString:@"7048E8"],	// P
				[UIColor colorFromHexString:@"4263E8"],	// Q
				[UIColor colorFromHexString:@"1C7CD6"],	// R
				[UIColor colorFromHexString:@"1098AD"],	// S
				[UIColor colorFromHexString:@"0CA678"],	// T
				[UIColor colorFromHexString:@"37B24D"],	// U
				[UIColor colorFromHexString:@"74B816"],	// V
				[UIColor colorFromHexString:@"F59F00"],	// W
				[UIColor colorFromHexString:@"F76707"],	// X
				[UIColor colorFromHexString:@"F03E3E"],	// Y
				[UIColor colorFromHexString:@"D6336C"],	// Z
		];
	}
	return _alphabetBGColors;
}

- (NSArray *)bodyBGStartColors {
	if (!_bodyBGStartColors) {
		_bodyBGStartColors = @[
				[UIColor colorFromHexString:@"C92A2A"],	// A
				[UIColor colorFromHexString:@"A61E4D"],	// B
				[UIColor colorFromHexString:@"862E9C"],	// C
				[UIColor colorFromHexString:@"5F3DC4"],	// D
				[UIColor colorFromHexString:@"364FC7"],	// E
				[UIColor colorFromHexString:@"1862AB"],	// F
				[UIColor colorFromHexString:@"0B7285"],	// G
				[UIColor colorFromHexString:@"087F5B"],	// H
				[UIColor colorFromHexString:@"2B8A3E"],	// I
				[UIColor colorFromHexString:@"5C940D"],	// J
				[UIColor colorFromHexString:@"E67700"],	// K
				[UIColor colorFromHexString:@"D9480F"],	// L
				[UIColor colorFromHexString:@"C92A2A"],	// M
				[UIColor colorFromHexString:@"A61E4D"],	// N
				[UIColor colorFromHexString:@"862E9C"],	// O
				[UIColor colorFromHexString:@"5F3DC4"],	// P
				[UIColor colorFromHexString:@"364FC7"],	// Q
				[UIColor colorFromHexString:@"1862AB"],	// R
				[UIColor colorFromHexString:@"0B7285"],	// S
				[UIColor colorFromHexString:@"087F5B"],	// T
				[UIColor colorFromHexString:@"2B8A3E"],	// U
				[UIColor colorFromHexString:@"5C940D"],	// V
				[UIColor colorFromHexString:@"E67700"],	// W
				[UIColor colorFromHexString:@"D9480F"],	// X
				[UIColor colorFromHexString:@"C92A2A"],	// Y
				[UIColor colorFromHexString:@"A61E4D"],	// Z
		];
	}
	return _bodyBGStartColors;
}


#pragma mark - UIGestureRecognizerDelegate


#pragma mark - UIPreviewInteractionDelegate

- (BOOL)previewInteractionShouldBegin:(UIPreviewInteraction *)previewInteraction {
	if (self.sharePopupViewControllerIsPresented) {
		return NO;
	}
	CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
	if ([_collectionView indexPathForItemAtPoint:location]) {
		return YES;
	}
	location = [previewInteraction locationInCoordinateSpace:_tableView];
	
	return [_tableView indexPathForRowAtPoint:location] != nil;
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdatePreviewTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
	FNLOG(@"%f, _previewIsPresented = %@, ended = %@", transitionProgress, _previewIsPresented ? @"YES" : @"NO", ended ? @"YES" : @"NO");

	if (!_previewIsPresented) {
		_previewIsPresented = YES;
		
		if (!ended) {
			_blurEffectView = [[UIVisualEffectView alloc] init];
			_blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			_blurEffectView.frame = self.view.bounds;
			[self.view addSubview:_blurEffectView];
			
			_blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
			
			_animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveLinear animations:^{
				_blurEffectView.effect = nil;
			}];
			
			CGPoint location = [previewInteraction locationInCoordinateSpace:_tableView];
			if ([_tableView pointInside:location withEvent:nil]) {
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
					[self.view addSubview:_previewView];
					
					_previewBottomView = [UIView new];
					_previewBottomView.backgroundColor = cell.alphabetBottomView.backgroundColor;
					CGRect frame = [self.view convertRect:cell.alphabetTopView.frame fromView:cell];
					frame.origin.y = _previewView.frame.origin.y + _previewView.frame.size.height;
					_previewBottomView.frame = frame;
					
					[self.view addSubview:_previewBottomView];
				}
			} else {
				CGPoint location = [previewInteraction locationInCoordinateSpace:_collectionView];
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
						[self.view addSubview:_previewView];

						// Prepare data
						_selectedComponent = hashTagSection[A3AbbreviationKeyComponents][idx];
					}
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
	if (!self.presentedViewController) {
		[self removeBlurEffectView];
	}
	[_sharePopupViewController cancelCurrentInteractiveTransition];
	_sharePopupViewControllerIsPresented = NO;
	
	[self removePreviewView];
}

- (void)removePreviewView {
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

@end
