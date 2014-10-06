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
#import "A3DaysCounterSlideShowCollectionViewLayout.h"
#import "A3UserDefaultsKeys.h"
#import "A3UserDefaults.h"

#define VISIBLE_INDEX_INTERVAL      2

@interface A3DaysCounterSlideShowMainViewController () <A3CenterViewDelegate, A3DaysCounterEventDetailViewControllerDelegate, A3InstructionViewControllerDelegate, UIActivityItemSource, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSArray *eventsArray;
@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (assign, nonatomic) BOOL isShowMoreMenu;
@property (strong, nonatomic) UIBarButtonItem *infoButton;
@property (strong, nonatomic) UIBarButtonItem *shareButton;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL isRotating;
@property (assign, nonatomic) BOOL isFirstViewLoad;
@property (strong, nonatomic) NSString *prevShownEventID;
@property (strong, nonatomic) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@end

@implementation A3DaysCounterSlideShowMainViewController {
	BOOL _barButtonEnabled;
}

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

	_barButtonEnabled = YES;

	if ( IS_IPHONE ) {
		[self leftBarButtonAppsButton];
        [self rightButtonMoreButton];
	}
	else {
        self.infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"information"] style:UIBarButtonItemStylePlain target:self action:@selector(detailAction:)];
        self.shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareOtherAction:)];
        self.infoButton.tintColor = [A3AppDelegate instance].themeColor;
        self.shareButton.tintColor = [A3AppDelegate instance].themeColor;
        self.navigationItem.rightBarButtonItems = @[self.shareButton, self.infoButton, self.instructionHelpBarButton];
	}

    [self.navigationController setToolbarHidden:YES];
    [self setToolbarItems:_bottomToolbar.items];
    [self leftBarButtonAppsButton];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    currentIndex = 0;
    [self makeBackButtonEmptyArrow];

    
    A3DaysCounterSlideShowCollectionViewLayout *flowLayout = [A3DaysCounterSlideShowCollectionViewLayout new];
	CGRect screenBounds = [self screenBoundsAdjustedWithOrientation];
	flowLayout.itemSize = screenBounds.size;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.minimumLineSpacing = 0;
	_collectionView.collectionViewLayout = flowLayout;
    self.navigationController.navigationBar.translucent = YES;
    [_collectionView registerNib:[UINib nibWithNibName:@"A3DaysCounterSlideshowEventSummaryView" bundle:nil] forCellWithReuseIdentifier:@"summaryCell"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoViewScreen:)];
    tapGesture.delegate = self;
    [_collectionView addGestureRecognizer:tapGesture];

    self.isFirstViewLoad = YES;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];

	self.eventsArray = [_sharedManager allEventsListContainedImage];
    if ([_eventsArray count] > 0) {
        [self setupInstructionView];
    }

	UILabel *noPhotosLabel = (UILabel *) [self.view viewWithTag:10];
	noPhotosLabel.text = NSLocalizedString(@"No Photos", nil);
	UILabel *messageLabel = (UILabel *)[self.view viewWithTag:11];
	messageLabel.text = NSLocalizedString(@"You can add photos into events.", nil);
}

- (void)cloudStoreDidImport {
	self.eventsArray = [_sharedManager allEventsListContainedImage];
	[self.collectionView reloadData];
	[self enableControls:_barButtonEnabled];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
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
    
    self.navigationController.delegate = nil;


	[self stopTimer];
}

- (void)dealloc {
    if (self.navigationController.delegate == self)
    {
        self.navigationController.delegate = nil;
    }
    
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
	_barButtonEnabled = enable;
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
//            [self hideTopToolbarAnimated:NO];
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
            [self tapPhotoViewScreen:nil];
    }

    [_collectionView reloadData];
    
    [[A3UserDefaults standardUserDefaults] setInteger:1 forKey:A3DaysCounterLastOpenedMainIndex];
    [[A3UserDefaults standardUserDefaults] synchronize];
    
    if (_prevShownEventID) {
		NSUInteger eventIdx = [_eventsArray indexOfObjectPassingTest:^BOOL(DaysCounterEvent *item, NSUInteger idx, BOOL *stop) {
			return [item.uniqueID isEqualToString:_prevShownEventID];
		}];
        
		if (eventIdx != NSNotFound) {
			currentIndex = eventIdx;
		}
        else {
			currentIndex = 0;
		}
        
        if ([_eventsArray count] > 0) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        }
    }
    
    [self updateNavigationTitle];
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
    A3DaysCounterSlideShowCollectionViewLayout *flowLayout = [A3DaysCounterSlideShowCollectionViewLayout new];
	flowLayout.itemSize = self.view.bounds.size;
	flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	flowLayout.minimumInteritemSpacing = 0;
	flowLayout.minimumLineSpacing = 0;
    [_collectionView setCollectionViewLayout:flowLayout animated:NO];

	if ([_eventsArray count] > 0) {
		[_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]
								atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
										animated:NO];
	}
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isRotating = YES;
}

- (void)cleanUp {
	[self stopTimer];

	self.eventsArray = nil;
	self.infoButton = nil;
	self.shareButton = nil;
}

- (void)moreButtonAction:(UIBarButtonItem *)button {
	[self rightBarButtonDoneButton];
    
	UIButton *info = [UIButton buttonWithType:UIButtonTypeSystem];
	[info setImage:[UIImage imageNamed:@"information"] forState:UIControlStateNormal];
	[info addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    
	UIButton *share = [UIButton buttonWithType:UIButtonTypeSystem];
	[share setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
	[share addTarget:self action:@selector(shareOtherAction:) forControlEvents:UIControlEventTouchUpInside];
    
	UIButton *help = [self instructionHelpButton];
    
    info.tintColor = [A3AppDelegate instance].themeColor;
    share.tintColor = [A3AppDelegate instance].themeColor;
    help.tintColor = [A3AppDelegate instance].themeColor;
    
	_moreMenuButtons = @[help, info, share];
    
    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
        info.enabled = NO;
        share.enabled = NO;
    }
    else {
        info.enabled = YES;
        share.enabled = YES;
    }
    
	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:nil];
	_isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
	[self dismissMoreMenu];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;
    
	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;
    
	_isShowMoreMenu = NO;
    
	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView scrollView:nil];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

#pragma mark -
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

- (void)tapPhotoViewScreen:(UITapGestureRecognizer*)gesture
{
    if (_isShowMoreMenu) {
        [self dismissMoreMenu];
        return;
    }
    
    BOOL isHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    [self.navigationController setToolbarHidden:!isHidden animated:YES];
    [self setNeedsStatusBarAppearanceUpdate];

    _addEventButton.hidden = !isHidden;
    [self rightBarButtonStateReload];
}

- (void)rightBarButtonStateReload {
    if ( [_sharedManager numberOfEventContainedImage] < 1 ) {
        _infoButton.enabled = NO;
        _shareButton.enabled = NO;
    }
    else {
        _infoButton.enabled = YES;
        _shareButton.enabled = YES;
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

static NSString *const A3V3InstructionDidShowForDaysCounterSlideshow = @"A3V3InstructionDidShowForDaysCounterSlideshow";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForDaysCounterSlideshow]) {
        [self showInstructionView];
    }
}

- (void)instructionHelpButtfonAction
{
    [self showInstructionView];
}

- (void)showInstructionView
{
    [self dismissMoreMenu];

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForDaysCounterSlideshow];
	[[A3UserDefaults standardUserDefaults] synchronize];

	UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
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

- (IBAction)detailAction:(id)sender {
    [self dismissMoreMenu];
    if ( [_eventsArray count] < 1 ) {
        return;
    }

    DaysCounterEvent *item = [_eventsArray objectAtIndex:currentIndex];
    _prevShownEventID = item.uniqueID;
    
    A3DaysCounterEventDetailViewController *viewCtrl = [[A3DaysCounterEventDetailViewController alloc] init];
    viewCtrl.eventItem = item;
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.delegate = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)calendarViewAction:(id)sender {
    [self dismissMoreMenu];
    A3DaysCounterCalendarListMainViewController *viewCtrl = [[A3DaysCounterCalendarListMainViewController alloc] initWithNibName:@"A3DaysCounterCalendarListMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    [self dismissMoreMenu];

    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] init];
	viewCtrl.savingContext = [NSManagedObjectContext MR_rootSavingContext];
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
    [self dismissMoreMenu];
    A3DaysCounterReminderListViewController *viewCtrl = [[A3DaysCounterReminderListViewController alloc] initWithNibName:@"A3DaysCounterReminderListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)favoriteAction:(id)sender {
    [self dismissMoreMenu];
    A3DaysCounterFavoriteListViewController *viewCtrl = [[A3DaysCounterFavoriteListViewController alloc] initWithNibName:@"A3DaysCounterFavoriteListViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (void)shareOtherAction:(id)sender
{
    [self dismissMoreMenu];
    
    A3SlideshowActivity *slideActivity = [[A3SlideshowActivity alloc] init];
    slideActivity.sharedManager = _sharedManager;
    slideActivity.completionBlock = ^(NSDictionary *userInfo, UIActivity *activity) {
        [activity activityDidFinish:YES];
        A3DaysCounterSlideshowViewController *viewCtrl = [[A3DaysCounterSlideshowViewController alloc] initWithNibName:nil bundle:nil];
        viewCtrl.optionDict = userInfo;
        viewCtrl.sharedManager = _sharedManager;
        viewCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:viewCtrl animated:YES completion:nil];
    };

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:@[slideActivity]];
    activityController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard];
	if (IS_IPHONE) {
		[self presentViewController:activityController animated:YES completion:NULL];
	}
    else {
		[self enableControls:NO];

        UIBarButtonItem *button = (UIBarButtonItem *)sender;
		UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityController];
        popoverController.delegate = self;
        self.popoverVC = popoverController;
        [popoverController presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        activityController.completionHandler = ^(NSString* activityType, BOOL completed) {
            if ( completed && [activityType isEqualToString:@"Slideshow"] ) {
                A3DaysCounterSlideshowOptionViewController *viewController = [[A3DaysCounterSlideshowOptionViewController alloc] init];
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
            else if ([activityType isEqualToString:UIActivityTypeMail]) {
                [self enableControls:YES];
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

#pragma mark UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FNLOG(@"%@", indexPath);
    FNLOG(@"collectionView: %@", collectionView);
}

#pragma mark UICollectionViewFlowLayout Delegate
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cell Size: %@", NSStringFromCGRect(self.view.frame));
//    return CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 500.0;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 500.0;
//}

#pragma mark UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView contentOffset]];
    currentIndex = indexPath.row;
    
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

		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share an event with you.", @"I'd like to share an event with you.")
									   contents:txt
										   tail:NSLocalizedString(@"You can manage your events in the AppBox Pro.", @"You can manage your events in the AppBox Pro.")];
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
