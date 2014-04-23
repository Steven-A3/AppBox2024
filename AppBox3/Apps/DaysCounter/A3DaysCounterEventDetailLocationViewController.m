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
#import "A3GradientView.h"


@interface A3DaysCounterEventDetailLocationViewController ()
@property (strong, nonatomic) NSString *addressStr;
@property (strong, nonatomic) FSVenue *locationItem;
@property (nonatomic, strong) A3GradientView *tableViewTopBlurView;
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
    _tableView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
    
    [self.view addSubview:self.tableViewTopBlurView];
    [self.tableViewTopBlurView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tableView.left);
        make.trailing.equalTo(self.tableView.right);
        make.height.equalTo(@5);
        make.bottom.equalTo(self.mapView.bottom);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( [_mapView.annotations count] < 2 ) {
        [_mapView addAnnotation:_locationItem];
        [_mapView selectAnnotation:_locationItem animated:YES];
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
    self.locationItem = nil;
}

- (A3GradientView *)tableViewTopBlurView {
    if (!_tableViewTopBlurView) {
        _tableViewTopBlurView = [A3GradientView new];
        _tableViewTopBlurView.gradientColors = @[
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.09].CGColor
                                                 ];
    }
    
    return _tableViewTopBlurView;
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if ( cell == nil ) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterLocationDetailCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    
    cell.textLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
    cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
    
    
    if ( indexPath.row == 0 ) {
        textLabel.text = @"Phone";
        detailTextLabel.text = _locationItem.contact;
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    else {
        textLabel.text = @"Address";
        detailTextLabel.text = _addressStr;
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.contentView.frame), 0, 0);
    }
    
    if ([detailTextLabel.text length] == 0) {
        detailTextLabel.text = @" ";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 58;
    }
    else {
        NSString *str = _addressStr;
        CGRect rect = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 35.0, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] }
                                        context:nil];
        CGFloat retHeight = 15.0 + 17.0 + 10.0 + ceilf(rect.size.height) + 15.0;
        
        return retHeight;
    }
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
    if ([annotation respondsToSelector:@selector(title)] && [annotation title]) {
		annotationView.canShowCallout = YES;
    }
    else {
        annotationView.canShowCallout = NO;
    }
    
	annotationView.animatesDrop = YES;
    
    UILabel *titleLabel = (UILabel*)[annotationView viewWithTag:100];
    if ( titleLabel == nil ) {
        CGRect txtRect = [[annotation title] boundingRectWithSize:CGSizeMake(self.view.frame.size.width*0.5, self.view.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]} context:nil];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(annotationView.frame.size.width, 0, ceilf(txtRect.size.width), ceilf(txtRect.size.height))];
        titleLabel.text = [annotation title];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        [annotationView addSubview:titleLabel];
    }
    else {
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
