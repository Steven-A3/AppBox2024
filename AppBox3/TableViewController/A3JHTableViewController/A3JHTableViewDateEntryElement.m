//
//  A3JHTableViewDateEntryElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewDateEntryElement.h"
#import "A3JHTableViewCell.h"

@implementation A3JHTableViewDateEntryElement

// KJH
- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	NSString *reuseIdentifier = @"A3JHTableViewDateEntryElement";
	A3JHTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3JHTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0];
	}
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = self.detailText;    // kjh
    
	return cell;
}

@end
