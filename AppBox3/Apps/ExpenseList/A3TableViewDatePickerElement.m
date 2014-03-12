//
//  A3TableViewDatePickerElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 11/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewDatePickerElement.h"
#import "A3TableViewDatePickerCell.h"

@implementation A3TableViewDatePickerElement
{
    NSIndexPath *_currentIndexPath;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3TableViewDatePickerCell";
	A3TableViewDatePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewDatePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.datePicker setDatePickerMode:UIDatePickerModeDate];
        [cell.datePicker addTarget:self action:@selector(didChangeDatePickerValue:) forControlEvents:UIControlEventValueChanged];
        _height = cell.datePicker.frame.size.height;
	}
    
    if (self.dateValue) {
        cell.datePicker.date = self.dateValue;
    }
    
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
    NSLog(@"%@", cell.datePicker);
    
	return cell;
}

-(void)didChangeDatePickerValue:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    _dateValue = datePicker.date;
    
    if (_cellValueChangedBlock) {
        _cellValueChangedBlock(self);
    }
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    //A3TableViewDatePickerCell *cell = (A3TableViewDatePickerCell *)[tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    //cell = (A3TableViewDatePickerCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row==0 inSection:indexPath.section]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
