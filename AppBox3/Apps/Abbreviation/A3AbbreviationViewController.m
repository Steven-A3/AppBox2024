//
//  A3AbbreviationViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/15/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationViewController.h"
#import "NSString+conversion.h"
#import "A3AbbreviationCollectionViewCell.h"
#import "A3AbbreviationTableViewCell.h"
#import "UIColor+A3Addition.h"
#import "A3AbbreviationDrillDownTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3AbbreviationCopiedViewController.h"
#import "A3SharePopupViewController.h"

NSString *const A3AbbreviationKeyTag = @"tag";
NSString *const A3AbbreviationKeyTags = @"tags";

NSString *const A3AbbreviationKeyComponents = @"components";
NSString *const A3AbbreviationKeySectionTitle = @"sectionTitle";

NSString *const A3AbbreviationKeyAbbreviation = @"abbreviation";
NSString *const A3AbbreviationKeyLetter = @"letter";
NSString *const A3AbbreviationKeyMeaning = @"meaning";

@interface A3AbbreviationViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIPreviewInteractionDelegate,
A3SharePopupViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray<NSDictionary *> *hashTagSections;
@property (nonatomic, strong) NSArray<NSDictionary *> *alphabetSections;

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

@end

@implementation A3AbbreviationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES];

	[self loadData];

	self.title = @"Abbreviation";
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCollectionView:)];
	tapGestureRecognizer.numberOfTapsRequired = 1;
	tapGestureRecognizer.delegate = self;
	
	[self.collectionView addGestureRecognizer:tapGestureRecognizer];

	if (IS_IOS10 && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
		_previewInteraction = [[UIPreviewInteraction alloc] initWithView:self.view];
		_previewInteraction.delegate = self;
	} else {
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCollectionView:)];
		longPressGestureRecognizer.minimumPressDuration = 1.0;
		longPressGestureRecognizer.delegate = self;
		[self.collectionView addGestureRecognizer:longPressGestureRecognizer];
	}
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
			
			NSDictionary *section = self.hashTagSections[indexPath.row];
			
			A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
			viewController.contentsArray = section[A3AbbreviationKeyComponents];
			viewController.contentsTitle = section[A3AbbreviationKeyTag];
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			// 섹션 내 상위 3개의 row 중 하나를 선택한 경우
			CGPoint pointInRoundedRect = [gestureRecognizer locationInView:cell.roundedRectView];
			NSInteger index = pointInRoundedRect.y / cell.roundedRectView.bounds.size.height / 3;

			NSDictionary *section = self.hashTagSections[indexPath.row];

			A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstance];
			[self.view addSubview:viewController.view];

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
		NSDictionary *section = self.hashTagSections[indexPath.row];
		
		A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
		viewController.contentsArray = section[A3AbbreviationKeyComponents];
		viewController.contentsTitle = section[A3AbbreviationKeyTag];
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		NSDictionary *section = self.hashTagSections[indexPath.row];

		CGFloat rowHeight = cell.roundedRectView.frame.size.height / 3;
		NSInteger idx = floor((pointInCell.y - cell.roundedRectView.frame.origin.y) / rowHeight);
		NSArray *components = section[A3AbbreviationKeyComponents];

		[self removeBlurEffectView];
		
		A3AbbreviationCopiedViewController *viewController = [A3AbbreviationCopiedViewController storyboardInstance];
		viewController.contents = components[idx];
		[self presentViewController:viewController animated:YES completion:NULL];
		_copiedViewController = viewController;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButtonAction:(id)sender {
	[super appsButtonAction:nil];
}

- (IBAction)favoritesButtonAction:(id)sender {
	
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.hashTagSections count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[A3AbbreviationCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *section = self.hashTagSections[indexPath.row];

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
    return [self.alphabetSections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[A3AbbreviationTableViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *section = self.alphabetSections[indexPath.row];
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
		NSArray *contents = self.alphabetSections[indexPath.row][A3AbbreviationKeyComponents];
		A3AbbreviationDrillDownTableViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[A3AbbreviationDrillDownTableViewController storyboardID]];
		viewController.contentsTitle = self.alphabetSections[indexPath.row][A3AbbreviationKeyLetter];
		viewController.contentsArray = contents;
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - Data Management

- (void)loadData {
	NSString *dataFilePath = [@"Abbreviation.json" pathInCachesDirectory];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:dataFilePath]) {
		dataFilePath = [[NSBundle mainBundle] pathForResource:@"Abbreviation.json" ofType:nil];
		if (![fileManager fileExistsAtPath:dataFilePath]) {
			return;
		}
	}
	NSData *rawData = [NSData dataWithContentsOfFile:dataFilePath];
	if (!rawData) {
		return;
	}
	NSError *error;
	NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:rawData options:NSJSONReadingAllowFragments error:&error];
	if (error) {
		FNLOG(@"%@", error.localizedDescription);
		return;
	}
	self.dataArray = dataArray;
	[self buildHashTagSections];
	[self buildAlphabetSections];
	
	FNLOG(@"%@", _hashTagSections);
	FNLOG(@"%@", _alphabetSections);
}

- (void)buildHashTagSections {
	NSMutableArray *hashTagSections = [NSMutableArray new];
	NSArray *availableTags = @[@"Top24", @"Romance", @"Business"];
	for (NSString *tag in availableTags) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", A3AbbreviationKeyTags, tag];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[hashTagSections addObject:@{A3AbbreviationKeyTag : tag, A3AbbreviationKeyComponents : components}];
	}
	_hashTagSections = hashTagSections;
}

- (void)buildAlphabetSections {
	NSMutableArray *alphabetSections = [NSMutableArray new];
	NSArray *alphabet = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
	for (NSString *letter in alphabet) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", A3AbbreviationKeyAbbreviation, letter];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[alphabetSections addObject:@{A3AbbreviationKeyLetter : letter, A3AbbreviationKeyComponents:components}];
	}
	_alphabetSections = alphabetSections;
}

/*
 /// Hash tag sections
 (
	{
		components =         (
			 {
				 abbreviation = B4N;
				 meaning = "Bye For Now ";
				 tags = Top24;
			 },
			 .... 생략
		);
		tag = Top24;
	},
	{
		components =         (
			{
				abbreviation = ALIWanIsU;
				meaning = "All I Want Is You";
				tags = Romance;
			},
			.... 생략
		);
		tag = Romance;
	},
	{
		components =         (
			 {
				 abbreviation = ADN;
				 meaning = "Any Day Now";
				 tags = Business;
			 },
		);
		tag = Business;
	}
 )
 
 /// Alphabet List
 (
	{
		 components =         (
			{
			 abbreviation = ADN;
			 meaning = "Any Day Now";
			 tags = Business;
			 },
		 );
		 letter = A;
	},
	{
		 components =         (
			 {
				 abbreviation = B2B;
				 meaning = "Business To Business";
				 tags = Business;
			 },
		);
		letter = B;
	},
	... Z까지 있음
 )
 */

- (NSArray *)hashTagSections {
	if (!_hashTagSections) {
		[self loadData];
	}
	return _hashTagSections;
}

- (NSArray *)alphabetSections {
	if (!_alphabetSections) {
		[self loadData];
	}
	return _alphabetSections;
}

/*
	{
		 component =         (
			 abbreviation = B2B;
			 meaning = "Business To Business";
			 tags = Business;
			 },
			 );
		 order = (double value);	새 항목 추가시 마지막 값 + 1.0
		 다른 항목 사이로 배치를 할 경우에는 위/아래 항목 순서값 / 2
	},
 */

- (NSArray *)favorites {
	return nil;
}

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


#pragma mark - UIViewControllerPreviewingDelegate


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
			
			_animator = [[UIViewPropertyAnimator alloc] initWithDuration:1.0 curve:UIViewAnimationCurveLinear animations:^{
				_blurEffectView.effect = nil;
			}];
			
			CGPoint location = [previewInteraction locationInCoordinateSpace:_tableView];
			if ([_tableView pointInside:location withEvent:nil]) {
				CGPoint locationInTableView = [previewInteraction locationInCoordinateSpace:_tableView];
				NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:locationInTableView];
				
				if (indexPath) {
					// Save data to use later
					_selectedComponent = [_alphabetSections[indexPath.row][A3AbbreviationKeyComponents][0] copy];
					
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
					NSDictionary *hashTagSection = _hashTagSections[indexPath.row];

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
		} else {
			double delayInSeconds = 0.5;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				_blurEffectView = [[UIVisualEffectView alloc] init];
				_blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				_blurEffectView.frame = self.view.bounds;
				[self.view addSubview:_blurEffectView];
				
				_blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
				
				_animator = [[UIViewPropertyAnimator alloc] initWithDuration:1.0 curve:UIViewAnimationCurveLinear animations:^{
					_blurEffectView.effect = nil;
				}];
				_animator.fractionComplete = 0.75;
			});
		}
	}

	if (ended) {
		[self removePreviewView];
	} else {
		_animator.fractionComplete = 1.0 - transitionProgress/4;
	}
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdateCommitTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
	FNLOG(@"%f, sharePopupViewControllerIsPresented = %@, ended = %@", transitionProgress, self.sharePopupViewControllerIsPresented ? @"YES" : @"NO", ended ? @"YES" : @"NO");
	
	if (!self.sharePopupViewControllerIsPresented) {
		_sharePopupViewController = [A3SharePopupViewController storyboardInstance];
		_sharePopupViewController.presentationIsInteractive = YES;
		_sharePopupViewController.delegate = self;
		_sharePopupViewController.contents = _selectedComponent;
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
	[self removePreviewView];
}

- (BOOL)sharePopupViewControllerIsPresented {
	return self.presentedViewController != nil;
}

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController {
	[self removeBlurEffectView];
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

@end
