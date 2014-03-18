//
//  A3DaysCounterEventDetailViewController_iPad.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterEventDetailViewController_iPad.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "A3DaysCounterLocationPopupViewController.h"
#import "A3DaysCounterAddEventViewController.h"

@interface A3DaysCounterEventDetailViewController_iPad ()
@property (strong, nonatomic) FSVenue *locationItem;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) A3DaysCounterEventDetailViewController *detailVC;

- (void)setupNavigationTitle;
- (void)editAction:(id)sender;
@end

@implementation A3DaysCounterEventDetailViewController_iPad
- (void)setupNavigationTitle
{
    self.titleLabel.text = @"Event Details";
    self.favoriteMark.hidden = ![_eventItem.isFavorite boolValue];
}

- (void)changeDetailViewControllerLayout:(BOOL)isFullScreen
{
    NSMutableArray *removeArray = [NSMutableArray array];
    
    for(NSLayoutConstraint *cont in self.detailVC.view.constraints){
        if( cont.secondItem == self.view )
            [removeArray addObject:cont];
    }
    
    [self.detailVC.view removeConstraints:removeArray];
    
    UIViewController *viewCtrl = _detailVC;

    if( isFullScreen ){
        viewCtrl.view.frame = CGRectMake(0, 64.0, self.view.frame.size.width, self.view.frame.size.height-64.0);
        viewCtrl.view.layer.cornerRadius = 0.0;
        viewCtrl.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        viewCtrl.view.layer.borderWidth = 0.0;
        viewCtrl.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        viewCtrl.view.layer.shadowOpacity = 0.0;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:64.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    else{
        CGFloat viewHeight = self.view.frame.size.height - 128.0 - 80.0;
        viewCtrl.view.frame = CGRectMake(20, self.view.frame.size.height*0.5 - viewHeight*0.5, 320.0, viewHeight);
        viewCtrl.view.layer.masksToBounds = YES;
        viewCtrl.view.layer.cornerRadius = 8.0;
//        viewCtrl.view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        viewCtrl.view.layer.borderWidth = 1.0;
        viewCtrl.view.layer.shadowColor = [[UIColor blackColor] CGColor];
        viewCtrl.view.layer.shadowOpacity = 0.5;
        
        [viewCtrl.view makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.left).with.offset(viewCtrl.view.frame.origin.x);
            make.width.equalTo(@(viewCtrl.view.frame.size.width));
            make.centerY.equalTo(@(0.0));
            make.top.equalTo(self.view.top).with.offset(viewCtrl.view.frame.origin.y);
            make.bottom.equalTo(self.view.bottom).with.offset(-viewCtrl.view.frame.origin.x);
        }];
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:viewCtrl.view.frame.origin.x]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:viewCtrl.view.frame.size.width]];
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:viewCtrl.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:viewCtrl.view.frame.size.height]];
    }
}

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
    [self setupNavigationTitle];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];

    [self.navigationController setToolbarHidden:YES];
    [self makeBackButtonEmptyArrow];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isFullDetailVC = NO;
    
    if( _eventItem.location ){
        _bgImageView.hidden = YES;
        _mapView.hidden = NO;
        self.locationItem = [[A3DaysCounterModelManager sharedManager] fsvenueFromEventLocationModel:_eventItem.location];
    }
    else if( [_eventItem.imageFilename length] > 0){
        _mapView.hidden = YES;
        _bgImageView.hidden = NO;
        _bgImageView.image = [A3DaysCounterModelManager photoImageFromFilename:_eventItem.imageFilename];
    }
    else{
        _mapView.hidden = YES;
        _bgImageView.hidden = YES;
        isFullDetailVC = YES;
    }
    
    if( self.detailVC == nil ){
        A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
        viewCtrl.eventItem = _eventItem;
        viewCtrl.delegate = self;
        if( isFullDetailVC ){
            viewCtrl.view.frame = self.view.bounds;
        }
        else{
            viewCtrl.view.frame = CGRectMake(20, self.view.frame.size.height*0.5 - viewCtrl.view.frame.size.height*0.5, viewCtrl.view.frame.size.width, viewCtrl.view.frame.size.height);
        }
        [self.view addSubview:viewCtrl.view];
        
        
        self.detailVC = viewCtrl;
        [self changeDetailViewControllerLayout:isFullDetailVC];
    }
    else{
        [self changeDetailViewControllerLayout:isFullDetailVC];
    }
    
    if( self.detailVC )
        [self.detailVC viewWillAppear:animated];
    [self setupNavigationTitle];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( !_mapView.hidden){
        if( [_mapView.annotations count] < 1 )
            [_mapView addAnnotation:_locationItem];
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(_locationItem.coordinate, 2000.0, 2000.0) animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.locationItem = nil;
    if( self.detailVC ){
        [self.detailVC.view removeFromSuperview];
        self.detailVC = nil;
    }
}

- (BOOL)usesFullScreenInLandscape
{
    return (IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && _landscapeFullScreen);
}


#pragma mark - action method
- (void)editAction:(id)sender
{
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.eventItem = self.eventItem;
    viewCtrl.landscapeFullScreen = _landscapeFullScreen;
    [self.navigationController pushViewController:viewCtrl animated:YES];
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
//    if ([annotation respondsToSelector:@selector(title)] && [annotation title])
		annotationView.canShowCallout = YES;
//    else
//        annotationView.canShowCallout = NO;
	annotationView.animatesDrop = YES;
    annotationView.enabled = YES;
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s",__FUNCTION__);
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    if( self.popoverVC )
        return;
    A3DaysCounterLocationPopupViewController *viewCtrl = [[A3DaysCounterLocationPopupViewController alloc] initWithNibName:@"A3DaysCounterLocationPopupViewController" bundle:nil];
    viewCtrl.locationItem = [[A3DaysCounterModelManager sharedManager] fsvenueFromEventLocationModel:_eventItem.location];
    viewCtrl.showDoneButton = YES;

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    CGSize size = viewCtrl.view.frame.size;
    
    self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
    self.popoverVC.delegate = self;
    viewCtrl.popoverVC = self.popoverVC;
    [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, size.height + 44.0) animated:NO];
    [self.popoverVC presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    [_mapView selectAnnotation:_locationItem animated:animated];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}

#pragma mark - A3DaysCounterEventDetailViewControllerDelegate
- (void)willDeleteEvent:(DaysCounterEvent *)event daysCounterEventDetailViewController:(A3DaysCounterEventDetailViewController *)ctrl
{
    [[A3DaysCounterModelManager sharedManager] removeEvent:_eventItem];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)willChangeEventDetailViewController:(A3DaysCounterEventDetailViewController *)ctrl
{
    [self setupNavigationTitle];
}

@end
