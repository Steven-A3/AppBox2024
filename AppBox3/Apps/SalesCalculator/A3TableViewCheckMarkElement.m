//
//  A3SalesCalcPriceTypeElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewCheckMarkElement.h"
#import "A3JHTableViewCell.h"
#import "A3SalesCalcPreferences.h"
//#import "UIScrollView+removeAutoScroll.h"

@implementation A3TableViewCheckMarkElement

@dynamic title;

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3TableViewElementCell";
	A3JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3JHTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0];
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = _checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    if (indexPath.row==0) {
//        cell.accessoryType = [A3SalesCalcPreferences priceType] == ShowPriceType_Origin ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    } else {
//        cell.accessoryType = [A3SalesCalcPreferences priceType] == ShowPriceType_SalePriceWithTax ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    }

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    A3JHTableViewCell *cell = (A3JHTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell = (A3JHTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row==0 inSection:indexPath.section]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
