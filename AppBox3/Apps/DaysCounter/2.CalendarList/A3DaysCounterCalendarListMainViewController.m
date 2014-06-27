//
//  A3DaysCounterCalendarListViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterCalendarListMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSlideShowMainViewController.h"
#import "A3DaysCounterAddEventViewController.h"
#import "A3DaysCounterEditCalendarListViewController.h"
#import "A3DaysCounterAddAndEditCalendarViewController.h"
#import "A3DaysCounterEventListViewController.h"
#import "A3DaysCounterReminderListViewController.h"
#import "A3DaysCounterFavoriteListViewController.h"
#import "DaysCounterCalendar.h"
#import "DaysCounterCalendar+Extension.h"
#import "DaysCounterEvent.h"
#import "DaysCounterDate.h"
#import "A3DateHelper.h"
#import "NSDate+LunarConverter.h"
#import "A3AppDelegate+appearance.h"
#import "UIColor+A3Addition.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate+formatting.h"
#import "A3InstructionViewController.h"


@interface A3DaysCounterCalendarListMainViewController () <UINavigationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, A3InstructionViewControllerDelegate>
@property (strong, nonatomic) NSArray *itemArray;
@property (strong, nonatomic) NSArray *searchResultArray;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;

@property (strong, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIView *rightTopButtonView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCalendarLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *updateDateLabel;
@property (strong, nonatomic) IBOutlet UIView *iPadheaderView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfCalendarLabeliPad;
@property (strong, nonatomic) IBOutlet UILabel *numberOfEventsLabeliPad;
@property (strong, nonatomic) IBOutlet UILabel *updateDateLabeliPad;
@property (strong, nonatomic) IBOutlet UIButton *addEventButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *headerEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerEventLabel_iPad;
@property (weak, nonatomic) IBOutlet UILabel *headerCalendarsLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerCalendarsLabel_iPad;
@property (weak, nonatomic) IBOutlet UILabel *headerUpdatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerUpdatedLabel_iPad;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *verticalSeperators;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator1_TopConst_iPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator2_TopConst_iPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator1_TopConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerSeparator2_TopConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view1_widthConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view2_widthConst_iPad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerView_view3_widthConst_iPad;

@end

@implementation A3DaysCounterCalendarListMainViewController

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

    self.navigationItem.title = NSLocalizedString(@"Days Counter", @"Days Counter");

    [self leftBarButtonAppsButton];
    [self makeBackButtonEmptyArrow];

    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItems = @[edit, [self instructionHelpBarButton]];
    [self setToolbarItems:_bottomToolbar.items];
    
    if ( IS_IPHONE ) {
        if (IS_RETINA) {
            CGRect rect = _headerView.frame;
            rect.size.height += 0.5;
            _headerView.frame = rect;
        }
        [self.tableView setTableHeaderView:_headerView];

		self.headerCalendarsLabel.text = NSLocalizedString(@"CALENDARS", nil);
		self.headerEventLabel.text = NSLocalizedString(@"EVENTS", nil);
		self.headerUpdatedLabel.text = NSLocalizedString(@"UPDATED", nil);

        self.numberOfCalendarLabel.font = [UIFont boldSystemFontOfSize:15];
        self.numberOfEventsLabel.font = [UIFont boldSystemFontOfSize:15];
        self.updateDateLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    else {
        if (IS_RETINA) {
            CGRect rect = _iPadheaderView.frame;
            rect.size.height += 0.5;
            _iPadheaderView.frame = rect;
        }
        [self.tableView setTableHeaderView:_iPadheaderView];

		self.headerCalendarsLabel_iPad.text = NSLocalizedString(@"CALENDARS", nil);
		self.headerEventLabel_iPad.text = NSLocalizedString(@"EVENTS", nil);
		self.headerUpdatedLabel_iPad.text = NSLocalizedString(@"UPDATED", nil);

        self.numberOfCalendarLabel = self.numberOfCalendarLabeliPad;
        self.numberOfEventsLabel = self.numberOfEventsLabeliPad;
        self.updateDateLabel = self.updateDateLabeliPad;
    }
    
    for (NSLayoutConstraint *layout in _verticalSeperators) {
        layout.constant = 1.0 / [[UIScreen mainScreen] scale];
    }
    
    if (IS_IPHONE) {
        _headerSeparator1_TopConst_iPhone.constant = 0.5;
        _headerSeparator2_TopConst_iPhone.constant = 0.5;
    }
    else {
        _headerSeparator1_TopConst_iPad.constant = 0.5;
        _headerSeparator2_TopConst_iPad.constant = 0.5;
    }
    
    [self.view addSubview:_addEventButton];
    [_addEventButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.bottom.equalTo(self.view.bottom).with.offset(-(CGRectGetHeight(self.bottomToolbar.frame) + 11));
        make.width.equalTo(@44);
        make.height.equalTo(@44);
    }];
    
    [self.view addSubview:self.searchBar];
    [self mySearchDisplayController];
    
    [A3DaysCounterModelManager reloadAlertDateListForLocalNotification];
    [self setupInstructionView];
	[self registerContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuViewDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
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
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuViewDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
	[self reloadTableView];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
	[self.addEventButton setEnabled:enable];

	[self.toolbarItems[2] setEnabled:enable];
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
    self.navigationController.delegate = nil;
    [self.navigationController setToolbarHidden:NO];
    
    [self reloadTableView];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"DaysCounterLastOpenedMainIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if ( IS_IPAD ) {
        CGFloat barWidth = IS_PORTRAIT ? 768 : 1024;
        _headerView_view1_widthConst_iPad.constant = barWidth / 3.0;
        _headerView_view2_widthConst_iPad.constant = barWidth / 3.0;
        _headerView_view3_widthConst_iPad.constant = barWidth / 3.0;
    }
}

- (void)setupHeaderInfo
{
    NSInteger eventNumber = [_sharedManager numberOfAllEvents];
    NSDate *latestDate = [_sharedManager dateOfLatestEvent];
    _numberOfCalendarLabel.text = [NSString stringWithFormat:@"%ld", (long)[_sharedManager numberOfUserCalendarVisible]];
    _numberOfEventsLabel.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%ld", (long)eventNumber]];
    
    if (IS_IPAD) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        _headerEventLabel_iPad.text = (eventNumber > 0 ? NSLocalizedString(@"EVENTS", @"EVENTS") : NSLocalizedString(@"EVENT", @"EVENT"));
        _updateDateLabel.text = (latestDate ? [A3DateHelper dateStringFromDate:latestDate withFormat:[formatter dateFormat]] : @"-");
    }
    else {
        _headerEventLabel.text = (eventNumber > 0 ? NSLocalizedString(@"EVENTS", @"EVENTS") : NSLocalizedString(@"EVENT", @"EVENT"));
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        _updateDateLabel.text = (latestDate ? [A3DateHelper dateStringFromDate:latestDate withFormat:[formatter dateFormat]] : @"-");
    }
}

- (void)reloadTableView
{
    self.itemArray = [_sharedManager visibleCalendarList];
    [self setupHeaderInfo];
    [self.tableView reloadData];
    self.addEventButton.tintColor = [A3AppDelegate instance].themeColor;
}

#pragma mark Initialize FontSize
- (void)contentSizeDidChange:(NSNotification*)noti
{
    if (IS_IPAD) {
        [self adjustFontSizeOfHeaderView:_iPadheaderView];
    }
}

- (void)adjustFontSizeOfHeaderView:(UIView *)aView {
    if ([aView.subviews count] > 0) {
        [aView.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
            [self adjustFontSizeOfHeaderView:subview];
        }];
    }
    else {
        switch ([aView tag]) {
            case 12:
                ((UILabel *)aView).font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
                [((UILabel *)aView) sizeToFit];
                break;
                
            case 13:
                ((UILabel *)aView).font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
                [((UILabel *)aView) sizeToFit];
                break;
                
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)adjustFontSizeOfCell:(UITableViewCell *)cell withCellType:(A3DaysCounterCalendarCellType)cellType {
    // suffix is tag
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:11];
    
    textLabel.font = [UIFont systemFontOfSize:30];
    countLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:65];
}

#pragma mark Instruction Related
- (void)setupInstructionView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DaysCounter_1"]) {
        [self showInstructionView];
    }
}

- (void)showInstructionView
{
    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? @"Instruction_iPhone" : @"Instruction_iPad" bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"DaysCounter_1"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view.superview addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;
}

#pragma mark - action method
- (IBAction)photoViewAction:(id)sender {
    A3DaysCounterSlideShowMainViewController *viewCtrl = [[A3DaysCounterSlideShowMainViewController alloc] initWithNibName:@"A3DaysCounterSlideShowMainViewController" bundle:nil];
    viewCtrl.sharedManager = _sharedManager;
    [self popToRootAndPushViewController:viewCtrl animate:NO];
}

- (IBAction)addEventAction:(id)sender {
    A3DaysCounterAddEventViewController *viewCtrl = [[A3DaysCounterAddEventViewController alloc] init];
    viewCtrl.landscapeFullScreen = NO;
    viewCtrl.sharedManager = _sharedManager;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        navCtrl.delegate = self;
        [self presentViewController:navCtrl animated:YES completion:^{
            [viewCtrl showKeyboard];
        }];
    }
    else {
        A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
        [rootViewController presentCenterViewController:[[A3NavigationController alloc] initWithRootViewController:viewCtrl]
                                     fromViewController:self
                                         withCompletion:^{
                                             [viewCtrl showKeyboard];
                                         }];
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

- (IBAction)editAction:(id)sender {
    A3DaysCounterEditCalendarListViewController *viewCtrl = [[A3DaysCounterEditCalendarListViewController alloc] init];
    viewCtrl.sharedManager = _sharedManager;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
		[self enableControls:NO];
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)addCalendarAction:(id)sender {
    A3DaysCounterAddAndEditCalendarViewController *viewCtrl = [[A3DaysCounterAddAndEditCalendarViewController alloc] init];
    viewCtrl.isEditMode = NO;
    viewCtrl.calendarItem = nil;
    viewCtrl.sharedManager = _sharedManager;
    
    if ( IS_IPHONE ) {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        navCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
    else {
        [self.A3RootViewController presentRightSideViewController:viewCtrl];
    }
}

- (IBAction)searchAction:(id)sender {
    [self.searchBar becomeFirstResponder];
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) {
        return;
    }
    
    if ([viewController isKindOfClass:[A3DaysCounterAddEventViewController class]]) {
        navigationController.delegate = nil;
        [((A3DaysCounterAddEventViewController *)viewController) showKeyboard];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView != self.tableView ) {
        return [_searchResultArray count];
    }
    
//    return [_itemArray count];
    NSInteger numberOfPage = (tableView.frame.size.height - _headerView.frame.size.height - _bottomToolbar.frame.size.height) / 84.0;
    
    if (_itemArray && [_itemArray count] > numberOfPage) {
        return [_itemArray count] + 1;
    }
    else {
        return numberOfPage + 1;;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
        
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return 0;
    }
    
    return 0.01;
}

- (NSString *)periodStringForEvent:(DaysCounterEvent *)event
{
    NSString *result;
    NSDate *today = [NSDate date];
    NSDate *startDate = [event effectiveStartDate];//[event.startDate solarDate];
    NSString *untilSinceString = [A3DateHelper untilSinceStringByFromDate:today
                                                                   toDate:startDate
                                                             allDayOption:[event.isAllDay boolValue]
                                                                   repeat:[event.repeatType integerValue] != RepeatType_Never ? YES : NO
                                                                   strict:NO];

    if ([untilSinceString isEqualToString:NSLocalizedString(@"Today", @"Today")] || [untilSinceString isEqualToString:NSLocalizedString(@"Now", @"Now")]) {
        result = untilSinceString;
    }
    else {
        if ( [event.repeatType integerValue] != RepeatType_Never ) {
            NSDate *nextDate;
            if ([event.isLunar boolValue]) {
                nextDate = [A3DaysCounterModelManager nextSolarDateFromLunarDateComponents:[A3DaysCounterModelManager dateComponentsFromDateModelObject:[event startDate]
                                                                                                                                                toLunar:[event.isLunar boolValue]]
                                                                                 leapMonth:[event.startDate.isLeapMonth boolValue]
                                                                                  fromDate:today];
            }
            else {
                nextDate = [A3DaysCounterModelManager nextDateWithRepeatOption:[event.repeatType integerValue]
                                                                     firstDate:[event.startDate solarDate]
                                                                      fromDate:today
                                                                      isAllDay:[event.isAllDay boolValue]];
            }

            untilSinceString = [A3DateHelper untilSinceStringByFromDate:today
                                                                 toDate:nextDate
                                                           allDayOption:[event.isAllDay boolValue]
                                                                 repeat:YES
                                                                 strict:NO];

            BOOL isAllDay = [event.isAllDay boolValue];
            if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.startDate.solarDate timeIntervalSince1970]) > 86400)) {
                isAllDay = YES;
            }

            result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
                                                                                                   fromDate:today
                                                                                                     toDate:nextDate
                                                                                                   isAllDay:isAllDay
                                                                                               isShortStyle:isAllDay? NO : YES
                                                                                          isStrictShortType:YES]
                      , untilSinceString];
//            if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.effectiveStartDate timeIntervalSince1970]) < 86400)) {
//                NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:event.effectiveStartDate isAllDay:YES];
//                if (diffDays == 1) {
//                    result = [NSString stringWithFormat:@"%ld day %@", (long)diffDays, untilSinceString];
//                }
//                else {
//                    result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
//                                                                                                           fromDate:today
//                                                                                                             toDate:nextDate
//                                                                                                           isAllDay:isAllDay
//                                                                                                       isShortStyle:isAllDay? NO : YES
//                                                                                                  isStrictShortType:YES]
//                              , untilSinceString];
//
//                }
//            }
//            else {
//                result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
//                                                                                                       fromDate:today
//                                                                                                         toDate:nextDate
//                                                                                                       isAllDay:isAllDay
//                                                                                                   isShortStyle:isAllDay? NO : YES
//                                                                                              isStrictShortType:YES]
//                          , untilSinceString];
//            }
        }
        else {
            BOOL isAllDay = [event.isAllDay boolValue];
            if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.effectiveStartDate timeIntervalSince1970]) > 86400)) {
                isAllDay = YES;
            }
//            //if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.startDate.solarDate timeIntervalSince1970]) < 86400)) {
//            FNLOG(@"%lld", llabs([today timeIntervalSince1970] - [event.effectiveStartDate timeIntervalSince1970]));
//            if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.effectiveStartDate timeIntervalSince1970]) < 86400)) {
//                NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:today];
//                NSDateComponents *efftvComp = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[event effectiveStartDate]];
//                if (todayComp.day != efftvComp.day) {
//                    isAllDay = YES;
//                }
//            }

            result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
                                                                                                   fromDate:today
                                                                                                     toDate:[event effectiveStartDate] //[event.startDate solarDate]
                                                                                                   isAllDay:isAllDay
                                                                                               isShortStyle:isAllDay? NO : YES //![event.isAllDay boolValue]
                                                                                          isStrictShortType:YES]
                      , untilSinceString];

//            if (!isAllDay && (llabs([today timeIntervalSince1970] - [event.effectiveStartDate timeIntervalSince1970]) < 86400)) {
//                NSInteger diffDays = [A3DateHelper diffDaysFromDate:[NSDate date] toDate:event.effectiveStartDate isAllDay:YES];
//                if (diffDays == 1) {
//                    result = [NSString stringWithFormat:@"%ld day %@", (long)diffDays, untilSinceString];
//                }
//                else {
//                    result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
//                                                                                                           fromDate:today
//                                                                                                             toDate:[event effectiveStartDate] //[event.startDate solarDate]
//                                                                                                           isAllDay:isAllDay
//                                                                                                       isShortStyle:isAllDay? NO : YES //![event.isAllDay boolValue]
//                                                                                                  isStrictShortType:YES]
//                              , untilSinceString];
//                }
//            }
//            else {
//                result = [NSString stringWithFormat:@"%@ %@", [A3DaysCounterModelManager stringOfDurationOption:DurationOption_Day
//                                                                                                       fromDate:today
//                                                                                                         toDate:[event effectiveStartDate] //[event.startDate solarDate]
//                                                                                                       isAllDay:isAllDay
//                                                                                                   isShortStyle:isAllDay? NO : YES //![event.isAllDay boolValue]
//                                                                                              isStrictShortType:YES]
//                          , untilSinceString];
//            }
        }
    }
    
    return result;
}

- (NSString *)dateStringForEvent:(DaysCounterEvent *)event
{
    NSString *result;
    NSDateFormatter *formatter = [NSDateFormatter new];
    if ([event.isAllDay boolValue]) {
        if ([NSDate isFullStyleLocale]) {
            [formatter setDateStyle:NSDateFormatterFullStyle];
        }
        else {
            [formatter setDateFormat:[formatter customFullStyleFormat]];
        }
    }
    else {
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    result = [A3DateHelper dateStringFromDate:[event effectiveStartDate]
                                   withFormat:[formatter dateFormat]];
    
    return result;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG();
    DaysCounterCalendar *calendarItem;
    if (tableView == self.tableView && (indexPath.row >= [_itemArray count])) {
        calendarItem = nil;
    }
    else {
        if (tableView == self.tableView) {
            calendarItem = [_itemArray objectAtIndex:[indexPath row]];
        }
        else {
            calendarItem = [_searchResultArray objectAtIndex:[indexPath row]];
        }
    }
    
    UITableViewCell *cell = nil;
    
    if (!calendarItem) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCell"];
        }
        cell.textLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    NSInteger cellType = [calendarItem.calendarType integerValue];
    NSString *CellIdentifier = (cellType == CalendarCellType_System) ? @"systemCalendarListCell" : @"userCalendarListCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        switch (cellType) {
            case CalendarCellType_System:
                cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterCalendarListMainSystemCell" owner:nil options:nil] lastObject];
                break;
                
            case CalendarCellType_User:
                cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterCalendarListMainUserCell" owner:nil options:nil] lastObject];                
                break;
                
            default:
                break;
        }
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *countLabel = (UILabel*)[cell viewWithTag:11];
    textLabel.textColor = [calendarItem color];
    countLabel.textColor = [calendarItem color];
    textLabel.text = calendarItem.calendarName;

    switch (cellType) {
        case CalendarCellType_User:
        {
            countLabel.text = [NSString stringWithFormat:@"%ld", (long)[calendarItem.events count]];
            
            UILabel *eventDetailInfoLabel1 = (UILabel*)[cell viewWithTag:14];
            UILabel *eventDetailInfoLabel2 = (UILabel*)[cell viewWithTag:15];
            NSMutableAttributedString *eventDetailInfoString = [[NSMutableAttributedString alloc] initWithString:@""];
            if ([calendarItem.events count] > 0) {
                DaysCounterEvent *event = [_sharedManager closestEventObjectOfCalendar:calendarItem];
                NSAttributedString *eventName;
                NSAttributedString *period;
                NSAttributedString *date;

                if (IS_IPHONE) {
                    eventName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [event eventName]]
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:13],
                                                                             NSForegroundColorAttributeName : [UIColor blackColor]
                                                                             }];
                    
                    period = [[NSAttributedString alloc] initWithString:[self periodStringForEvent:event]
                                                             attributes:@{
                                                                          NSFontAttributeName : [UIFont systemFontOfSize:11],
                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
                                                                          }];
                    date = [[NSAttributedString alloc] initWithString:@""
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont systemFontOfSize:11],
                                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0]
                                                                        }];
                }
                else {
                    eventName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [event eventName]]
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
                                                                             NSForegroundColorAttributeName : [UIColor blackColor]
                                                                             }];
                    period = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [self periodStringForEvent:event]]
                                                             attributes:@{
                                                                          NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote],
                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]
                                                                          }];
                    date = [[NSAttributedString alloc] initWithString:[self dateStringForEvent:event]
                                                           attributes:@{
                                                                        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                                                        NSForegroundColorAttributeName : [UIColor colorWithRed:159/255.0 green:159/255.0 blue:159/255.0 alpha:1.0]
                                                                        }];
                }
                
                
                [eventDetailInfoString appendAttributedString:period];
                [eventDetailInfoString appendAttributedString:date];
                eventDetailInfoLabel1.attributedText = eventName;
                eventDetailInfoLabel2.attributedText = eventDetailInfoString;
            }
            else {
                eventDetailInfoLabel1.text = @"";
                eventDetailInfoLabel2.text = @"";
            }
        }
            break;
            
        case CalendarCellType_System:
        {
			textLabel.text = [_sharedManager localizedSystemCalendarNameForCalendarID:calendarItem.calendarId];
            NSInteger numberOfEvents = 0;
            if ( [calendarItem.calendarId isEqualToString:SystemCalendarID_All] ) {
                numberOfEvents = [_sharedManager numberOfAllEvents];
            }
            else if ( [calendarItem.calendarId isEqualToString:SystemCalendarID_Upcoming]) {
                numberOfEvents = [_sharedManager numberOfUpcomingEventsWithDate:[NSDate date]];
            }
            else if ( [calendarItem.calendarId isEqualToString:SystemCalendarID_Past] ) {
                numberOfEvents = [_sharedManager numberOfPastEventsWithDate:[NSDate date]];
            }
            
            countLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfEvents];
        }
            break;
        default:
            break;
    }
    
    [self adjustFontSizeOfCell:cell withCellType:cellType];
    
    
    return cell;
}




#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView == self.tableView && (indexPath.row >= [_itemArray count]) ) {
        return;
    }
    
    DaysCounterCalendar *item = [(tableView == self.tableView ?_itemArray : _searchResultArray) objectAtIndex:indexPath.row];
    A3DaysCounterEventListViewController *viewCtrl = [[A3DaysCounterEventListViewController alloc] initWithNibName:@"A3DaysCounterEventListViewController" bundle:nil];
    viewCtrl.calendarItem = item;
    viewCtrl.sharedManager = _sharedManager;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG();
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
        if ( [item.calendarType integerValue] == CalendarCellType_System ) {
            return;
        }
        
        [_sharedManager removeCalendarItemWithID:item.calendarId];
        self.itemArray = [_sharedManager visibleCalendarList];
        [self setupHeaderInfo];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    FNLOG(@"indexPath: %@, _itemArray count: %ld", indexPath, (long)[_itemArray count]);
    if ( tableView == self.tableView && (indexPath.row >= [_itemArray count]) )
        return NO;

    if ([DaysCounterCalendar MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"calendarType == %@", @(CalendarCellType_User)]] == 1) {
        return NO;
    }
    
    DaysCounterCalendar *item = [_itemArray objectAtIndex:indexPath.row];
    if (!item) {
        FNLOG(@"asdf");
        return NO;
    }
    
    if (!item.calendarType || [item.calendarType isKindOfClass:[NSNull class]]) {
        FNLOG(@"asdf2");
        return NO;
    }

    return ([item.calendarType integerValue] == CalendarCellType_User);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ( scrollView != self.tableView )
        return;
    if ( (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height && scrollView.contentSize.height > (scrollView.frame.size.height - _headerView.frame.size.height - _bottomToolbar.frame.size.height) ) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 10.0);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( scrollView != self.tableView )
        return;
    if ( !decelerate )
        [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - UISearchDisplayDelegate
- (UISearchDisplayController *)mySearchDisplayController {
	if (!_mySearchDisplayController) {
		_mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
		_mySearchDisplayController.delegate = self;
		_mySearchDisplayController.searchBar.delegate = self;
		_mySearchDisplayController.searchResultsTableView.delegate = self;
		_mySearchDisplayController.searchResultsTableView.dataSource = self;
		_mySearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
        _mySearchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
	}
	return _mySearchDisplayController;
}

- (UISearchBar *)searchBar {
	if (!_searchBar) {
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, kSearchBarHeight)];
		_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
		_searchBar.delegate = self;
	}
	return _searchBar;
}

#pragma mark- UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:YES];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
	[self.tableView setHidden:NO];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 20.0;
	_searchBar.frame = frame;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	CGRect frame = _searchBar.frame;
	frame.origin.y = 0.0;
	_searchBar.frame = frame;
}

#pragma mark - SearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBar.text = @"";
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [_itemArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"calendarName contains[cd] %@",searchText]];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    [self.searchDisplayController.searchResultsTableView reloadData];
    self.searchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsZero;
    self.searchDisplayController.searchBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
}

@end
