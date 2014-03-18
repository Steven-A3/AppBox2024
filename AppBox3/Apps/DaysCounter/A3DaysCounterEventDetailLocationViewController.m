//
//  A3DaysCounterEventDetailLocationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventDetailLocationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "common.h"
#import "A3PlacemarkBackgroundView.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NSString+conversion.h"


@interface A3DaysCounterEventDetailLocationViewController ()
@property (strong, nonatomic) NSString *addressStr;
@property (strong, nonatomic) FSVenue *locationItem;
@end

@implementation A3DaysCounterEventDetailLocationViewController

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
    [self makeBackButtonEmptyArrow];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.locationItem = [[A3DaysCounterModelManager sharedManager] fsvenueFromEventLocationModel:_location];
    self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 44.0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if( [_mapView.annotations count] < 2 )
        [_mapView addAnnotation:_locationItem];
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
    self.locationItem = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if( cell == nil ){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        
        cell.textLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if( indexPath.row == 0 ){
        cell.textLabel.text = @"Phone";
        cell.detailTextLabel.text = _locationItem.contact;
    }
    else{
        cell.textLabel.text = @"Address";
        cell.detailTextLabel.text = _addressStr;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 ){
        CGSize size = [self.addressStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0]}];
        CGSize textSize = [@"Address" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0]}];
        return size.height + textSize.height + 14.0;
    }
    return 44.0;
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
    
	static NSString *identifier = @"A3MapViewAnnotation";
    
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (nil == annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.draggable = NO;
	}
    if ([annotation respondsToSelector:@selector(title)] && [annotation title])
		annotationView.canShowCallout = YES;
    else
        annotationView.canShowCallout = NO;
	annotationView.animatesDrop = YES;
    
    UILabel *titleLabel = (UILabel*)[annotationView viewWithTag:100];
    if( titleLabel == nil ){
        CGRect txtRect = [[annotation title] boundingRectWithSize:CGSizeMake(self.view.frame.size.width*0.5, self.view.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]} context:nil];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(annotationView.frame.size.width, 0, ceilf(txtRect.size.width), ceilf(txtRect.size.height))];
        titleLabel.text = [annotation title];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        [annotationView addSubview:titleLabel];
    }
    else{
        titleLabel.text = [annotation title];
        CGRect txtRect = [[annotation title] boundingRectWithSize:CGSizeMake(self.view.frame.size.width*0.5, self.view.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]} context:nil];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, ceilf(txtRect.size.width), ceilf(txtRect.size.height));
    }
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [_mapView selectAnnotation:_locationItem animated:animated];
}


@end
