//
//  A3WalletFieldStyleSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFieldStyleSelectViewController.h"
#import "WalletData.h"
#import "A3AppDelegate.h"
#import "UIViewController+NumberKeyboard.h"
#import "NSString+WalletStyle.h"

@interface A3WalletFieldStyleSelectViewController ()

@property (nonatomic, strong) NSMutableArray *fieldStyles;

@end

@implementation A3WalletFieldStyleSelectViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = NSLocalizedString(@"Field Style", @"Field Style");
    
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
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

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (NSMutableArray *)fieldStyles
{
    if (!_fieldStyles) {
        NSArray *typeList = [WalletData typeList];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", WalletFieldTypeID, _typeName];
        NSArray *types = [typeList filteredArrayUsingPredicate:predicate];
		if ([types count] >= 1) {
			NSDictionary *typeInfo = types[0];
			NSDictionary *styleDic = [WalletData styleList];
			NSArray *styleList = styleDic[typeInfo[WalletFieldNativeType]];
			_fieldStyles = [[NSMutableArray alloc] initWithArray:styleList];
		}
    }
    
    return _fieldStyles;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)styleStringAttributeWithColor:(UIColor *)color {
	return @{
             NSFontAttributeName : [UIFont systemFontOfSize:17],
             NSForegroundColorAttributeName:color};
}

- (NSDictionary *)egStringAttributeWithColor:(UIColor *)color {
	return @{
             NSFontAttributeName : [UIFont systemFontOfSize:17],
             NSForegroundColorAttributeName:color};
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *style = _fieldStyles[indexPath.row];
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletFieldStyleSelected:)]) {
        [_delegate walletFieldStyleSelected:style];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fieldStyles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
	cell.textLabel.font = [UIFont systemFontOfSize:17];

    NSString *fieldStyle = _fieldStyles[indexPath.row];

    NSAttributedString *styleString = [[NSAttributedString alloc] initWithString:NSLocalizedString(fieldStyle, nil)
                                                                     attributes:[self styleStringAttributeWithColor:[UIColor blackColor]]];
    NSMutableAttributedString *cellString = [[NSMutableAttributedString alloc] init];
    if ([fieldStyle isEqualToString:WalletFieldStyleNormal]) {
        [cellString appendAttributedString:styleString];
        cell.textLabel.attributedText = cellString;

    }
    else {
        NSString *egText = [NSString stringWithFormat:NSLocalizedString(@"  (e.g. %@)", nil), [@"12341234" stringForStyle:fieldStyle]];
        NSAttributedString *egString = [[NSAttributedString alloc] initWithString:egText
                                                                       attributes:[self egStringAttributeWithColor:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0]]];

        [cellString appendAttributedString:styleString];
        [cellString appendAttributedString:egString];
        cell.textLabel.attributedText = cellString;
    }



    if ([fieldStyle isEqualToString:_selectedStyle]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

@end
