//
//  A3DateMainTableViewController.m
//  A3TeamWork
//
//  Created by dotnetguy83 on 3/10/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateMainTableViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DateCalcHeaderView.h"
#import "A3DateCalcFooterView.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3DateCalcDurationViewController.h"
#import "A3DateCalcExcludeViewController.h"
#import "A3DateCalcEditEventViewController.h"
#import "A3DateCalcStateManager.h"
#import "A3DateCalcAddSubCell1.h"
#import "A3DateCalcAddSubCell2.h"
#import "A3DefaultColorDefines.h"
#import "A3AppDelegate+appearance.h"
#import "NSString+conversion.h"
#import "UIViewController+iPad_rightSideView.h"

#define kDefaultBackgroundColor [UIColor lightGrayColor]
#define kDefaultButtonColor     [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0]
#define kSelectedButtonColor    [A3AppDelegate instance].themeColor
NSString *kCalculationString;

@interface A3DateMainTableViewController () <UITextFieldDelegate, UIPopoverControllerDelegate, A3DateKeyboardDelegate, A3DateCalcExcludeDelegate, A3DateCalcDurationDelegate, A3DateCalcHeaderViewDelegate, A3DateCalcEditEventDelegate, UIActivityItemSource>

@property (strong, nonatomic) A3DateCalcHeaderView *headerView;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;

@property (assign, nonatomic) BOOL isAddSubMode;
@property (strong, nonatomic) NSDate * fromDate;
@property (strong, nonatomic) NSDate * toDate;
@property (strong, nonatomic) NSDate * fromDateCursor;  // 슬라이더 커서를 날짜에 반영하는 임시값
@property (strong, nonatomic) NSDate * toDateCursor;
@property (strong, nonatomic) NSDate * offsetDate;
@property (strong, nonatomic) NSDateComponents* offsetComp;
@property (strong, nonatomic) NSString * excludeDateString;
@property (strong, nonatomic) NSString * durationOptionString;

@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, copy) NSString *textBeforeEditingText;
@property (nonatomic, copy) NSString *placeholderBeforeEditingText;
@end


@implementation A3DateMainTableViewController {
    BOOL _isShowMoreMenu;
    BOOL _isKeyboardShown;
    BOOL _datePrevShow, _dateNextShow;
    BOOL _isSelectedFromToCell;
    CGFloat _tableYOffset;
    CGFloat _oldTableOffset;
    A3NumberKeyboardViewController *_simpleNormalNumberKeyboard;
}

@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize offsetDate = _offsetDate;


- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {

	}

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Date Calculator";
    [self leftBarButtonAppsButton];
    [self makeBackButtonEmptyArrow];

	self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    
    // 저장된 textField의 값으로 초기화 하도록 수정.
    self.offsetComp = [A3DateCalcAddSubCell2 dateComponentBySavedText];
    
    if (self.fromDate==nil) {
        self.fromDate = [NSDate date];
    }
    if (self.toDate==nil) {
        NSDateComponents *comp = [NSDateComponents new];
        comp.month = 1;
        self.toDate = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:comp toDate:self.fromDate options:0];
    }
    
    if ([A3DateCalcStateManager excludeOptions]==0) {
        [A3DateCalcStateManager setExcludeOptions:ExcludeOptions_None];
    }
    if ([A3DateCalcStateManager durationType]==0) {
        [A3DateCalcStateManager setDurationType:DurationType_Year|DurationType_Month|DurationType_Day];
    }
    _isKeyboardShown = NO;

//    if (IS_IPHONE) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
//    }

    [self initializeControl];
    [self reloadTableViewData:YES];
    [self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)rightSideViewWillHide {
	[self enableControls:YES];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)initializeControl
{
    // HeaderView
    self.headerView = [[A3DateCalcHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), IS_IPHONE ? 104 : 158)];
    self.headerView.delegate = self;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    kCalculationString = @"CALCULATION";
    self.tableView.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15.0 : 28.0, 0, 0);
    if (IS_IPAD) {
        self.navigationItem.hidesBackButton = YES;
    }
    
    self.tableView.tableHeaderView = self.headerView;
    
    // NavigationItem
//    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addToDaysCounter"]
//                                                            style:UIBarButtonItemStylePlain
//                                                           target:self
//                                                           action:@selector(addEventButtonAction:)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(shareButtonAction:)];
    self.navigationItem.rightBarButtonItems = @[share];
    
    // Etc
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (IS_IPAD) {
        if ([self isAddSubMode]) {
            [self refreshAddSubModeButtonForResultWithAnimation:YES];
        }
        else {
            [self.headerView setFromDate:self.fromDate toDate:self.toDate];
        }
    }
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.headerView setNeedsLayout];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.dateKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)clearEverything {
	if (_editingIndexPath) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_editingIndexPath];
		cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
		_editingIndexPath = nil;
	}

    [self.firstResponder resignFirstResponder];
	[self dismissMoreMenu];
}

#pragma mark - Properties
#define kDefault_didSelectMinus @"didSelectMinus"

-(void)setIsAddSubMode:(BOOL)isAddSubMode
{
    [[NSUserDefaults standardUserDefaults] setBool:isAddSubMode forKey:@"isAddSubMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isAddSubMode
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAddSubMode"];
}

-(BOOL)didSelectedAdd
{
    BOOL didSelectMinus = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];
    return didSelectMinus==YES? NO : YES;
}

-(void)setFromDate:(NSDate *)fromDate
{
    _fromDate = [fromDate copy];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                                                         fromDate:_fromDate];
    comp.hour = 0;
    comp.minute = 0;
    _fromDate = [[A3DateCalcStateManager currentCalendar] dateFromComponents:comp];
    
    [[NSUserDefaults standardUserDefaults] setObject:_fromDate forKey:@"fromDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setToDate:(NSDate *)toDate
{
    _toDate = [toDate copy];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                                                         fromDate:_toDate];
    comp.hour = 0;
    comp.minute = 0;
    _toDate = [[A3DateCalcStateManager currentCalendar] dateFromComponents:comp];
    
    [[NSUserDefaults standardUserDefaults] setObject:_toDate forKey:@"toDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setOffsetDate:(NSDate *)offsetDate
{
    _offsetDate = [offsetDate copy];
    [[NSUserDefaults standardUserDefaults] setObject:_offsetDate forKey:@"offsetDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDate *)fromDate
{
    _fromDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"fromDate"];
    return _fromDate;
}

-(NSDate *)toDate
{
    _toDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"toDate"];
    return _toDate;
}

-(NSDate *)offsetDate
{
    _offsetDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"offsetDate"];
    return _offsetDate;
}

-(NSDateComponents *)betweenDateCalculatedFromTo
{
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:self.fromDate toDate:self.toDate options:0];
    return components;
}

#pragma mark - Button Actions

- (IBAction)addButtonTouchUpAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDefault_didSelectMinus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL isMinusSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];

    A3DateCalcAddSubCell1 *footerAddSubCell = (A3DateCalcAddSubCell1 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.addModeButton setNeedsDisplay];
    [footerAddSubCell.subModeButton setNeedsDisplay];
    
    [self refreshAddSubModeButtonForResultWithAnimation:YES];
}

- (IBAction)subButtonTouchUpAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefault_didSelectMinus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL isMinusSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];
    
    A3DateCalcAddSubCell1 *footerAddSubCell = (A3DateCalcAddSubCell1 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.addModeButton setNeedsDisplay];
    [footerAddSubCell.subModeButton setNeedsDisplay];
    
    [self refreshAddSubModeButtonForResultWithAnimation:YES];
}

- (void)refreshAddSubModeButtonForResultWithAnimation:(BOOL)animation
{
    NSDateComponents *compAdd = [NSDateComponents new];
    
    if ([self didSelectedAdd]) {
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:self.offsetComp
                                                                                   toDate:_fromDate
                                                                                  options:0];
        [self.headerView setFromDate:self.fromDate toDate:result];
        [self.headerView setResultAddDate:result withAnimation:animation];
        
    } else {
        compAdd.year = self.offsetComp.year * -1;
        compAdd.month = self.offsetComp.month * -1;
        compAdd.day = self.offsetComp.day * -1;
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:compAdd
                                                                                   toDate:_fromDate
                                                                                  options:0];
        [self.headerView setFromDate:self.fromDate toDate:result];
        [self.headerView setResultSubDate:result withAnimation:animation];
    }
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	FNLOG();

	[self clearEverything];
	[super appsButtonAction:barButtonItem];
	if (IS_IPAD) {
		[self enableControls:!self.A3RootViewController.showLeftView];
	}
}

- (void)addEventButtonAction:(UIButton *)button
{
    [self clearEverything];
    A3DateCalcEditEventViewController *viewController = [[A3DateCalcEditEventViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    if (IS_IPHONE) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        viewController.delegate = self;
        [self presentSubViewController:viewController];
		[self enableControls:NO];
    }
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
}

#pragma mark Share

- (void)shareButtonAction:(id)sender {
    [self clearEverything];
    
    _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender];
    if (IS_IPAD) {
        _sharePopoverController.delegate = self;
		[self enableControls:NO];
    }
}

#pragma mark Share Activities releated
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return @"Date Calculator using AppBox Pro";
	}
    
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        
		NSMutableString *txt = [NSMutableString new];
		[txt appendString:@"<html><body>I'd like to share a calculation with you.<br/><br/>"];
		[txt appendString:[self stringForShare]];
		[txt appendString:@"<br/><br/>You can calculator more in the AppBox Pro.<br/><img style='border:0;' src='http://apns.allaboutapps.net/allaboutapps/appboxIcon60.png' alt='AppBox Pro'><br/><a href='https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8'>Download from AppStore</a></body></html>"];
        
		return txt;
	}
	else {
        NSString *shareString = [self stringForShare];
        shareString = [shareString stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
		return shareString;
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return @"Share Currency Converter Data";
}

- (NSString *)stringForShare {
    NSString *shareString;
    if (self.isAddSubMode) {
        shareString = [self stringOfAddSubModeForShare];
    }
    else {
        shareString = [self stringOfBetweenModeForShare];
    }
    return shareString;
}

- (NSString *)stringOfBetweenModeForShare {
    
    NSMutableString *shareString = [[NSMutableString alloc] init];
    
    /*  Between인 경우
     "Calculate duration between two dates.
     From and including: 시작날
     To, but not including: 끝날
     Result:  ? years ? months ? days" */
    [shareString appendString:[NSString stringWithFormat:@"From: %@<br>", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
    [shareString appendString:[NSString stringWithFormat:@"To: %@<br>", [A3DateCalcStateManager formattedStringDate:_toDate]]];
    if ([A3DateCalcStateManager excludeOptions] != ExcludeOptions_None) {
        [shareString appendString:[NSString stringWithFormat:@"Exclude: %@<br>", [A3DateCalcStateManager excludeOptionsString]]];
    }
    
    NSDateComponents *intervalComp = [A3DateCalcStateManager dateComponentFromDate:_fromDate toDate:_toDate];
    DurationType durationType = [A3DateCalcStateManager durationType];
    NSMutableString *intervals = [[NSMutableString alloc] init];
    
    if ( (durationType & DurationType_Year) && intervalComp.year!=0 ) {
        [intervals appendString:[NSString stringWithFormat:@" %ld year", (long)intervalComp.year]];
        if ([intervalComp year] > 1) {
            [intervals appendString:@"s"];
        }
    }
    
    if ( (durationType & DurationType_Month) && intervalComp.month!=0 ) {
        [intervals appendString:[NSString stringWithFormat:@" %ld month", (long)intervalComp.month]];
        if ([intervalComp month] > 1) {
            [intervals appendString:@"s"];
        }
    }
    
    if ( (durationType & DurationType_Week) && intervalComp.week!=0 ) {
        [intervals appendString:[NSString stringWithFormat:@" %ld week", (long)intervalComp.week]];
        if ([intervalComp week] > 1) {
            [intervals appendString:@"s"];
        }
    }
    
    if ( (durationType & DurationType_Day) && intervalComp.day!=0 ) {
        [intervals appendString:[NSString stringWithFormat:@" %ld day", (long)intervalComp.day]];
        if ([intervalComp day] > 1) {
            [intervals appendString:@"s"];
        }
    }
    
    [shareString appendString:[NSString stringWithFormat:@"Result: %@", intervals]];
    
    
    return shareString;
}

- (NSString *)stringOfAddSubModeForShare {
    
    NSMutableString *shareString = [[NSMutableString alloc] init];
    
    /* Date Calculator
     From 시작날
     Added (or Subtracted)  x years ?? months ?? days (값이 0이 아닌 경우만 표시)
     Result: 결과 값  */
    if ([self didSelectedAdd]) {
        
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:self.offsetComp
                                                                                   toDate:_fromDate
                                                                                  options:0];
        
        //[shareString appendString:[NSString stringWithFormat:@"Date Calculator\n"]];
        [shareString appendString:[NSString stringWithFormat:@"From: %@<br>", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
        
        NSMutableString *intervals = [[NSMutableString alloc] init];
        if (self.offsetComp.year!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld year", (long)self.offsetComp.year]];
            if ([self.offsetComp year] > 1) {
                [intervals appendString:@"s"];
            }
        }
        if (self.offsetComp.month!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld month", (long)self.offsetComp.month]];
            if ([self.offsetComp month] > 1) {
                [intervals appendString:@"s"];
            }
        }
        if (self.offsetComp.day!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld day", (long)self.offsetComp.day]];
            if ([self.offsetComp day] > 1) {
                [intervals appendString:@"s"];
            }
        }
        
        if (intervals.length <= 0) {
            [shareString appendString:[NSString stringWithFormat:@"Add: 0 day<br>"]];
        }
        else {
            [shareString appendString:[NSString stringWithFormat:@"Add: %@<br>", intervals]];
        }
        
        [shareString appendString:[NSString stringWithFormat:@"Result: %@", [A3DateCalcStateManager formattedStringDate:result]]];
        
    }
    else {
        NSDateComponents *compAdd = [NSDateComponents new];
        compAdd.year = self.offsetComp.year * -1;
        compAdd.month = self.offsetComp.month * -1;
        compAdd.day = self.offsetComp.day * -1;
        
        NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:compAdd
                                                                                   toDate:_fromDate
                                                                                  options:0];
        
        //[shareString appendString:[NSString stringWithFormat:@"Date Calculator\n"]];
        [shareString appendString:[NSString stringWithFormat:@"From: %@<br>", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
        
        NSMutableString *intervals = [[NSMutableString alloc] init];
        if (self.offsetComp.year!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld year", (long)self.offsetComp.year]];
            if ([self.offsetComp year] > 1) {
                [intervals appendString:@"s"];
            }
        }
        if (self.offsetComp.month!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld month", (long)self.offsetComp.month]];
            if ([self.offsetComp month] > 1) {
                [intervals appendString:@"s"];
            }
        }
        if (self.offsetComp.day!=0) {
            [intervals appendString:[NSString stringWithFormat:@" %ld day", (long)self.offsetComp.day]];
            if ([self.offsetComp day] > 1) {
                [intervals appendString:@"s"];
            }
        }
        
        if (intervals.length <= 0) {
            [shareString appendString:[NSString stringWithFormat:@"Subtract: 0 day<br>"]];
        } else {
            [shareString appendString:[NSString stringWithFormat:@"Subtract: %@<br>", intervals]];
        }
        
        [shareString appendString:[NSString stringWithFormat:@"Result: %@", [A3DateCalcStateManager formattedStringDate:result]]];
    }
    
    return shareString;
}

#pragma mark - More Menu Actions

- (void)moreButtonAction:(UIButton *)button
{
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(doneButtonAction:)];

	UIButton *add = [UIButton buttonWithType:UIButtonTypeSystem];
	[add setImage:[UIImage imageNamed:@"addToDaysCounter"] forState:UIControlStateNormal];
	[add addTarget:self action:@selector(addEventButtonAction:) forControlEvents:UIControlEventTouchUpInside];

	UIButton *space = [UIButton buttonWithType:UIButtonTypeSystem];

	_moreMenuButtons = @[add, space, self.shareButton];

	_moreMenuView = [self presentMoreMenuWithButtons:_moreMenuButtons tableView:self.tableView];
	_isShowMoreMenu = YES;
}

- (void)doneButtonAction:(id)button {
	[self clearEverything];
}

- (void)dismissMoreMenu {
	if ( !_isShowMoreMenu || IS_IPAD ) return;

	[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	if (!_isShowMoreMenu) return;

	_isShowMoreMenu = NO;

	[self rightButtonMoreButton];
	[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
	[self.view removeGestureRecognizer:gestureRecognizer];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popover controller, iPad only.
	[self enableControls:YES];
	_sharePopoverController = nil;
}

#pragma mark - View Control Actions

- (void)moveToFromDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;

//    CGFloat keyboardPadding = IS_IPHONE ? -1.0 : 0.0;
    
    self.editingIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:11];
    [textField becomeFirstResponder];
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    _isSelectedFromToCell = YES;
    
//    if (IS_IPAD && IS_PORTRAIT) {
//        return;
//    }
    
//    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.editingIndexPath];
//    CGFloat offset = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.dateKeyboardViewController.view.bounds.size.height);
//    _oldTableOffset = self.tableView.contentOffset.y;
//    NSLog(@"%f", offset);
//    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:YES];
}

- (void)moveToToDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;

//    CGFloat keyboardPadding = IS_IPHONE ? -1.0 : 0.0;
    
    self.editingIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:11];
    [textField becomeFirstResponder];
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    _isSelectedFromToCell = YES;
    
    if (IS_IPAD && IS_PORTRAIT) {
        return;
    }
    
//    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.editingIndexPath];
//	FNLOGRECT(self.tableView.frame);
//	FNLOGRECT(self.dateKeyboardViewController.view.bounds);
//	FNLOGRECT(cellRect);
//    CGFloat offset = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.dateKeyboardViewController.view.bounds.size.height);
//    _oldTableOffset = self.tableView.contentOffset.y;
//    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:YES];
}

- (void)moveToFooterView
{
    if (IS_IPAD && IS_PORTRAIT) {
        return;
    }
    
    CGPoint contentOffset = CGPointZero;
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    CGFloat keyboardPadding = IS_IPHONE ? 0.0 : 2.0;
    contentOffset.y = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.simpleNumberKeyboard.view.bounds.size.height);
	FNLOGRECT(self.tableView.frame);
	FNLOGRECT(self.simpleNumberKeyboard.view.frame);
	FNLOGRECT(cellRect);
	FNLOG(@"contentOffset.y = %f", contentOffset.y);

    _oldTableOffset = self.tableView.contentOffset.y;
    self.tableView.contentOffset = contentOffset;
}

- (void)setResultToHeaderViewWithAnimation:(BOOL)animation
{
    self.fromDateCursor = [self.fromDate copy];
    self.toDateCursor = [self.toDate copy];
    
    if (self.isAddSubMode) {
        [self refreshAddSubModeButtonForResultWithAnimation:animation];
    }
    else {
        NSDateComponents *resultComp;
        if ([_fromDate compare:_toDate] == NSOrderedAscending) {
            resultComp = [A3DateCalcStateManager dateComponentFromDate:_fromDate toDate:_toDate];
        } else {
            resultComp = [A3DateCalcStateManager dateComponentFromDate:_toDate toDate:_fromDate];
        }
        
        [self.headerView setCalcType:CALC_TYPE_BETWEEN];
        [self.headerView setFromDate:self.fromDate toDate:self.toDate];
        [self.headerView setResultBetweenDate:resultComp withAnimation:animation];
    }
}

#pragma mark - HeaderView Delegate

- (void)dateCalcHeaderChangedFromDate:(NSDate *)fDate toDate:(NSDate *)tDate
{
    NSLog(@"fDate: %@", fDate);
    NSLog(@"tDate: %@", tDate);
    
    if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {   // from > to, 큰 값이 오른쪽(to)에 위치한다.
        self.fromDateCursor = tDate;
        self.toDateCursor = fDate;
    } else {
        self.fromDateCursor = fDate;
        self.toDateCursor = tDate;
    }
    
    if (![self isAddSubMode]) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

-(void)dateCalcHeaderAddSubResult:(NSDateComponents *)compResult {
    //    footerCell.yearTextField.text = [NSString stringWithFormat:@"%d", compResult.year];
    //    footerCell.monthTextField.text = [NSString stringWithFormat:@"%d", compResult.month];
    //    footerCell.dayTextField.text = [NSString stringWithFormat:@"%d", compResult.day];
}

-(void)dateCalcHeaderFromThumbTapped {
    /*
     * from 이 더 큰 경우, to와 위치가 바뀜.
     - Between
     : from 이 to 보다 작거나 같은 경우 => from 서클(left) Tap => from 셀로 이동.
     : from 이 to 보다 작거나 같은 경우 => to 서클(right) Tap => to 셀로 이동.
     : (reverse) from 이 to 보다 큰 경우 => to 서클(right) Tap => From 셀로 이동.
     : (reverse) from 이 to 보다 큰 경우 => from 서클(left) Tap => to 셀로 이동.
     
     - AddSub
     : add 모드 => from 서클(left) Tap => from 셀로 이동.
     : add 모드 => to 서클(right) Tap => 하단 날짜 입력 필드 이동?
     : (reverse) sub 모드 => from 서클(left) Tap => 하단 날짜 입력 필드 이동?
     : (reverse) sub 모드 => to 서클(right) Tap => from 셀로 이동.
     
     #입력중에도 좌우 크기에 따라서, 터치했던 커서의 위치겨 변경됩니다.
     #회색 처리된 circle 도, 탭 가능.
     */

	self.dateKeyboardViewController = self.newDateKeyboardViewController;
	[self.dateKeyboardViewController changeInputToYear];

	if (!self.isAddSubMode) {

        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
			self.dateKeyboardViewController.date = self.toDate;
			[self moveToToDateCell];
        } else {
            // from < to
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        }
        
    } else {
        if ([self didSelectedAdd]) {
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        } else {
            A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            if (!footerCell) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            }
            
            [footerCell.yearTextField becomeFirstResponder];
            self.firstResponder = footerCell.yearTextField;
        }
    }
}

-(void)dateCalcHeaderToThumbTapped {
	self.dateKeyboardViewController = self.newDateKeyboardViewController;
	[self.dateKeyboardViewController changeInputToYear];

	if (!self.isAddSubMode) {
        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        } else {
            // from < to
			self.dateKeyboardViewController.date = self.toDate;
            [self moveToToDateCell];
        }
    }
    else {
        if ([self didSelectedAdd]) {
            A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
            [footerCell.yearTextField becomeFirstResponder];
            self.firstResponder = footerCell.yearTextField;
        } else {
			self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        }
    }
}

-(void)dateCalcHeaderThumbPositionChangeOfFromDate:(NSDate *)fDate toDate:(NSDate *)toDate
{
    NSLog(@"f: %@, t: %@", fDate, toDate);
//    UITableViewCell *fromCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//    UITableViewCell *toCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];

    
}

-(void)dateCalcHeaderThumbPositionChangeOfAddSubDateComponents:(NSDateComponents *)dateComp
{
    NSLog(@"%@", dateComp);
}

#pragma mark - UITextField Related

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.firstResponder = textField;
	self.textBeforeEditingText = textField.text;
	self.placeholderBeforeEditingText = textField.placeholder;
	textField.text = @"";
	textField.placeholder = @"0";
    
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    if (!footerCell) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }

	if (self.isAddSubMode && [footerCell hasEqualTextField:(UITextField *)self.firstResponder]) {
		if (_simpleNormalNumberKeyboard==nil) {
			_simpleNormalNumberKeyboard = [self simplePrevNextNumberKeyboard];
			if (IS_IPHONE) {
				((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).needButtonsReload = NO;
			}
			_simpleNormalNumberKeyboard.useDotAsClearButton = YES;
		}

		_simpleNormalNumberKeyboard.textInputTarget = textField;
		_simpleNormalNumberKeyboard.delegate = self;
		textField.inputView = _simpleNormalNumberKeyboard.view;

		if (textField == footerCell.yearTextField) {
			_datePrevShow = NO;
			_dateNextShow = YES;

		}
		else if (textField == footerCell.monthTextField) {
			_datePrevShow = YES;
			_dateNextShow = YES;
		}
		else if (textField == footerCell.dayTextField) {
			_datePrevShow = YES;
			_dateNextShow = NO;
		}

		[_simpleNormalNumberKeyboard reloadPrevNextButtons];
	}
	else {
		A3DateKeyboardViewController * keyboardVC = [self dateKeyboardViewController];
		keyboardVC.delegate = self;
		textField.inputView = keyboardVC.view;
	}

	_isKeyboardShown = YES;

	[self setFirstResponder:textField];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.firstResponder == textField) {
        [self setFirstResponder:nil];
    }

    _isSelectedFromToCell = NO;
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [textField convertPoint:textField.center toView:self.tableView].y)];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && [indexPath section] == 1) {
        cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    }
    
	if (![textField.text length] && _textBeforeEditingText) {
		textField.text = [NSString stringWithFormat:@"%ld", (long)[_textBeforeEditingText floatValueEx]];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
	[self updateOffsetDateCompWithTextField:textField];

	textField.placeholder = _placeholderBeforeEditingText;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    
	UITextField *textField = notification.object;
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
	if (self.isAddSubMode && [footerCell hasEqualTextField:textField]) {
        if (textField == footerCell.yearTextField) {
            self.offsetComp.year = textField.text.integerValue;
        }
        else if (textField == footerCell.monthTextField) {
            self.offsetComp.month = textField.text.integerValue;
        }
        else if (textField == footerCell.dayTextField) {
            self.offsetComp.day = textField.text.integerValue;
        }
        
        [footerCell saveInputedTextField:textField];
	}
    else {
        NSLog(@"from/to: %@", notification);
	}
}

//-(void)keyboardWillShow:(NSNotification *)aNoti
//{
//    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
//    
//    if (self.isAddSubMode && [footerCell hasEqualTextField:_selectedTextField]) {
//        NSDictionary *aDict = [aNoti userInfo];
//        CGRect keyboardSize = [self.view convertRect:[[aDict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
//        keyboardSize.size.height = keyboardSize.size.height-90.0;
//        NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
//        NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
//        
//        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//        [UIView setAnimationCurve:[animationCurve intValue]];
//        [UIView setAnimationDuration:[animationDuration doubleValue]];
//        
//        if (self.isAddSubMode) {
//            [self moveToFooterView];
//        }
//        
//        [UIView commitAnimations];
//    }
//}

- (void)keyboardDidHide:(NSNotification *)noti {
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:NO];
}

#pragma mark  A3KeyboardViewControllerDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    // 풋터뷰 필드(ADD/SUB모드)
    if (self.isAddSubMode && (self.firstResponder == footerCell.yearTextField || self.firstResponder == footerCell.monthTextField || self.firstResponder == footerCell.dayTextField)) {
        NSDateComponents *changed = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                                fromDate:date];
        if (self.firstResponder == footerCell.yearTextField) {
            self.offsetComp.year = changed.year;
        }
        else if (self.firstResponder == footerCell.monthTextField) {
            self.offsetComp.month = changed.month;
        }
        else if (self.firstResponder == footerCell.dayTextField) {
            self.offsetComp.day = changed.day;
        }
        
        [footerCell setOffsetDateComp:self.offsetComp];
    }
    else {
        // From/To Cell
        UITextField *selectedTextField = (UITextField *)self.firstResponder;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(100, [selectedTextField convertPoint:selectedTextField.center toView:self.tableView].y)];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        if (self.editingIndexPath.row == 0) {
            if (self.isAddSubMode) {
                self.fromDate = date == nil ? [NSDate date] : date;
            }
            else {
                self.fromDate = date == nil ? [NSDate date] : date;
            }
            
            if (cell) {
                cell.detailTextLabel.text = [A3DateCalcStateManager formattedStringDate:self.fromDate];
                cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
            }
        }
        else {
            self.toDate = date == nil ? [NSDate date] : date;
            if (cell) {
                cell.detailTextLabel.text = [A3DateCalcStateManager formattedStringDate:self.toDate];
                cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
            }
        }
        
        if (_isSelectedFromToCell) {
            _isSelectedFromToCell = NO;
            [self.tableView deselectRowAtIndexPath:_editingIndexPath animated:YES];
        }
        
        [self setResultToHeaderViewWithAnimation:YES];
    }
}

- (BOOL)isPreviousEntryExists {
    return _datePrevShow;
}

- (BOOL)isNextEntryExists {
    return _dateNextShow;
}

- (void)nextButtonPressed{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
	if (self.firstResponder == footerCell.yearTextField) {
		self.firstResponder = footerCell.monthTextField;
		[footerCell.monthTextField becomeFirstResponder];
	}
    else if (self.firstResponder == footerCell.monthTextField) {
		self.firstResponder = footerCell.dayTextField;
		[footerCell.dayTextField becomeFirstResponder];
	}
    else if (self.firstResponder == footerCell.dayTextField) {
		return;
	}
}

- (void)prevButtonPressed
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
	if (self.firstResponder == footerCell.dayTextField) {
		footerCell.dayTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.day];
		self.firstResponder = footerCell.monthTextField;
		[footerCell.monthTextField becomeFirstResponder];
	}
    else if (self.firstResponder == footerCell.monthTextField) {
		footerCell.monthTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.month];
		self.firstResponder = footerCell.yearTextField;
		[footerCell.yearTextField becomeFirstResponder];
	}
    else if (self.firstResponder == footerCell.yearTextField) {
		footerCell.yearTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.year];
		[self moveToFromDateCell];
	}
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController
{
    [self.firstResponder resignFirstResponder];

    _isKeyboardShown = NO;
	_editingIndexPath = nil;
    [self setResultToHeaderViewWithAnimation:YES];
	self.dateKeyboardViewController = nil;
}

- (void)updateOffsetDateCompWithTextField:(UITextField *)textField
{
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];

	if (self.isAddSubMode && (self.firstResponder == footerCell.yearTextField || self.firstResponder == footerCell.monthTextField || self.firstResponder == footerCell.dayTextField)) {
		if (self.firstResponder == footerCell.yearTextField) {
			self.offsetComp.year = footerCell.yearTextField.text.integerValue;
		}
        else if (self.firstResponder == footerCell.monthTextField) {
			self.offsetComp.month = footerCell.monthTextField.text.integerValue;
		}
        else if (self.firstResponder == footerCell.dayTextField) {
			self.offsetComp.day = footerCell.dayTextField.text.integerValue;
		}

		[footerCell setOffsetDateComp:self.offsetComp];
		[self setResultToHeaderViewWithAnimation:YES];
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (keyInputDelegate != self.firstResponder) {
		return;
	}

	[self.firstResponder resignFirstResponder];
	_isKeyboardShown = NO;
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    UITextField *selectedTextField = (UITextField *)self.firstResponder;
    selectedTextField.text = @"";
	_textBeforeEditingText = nil;
    A3DateCalcAddSubCell2 *footerCell = (A3DateCalcAddSubCell2 *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
	if ([footerCell hasEqualTextField:selectedTextField]) {
		if (selectedTextField == footerCell.yearTextField) {
			self.offsetComp.year = 0;
		}
		else if (selectedTextField==footerCell.monthTextField) {
			self.offsetComp.month = 0;
		}
		else if (selectedTextField==footerCell.dayTextField) {
			self.offsetComp.day = 0;
		}

		[footerCell saveInputedTextField:selectedTextField];
	}
}

#pragma mark - UITableView Related

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![self isAddSubMode]) {
        return section == 0 ? 55 : 0;
    }
    
    return section == 0 ? 55.0 : 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (![self isAddSubMode]) {
        return 0;
    }
    
    return section == 3 ? (IS_RETINA ? 37.5 : 38) : 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAddSubMode==YES && indexPath.section==2 && indexPath.row==0) {
        //return self.footerView.bounds.size.height;
        return 50.0;
    }
    if (self.isAddSubMode==YES && indexPath.section==3 && indexPath.row==0) {
        return 82.0;
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:  // From, To 날짜 입력 셀 섹션.
        {
            CGRect rect = cell.detailTextLabel.frame;
            rect.origin.x = 300;//cell.bounds.size.width - cell.detailTextLabel.frame.size.width;
            cell.detailTextLabel.frame = rect;
        }
    }
}

- (A3DateCalcAddSubCell1 *)cellOfAddSub1CellForID:(NSString *)cellAddSubCell1 tableView:(UITableView *)tableView
{
    // FooterViewCell - Add Sub Button Cell
    A3DateCalcAddSubCell1 *footerAddSubCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell1];
    if (!footerAddSubCell) {
        footerAddSubCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell1" owner:self options:nil] lastObject];
    }
    
    [footerAddSubCell.addModeButton addTarget:self action:@selector(addButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerAddSubCell.subModeButton addTarget:self action:@selector(subButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isMinusSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];
    footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    
    [footerAddSubCell.addModeButton setBackgroundColor:footerAddSubCell.addModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
    [footerAddSubCell.subModeButton setBackgroundColor:footerAddSubCell.subModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
    return footerAddSubCell;
}

- (A3DateCalcAddSubCell2 *)cellOfAddSub2CellForID:(NSString *)cellAddSubCell2 tableView:(UITableView *)tableView
{
    // FooterViewCell - Year Month Day, Input TextField Cell
    A3DateCalcAddSubCell2 *footerCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell2];
    if (!footerCell) {
        footerCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell2" owner:self options:nil] lastObject];
    }
    
    footerCell.yearTextField.delegate = self;
    footerCell.monthTextField.delegate = self;
    footerCell.dayTextField.delegate = self;
    
    [footerCell setOffsetDateComp:self.offsetComp];
    
    if (IS_IPHONE) {
        footerCell.yearLabel.font = [UIFont systemFontOfSize:13];
        footerCell.monthLabel.font = [UIFont systemFontOfSize:13];
        footerCell.dayLabel.font = [UIFont systemFontOfSize:13];
    }
    else {
        footerCell.yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        footerCell.monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        footerCell.dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    return footerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellIdentifier = @"Cell";
    static NSString *const cellAddSubCell1 = @"AddSubCell1";
    static NSString *const cellAddSubCell2 = @"AddSubCell2";
    
    if (self.isAddSubMode==YES) {
        if (indexPath.section==2 && indexPath.row==0) {
            A3DateCalcAddSubCell1 *footerAddSubCell;
            footerAddSubCell = [self cellOfAddSub1CellForID:cellAddSubCell1 tableView:tableView];
            return footerAddSubCell;
        }
        else if (indexPath.section==3 && indexPath.row==0) {
            A3DateCalcAddSubCell2 *footerCell;
            footerCell = [self cellOfAddSub2CellForID:cellAddSubCell2 tableView:tableView];
            return footerCell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        UITextField *textField = [UITextField new];
        textField.tag = 11;
        [cell.contentView addSubview:textField];
        [textField makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@10);
            make.top.equalTo(cell.contentView.top);
            make.bottom.equalTo(cell.contentView.bottom);
            make.trailing.equalTo(cell.contentView.right);
        }];
        textField.hidden = YES;
        textField.delegate = self;
    }
    
    [cell.textLabel setText:self.sections[indexPath.section][indexPath.row]];
    
    switch (indexPath.section) {
        case 0: // Caculation - between, add/sub 모드 선택 섹션.
        {
            switch (indexPath.row) {
                case 0:
                    cell.accessoryType = self.isAddSubMode==YES? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                    
                case 1:
                    cell.accessoryType = self.isAddSubMode==YES? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            cell.detailTextLabel.text = @"";
        }
            break;
            
        case 1:  // From, To 날짜 입력 셀 섹션.
        {
            UIFont *font = cell.detailTextLabel.font;
            font = [font fontWithSize:17.0];
            cell.detailTextLabel.font = font;
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager formattedStringDate:self.fromDateCursor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 1:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager formattedStringDate:self.toDateCursor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }
            
//            [cell.detailTextLabel sizeToFit];
//            
//            // detailTextLabel 위치 조정, 실패.
//            CGRect rect = cell.detailTextLabel.frame;
//            //rect.origin.x = cell.contentView.bounds.size.width - cell.detailTextLabel.frame.size.width;
//            rect.origin.x = 300;//cell.bounds.size.width - cell.detailTextLabel.frame.size.width;
//            cell.detailTextLabel.frame = rect;
            
//            // 선택된 셀로 이동.
//            if (indexPath.section==_editingIndexPath.section && indexPath.row==_editingIndexPath.row && _isSelectedFromToCell) {
//                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//            }
            
            // 선택된 셀 텍스트 색상 편집 중에만 변경.
            if (_isKeyboardShown && _editingIndexPath && (indexPath.row==_editingIndexPath.row)) {
                cell.detailTextLabel.textColor = [A3AppDelegate instance].themeColor;
            } else {
                cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            }
        }
            break;
            
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager excludeOptionsString];
                    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
            
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.detailTextLabel.text = [A3DateCalcStateManager durationTypeString];
                    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
            }
        }
            break;
    }
    
    return cell;
}

- (void)reloadTableViewData:(BOOL)bInit
{
    if (bInit) {
        if (self.isAddSubMode) {
            self.sectionTitles = @[kCalculationString, @"", @"", @""];
            self.sections = @[
                              @[@"Between two dates", @"Add or Subtract days"],
                              @[@"From"],
                              @[@"AddSubCell1"],
                              @[@"AddSubCell2"]
                              ];
        } else {
            self.sectionTitles = @[kCalculationString, @"", @"", @""];
            self.sections = @[
                              @[@"Between two dates", @"Add or Subtract days"],
                              @[@"From", @"To"],
                              @[@"Exclude"],
                              @[@"Duration"]
                              ];
        }
        
        [_headerView setFromDate:self.fromDate toDate:self.toDate];
        [self setResultToHeaderViewWithAnimation: bInit? NO : YES];
        
        [self.tableView reloadData];
        return;
    }
    else {
        [self setResultToHeaderViewWithAnimation: bInit? NO : YES];
        
        if (self.isAddSubMode) {
            
            self.sectionTitles = @[kCalculationString, @""];
            self.sections = @[
                              @[@"Between two dates", @"Add or Subtract days"],
                              @[@"From"],
                              @[@"AddSubCell1"],
                              @[@"AddSubCell2"]
                              ];
            
            
            self.tableView.allowsSelection = NO;
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.sectionTitles = @[kCalculationString, @"", @"", @""];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [self.tableView reloadData];
                    self.tableView.allowsSelection = YES;
                    
                    if ([UIScreen mainScreen].bounds.size.height==480.0) {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
                                              atScrollPosition:UITableViewScrollPositionBottom
                                                      animated:YES];
                    }
                }];
                [self.tableView beginUpdates];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [CATransaction commit];
            }];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
            [CATransaction commit];
            
        } else {
            
            self.tableView.allowsSelection = NO;
            self.sectionTitles = @[kCalculationString, @""];
            self.sections = @[
                              @[@"Between two dates", @"Add or Subtract days"],
                              @[@"From", @"To"]
                              ];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.01];
            [CATransaction setCompletionBlock:^{
                
                self.sectionTitles = @[kCalculationString, @"", @"", @""];
                self.sections = @[
                                  @[@"Between two dates", @"Add or Subtract days"],
                                  @[@"From", @"To"],
                                  @[@"Exclude"],
                                  @[@"Duration"]
                                  ];
                // 2
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
                self.tableView.allowsSelection = YES;
                [self.tableView endUpdates];
                
                [CATransaction commit];
            }];
            
            // 1
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [CATransaction commit];
        }
    }
}

#define kAddSubRowIndex 1
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self clearEverything];
        if ((self.isAddSubMode==YES && indexPath.row==kAddSubRowIndex) || (self.isAddSubMode==NO && indexPath.row==0)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        } else {
            self.isAddSubMode = !self.isAddSubMode;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:!indexPath.row inSection:indexPath.section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [self reloadTableViewData:NO];
            if ([self isAddSubMode]) {
                [self refreshAddSubModeButtonForResultWithAnimation:NO];
            }
        }
    }
    else if (indexPath.section == 1) {
        // From, To Date Input
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
		self.dateKeyboardViewController = self.newDateKeyboardViewController;
		[self.dateKeyboardViewController changeInputToYear];
        
        if ([indexPath row] == 0) {
            [self moveToFromDateCell];
        }
        else {
            [self moveToToDateCell];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.isAddSubMode) {
            return;
        }
        
        // Exclude
        [self clearEverything];
        A3DateCalcExcludeViewController *viewController = [[A3DateCalcExcludeViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            [self presentSubViewController:viewController];
			[self enableControls:NO];
        }
        
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        // Duration
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.isAddSubMode) {
            return;
        }
        
        [self clearEverything];
        A3DateCalcDurationViewController *viewController = [[A3DateCalcDurationViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.delegate = self;
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            [self presentSubViewController:viewController];
			[self enableControls:NO];
        }
    }
}

#pragma mark - Option Views Delegate
-(void)durationSettingChanged
{
    [self setResultToHeaderViewWithAnimation:YES];
    [self.tableView reloadData];
}

-(void)excludeSettingDelegate
{
    [self setResultToHeaderViewWithAnimation:YES];
    [self.tableView reloadData];
}

-(void)dismissDateCalcDurationViewController {
	[self enableControls:YES];
}

-(void)dismissExcludeSettingViewController {
	[self enableControls:YES];
}

-(void)dismissEditEventViewController {
	[self enableControls:YES];
}

@end
