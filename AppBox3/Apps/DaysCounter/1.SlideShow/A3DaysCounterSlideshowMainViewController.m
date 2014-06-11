//
//  A3DaysCounterViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideShowMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3SlideshowActivity.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterCalendarListMainViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "A3DaysCounterDefine.h"
#import "DaysCounterEvent.h"
#import "A3DateHelper.h"
#import "A3DaysCounterEventDetailViewController.h"
#import "A3DaysCounterSlideshowOptionViewController.h"
#import "A3MainViewController.h"
#import "UIImage+JHExtension.h"
#import "A3DefaultColorDefines.h"
#import "A3DaysCounterSlideshowViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate+formatting.h"
#import "A3InstructionViewController.h"


#define VISIBLE_INDEX_INTERVAL      2

@interface A3DaysCounterSlideShowMainViewController () <A3DaysCounterEventDetailViewControllerDelegate, A3InstructionViewControllerDelegate, UIActivityItemSource>
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSArray *eventsArray;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (assign, nonatomic) BOOL isShowMoreMenu;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isRotating;
@property (assign, nonatomic) BOOL isFirstViewLoad;
@property (strong, nonatomic) NSString *prevShownEventID;
@property (strong, nonatomic) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@end

@implementation A3DaysCounterSlideShowMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIView *rightButtonView = nil;
	if ( IS_IPHONE ) {
		[self leftBarButtonAppsButton];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
		rightButtonView = _naviRightButtonViewiPhone;
	}
	else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonView];
		rightButtonView = _naviRightButtonView;
	}
	self.infoButton = (UIButton*)[rightButtonView viewWithTag:10];
	self.shareButton = (UIButton*)[rightButtonView viewWithTag:11];
	self.infoButton.tintColor = [A3AppDelegate instance].themeColor;
	self.shareButton.tintColor = [A3AppDelegate instance].themeColor;
	[self.infoButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"information"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];
	[self.shareButton setImage:[UIImage getImageToGreyImage:[UIImage imageNamed:@"share"] grayColor:COLOR_DISABLE_POPOVER] forState:UIControlStateDisabled];

    [self.navigationController setToolbarHidden:YES];
    [self setToolbarItems:_bottomToolbar.items];
    [self leftBarButtonAppsButton];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    currentIndex = 0;
    [self makeBackButtonEmptyArrow];

	UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	flowLayout.itemSize = screenBounds.size;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.minimumLineSpacing = 0;
	_collectionView.collectionViewLayout = flowLayout;
    self.navigationController.navigationBar.translucent = YES;
    [_collectionView registerNib:[UINib nibWithNibName:@"A3DaysCounterSlideshowEventSummaryView" bundle:nil] forCellWithReuseIdentifier:@"summaryCell"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu:)];
    tapGesture.delegate = self;
    [_collectionView addGestureRecognizer:tapGesture];

    self.isFirstViewLoad = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
    
    self.eventsArray = [_sharedManager allEventsListContainedImage];
    if ([_eventsArray count] > 0) {
        [self setupInstructionView];
    }
}

- (void)removeObserver {
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
	if ( _isShowMoreMenu ) {
		[self hideTopToolbarAnimated:YES];
	}

	[self stopTimer];
}

- (void)dealloc {
	[self cleanUp];
	[self removeObserver];
}

- (void)mainMenuViewDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewDidAppear {
	FNLOG();
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	FNLOG();
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		BOOL hasPhotos = [_sharedManager numberOfEventContainedImage] > 0;
		[self.infoButton setEnabled:hasPhotos];
		[self.shareButton setEnabled:hasPhotos];
	} else {
		[self.infoButton setEnabled:NO];
		[self.shareButton setEnabled:NO];
	}
	[self.toolbarItems[0] setEnabled:enable];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isRotating = NO;
    self.navigationController.delegate = self;
    self.eventsArray = [_sharedManager allEventsListContainedImage];
    
    NSDate *now = [NSDate date];
    
    // Start Timer 화면 갱신.
    NSDateComponents *nowComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now];
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:60 - [nowComp second]];

    if ( [_sharedManager numberOfEventContainedImage] > 0 ) {
        if ( !_isShowMoreMenu ) {
            self.navigationController.navigationBarHidden = YES;
        }
        else {
            self.navigationController.navigationBarHidden = NO;
        }
        _noPhotoView.hidden = YES;
        _collectionView.hidden = NO;
        _infoButton.enabled = YES;
        _shareButton.enabled = YES;
    }
    else {
        if ( _isShowMoreMenu ) {
            [self hideTopToolbarAnimated:NO];
        }
        self.navigationController.navigationBarHidden = NO;
        _noPhotoView.hidden = NO;
        _collectionView.hidden = YES;
        _infoButton.enabled = NO;
        _shareButton.enabled = NO;
        [self.view bringSubviewToFront:_noPhotoView];
    }
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setToolbarHidden:self.navigationController.navigationBarHidden];
    [self updateNavigationTitle];
    
    if ( IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.A3RootViewController animateHideLeftViewForFullScreenCenterView:YES];
    }
    if ( self.A3RootViewController.showRightView ) {
        if ( self.navigationController.navigationBarHidden )
            [self toggleMenu:nil];
    }

    [_collectionView reloadData];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"DaysCounterLastOpenedMainIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_prevShownEventID) {
        [_eventsArray enumerateObjectsUsingBlock:^(DaysCounterEvent *item, NSUInteger idx, BOOL *stop) {
            if ([item.uniqueID isEqualToString:_prevShownEventID]) {
                [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:NO];
                currentIndex = idx;
                [self updateNavigationTitle];
            }
        }];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.delegate = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_isRotating) {
        return;
    }

    if (self.isFirstViewLoad) {
        self.isFirstViewLoad = NO;
        __block NSInteger indexOfTodayPhoto = -1;
        
        NSDateComponents *nowComp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
        nowComp.hour = 0;
        nowComp.minute = 0;
        nowComp.second = 0;
        NSDate *today = [[NSCalendar currentCalendar] dateFromComponents:nowComp];
        
        [self.eventsArray enumerateObjectsUsingBlock:^(DaysCounterEvent *event, NSUInteger idx, BOOL *stop) {
            if ([event.effectiveStartDate timeIntervalSince1970] >= [today timeIntervalSince1970]) {
                indexOfTodayPhoto = idx;
                *stop = YES;
                return;
            }
            indexOfTodayPhoto = idx;
        }];
        
        if (indexOfTodayPhoto != -1) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexOfTodayPhoto inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
            currentIndex = indexOfTodayPhoto;
        }
        
        [self updateNavigationTitle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
	flowLayout.itemSize = self.view.bounds.size;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.minimumLineSpacing = 0;
	_collectionView.collectionViewLayout = flowLayout;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    _isRotating = YES;
//
//    [_collectionView reloadData];
//    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
//    if (cell) {
//        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
//                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
//                                        animated:NO];
//    }
//
//    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
//        self.navigationItem.title = @"Days Counter";
//    }
//    else {
//        self.navigationItem.title = [NSString stringWithFormat:@"%ld of %ld", (long)currentIndex + 1, (long)[_eventsArray count]];
//    }
}

- (void)cleanUp {
	[self stopTimer];

	self.eventsArray = nil;
	self.infoButton = nil;
	self.shareButton = nil;
}

#pragma mark -

- (void)presentMoreMenuView
{
    if ( self.moreMenuView == nil ) {
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
    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
        _infoButton.enabled = NO;
        _shareButton.enabled = NO;
    }
    else {
        _infoButton.enabled = YES;
        _shareButton.enabled = YES;
    }
    _moreMenuButtons = @[self.infoButton, self.shareButton];
    [self presentMoreMenuView];
    _isShowMoreMenu = YES;
}

- (void)hideTopToolbarAnimated:(BOOL)animated
{
    if (!_isShowMoreMenu) {
        return;
    }
    
    _isShowMoreMenu = NO;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
    [self dismissMoreMenuView];
}

- (void)updateNavigationTitle
{
    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
        self.navigationItem.title = NSLocalizedString(@"Days Counter", @"Days Counter");
    }
    else {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", @"%ld of %ld"), (long) currentIndex + 1, (long) [_eventsArray count]];
    }
}

- (void)addViewToMain:(UIView*)addView
{
    if ( [addView isDescendantOfView:self.view] )
        return;
    
    addView.translatesAutoresizingMaskIntoConstraints = NO;
    addView.frame = [self screenBoundsAdjustedWithOrientation];
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

- (void)toggleMenu:(UITapGestureRecognizer*)gesture
{
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    [self.navigationController setToolbarHidden:!isHidden animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];

    _addEventButton.hidden = !isHidden;
    if ( !isHidden ) {
        [self hideTopToolbarAnimated:YES];
        if ( IS_IPHONE )
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (void)startTimer
{
    if ([self.timer isValid]) {
        [self stopTimer];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
}

- (void)timerFireMethod:(NSTimer *)timer
{
    FNLOG();
    [_collectionView reloadData];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark Instruction Related

- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DaysCounter_2"]) {
        [self showInstructionView];
    }
    [self setupTwoFingerDoubleTapGestureToShowInstruction];
}

- (void)showInstructionView
{
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"DaysCounter_2"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	FNLOG();
    self.popoverVC = nil;
	[self enableControls:YES];
}

#pragma mark - A3DaysCounterEventDetailViewControllerDelegate

- (void)didChangedCalendarEventDetailViewController:(A3DaysCounterEventDetailViewController *)ctrl {
	FNLOG();
}

#pragma mark - action method
- (void)moreButtonAction:(UIBarButtonItem *)button {
    if ( ![_topToolbar isDescendantOfView:self.view] ) {
        [self rightBarButtonDoneButton];
        [self showTopToolbarAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_naviRightButtonViewiPhone];
    [self hideTopToolbarAnimated:YES];
}

- (IBAction)detailAction:(id)sender {
    if ( [_eventsArray count] < 1 ) {
        return;
    }
    [self hideTopToolbarAnimated:NO];
    DaysCounterEvent *item = [_eventsArray objectAtIndex:currentIndex];
    _prevShownEventID = item.uniqueID;
    
    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] initWithNibName:@"A3DaysCounterEventDetailViewController" bundle:nil];
    viewCtrl.eventItem = item;
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.delegate = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)calendarViewAction:(id)sender {
    A3DaysCounterCalendarListMainViewController *viewCtrl = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] initWithNibName:@"A3DaysCounterAddEventViewController" bundle:nil];
    viewCtrl.landscapeFullScreen = YES;
    viewCtrl.sharedManager = _sharedManager;
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

- (IBAction)reminderAction:(id)sender {
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)shareOtherAction:(id)sender
{
    A3SlideshowActivity *slideActivity = [[A3SlideshowActivity alloc] init];
    slideActivity.sharedManager = _sharedManager;
    slideActivity.completionBlock = ^(NSDictionary *userInfo, UIActivity *activity) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [activity activityDidFinish:YES];
            A3DaysCounterSlideshowViewController *viewCtrl = [[A3DaysCounterSlideshowViewController alloc] initWithNibName:@"A3DaysCounterSlideshowViewController" bundle:nil];
            viewCtrl.optionDict = userInfo;
            viewCtrl.sharedManager = _sharedManager;
            viewCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:viewCtrl animated:YES completion:nil];
        }];
    };

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:@[slideActivity]];
    activityController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	}
    else {
		[self enableControls:NO];

        UIButton *button = (UIButton*)sender;
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        popoverController.delegate = self;
        self.popoverVC = popoverController;
        [popoverController presentPopoverFromRect:[button convertRect:button.bounds toView:self.view]
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        activityController.completionHandler = ^(NSString* activityType, BOOL completed) {
            if ( completed && [activityType isEqualToString:@"Slideshow"] ) {
                A3DaysCounterSlideshowOptionViewController *viewController = [[A3DaysCounterSlideshowOptionViewController alloc] initWithNibName:@"A3DaysCounterSlideshowOptionViewController" bundle:nil];
                viewController.sharedManager = _sharedManager;

				if (IS_IPHONE) {
					_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
					[self presentViewController:_modalNavigationController animated:YES completion:NULL];
					[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
				} else {
					[self.A3RootViewController presentRightSideViewController:viewController];
					double delayInSeconds = 0.6;
					dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
					dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
						[self enableControls:NO];
					});
				}
            }
        };
	}
}

- (void)optionViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ( [viewController isKindOfClass:[A3MainViewController class]]) {
        if ( IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
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
    [_sharedManager setupEventSummaryInfo:[_eventsArray objectAtIndex:indexPath.row] toView:cell];
    
    return cell;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//	UICollectionViewFlowLayout *flowLayout = collectionViewLayout;
//	FNLOG(@"%f, %f", flowLayout.itemSize.width, flowLayout.itemSize.height);
//	FNLOG(@"%f, %f, %f, %f", flowLayout.sectionInset.top, flowLayout.sectionInset.left, flowLayout.sectionInset.right, flowLayout.sectionInset.bottom);
//	FNLOG(@"%f, %f", flowLayout.minimumLineSpacing, flowLayout.minimumInteritemSpacing);
//    FNLOG(@"%@", NSStringFromCGSize(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)));
//    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//}

#pragma mark UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FNLOG(@"%@", indexPath);
    FNLOG(@"collectionView: %@", collectionView);
}

#pragma mark UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        currentIndex = indexPath.row;
    }
    
    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
        self.navigationItem.title = NSLocalizedString(@"Days Counter", @"Days Counter");
    }
    else {
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld", @"%ld of %ld"), (long) currentIndex + 1, (long) [_eventsArray count]];
    }
}

#pragma mark - UIActivityItemSource

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    DaysCounterEvent *eventItem = [_eventsArray objectAtIndex:currentIndex];
    
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ using AppBox Pro", @"%@ using AppBox Pro"), eventItem.eventName];
	}
    
	return eventItem.eventName;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Days Counter Data", @"Share Days Counter Data");
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    DaysCounterEvent *eventItem = [_eventsArray objectAtIndex:currentIndex];
    if (!eventItem) {
        return nil;
    }
    
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        
		NSMutableString *txt = [NSMutableString new];
		[txt appendString:NSLocalizedString(@"<html><body>I'd like to share a event with you.<br/><br/>", @"<html><body>I'd like to share a event with you.<br/><br/>")];
        
        // 7 days until (계산된 날짜)
        NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[eventItem.durationOption integerValue]
                                                                        fromDate:[NSDate date]
                                                                          toDate:eventItem.effectiveStartDate
                                                                        isAllDay:[eventItem.isAllDay boolValue]
                                                                    isShortStyle:IS_IPHONE ? YES : NO
                                                               isStrictShortType:NO];
        NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                       toDate:eventItem.effectiveStartDate
                                                                 allDayOption:[eventItem.isAllDay boolValue]
                                                                       repeat:[eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                       strict:NO];
        [txt appendFormat:@"%@<br/>", [eventItem eventName]];
        [txt appendFormat:@"%@ %@<br/>", daysString, untilSinceString];
        
        // Friday, April 11, 2014 (사용자가 입력한 날)
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterFullStyle];
        if (![eventItem.isAllDay boolValue]) {
            [formatter setTimeStyle:NSDateFormatterShortStyle];
        }
        [txt appendFormat:@"%@<br/>", [A3DateHelper dateStringFromDate:[eventItem effectiveStartDate]
                                                            withFormat:[formatter dateFormat]]];
		[txt appendString:NSLocalizedString(@"dayscounter_share_html_body", nil)];
        
		return txt;
	}
	else {
		NSMutableString *txt = [NSMutableString new];
        // 7 days until (계산된 날짜)
        NSString *daysString = [A3DaysCounterModelManager stringOfDurationOption:[eventItem.durationOption integerValue]
                                                                        fromDate:[NSDate date]
                                                                          toDate:eventItem.effectiveStartDate
                                                                        isAllDay:[eventItem.isAllDay boolValue]
                                                                    isShortStyle:IS_IPHONE ? YES : NO
                                                               isStrictShortType:NO];
        NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:[NSDate date]
                                                                       toDate:eventItem.effectiveStartDate
                                                                 allDayOption:[eventItem.isAllDay boolValue]
                                                                       repeat:[eventItem.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                       strict:NO];
        [txt appendFormat:@"%@\n", [eventItem eventName]];
        [txt appendFormat:@"%@ %@\n", daysString, untilSinceString];
        
        //         Friday, April 11, 2014 (사용자가 입력한 날)
        NSDateFormatter *formatter = [NSDateFormatter new];

        if ([NSDate isFullStyleLocale]) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
            if (![eventItem.isAllDay boolValue]) {
                [formatter setTimeStyle:NSDateFormatterShortStyle];
            }
        }
        else {
            if ([eventItem.isAllDay boolValue]) {
                [formatter setDateFormat:[formatter customFullStyleFormat]];
            }
            else {
                [formatter setDateFormat:[formatter customFullWithTimeStyleFormat]];
            }
        }

        [txt appendFormat:@"%@\n", [A3DateHelper dateStringFromDate:[eventItem effectiveStartDate]
                                                         withFormat:[formatter dateFormat]]];
        
		return txt;
	}
}

@end
