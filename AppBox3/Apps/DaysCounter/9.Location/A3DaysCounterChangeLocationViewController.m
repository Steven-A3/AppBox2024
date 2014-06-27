//
//  A3DaysCounterChangeLocationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2014. 1. 11..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterChangeLocationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "FSVenue.h"
#import "common.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NSString+conversion.h"
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import "A3AppDelegate+appearance.h"
#import "MBProgressHUD.h"


@interface A3DaysCounterChangeLocationViewController () <MBProgressHUDDelegate>
@property (strong, nonatomic) NSArray *tableDataSource;
@property (strong, nonatomic) MBProgressHUD *progressHud;
@end

@implementation A3DaysCounterChangeLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"Change Location", @"Change Location");
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
    self.tableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + 20, 0, 0, 0);
    self.tableDataSource = @[NSLocalizedString(@"Current Location", @"Current Location")];
	[self.searchBar setPlaceholder:NSLocalizedString(@"Enter an address or city name", nil)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, -(self.navigationController.navigationBar.frame.size.height + 20)) animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableDataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"locationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ( indexPath.row == 0 ) {
        cell.textLabel.text = NSLocalizedString(@"Current Location", @"Current Location");
        cell.textLabel.textColor = [A3AppDelegate instance].themeColor;
    }
    else {
        cell.textLabel.textColor = [UIColor darkTextColor];
        NSString *address = [_sharedManager addressFromPlacemark:[self.tableDataSource objectAtIndex:indexPath.row]];
        cell.textLabel.text = address;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *placemark = (indexPath.row == 0 ? nil : [_tableDataSource objectAtIndex:indexPath.row]);
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLocationViewController:didSelectLocation:searchText:)] ) {
        [self.delegate changeLocationViewController:self didSelectLocation:placemark searchText:self.searchBar.text];
    }
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( [searchText length] < 1 ) {
        return;
    }
    
    
	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.labelText = NSLocalizedString(@"Searching", @"Searching");
	self.progressHud.minShowTime = 2;
	self.progressHud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.progressHud.completionBlock = ^{
		weakSelf.progressHud = nil;
	};
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchText completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!placemarks || [error code] == kCLErrorGeocodeFoundNoResult) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"No Results Found", @"No Results Found")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }

        NSMutableArray *resultArray = [NSMutableArray new];
		[resultArray addObject:NSLocalizedString(@"Current Location", @"Current Location")];
        for (CLPlacemark *placemark in placemarks) {
            FNLOG(@"%s %@/%@",__FUNCTION__,placemark.name,placemark.addressDictionary);
            [resultArray addObject:placemark];
        }
        
        self.tableDataSource = resultArray;
        
        [self.tableView reloadData];
        if (self.progressHud) {
            [self.progressHud setHidden:YES];
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

@end
