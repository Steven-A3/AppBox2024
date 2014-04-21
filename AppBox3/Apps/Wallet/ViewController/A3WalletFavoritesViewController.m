//
//  A3WalletFavoritesViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletFavoritesViewController.h"
#import "A3WalletItemViewController.h"
#import "A3WalletPhotoItemViewController.h"
#import "A3WalletVideoItemViewController.h"
#import "A3WalletListPhotoCell.h"
#import "WalletData.h"
#import "WalletCategory.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "WalletFavorite.h"
#import "NSString+WalletStyle.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+A3Addition.h"
#import "NSDate+TimeAgo.h"
#import "WalletFieldItem+initialize.h"


@interface A3WalletFavoritesViewController ()

@property (nonatomic, strong) NSMutableArray *favorites;

@end

@implementation A3WalletFavoritesViewController

NSString *const A3WalletTextCellID2 = @"A3WalletListTextCell";
NSString *const A3WalletPhotoCellID2 = @"A3WalletListPhotoCell";

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

    self.navigationItem.title = @"Favorites";

	[self makeBackButtonEmptyArrow];

    // more tabBar 안에서도 좌측barItem을 Apps로 유지한다.
    self.navigationItem.hidesBackButton = YES;
    [self leftBarButtonAppsButton];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.rowHeight = 48.0;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    if (IS_IPAD) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28, 0, 0);
    }
    
    [self.tableView registerClass:[A3WalletListPhotoCell class] forCellReuseIdentifier:A3WalletPhotoCellID2];

    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)showLeftNavigationBarItems
{
    // 현재 more탭바인지 여부 체크
    if (_isFromMoreTableViewController) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
        // more 탭바
        
        self.navigationItem.hidesBackButton = NO;
        
        if (IS_IPAD) {
            if (IS_LANDSCAPE) {
                self.navigationItem.leftBarButtonItem = nil;
            }
            else {
                UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
                self.navigationItem.leftBarButtonItem = appsItem;
            }
        }
        else {
            UIBarButtonItem *appsItem = [[UIBarButtonItem alloc] initWithTitle:@"Apps" style:UIBarButtonItemStylePlain target:self action:@selector(appsButtonAction:)];
            self.navigationItem.leftBarButtonItem = appsItem;
        }
    } else {
        self.navigationItem.hidesBackButton = YES;

		[self leftBarButtonAppsButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[self showLeftNavigationBarItems];
    
    // 페이지 들어올때마다 갱신한다.
    [self refreshItems];
    
    // edit 버튼 활성화 여부
    BOOL editable = (self.favorites.count>0) ? YES:NO;
    self.navigationItem.rightBarButtonItem.enabled = editable;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    
	if (IS_IPAD) {
        
        if (self.editing) {
            
        }
        else {
			[self showLeftNavigationBarItems];
        }
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
		self.navigationItem.leftBarButtonItem = nil;
    } else {
		[self leftBarButtonAppsButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshItems
{
    _favorites = nil;
    [self.tableView reloadData];
}

- (NSMutableArray *)favorites
{
    if (!_favorites) {
        _favorites = [NSMutableArray arrayWithArray:[WalletFavorite MR_findAllSortedBy:@"order" ascending:YES]];
    }
    
    return _favorites;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WalletFavorite *favorite = _favorites[indexPath.row];
    WalletItem *item = favorite.item;

    if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletPhotoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletPhotoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletVideoItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletVideoItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        NSString *boardName = IS_IPAD ? @"WalletPadStoryBoard":@"WalletPhoneStoryBoard";
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:boardName bundle:nil];
        A3WalletItemViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemViewController"];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.item = item;
        viewController.showCategory = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
		if ([[self.favorites objectAtIndex:indexPath.row] isKindOfClass:[WalletFavorite class]]) {
            
            WalletFavorite *favorite = _favorites[indexPath.row];
            WalletItem *item = favorite.item;
            
            if ([item.category.name isEqualToString:WalletCategoryTypePhoto]) {
                A3WalletListPhotoCell *photoCell;
                photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID2 forIndexPath:indexPath];
                
                photoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                photoCell.rightLabel.text = [item.modificationDate timeAgo];
                
                NSMutableArray *photoPick = [[NSMutableArray alloc] init];
                NSArray *fieldItems = [item fieldItemsArray];
                for (int i=0; i<fieldItems.count; i++) {
                    WalletFieldItem *fieldItem = fieldItems[i];
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && fieldItem.image) {
                        [photoPick addObject:fieldItem];
                    }
                }
                
                NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
                NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);
                
                [photoCell resetThumbImages];

                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    [photoCell addThumbImage:fieldItem.thumbnailImage];
                }
                
                cell = photoCell;
            }
            else if ([item.category.name isEqualToString:WalletCategoryTypeVideo]) {
                A3WalletListPhotoCell *videoCell;
                videoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletPhotoCellID2 forIndexPath:indexPath];
                
                videoCell.rightLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                videoCell.rightLabel.text = [item.modificationDate timeAgo];
                
                NSMutableArray *photoPick = [[NSMutableArray alloc] init];
                NSArray *fieldItems = [item fieldItemsArray];
                for (int i=0; i<fieldItems.count; i++) {
                    WalletFieldItem *fieldItem = fieldItems[i];
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && fieldItem.hasVideo) {
                        [photoPick addObject:fieldItem];
                    }
                }
                
                NSInteger maxPhotoCount = (IS_IPAD) ? 5 : 2;
                NSInteger showPhotoCount = MIN(maxPhotoCount, photoPick.count);

                [videoCell resetThumbImages];
                for (int i=0; i<showPhotoCount; i++) {
                    WalletFieldItem *fieldItem = photoPick[i];
                    [videoCell addThumbImage:fieldItem.thumbnailImage];
                }
                
                cell = videoCell;
            }
            else {
                /*
                A3WalletListTextCell *dataCell;
                dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID2 forIndexPath:indexPath];
                
                dataCell.titleLabel.text = item.name;
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                if (fieldItems.count>0) {
                    WalletFieldItem *fieldItem = fieldItems[0];
                    NSString *itemValue = @"";
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                        itemValue = [df stringFromDate:fieldItem.date];
                    }
                    else {
                        itemValue = fieldItem.value;
                    }
                    
                    if (itemValue && (itemValue.length>0)) {
                        NSString *styleValue = [itemValue stringForStyle:fieldItem.field.style];
                        dataCell.detailLabel.text = styleValue;
                    }
                    else {
                        dataCell.detailLabel.text = @"";
                    }
                }
                else {
                    dataCell.detailLabel.text = @"";
                }
                
                cell = dataCell;
                 */
                
                UITableViewCell *dataCell;
                dataCell = [tableView dequeueReusableCellWithIdentifier:A3WalletTextCellID2];
                if (dataCell == nil) {
                    dataCell = [[UITableViewCell alloc] initWithStyle:IS_IPAD ? UITableViewCellStyleValue1:UITableViewCellStyleSubtitle reuseIdentifier:A3WalletTextCellID2];
                    dataCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    dataCell.detailTextLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
                }
				if (IS_IPHONE) {
					dataCell.textLabel.font = [UIFont systemFontOfSize:15];
					dataCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
				}
				else {
					dataCell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
					dataCell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
				}

                if (item.name && item.name.length>0) {
                    dataCell.textLabel.text = item.name;
                }
                else {
                    dataCell.textLabel.text = @"New Item";
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
                NSArray *fieldItems = [item.fieldItems sortedArrayUsingDescriptors:@[sortDescriptor]];
                if (fieldItems.count>0) {
                    WalletFieldItem *fieldItem = fieldItems[0];
                    NSString *itemValue = @"";
                    if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                        itemValue = [df stringFromDate:fieldItem.date];
                    }
                    else {
                        itemValue = fieldItem.value;
                    }
                    
                    if (itemValue && (itemValue.length>0)) {
                        NSString *styleValue = [itemValue stringForStyle:fieldItem.field.style];
                        dataCell.detailTextLabel.text = styleValue;
                    }
                    else {
                        dataCell.detailTextLabel.text = @"";
                    }
                }
                else {
                    dataCell.detailTextLabel.text = @"";
                }
                
                cell = dataCell;
            }
		}
	}
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        WalletFavorite *favorite = _favorites[indexPath.row];
        [_favorites removeObject:favorite];
        
        [favorite.item MR_deleteEntity];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    @autoreleasepool {
		[self.favorites moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
	}
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
