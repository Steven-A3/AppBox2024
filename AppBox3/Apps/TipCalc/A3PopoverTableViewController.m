//
//  A3PopoverTableViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 2/21/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3PopoverTableViewController.h"
#import "A3DefaultColorDefines.h"
#import "UIColor+A3Addition.h"
#import "UIViewController+A3Addition.h"
#import "A3StandardLeft15Cell.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3UIDevice.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionType_Empty = 0,
    SectionType_Rows
};

#pragma mark - Class SectionArrayDataEntity
@interface SectionArrayDataEntity : NSObject
@property (nonatomic, assign) SectionType sectionType;
@property (nonatomic, strong) NSArray * sectionTitleRows;
@property (nonatomic, strong) NSArray * sectionDetailRows;
@end

@implementation SectionArrayDataEntity
@end


#pragma mark - Class A3PopoverTableViewController

@interface A3PopoverTableViewController ()
@property (nonatomic, strong) NSArray * tableDataSourceArray;
@end

@implementation A3PopoverTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.scrollEnabled = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorColor = A3UITableViewSeparatorColor;
    self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
		self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
	}
    self.tableView.backgroundColor = [UIColor colorWithRGBRed:239 green:239 blue:244 alpha:255];
    UIView *footerView = [UIView new];
    self.tableView.tableFooterView = footerView;
    
    if (IS_IPHONE) {
        [self rightBarButtonDoneButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if ([self.tableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = self.tableView.layoutMargins;
		layoutMargins.left = 0;
		self.tableView.layoutMargins = layoutMargins;
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Sections Rows Manipulate
- (void)setSectionArrayForTitles:(NSArray *)titles withDetails:(NSArray *)details {
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (int i = 0; i < [titles count]; i++) {
        SectionArrayDataEntity * sectionEntity = [SectionArrayDataEntity new];
        sectionEntity.sectionTitleRows = [titles objectAtIndex:i];
        sectionEntity.sectionDetailRows = [details objectAtIndex:i];
        sectionEntity.sectionType = SectionType_Rows;
        [tempArray addObject:sectionEntity];

        if (i < [titles count] - 1) {
            sectionEntity = [SectionArrayDataEntity new];
            sectionEntity.sectionTitleRows = @[@""];
            sectionEntity.sectionDetailRows = @[@""];
            sectionEntity.sectionType = SectionType_Empty;
            [tempArray addObject:sectionEntity];
        }
    }
    
    self.tableDataSourceArray = tempArray;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableDataSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.tableDataSourceArray objectAtIndex:section] sectionTitleRows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableCellBlock) {
        return _tableCellBlock(tableView, indexPath);
    }
    
    static NSString *CellIdentifier = @"Cell";
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
			UIEdgeInsets layoutMargins = cell.layoutMargins;
			layoutMargins.left = 0;
			cell.layoutMargins = layoutMargins;
		}
#endif
	}

    SectionArrayDataEntity * section = [self.tableDataSourceArray objectAtIndex:[indexPath section]];
    switch (section.sectionType) {
        case SectionType_Rows:
        {
            cell.textLabel.text = [section.sectionTitleRows objectAtIndex:[indexPath row]];
            cell.detailTextLabel.text = [section.sectionDetailRows objectAtIndex:[indexPath row]];
            cell.backgroundColor = [UIColor whiteColor];
            
            if (([indexPath row] == [section.sectionTitleRows count] - 1)) {
                if ((IS_IPAD) && ([indexPath section] == [self.tableDataSourceArray count] - 1)) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
                } else {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
            else {
                cell.separatorInset = A3UITableViewSeparatorInset;
            }
        }
            break;
        case SectionType_Empty:
        {
            cell.textLabel.text = [section.sectionTitleRows objectAtIndex:[indexPath row]];
            cell.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SectionArrayDataEntity * section = [self.tableDataSourceArray objectAtIndex:[indexPath section]];
    
    if (section.sectionType == SectionType_Empty) {
        return 23;
    }

    if (IS_RETINA) {
        return indexPath.row == 0 ? 43.5 : 44.0;
    }
    else {
        return indexPath.row == 0 ? 43.0 : 44.0;
    }
}


@end
