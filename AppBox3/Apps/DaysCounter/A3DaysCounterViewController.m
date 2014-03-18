//
//  A3DaysCounterViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3SlideshowActivity.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterCalendarListViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterDefine.h"
#import "DaysCounterEvent.h"
#import "A3DateHelper.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterEventDetailViewController_iPad.h"
#import "A3DaysCounterSlideshowOptionViewController.h"
#import "MMDrawerController+Subclass.h"
#import "A3MainViewController.h"

#define VISIBLE_INDEX_INTERVAL      2

@interface A3DaysCounterViewController ()
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSArray *eventsArray;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (assign, nonatomic) BOOL isShowMoreMenu;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *shareButton;

- (void)showTopToolbarAnimated:(BOOL)animated;
- (void)hideTopToolbarAnimated:(BOOL)animated;

- (void)updateNavigationTitle;
- (void)addViewToMain:(UIView*)addView;
- (CGRect)orientataionFrame;
- (CGRect)orientataionBounds;
@end

@implementation A3DaysCounterViewController

- (CGRect)orientataionFrame
{
    CGSize size = self.view.frame.size;
    if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
        size = CGSizeMake(size.height, size.width);
    
    return CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, size.width, size.height);
}

- (CGRect)orientataionBounds
{
    CGSize size = self.view.bounds.size;
    if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
        size = CGSizeMake(size.height, size.width);
    
    return CGRectMake(0, 0, size.width, size.height);
}

- (void)presentMoreMenuView
{
    if( self.moreMenuView == nil ){
        UIView *moreMenuView = [self moreMenuViewWithButtons:@[self.infoButton,self.shareButton]];
        moreMenuView.backgroundColor = [UIColor clearColor];
        
        UIView *moreMenuBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, moreMenuView.frame.size.width, moreMenuView.frame.size.height)];
        moreMenuBaseView.backgroundColor = [UIColor clearColor];
        moreMenuBaseView.clipsToBounds = YES;
        self.moreMenuView = moreMenuBaseView;
        
        UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, moreMenuBaseView.frame.size.width, moreMenuBaseView.frame.size.height-1.0)];
        bgColorView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        bgColorView.alpha = 0.864;
        bgColorView.tag = 10;

        [moreMenuBaseView addSubview:bgColorView];
        moreMenuView.frame = CGRectMake(0, 0, moreMenuBaseView.frame.size.width, moreMenuBaseView.frame.size.height-1.0);
        [moreMenuBaseView addSubview:moreMenuView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, moreMenuBaseView.frame.size.width, 1.0)];
        lineView.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
        [moreMenuBaseView addSubview:lineView];
        
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:moreMenuView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:moreMenuView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:moreMenuView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:moreMenuView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:bgColorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:bgColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:bgColorView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:bgColorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_moreMenuView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [_moreMenuView addConstraint:[NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:1.0]];
    }
    
	[self.navigationController.view insertSubview:_moreMenuView belowSubview:self.view];
    
    _moreMenuView.alpha = 0.0;
    UIView *bgColorView = [_moreMenuView viewWithTag:10];
    bgColorView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
		_moreMenuView.frame = CGRectMake(_moreMenuView.frame.origin.x, 20.0 + 44.0 - 1.0, _moreMenuView.frame.size.width, _moreMenuView.frame.size.height);
        _moreMenuView.alpha = 1.0;
        bgColorView.alpha = 0.864;
	} completion:^(BOOL finished) {

    }];
}

- (void)dismissMoreMenuView
{
    UIView *menuView = _moreMenuView;
    
    UIView *bgColorView = [menuView viewWithTag:10];
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = menuView.frame;
		frame = CGRectOffset(frame, 0.0, -44.0);
		menuView.frame = frame;
        menuView.alpha = 0.0;
        bgColorView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_moreMenuView removeFromSuperview];
	}];
}

- (void)showTopToolbarAnimated:(BOOL)animated
{
    if( [[A3DaysCounterModelManager sharedManager] numberOfEventContainedImage] < 1 ){
        _infoButton.enabled = NO;
        _shareButton.enabled = NO;
    }
    else{
        _infoButton.enabled = YES;
        _shareButton.enabled = YES;
    }
    _moreMenuButtons = @[self.infoButton, self.shareButton];
    [self presentMoreMenuView];
    _isShowMoreMenu = YES;
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    if (!_isShowMoreMenu) return;
    
    _isShowMoreMenu = NO;
    
//    [self rightButtonMoreButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
    [self dismissMoreMenuView];
}

- (void)updateNavigationTitle
{
    if( [[A3DaysCounterModelManager sharedManager] numberOfEventContainedImage] < 1 )
        self.navigationItem.title = @"Days Counter";
    else
        self.navigationItem.title = [NSString stringWithFormat:@"%ld of %ld", (long)currentIndex+1, (long)[_eventsArray count]];
}

- (void)addViewToMain:(UIView*)addView
{
    if( [addView isDescendantOfView:self.view] )
        return;
    
    addView.translatesAutoresizingMaskIntoConstraints = NO;
    addView.frame = [self orientataionBounds];
    [self.view addSubview:addView];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
}

- (BOOL)usesFullScreenInLandscape
{
    return (IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation));
}

- (BOOL)hidesNavigationBar
{
    return self.navigationController.navigationBarHidden;
}

- (void)cleanUp
{
    
}

- (void)toggleMenu:(UITapGestureRecognizer*)gesture
{
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    [self.navigationController setToolbarHidden:!isHidden animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];

    _addEventButton.hidden = !isHidden;
    if( !isHidden ){
        [self hideTopToolbarAnimated:YES];
        if( IS_IPHONE )
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
//            [self rightButtonMoreButton];
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
    @autoreleasepool {
        UIView *rightButtonView = nil;
        if( IS_IPHONE ){
            [self leftBarButtonAppsButton];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
            rightButtonView = _naviRightButtonViewiPhone;
//            [self rightButtonMoreButton];
        }
        else{

            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonView];
            rightButtonView = _naviRightButtonView;
        }
        self.infoButton = (UIButton*)[rightButtonView viewWithTag:10];
        self.shareButton = (UIButton*)[rightButtonView viewWithTag:11];
    }
    [self.navigationController setToolbarHidden:YES];
    [self setToolbarItems:_bottomToolbar.items];
    [self leftBarButtonAppsButton];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    currentIndex = 0;
    [self makeBackButtonEmptyArrow];
    
//    self.infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [_infoButton setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
//    [_infoButton addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_infoButton setBackgroundColor:[UIColor clearColor]];
//    self.shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [_shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
//    [_shareButton addTarget:self action:@selector(shareOtherAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_shareButton setBackgroundColor:[UIColor clearColor]];
    
    self.navigationController.navigationBar.translucent = YES;
    [_collectionView registerNib:[UINib nibWithNibName:@"A3DaysCounterEventSummaryView" bundle:nil] forCellWithReuseIdentifier:@"summaryCell"];
    

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu:)];
    tapGesture.delegate = self;
    [_collectionView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
    self.eventsArray = [[A3DaysCounterModelManager sharedManager] allEventsListContainedImage];
    
    if( [[A3DaysCounterModelManager sharedManager] numberOfEventContainedImage] > 0 ){
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        if( !_isShowMoreMenu )
            self.navigationController.navigationBarHidden = YES;
        else
            self.navigationController.navigationBarHidden = NO;
        _noPhotoView.hidden = YES;
        _collectionView.hidden = NO;
        _infoButton.enabled = YES;
        _shareButton.enabled = YES;
    }
    else{
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        if( _isShowMoreMenu )
            [self hideTopToolbarAnimated:NO];
        self.navigationController.navigationBarHidden = NO;
        _noPhotoView.hidden = NO;
        _collectionView.hidden = YES;
        _infoButton.enabled = NO;
        _shareButton.enabled = NO;
        [self.view bringSubviewToFront:_noPhotoView];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setToolbarHidden:self.navigationController.navigationBarHidden];
//    if( ![_addEventButton isDescendantOfView:self.view] ){
//        _addEventButton.frame = CGRectMake(self.view.frame.size.width*0.5 - _addEventButton.frame.size.width*0.5, self.view.frame.size.height - _bottomToolbar.frame.size.height - 8 - _addEventButton.frame.size.height, _addEventButton.frame.size.width, _addEventButton.frame.size.height);
//        [self.view addSubview:_addEventButton];
//    }
//    _addEventButton.hidden = self.navigationController.navigationBarHidden;
    
    [self updateNavigationTitle];
    
    if( IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        [self.A3RootViewController animateHideLeftViewForFullScreenCenterView:YES];
    }
    if( self.A3RootViewController.showRightView ){
        if( self.navigationController.navigationBarHidden )
            [self toggleMenu:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if( _isShowMoreMenu )
        [self hideTopToolbarAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
//    CGSize size = ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? CGSizeMake(appFrame.size.height, appFrame.size.width) : appFrame.size);
//    [UIView animateWithDuration:duration animations:^{
//        _addEventButton.frame = CGRectMake(size.width*0.5 - _addEventButton.frame.size.width*0.5, size.height - _addEventButton.frame.size.height - _bottomToolbar.frame.size.height, _addEventButton.frame.size.width, _addEventButton.frame.size.height);
//    }];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_collectionView reloadData];
}

- (void)dealloc
{
    self.eventsArray = nil;
    self.infoButton = nil;
    self.shareButton = nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    if( [_eventsArray count] > 0 ){
//        [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_eventsArray objectAtIndex:currentIndex] toView:self.visibleView];
//    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}

#pragma mark - action method
- (void)moreButtonAction:(UIBarButtonItem *)button {
    if( ![_topToolbar isDescendantOfView:self.view] ){
        [self rightBarButtonDoneButton];
        [self showTopToolbarAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
//    [self rightButtonMoreButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
    [self hideTopToolbarAnimated:YES];
}

- (IBAction)detailAction:(id)sender {
    if( [_eventsArray count] < 1 )
        return;
    [self hideTopToolbarAnimated:NO];
    DaysCounterEvent *item = [_eventsArray objectAtIndex:currentIndex];
//    if( IS_IPHONE ){
        A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
        viewCtrl.eventItem = item;
        [self.navigationController pushViewController:viewCtrl animated:YES];
//    }
//    else{
//        A3DaysCounterEventDetailViewController_iPad *viewCtrl = [[A3DaysCounterEventDetailViewController_iPad alloc] initWithNibName:@"A3DaysCounterEventDetailViewController_iPad" bundle:nil];
//        viewCtrl.eventItem = item;
//        [self.navigationController pushViewController:viewCtrl animated:YES];
//    }
}

- (IBAction)calendarViewAction:(id)sender {
    A3DaysCounterCalendarListViewController *viewCtrl = [[A3DaysCounterCalendarListViewController alloc] initWithNibName:@"A3DaysCounterCalendarListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.landscapeFullScreen = YES;
    if( IS_IPHONE ){
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else{
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)shareOtherAction:(id)sender {
    
    A3SlideshowActivity *slideActivity = [[A3SlideshowActivity alloc] init];
    
    NSString *shareString = ( [_eventsArray count] > 0 ? [[A3DaysCounterModelManager sharedManager] stringForShareEvent:[_eventsArray objectAtIndex:currentIndex]] : @"");
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:@[slideActivity]];
    activityController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	} else {
        UIButton *button = (UIButton*)sender;
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        popoverController.delegate = self;
        self.popoverVC = popoverController;
//		[popoverController presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [popoverController presentPopoverFromRect:[button convertRect:button.bounds toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        activityController.completionHandler = ^(NSString* activityType, BOOL completed){
            NSLog(@"%s %@",__FUNCTION__,activityType);
            if( completed && [activityType isEqualToString:@"Slideshow"] ){
                A3DaysCounterSlideshowOptionViewController *viewCtrl = [[A3DaysCounterSlideshowOptionViewController alloc] initWithNibName:@"A3DaysCounterSlideshowOptionViewController" bundle:nil];
                [self presentSubViewController:viewCtrl];
            }
        };
	}
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if( [viewController isKindOfClass:[A3MainViewController class]]){
        if( IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.A3RootViewController animateHideLeftViewForFullScreenCenterView:NO];
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_eventsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"summaryCell" forIndexPath:indexPath];
    [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_eventsArray objectAtIndex:indexPath.row] toView:cell];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

@end
