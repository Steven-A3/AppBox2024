//
//  A3SalesCalcDetailInfoView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 24..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcDetailInfoViewController.h"
#import "A3SalesCalcData.h"
#import "A3SalesCalcCalculator.h"
#import "A3DefaultColorDefines.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+A3Addition.h"
#import "A3StandardLeft15Cell.h"
#import "UIColor+A3Addition.h"

@interface A3SalesCalcDetailInfoViewController ()

@end

@implementation A3SalesCalcDetailInfoViewController
{
    NSDictionary *_resultDic;
    A3SalesCalcData *_resultData;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Detail", @"Detail");
	[self rightBarButtonDoneButton];

    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);

#ifdef __IPHONE_8_0
	if (!IS_IOS7) {
		UITableView *view = self.tableView;
		if ([view respondsToSelector:@selector(setLayoutMargins:)]) {
			[view setLayoutMargins:UIEdgeInsetsZero];
		}
		self.tableView.backgroundColor = [UIColor colorWithRGBRed:239 green:239 blue:244 alpha:255];
		UIView *footerView = [UIView new];
		self.tableView.tableFooterView = footerView;
	}
#endif

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    FNLOG(@"%@", notification);
    [self.tableView reloadData];
}

#ifdef __IPHONE_8_0
- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	UITableView *view = self.tableView;
	if ([view respondsToSelector:@selector(setLayoutMargins:)]) {
		[view setLayoutMargins:UIEdgeInsetsZero];
	}
}
#endif

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 

- (void)setResult:(A3SalesCalcData *)resultData
{
    _resultData = resultData;
    _resultDic = [A3SalesCalcCalculator resultInfoForSalesCalcData:resultData];
    
    [self.tableView reloadData];
    
    CGRect rect = self.view.frame;
    rect.size.height = self.tableView.contentSize.height;
    self.view.frame = rect;
}

#pragma mark - Table view data source
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 || section == 3) {
        return 1;
    }
    
    return 2;
}

static NSString *CellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    A3StandardLeft15Cell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[A3StandardLeft15Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
		cell.detailTextLabel.textColor = COLOR_DEFAULT_TEXT_GRAY;
#ifdef __IPHONE_8_0
		if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
			[cell setLayoutMargins:UIEdgeInsetsZero];
		}
#endif
	}
    cell.backgroundColor = [UIColor whiteColor];

    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    if (indexPath.section == 0) {
		cell.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == 0) {
			[cell.textLabel setText:NSLocalizedString(@"Sale Price", @"Sale Price")];
            
            NSNumber *salePrice = [A3SalesCalcCalculator salePriceWithoutTaxForCalcData:_resultData];
            cell.detailTextLabel.text = [formatter stringFromNumber:salePrice];
            cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        }
        else {
			[cell.textLabel setText:NSLocalizedString(@"Sale Price Tax", @"Sale Price Tax")];
            NSNumber *salePriceTax = [A3SalesCalcCalculator salePriceTaxForCalcData:_resultData];
            cell.detailTextLabel.text = [formatter stringFromNumber:salePriceTax];
            cell.separatorInset = UIEdgeInsetsZero;
        }
    }
    else if (indexPath.section == 1) {
        cell.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        cell.separatorInset = UIEdgeInsetsZero;
    }
    else if (indexPath.section == 2) {
		cell.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == 0) {
			[cell.textLabel setText:NSLocalizedString(@"Original Price", @"Original Price")];
            NSNumber *originalPrice = [A3SalesCalcCalculator originalPriceBeforeTaxAndDiscountForCalcData:_resultData];
            cell.detailTextLabel.text = [formatter stringFromNumber:originalPrice];
            cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        }
        else {
			[cell.textLabel setText:NSLocalizedString(@"Original Price Tax", @"Original Price Tax")];
            cell.detailTextLabel.text = [formatter stringFromNumber:[A3SalesCalcCalculator originalPriceTaxForCalcData:_resultData]];
            cell.separatorInset = UIEdgeInsetsZero;
        }
    }
    else if (indexPath.section == 3) {
        cell.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        cell.separatorInset = UIEdgeInsetsZero;
    }
    else if (indexPath.section == 4) {
		cell.backgroundColor = [UIColor whiteColor];
        if (indexPath.row == 0) {
			[cell.textLabel setText:NSLocalizedString(@"Saved Amount", @"Saved Amount")];
            cell.detailTextLabel.text = [formatter stringFromNumber:[A3SalesCalcCalculator savedAmountForCalcData:_resultData]];
            cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        }
        else {
			[cell.textLabel setText:NSLocalizedString(@"Saved Amount Tax", @"Saved Amount Tax")];
            cell.detailTextLabel.text = [formatter stringFromNumber:[A3SalesCalcCalculator savedAmountTaxForCalcData:_resultData]];
			if (IS_IOS7 || IS_IPAD) {
				cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
			} else {
				cell.separatorInset = UIEdgeInsetsZero;
			}
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || indexPath.section == 3) {
        return 23;
    }
    
    if (IS_RETINA) {
        return indexPath.row == 0 ? 43.5 : 44.0;
    } else {
        return indexPath.row == 0 ? 43.0 : 44.0;
    }
}

@end
