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

NSString *const A3AbbreviationKeyTag = @"tag";
NSString *const A3AbbreviationKeyTags = @"tags";
NSString *const A3AbbreviationKeyComponents = @"components";
NSString *const A3AbbreviationKeyAbbreviation = @"abbreviation";
NSString *const A3AbbreviationKeyLetter = @"letter";
NSString *const A3AbbreviationKeyMeaning = @"meaning";

@interface A3AbbreviationViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray<NSDictionary *> *hasTagSections;
@property (nonatomic, strong) NSArray<NSDictionary *> *alphabetSections;

@property (nonatomic, strong) NSArray<UIColor *> *headStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *alphabetBGColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGStartColors;
@property (nonatomic, strong) NSArray<UIColor *> *bodyBGEndColors;

@end

@implementation A3AbbreviationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES];

	[self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appsButtonAction:(id)sender {
	
}

- (IBAction)favoritesButtonAction:(id)sender {
	
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.hasTagSections count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	A3AbbreviationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[A3AbbreviationCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *section = self.hasTagSections[indexPath.row];

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

	cell.backgroundHeadView.gradientColors = @[(__bridge id)baseColor.CGColor, (__bridge id)endColor.CGColor];

	if (indexPath.row > 0) {
		cell.clipToTrapezoid = NO;
		cell.alphabetTopView.backgroundColor = self.alphabetBGColors[indexPath.row - 1];
	} else {
		cell.alphabetTopView.backgroundColor = [UIColor whiteColor];
		cell.clipToTrapezoid = YES;
	}
	cell.backgroundBodyView.gradientColors = @[(__bridge id)self.bodyBGStartColors[indexPath.row].CGColor, (__bridge id)self.alphabetBGColors[indexPath.row].CGColor];

	[cell.backgroundBodyView setNeedsDisplay];
    return cell;
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
}

- (void)buildHashTagSections {
	NSMutableArray *hashTagSections = [NSMutableArray new];
	NSArray *availableTags = @[@"Top24", @"Romance", @"Business"];
	for (NSString *tag in availableTags) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS %@", A3AbbreviationKeyTags, tag];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[hashTagSections addObject:@{A3AbbreviationKeyTag : tag, A3AbbreviationKeyComponents : components}];
	}
	_hasTagSections = hashTagSections;
}

- (void)buildAlphabetSections {
	NSMutableArray *alphabetSections = [NSMutableArray new];
	NSArray *alphabet = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
	for (NSString *letter in alphabet) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH %@", A3AbbreviationKeyAbbreviation, letter];
		NSArray *components = [self.dataArray filteredArrayUsingPredicate:predicate];
		[alphabetSections addObject:@{A3AbbreviationKeyLetter:letter, A3AbbreviationKeyComponents:components}];
	}
	_alphabetSections = alphabetSections;
}

- (NSArray *)hashTagSections {
	if (!_hasTagSections) {
		[self loadData];
	}
	return _hasTagSections;
}

- (NSArray *)alphabetSections {
	if (!_alphabetSections) {
		[self loadData];
	}
	return _alphabetSections;
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

@end
