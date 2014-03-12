//
//  A3PopoverTableViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 2/21/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UITableViewCell * (^TableCellBlock)(UITableView *, NSIndexPath *);

@interface A3PopoverTableViewController : UITableViewController

@property (nonatomic, strong) TableCellBlock tableCellBlock;

- (void)setSectionArrayForTitles:(NSArray *)titles withDetails:(NSArray *)details;

@end
