//
//  A3DaysCounterLocationDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterLocationDetailViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSetupLocationViewController.h"
#import "common.h"
#import "A3PlacemarkBackgroundView.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NSString+conversion.h"
#import "A3DaysCounterLocationPopupViewController.h"

@interface A3DaysCounterLocationDetailViewController ()
@property (strong, nonatomic) NSString *addressStr;
@property (strong, nonatomic) UIPopoverController *popoverVC;

- (void)editAction:(UIBarButtonItem*)button;
@end

@implementation A3DaysCounterLocationDetailViewController

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
    self.title = @"Location";
    if ( self.isEditMode ) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    }
    else {
        [self rightBarButtonDoneButton];
    }
    [self makeBackButtonEmptyArrow];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
//    _tableView.separatorInset = UIEdgeInsetsMake(0, 44.0, 0, 0);
//    self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _isEditMode ) {
        NSDictionary *locItem = [_eventModel objectForKey:EventItem_Location];
        if (([[locItem objectForKey:EventItem_Latitude] isKindOfClass:[NSNumber class]] && [[locItem objectForKey:EventItem_Longitude] isKindOfClass:[NSNumber class]]) &&
            ([[locItem objectForKey:EventItem_Latitude] doubleValue] != _locationItem.location.coordinate.latitude ||
             [[locItem objectForKey:EventItem_Longitude] doubleValue] != _locationItem.location.coordinate.longitude )) {
            [_mapView removeAnnotation:self.locationItem];
            self.locationItem = [[A3DaysCounterModelManager sharedManager] fsvenueFromEventModel:locItem];
            self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
            
            [_tableView reloadData];
        }
    }
    
    if ( [_mapView.annotations count] < 1 ) {
        [_mapView addAnnotation:self.locationItem];
    }
    
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_locationItem.coordinate, 2000.0, 2000.0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.addressStr = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_isEditMode ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 1 )
        return 1;
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( section == 1 )
        return 18.0;
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 1 )
        return 18.0;
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = (indexPath.section == 0 ? @"locationDetailCell" : @"deleteCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if ( cell == nil ) {
        if ( indexPath.section == 0) {
            NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterLocationDetailCell" owner:nil options:nil];
            cell = [cellArray objectAtIndex:0];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
    if ( indexPath.section == 0) {
        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
        UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
        
        if ( indexPath.row == 0 ) {
            textLabel.text = @"Phone";
            detailTextLabel.text = _locationItem.contact;
            cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
        }
        else {
            textLabel.text = @"Address";
            detailTextLabel.text = _addressStr;
//            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.frame), 0, 0);
            cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.contentView.frame), 0, 0);
//            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(cell.contentView.frame));
        }
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Delete Location";
        cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(cell.contentView.frame));
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ( indexPath.section == 0 ) {
//        UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
//        for (NSLayoutConstraint *layout in cell.contentView.constraints) {
//            if ( layout.firstItem == textLabel && layout.firstAttribute == NSLayoutAttributeLeading ) {
//                layout.constant = (IS_IPHONE ? 15.0 : 28.0);
//            }
//        }
//        [cell layoutIfNeeded];
//        cell.separatorInset = UIEdgeInsetsMake(0, 100, 0, 0);
//        return;
//    }
//    
//    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.contentView.frame.size.width, cell.textLabel.frame.size.height);
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        NSString *str = (indexPath.row == 0 ? _locationItem.contact : _addressStr);
        CGRect rect = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width-35.0, 99999.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]} context:nil];
        CGFloat retHeight = 15.0 + 17.0 + 10.0 + ceilf(rect.size.height) + 15.0;
//        NSLog(@"%s %@ / %f",__FUNCTION__,NSStringFromCGRect(rect),retHeight);
//        if ( retHeight < (tableView.frame.size.height-44.0))
//            retHeight = tableView.frame.size.height - 44.0;
        return retHeight;
    }
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        return;
    }
    
    [self deleteLocationAction:nil];
}

#pragma mark - action method
- (void)editAction:(UIBarButtonItem*)button
{
    A3DaysCounterSetupLocationViewController *viewCtrl = [[A3DaysCounterSetupLocationViewController alloc] initWithNibName:@"A3DaysCounterSetupLocationViewController" bundle:nil];
    viewCtrl.eventModel = self.eventModel;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    NSMutableDictionary *locItem = [[A3DaysCounterModelManager sharedManager] emptyEventLocationModel];
    [locItem setObject:[_eventModel objectForKey:EventItem_ID] forKey:EventItem_ID];
    [locItem setObject:@(_locationItem.location.coordinate.latitude) forKey:EventItem_Latitude];
    [locItem setObject:@(_locationItem.location.coordinate.longitude) forKey:EventItem_Longitude];
    [locItem setObject:_locationItem.name forKey:EventItem_LocationName];
    [locItem setObject:([_locationItem.location.country length] > 0 ? _locationItem.location.country : @"") forKey:EventItem_Country];
    [locItem setObject:([_locationItem.location.state length] > 0 ? _locationItem.location.state : @"") forKey:EventItem_State];
    [locItem setObject:([_locationItem.location.city length] > 0 ? _locationItem.location.city : @"") forKey:EventItem_City];
    [locItem setObject:([_locationItem.location.address length] > 0 ? _locationItem.location.address : @"") forKey:EventItem_Address];
    [locItem setObject:([_locationItem.contact length] > 0 ? _locationItem.contact : @"") forKey:EventItem_Contact];
    [_eventModel setObject:locItem forKey:EventItem_Location];
    
    if ( _isEditMode ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if ( IS_IPHONE ) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            if ( [self.navigationController.viewControllers count] > 2 ) {
                UIViewController *viewCtrl = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
                [self.navigationController popToViewController:viewCtrl animated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (IBAction)deleteLocationAction:(id)sender {
    [_eventModel removeObjectForKey:EventItem_Location];
    
    if ( _isEditMode ) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        if ( IS_IPHONE )
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
    }
    
	static NSString *identifier = @"A3MapViewAnnotation";
    
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (nil == annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.draggable = NO;
	}
    
    if ([annotation respondsToSelector:@selector(title)] && [annotation title]) {
		annotationView.canShowCallout = YES;
    }
    
//    if (!self.popoverVC) {
//        A3DaysCounterLocationPopupViewController *viewCtrl = [[A3DaysCounterLocationPopupViewController alloc] initWithNibName:@"A3DaysCounterLocationPopupViewController" bundle:nil];
//        viewCtrl.locationItem = annotationView.annotation;
//        
//        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
//        CGSize size = viewCtrl.view.frame.size;
//        
//        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
//        self.popoverVC.delegate = self;
//        viewCtrl.popoverVC = self.popoverVC;
//        [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, size.height + 44.0) animated:NO];
//        [self.popoverVC presentPopoverFromRect:annotationView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
//    }
        
	annotationView.animatesDrop = YES;
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ( IS_IPAD ) {
        [mapView deselectAnnotation:view.annotation animated:NO];
        
        A3DaysCounterLocationPopupViewController *viewCtrl = [[A3DaysCounterLocationPopupViewController alloc] initWithNibName:@"A3DaysCounterLocationPopupViewController" bundle:nil];
        viewCtrl.locationItem = view.annotation;
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        CGSize size = viewCtrl.view.frame.size;
        
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        self.popoverVC.delegate = self;
        viewCtrl.popoverVC = self.popoverVC;
        [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, size.height + 44.0) animated:NO];
        [self.popoverVC presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [_mapView selectAnnotation:_locationItem animated:YES];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}

@end
