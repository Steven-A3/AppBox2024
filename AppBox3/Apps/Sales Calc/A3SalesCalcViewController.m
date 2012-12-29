//
//  A3SalesCalcViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcViewController.h"
#import "CommonUIDefinitions.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarChartView.h"
#import "common.h"
#import "A3CurrencyKeyboardViewController.h"

@interface A3SalesCalcViewController ()

@property (nonatomic, strong) A3CurrencyKeyboardViewController *keyboardViewController;

@end

@implementation A3SalesCalcViewController

- (void)assignRowHeightToElementInSection:(QSection *)section {
	CGFloat rowHeight = 58.0f;
	for (QElement *element in section.elements) {
		element.height = rowHeight;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	// Custom initialization
    self = [super initWithNibName:nil bundle:nil];
	if (self) {
		QRootElement *myRoot = [[QRadioElement alloc] init];
		myRoot.controllerName = @"A3SalesCalcViewController";
		myRoot.title = @"Sales Calc";
		myRoot.grouped = YES;

		QRadioSection *section1 = [[QRadioSection alloc] initWithItems:@[@"Original Price", @"Sale Price"] selected:0 title:@"Select Known Value"];
	 	[self assignRowHeightToElementInSection:section1];
		[myRoot addSection:section1];

		QSection *section2 = [[QSection alloc] init];
		QEntryElement *price = [[QEntryElement alloc] initWithTitle:@"Price:" Value:@"" Placeholder:@"$0.00 USD"];
		price.delegate = self;
		[section2 addElement:price];
		QEntryElement *discount = [[QEntryElement alloc] initWithTitle:@"Discount:" Value:@"" Placeholder:@"0%"];
		discount.delegate = self;
		[section2 addElement:discount];
		QEntryElement *additionalOff = [[QEntryElement alloc] initWithTitle:@"Additional Off:" Value:@"" Placeholder:@"0%"];
		additionalOff.delegate = self;
		[section2 addElement:additionalOff];
		QEntryElement *tax = [[QEntryElement alloc] initWithTitle:@"Tax:" Value:@"" Placeholder:@"0%"];
		tax.delegate = self;
		[section2 addElement:tax];
		QMultilineElement *notes = [QMultilineElement new];
		notes.title = @"Notes:";
		notes.delegate = self;
		[section2 addElement:notes];
		QButtonElement *simple = [[QButtonElement alloc] initWithTitle:@"Simple"];
		[simple setControllerAction:@"onChangeType"];
		[section2 addElement:simple];

		[self assignRowHeightToElementInSection:section2];
		[myRoot addSection:section2];

		[self setRoot:myRoot];

		[self.view setFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, [A3UIDevice applicationHeightForCurrentOrientation])];

		UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, 120.0f)];
		CGFloat offsetX = 44.0f, offsetY = 38.0f;
		CGFloat chartHeight = 44.0f;
		CGFloat chartWidth = APP_VIEW_WIDTH - offsetX * 2.0f;
		CGFloat labelHeight = 23.0f;
		UIColor *chartLabelColor = [UIColor colorWithRed:73.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
		UIFont *chartLabelFont = [UIFont boldSystemFontOfSize:18.0f];

		UILabel *labelLeftTop = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + chartHeight / 2.0f, 12.0f, chartWidth / 2.0f - chartHeight / 2.0f, labelHeight)];
		labelLeftTop.backgroundColor = [UIColor clearColor];
		labelLeftTop.font = chartLabelFont;
		labelLeftTop.textColor = chartLabelColor;
		labelLeftTop.text = @"Sale Price";
		[tableHeaderView addSubview:labelLeftTop];

		UILabel *labelRightTop = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + chartWidth / 2.0f, 12.0f, chartWidth / 2.0f - chartHeight/ 2.0f, labelHeight)];
		labelRightTop.backgroundColor = [UIColor clearColor];
		labelRightTop.font = chartLabelFont;
		labelRightTop.textColor = chartLabelColor;
		labelRightTop.textAlignment = NSTextAlignmentRight;
		labelRightTop.text = @"Amount Saved";
		[tableHeaderView addSubview:labelRightTop];

		UILabel *labelRightBottom = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY + chartHeight + 5.0f, chartWidth - chartHeight / 2.0f, labelHeight)];
		labelRightBottom.backgroundColor = [UIColor clearColor];
		labelRightBottom.font = chartLabelFont;
		labelRightBottom.textColor = chartLabelColor;
		labelRightBottom.textAlignment = NSTextAlignmentRight;
		labelRightBottom.text = @"Original Price";
		[tableHeaderView addSubview:labelRightBottom];

		A3HorizontalBarChartView *barChartView = [[A3HorizontalBarChartView alloc] initWithFrame:CGRectMake(offsetX, offsetY, APP_VIEW_WIDTH - offsetX * 2.0f, chartHeight)];
		[tableHeaderView addSubview:barChartView];

		self.quickDialogTableView.tableHeaderView = tableHeaderView;
		self.quickDialogTableView.styleProvider = self;
		self.quickDialogTableView.backgroundView = nil;
		self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
		self.quickDialogTableView.rowHeight = 58.0f;
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QuickDialogStyleProvider

- (UIColor *)darkBlueColor {
	return [UIColor colorWithRed:40.0f/255.0f green:72.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
}

- (UIColor *)grayColor {
	return [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
}

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];

	switch (indexPath.section) {
		case 0:
			cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0f];
			if ([element.parentSection isKindOfClass:[QRadioSection class]]) {
				QRadioSection *radioSection = (QRadioSection *)element.parentSection;
				if (radioSection.selected == indexPath.row) {
					cell.textLabel.textColor = [self darkBlueColor];
				} else {
					cell.textLabel.textColor = [self grayColor];
				}
			}
			break;
		case 1:
			cell.textLabel.font = [UIFont systemFontOfSize:25.0f];
			if ([element isKindOfClass:[QButtonElement class]]) {
				cell.textLabel.textColor = [self darkBlueColor];
			} else {
				cell.textLabel.textColor = [self grayColor];
			}
			if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
				QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;
				[entryTableViewCell.textField setFont:[UIFont boldSystemFontOfSize:25.0f]];
				entryTableViewCell.textField.inputView = self.keyboardViewController.view;
			}
			break;
	}
}

-(void) sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, 44.0f)];
	UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 0.0f, APP_VIEW_WIDTH - 64.0f * 2.0f, 44.0f)];
	sectionText.backgroundColor = [UIColor clearColor];
	sectionText.font = [UIFont boldSystemFontOfSize:24.0f];
	sectionText.textColor = [UIColor blackColor];
	sectionText.text = section.title;
	[headerView addSubview:sectionText];

	section.headerView = headerView;
}

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    _keyboardViewController.keyInputDelegate = cell.textField;
}

- (A3CurrencyKeyboardViewController *)keyboardViewController {
	if (nil == _keyboardViewController) {
		_keyboardViewController = [[A3CurrencyKeyboardViewController alloc] initWithNibName:@"A3CurrencyKeyboardViewController" bundle:nil];
	}
	return _keyboardViewController;
}

@end
