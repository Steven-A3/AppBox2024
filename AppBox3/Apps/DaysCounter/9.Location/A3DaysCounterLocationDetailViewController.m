//
//  A3DaysCounterLocationDetailViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterLocationDetailViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSetupLocationViewController.h"
#import "common.h"
#import "A3PlacemarkBackgroundView.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NSString+conversion.h"
#import "A3DaysCounterLocationPopupViewController.h"
#import "A3GradientView.h"
#import "DaysCounterEvent+extension.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"

@interface A3DaysCounterLocationDetailViewController ()
@property (strong, nonatomic) NSString *addressStr;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (nonatomic, strong) A3GradientView *tableViewTopBlurView;

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

    self.title = NSLocalizedString(@"Location", @"Location");
    
    if (self.isEditMode) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    }
    else {
        [self rightBarButtonDoneButton];
    }
    
    [self makeBackButtonEmptyArrow];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view addSubview:self.tableViewTopBlurView];
    [self.tableViewTopBlurView bringSubviewToFront:self.mapView];
    [self.tableViewTopBlurView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mapView.left);
        make.right.equalTo(self.mapView.right);
        make.height.equalTo(@5);
        make.bottom.equalTo(self.mapView.bottom);
    }];
    
    self.addressStr = [_sharedManager addressFromVenue:_locationItem isDetail:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _isEditMode ) {
        DaysCounterEventLocation_ *locItem = [_eventModel location];
        if ( (locItem.latitude && locItem.longitude) &&
            ([locItem.latitude doubleValue] != _locationItem.location.coordinate.latitude ||
             [locItem.longitude doubleValue] != _locationItem.location.coordinate.longitude) ) {
                [_mapView removeAnnotation:self.locationItem];
                self.locationItem = [_sharedManager fsvenueFromEventModel:locItem];
                self.addressStr = [_sharedManager addressFromVenue:_locationItem isDetail:YES];
                
                [_tableView reloadData];
        }
    }
    
    if ( [_mapView.annotations count] < 1 ) {
        [_mapView addAnnotation:self.locationItem];
        [_mapView selectAnnotation:self.locationItem animated:YES];
    }
    
    [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_locationItem.coordinate, 2000.0, 2000.0) animated:YES];
    if ([self.navigationController.navigationBar isHidden]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
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

#pragma mark
- (A3GradientView *)tableViewTopBlurView {
    if (!_tableViewTopBlurView) {
        _tableViewTopBlurView = [A3GradientView new];
        _tableViewTopBlurView.gradientColors = @[
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.18].CGColor
                                                 ];
    }
    
    return _tableViewTopBlurView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_isEditMode ? 2 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 1 ) {
        return 1;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ( section == 1 ) {
        return 18.0;
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 1 ) {
        return 18.0;
    }
    
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = (indexPath.section == 0 ? @"locationDetailCell" : @"deleteCell");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if ( cell == nil ) {
        if ( indexPath.section == 0) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterLocationDetailCell" owner:nil options:nil] lastObject];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch ([indexPath section]) {
        case 0:
        {
            UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
            UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
            
            if ( indexPath.row == 0 ) {
                textLabel.text = NSLocalizedString(@"Phone", @"Phone");
                detailTextLabel.text = _locationItem.contact;
                cell.separatorInset = A3UITableViewSeparatorInset;
            }
            else {
                textLabel.text = NSLocalizedString(@"Address", @"Address");
                detailTextLabel.text = _addressStr;
                cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.contentView.frame), 0, 0);
            }
        }
            break;
            
        case 1:
        {
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Delete Location", @"Delete Location");
            cell.textLabel.textColor = [UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(cell.contentView.frame));
        }
            break;
            
        default:
            break;
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
        CGRect rect = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 35.0, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] }
                                        context:nil];
        CGFloat retHeight = 15.0 + 17.0 + 10.0 + ceilf(rect.size.height) + 15.0;

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
    viewCtrl.sharedManager = _sharedManager;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [_eventModel deleteLocation];
    
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    DaysCounterEventLocation_ *locItem = [[DaysCounterEventLocation_ alloc] initWithContext:context];
	locItem.uniqueID = [[NSUUID UUID] UUIDString];
	locItem.updateDate = [NSDate date];
    locItem.eventID = _eventModel.uniqueID;
    locItem.latitude = @(_locationItem.location.coordinate.latitude);
    locItem.longitude = @(_locationItem.location.coordinate.longitude);
    locItem.locationName = _locationItem.name;
    locItem.country = ([_locationItem.location.country length] > 0 ? _locationItem.location.country : @"");
    locItem.state = ([_locationItem.location.state length] > 0 ? _locationItem.location.state : @"");
    locItem.city = ([_locationItem.location.city length] > 0 ? _locationItem.location.city : @"");
    locItem.address = ([_locationItem.location.address length] > 0 ? _locationItem.location.address : @"");
    locItem.contact = ([_locationItem.contact length] > 0 ? _locationItem.contact : @"");

    if ( _isEditMode ) {
        [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)deleteLocationAction:(id)sender {
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    [context deleteObject:_eventModel];
    
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
