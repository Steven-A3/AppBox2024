//
//  A3WalletRecentsViewController.m
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 2022/08/15.
//  Copyright © 2022 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletRecentsViewController.h"
#import "WalletItem.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "UIColor+A3Addition.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"

@interface A3WalletRecentsViewController ()

@end

@implementation A3WalletRecentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = NSLocalizedString(@"Recents", nil);
    self.showCategoryInDetailViewController = YES;

    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidShow) name:A3NotificationMainMenuDidShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.tableView.contentInset = UIEdgeInsetsZero;
}

- (void)applicationDidEnterBackground {
    [self dismissInstructionViewController:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextWillSaveNotification object:nil];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidShow object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
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

- (void)cleanUp {
    [self dismissInstructionViewController:nil];
    [self removeObserver];
}

- (void)enableControls:(BOOL)enable {
    if (!IS_IPAD) return;
    [self.navigationItem.leftBarButtonItem setEnabled:enable];
    UIColor *disabledColor = [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255];
    self.tabBarController.tabBar.tintColor = enable ? nil : disabledColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self showLeftNavigationBarItems];
    
    // 페이지 들어올때마다 갱신한다.
    [self refreshItems];
}

- (void)cloudStoreDidImport {
    [self refreshItems];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshItems
{
    self.items = nil;
    [self.tableView reloadData];
}

- (void)mainMenuDidShow {
    [self enableControls:NO];
}

- (void)mainMenuDidHide {
    [self enableControls:YES];
}

- (NSMutableArray *)items
{
    if (!super.items) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastOpened != NULL"];
        super.items = [NSMutableArray arrayWithArray:[WalletItem findAllSortedBy:@"lastOpened" ascending:NO withPredicate:predicate]];
    }
    
    return super.items;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:indexPath walletItem:self.items[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowAtIndexPath:indexPath withItem:self.items[indexPath.row]];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

@end
