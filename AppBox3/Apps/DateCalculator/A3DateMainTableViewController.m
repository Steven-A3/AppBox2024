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
#import "common.h"
#import "A3DateCalcHeaderView.h"
#import "A3DateCalcFooterView.h"
#import "A3DateCalcTableRowData.h"
#import "A3DateCalcFooterViewCell.h"
#import "A3DateKeyboardViewController.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3KeyboardButton_iOS7_iPhone.h"
#import "A3DateCalcDurationViewController.h"
#import "A3DateCalcExcludeViewController.h"
#import "A3DateCalcEditEventViewController.h"
#import "A3DateCalcResultCursorView.h"
#import "A3DateCalcStateManager.h"
#import "A3DateCalcAddSubCell1.h"
#import "A3DateCalcAddSubCell2.h"
#import "A3DefaultColorDefines.h"

#define kDefaultBackgroundColor     [UIColor lightGrayColor]
#define kDefaultButtonColor     [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0]
#define kSelectedButtonColor    [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:250.0/255.0 alpha:1.0]
NSString *kCalculationString;

@interface A3DateMainTableViewController () <UITextFieldDelegate, UIPopoverControllerDelegate, A3DateKeyboardDelegate, A3DateCalcExcludeDelegate, A3DateCalcDurationDelegate, A3DateCalcHeaderViewDelegate, A3DateCalcEditEventDelegate>

@property (strong, nonatomic) A3DateCalcHeaderView *headerView;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) BOOL isAddSubMode;
@property (strong, nonatomic) NSDate * fromDate;
@property (strong, nonatomic) NSDate * toDate;
@property (strong, nonatomic) NSDate * fromDateCursor;  // 슬라이더 커서를 날짜에 반영하는 임시값
@property (strong, nonatomic) NSDate * toDateCursor;
@property (strong, nonatomic) NSDate * offsetDate;
@property (strong, nonatomic) NSDateComponents* offsetComp;
@property (strong, nonatomic) NSString * excludeDateString;
@property (strong, nonatomic) NSString * durationOptionString;

@property (strong, nonatomic) UITextField *fromToTextField;

@property (nonatomic, strong) NSArray *moreMenuButtons;
@property (nonatomic, strong) UIView *moreMenuView;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;

- (IBAction)addButtonTouchUpAction:(id)sender;
- (IBAction)subButtonTouchUpAction:(id)sender;
@end


@implementation A3DateMainTableViewController {
    BOOL _isShowMoreMenu;
    BOOL _isKeyboardShown;
    BOOL _hasKeyboardInputedText;
    BOOL _datePrevShow, _dateNextShow;
    BOOL _isSelectedFromToCell;
    CGFloat _tableYOffset;
    CGFloat _oldTableOffset;
    UITextField *_selectedTextField;
    A3NumberKeyboardViewController *_simpleNormalNumberKeyboard;
    A3DateCalcAddSubCell1 *_footerAddSubCell;
    A3DateCalcAddSubCell2 *_footerCell;
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
    _hasKeyboardInputedText = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    [self initializeControl];
    [self reloadTableViewData:YES];
    [self registerContentSizeCategoryDidChangeNotification];
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
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addToDaysCounter"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(addEventButtonAction:)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(shareButtonAction:)];
    self.navigationItem.rightBarButtonItems = @[share, add];
    
    // Etc
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.fromToTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, -100, 50, 30)];
    self.fromToTextField.delegate = self;
    [self.view addSubview:_fromToTextField];
    
    [self setResultToHeaderViewWithAnimation:NO];
}

-(void)viewWillAppear:(BOOL)animated {
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self setResultToHeaderViewWithAnimation:NO];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
    [self.headerView setNeedsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)clearEverything {
	@autoreleasepool {
        if (_selectedIndexPath) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
            cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
            _selectedIndexPath = nil;
        }
        
        [_fromToTextField resignFirstResponder];
        [_selectedTextField resignFirstResponder];
		[self dismissMoreMenu];
	}
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
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                         fromDate:_fromDate];
    comp.hour = 12;
    _fromDate = [[A3DateCalcStateManager currentCalendar] dateFromComponents:comp];
    
    [[NSUserDefaults standardUserDefaults] setObject:_fromDate forKey:@"fromDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setToDate:(NSDate *)toDate
{
    _toDate = [toDate copy];
    NSDateComponents *comp = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                         fromDate:_toDate];
    comp.hour = 12;
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
    
    _footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    _footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [_footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [_footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [_footerAddSubCell.addModeButton setNeedsDisplay];
    [_footerAddSubCell.subModeButton setNeedsDisplay];
    
    [self refreshAddSubModeButtonForResultWithAnimation:YES];
}

- (IBAction)subButtonTouchUpAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefault_didSelectMinus];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL isMinusSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];
    
    _footerAddSubCell.addModeButton.selected = isMinusSelected ? NO : YES;
    _footerAddSubCell.subModeButton.selected = isMinusSelected ? YES : NO;
    [_footerAddSubCell.addModeButton setBackgroundColor:isMinusSelected ? kDefaultButtonColor : kSelectedButtonColor];
    [_footerAddSubCell.subModeButton setBackgroundColor:isMinusSelected ? kSelectedButtonColor : kDefaultButtonColor];
    [_footerAddSubCell.addModeButton setNeedsDisplay];
    [_footerAddSubCell.subModeButton setNeedsDisplay];
    
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

- (void)shareButtonAction:(id)sender {
    
	@autoreleasepool {
		[self clearEverything];
        NSString * headString = @"I'd like to share a calculation with you.\n\n";
        NSMutableString *shareString = [[NSMutableString alloc] init];
        if (self.isAddSubMode) {
            /* Date Calculator
             From 시작날
             Added (or Subtracted)  x years ?? months ?? days (값이 0이 아닌 경우만 표시)
             Result: 결과 값  */
            if ([self didSelectedAdd]) {
                
                NSDate *result = [[A3DateCalcStateManager currentCalendar] dateByAddingComponents:self.offsetComp
                                                                                           toDate:_fromDate
                                                                                          options:0];
                
                //[shareString appendString:[NSString stringWithFormat:@"Date Calculator\n"]];
                [shareString appendString:[NSString stringWithFormat:@"From: %@\n", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
                
                NSMutableString *intervals = [[NSMutableString alloc] init];
                if (self.offsetComp.year!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld years", (long)self.offsetComp.year]];
                }
                if (self.offsetComp.month!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld months", (long)self.offsetComp.month]];
                }
                if (self.offsetComp.day!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld days", (long)self.offsetComp.day]];
                }
                
                if (intervals.length <= 0) {
                    [shareString appendString:[NSString stringWithFormat:@"Added: 0 days\n"]];
                }
                else {
                    [shareString appendString:[NSString stringWithFormat:@"Added: %@\n", intervals]];
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
                [shareString appendString:[NSString stringWithFormat:@"From: %@\n", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
                
                NSMutableString *intervals = [[NSMutableString alloc] init];
                if (self.offsetComp.year!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld years", (long)self.offsetComp.year]];
                }
                if (self.offsetComp.month!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld months", (long)self.offsetComp.month]];
                }
                if (self.offsetComp.day!=0) {
                    [intervals appendString:[NSString stringWithFormat:@" %ld days", (long)self.offsetComp.day]];
                }
                
                if (intervals.length <= 0) {
                    [shareString appendString:[NSString stringWithFormat:@"Subtracted: 0 days\n"]];
                } else {
                    [shareString appendString:[NSString stringWithFormat:@"Subtracted: %@\n", intervals]];
                }
                
                [shareString appendString:[NSString stringWithFormat:@"Result: %@", [A3DateCalcStateManager formattedStringDate:result]]];
            }
        }
        else {
            /*  Between인 경우
             "Calculate duration between two dates.
             From and including: 시작날
             To, but not including: 끝날
             Result:  ? years ? months ? days" */
            [shareString appendString:[NSString stringWithFormat:@"Calculate duration between two dates.\n"]];
            [shareString appendString:[NSString stringWithFormat:@"From and including: %@\n", [A3DateCalcStateManager formattedStringDate:_fromDate]]];
            [shareString appendString:[NSString stringWithFormat:@"To  %@\n", [A3DateCalcStateManager formattedStringDate:_toDate]]];
            if ([A3DateCalcStateManager excludeOptions] != ExcludeOptions_None) {
                [shareString appendString:[NSString stringWithFormat:@"but not including: %@\n", [A3DateCalcStateManager excludeOptionsString]]];
            }
            
            NSDateComponents *intervalComp = [A3DateCalcStateManager dateComponentFromDate:_fromDate toDate:_toDate];
            DurationType durationType = [A3DateCalcStateManager durationType];
            NSMutableString *intervals = [[NSMutableString alloc] init];
            
            if ( (durationType & DurationType_Year) && intervalComp.year!=0 ) {
                [intervals appendString:[NSString stringWithFormat:@" %ld years", (long)intervalComp.year]];
            }
            
            if ( (durationType & DurationType_Month) && intervalComp.month!=0 ) {
                [intervals appendString:[NSString stringWithFormat:@" %ld months", (long)intervalComp.month]];
            }
            
            if ( (durationType & DurationType_Week) && intervalComp.week!=0 ) {
                [intervals appendString:[NSString stringWithFormat:@" %ld weeks", (long)intervalComp.week]];
            }
            
            if ( (durationType & DurationType_Day) && intervalComp.day!=0 ) {
                [intervals appendString:[NSString stringWithFormat:@" %ld days", (long)intervalComp.day]];
            }
            
            [shareString appendString:[NSString stringWithFormat:@"Result: %@", intervals]];
        }
        
        NSString * mailTailString = @"\n\nYou can calculate more in the AppBox Pro.\n https://itunes.apple.com/us/app/appbox-pro-swiss-army-knife/id318404385?mt=8";
        
        _sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[[NSString stringWithFormat:@"%@%@%@", headString, shareString, mailTailString]]
                                                                               subject:@"Date Calculator in the AppBox Pro"
                                                                     fromBarButtonItem:sender];
        
        if (IS_IPAD) {
            _sharePopoverController.delegate = self;
            [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
                [buttonItem setEnabled:NO];
            }];
        }
	}
}

- (void)appsButtonAction {
	[self clearEverything];

	[super appsButtonAction:nil];
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
        [self enableBarButtons:NO];
    }
}

- (void)enableBarButtons:(BOOL)enable {
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
        buttonItem.enabled = enable;
    }];
}

#pragma mark - More Menu Actions

- (void)moreButtonAction:(UIButton *)button
{
    @autoreleasepool {
        
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
    };
}

- (void)doneButtonAction:(id)button {
	@autoreleasepool {
        [self clearEverything];
	}
}

- (void)dismissMoreMenu {
	@autoreleasepool {
		if ( !_isShowMoreMenu || IS_IPAD ) return;
        
		[self moreMenuDismissAction:[[self.view gestureRecognizers] lastObject] ];
	}
}

- (void)moreMenuDismissAction:(UITapGestureRecognizer *)gestureRecognizer {
	@autoreleasepool {
		if (!_isShowMoreMenu) return;
        
		_isShowMoreMenu = NO;
        
		[self rightButtonMoreButton];
		[self dismissMoreMenuView:_moreMenuView scrollView:self.tableView];
		[self.view removeGestureRecognizer:gestureRecognizer];
	}
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// Popver controller, iPad only.
	[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *buttonItem, NSUInteger idx, BOOL *stop) {
		[buttonItem setEnabled:YES];
	}];
	_sharePopoverController = nil;
}

#pragma mark - View Control Actions

- (void)scrollTableViewToIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    CGFloat offset = (cellRect.origin.y + cellRect.size.height); // and more condition...
    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:YES];
}

- (void)moveToFromDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;

    CGFloat keyboardPadding = IS_IPHONE ? -1.0 : 0.0;
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    cell.detailTextLabel.textColor = COLOR_TABLE_TEXT_TYPING;
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    
    _isSelectedFromToCell = YES;
    
    if (IS_IPAD && IS_PORTRAIT) {
        return;
    }
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.selectedIndexPath];
    CGFloat offset = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.dateKeyboardViewController.view.bounds.size.height);
    _oldTableOffset = self.tableView.contentOffset.y;
    NSLog(@"%f", offset);
    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:YES];
}

- (void)moveToToDateCell
{
    _datePrevShow = NO;
    _dateNextShow = YES;

    CGFloat keyboardPadding = IS_IPHONE ? -1.0 : 0.0;
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    cell.detailTextLabel.textColor = COLOR_TABLE_TEXT_TYPING;
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    _isSelectedFromToCell = YES;
    
    if (IS_IPAD && IS_PORTRAIT) {
        return;
    }
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.selectedIndexPath];
    CGFloat offset = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.dateKeyboardViewController.view.bounds.size.height);
    _oldTableOffset = self.tableView.contentOffset.y;
    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:YES];
}

- (void)moveToFooterView
{
    if (IS_IPAD && IS_PORTRAIT) {
        return;
    }
    
    CGPoint contentOffset = CGPointZero;
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    CGFloat keyboardPadding = IS_IPHONE ? 0.0 : 2.0;
    contentOffset.y = (cellRect.origin.y + cellRect.size.height + keyboardPadding) - (self.tableView.frame.size.height-self.dateKeyboardViewController.view.bounds.size.height);
    
    _oldTableOffset = self.tableView.contentOffset.y;
    self.tableView.contentOffset = contentOffset;
//    [self.tableView setContentOffset:contentOffset animated:YES];
}

- (void)movePreviousContentOffset
{
    [self.tableView setContentOffset:CGPointMake(0.0, -_tableYOffset) animated:YES];
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
-(void)dateCalcHeaderChangedFromDate:(NSDate *)fDate toDate:(NSDate *)tDate
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
    //    _footerCell.yearTextField.text = [NSString stringWithFormat:@"%d", compResult.year];
    //    _footerCell.monthTextField.text = [NSString stringWithFormat:@"%d", compResult.month];
    //    _footerCell.dayTextField.text = [NSString stringWithFormat:@"%d", compResult.day];
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
    
    if (!self.isAddSubMode) {
        
        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
            [self.fromToTextField becomeFirstResponder];
            [self moveToToDateCell];
        } else {
            // from < to
            [self.fromToTextField becomeFirstResponder];
            [self moveToFromDateCell];
        }
        
    } else {
        if ([self didSelectedAdd]) {
            [self.fromToTextField becomeFirstResponder];
            [self moveToFromDateCell];
        } else {
            [_footerCell.yearTextField becomeFirstResponder];
        }
    }
    
}

-(void)dateCalcHeaderToThumbTapped {
    
    if (!self.isAddSubMode) {
        
        if ([self.fromDate compare:self.toDate] == NSOrderedDescending) {
            // from > to, 큰 값이 오른쪽(to)에 위치한다.
            [self.fromToTextField becomeFirstResponder];
            [self moveToFromDateCell];
        } else {
            // from < to
            [self.fromToTextField becomeFirstResponder];
            [self moveToToDateCell];
        }
        
    } else {
        if ([self didSelectedAdd]) {
            [_footerCell.yearTextField becomeFirstResponder];
        } else {
            [self.fromToTextField becomeFirstResponder];
            [self moveToFromDateCell];
        }
    }
}

#pragma mark - UITextField Related

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _selectedTextField = textField;
    
    if ([_footerCell hasEqualTextField:_selectedTextField]) {
        if (_simpleNormalNumberKeyboard==nil) {
            _simpleNormalNumberKeyboard = [self simpleNumberKeyboard];
            if (IS_IPHONE) {
                ((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).needButtonsReload = NO;
            }
        }
        
        _simpleNormalNumberKeyboard.textInputTarget = textField;
        _simpleNormalNumberKeyboard.delegate = self;
        _selectedTextField.inputView = _simpleNormalNumberKeyboard.view;
        
        if (_selectedTextField==_footerCell.yearTextField) {
            if (self.offsetComp.year==0) {
                textField.text = @"";
                _hasKeyboardInputedText = NO;
            }
            else {
                textField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.year];
                _hasKeyboardInputedText = YES;
            }
            
            _datePrevShow = NO;
            _dateNextShow = YES;
            
        }
        else if (_selectedTextField==_footerCell.monthTextField) {
            if (self.offsetComp.month==0) {
                textField.text = @"";
                _hasKeyboardInputedText = NO;
            }
            else {
                textField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.month];
                _hasKeyboardInputedText = YES;
            }
            
            _datePrevShow = YES;
            _dateNextShow = YES;
        }
        else if (_selectedTextField==_footerCell.dayTextField) {
            if (self.offsetComp.day==0) {
                textField.text = @"";
                _hasKeyboardInputedText = NO;
            }
            else {
                textField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.day];
                _hasKeyboardInputedText = YES;
            }
            
            _datePrevShow = YES;
            _dateNextShow = NO;
        }
        
		[_simpleNormalNumberKeyboard reloadPrevNextButtons];
        
        if (IS_IPHONE) {
            [((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).prevButton setImage:nil forState:UIControlStateNormal];
            [((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).prevButton setTitle:_datePrevShow?@"Prev":nil forState:UIControlStateNormal];
            [((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).nextButton setImage:nil forState:UIControlStateNormal];
            [((A3NumberKeyboardViewController_iPhone *)_simpleNormalNumberKeyboard).nextButton setTitle:_dateNextShow?@"Next":nil forState:UIControlStateNormal];
        }
    }
    else {
        A3DateKeyboardViewController * keyboardVC = [self dateKeyboardViewController];
        keyboardVC.delegate = self;
        
        _selectedTextField.inputView = keyboardVC.view;
    }
    
    _isKeyboardShown = YES;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    if (![textField.text length]) {
        return;
    }
    
	int value = [textField.text intValue];
    textField.text = [NSString stringWithFormat:@"%d", value];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    
	UITextField *textField = notification.object;
    
	if ([_footerCell hasEqualTextField:textField]) {
        
        if (_selectedTextField==_footerCell.yearTextField) {
            
            if (_hasKeyboardInputedText) {
                if (_selectedTextField.text.integerValue > self.offsetComp.year) {
                    _selectedTextField.text = [_selectedTextField.text substringWithRange:NSMakeRange(_selectedTextField.text.length-1, 1)];
                }
                else {
                    _selectedTextField.text = @"0";
                }
                
                _hasKeyboardInputedText = NO;
            }
            
            self.offsetComp.year = _selectedTextField.text.integerValue;
            
        }
        else if (_selectedTextField==_footerCell.monthTextField) {
            
            if (_hasKeyboardInputedText) {
                if (_selectedTextField.text.integerValue > self.offsetComp.month) {
                    _selectedTextField.text = [_selectedTextField.text substringWithRange:NSMakeRange(_selectedTextField.text.length-1, 1)];
                }
                else {
                    _selectedTextField.text = @"0";
                }
                
                _hasKeyboardInputedText = NO;
            }
            
            self.offsetComp.month = _selectedTextField.text.integerValue;
            
        }
        else if (_selectedTextField==_footerCell.dayTextField) {
            
            if (_hasKeyboardInputedText) {
                if (_selectedTextField.text.integerValue > self.offsetComp.day) {
                    _selectedTextField.text = [_selectedTextField.text substringWithRange:NSMakeRange(_selectedTextField.text.length-1, 1)];
                }
                else {
                    _selectedTextField.text = @"0";
                }
                
                _hasKeyboardInputedText = NO;
            }
            
            self.offsetComp.day = _selectedTextField.text.integerValue;
        }
        
        [_footerCell saveInputedTextField:textField];
	}
    else {
        NSLog(@"from/to: %@", notification);
	}
}

-(void)keyboardWillShow:(NSNotification *)aNoti
{
    if (self.isAddSubMode && [_footerCell hasEqualTextField:_selectedTextField]) {
        NSDictionary *aDict = [aNoti userInfo];
        CGRect keyboardSize = [self.view convertRect:[[aDict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
        keyboardSize.size.height = keyboardSize.size.height-90.0;
        NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
        NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
        
        [UIView beginAnimations:@"KeyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[animationCurve intValue]];
        [UIView setAnimationDuration:[animationDuration doubleValue]];
        
        if (self.isAddSubMode) {
            [self moveToFooterView];
        }
        
        [UIView commitAnimations];
    }
}
//
//-(void)keyboardWillDisappear:(NSNotification *)aNoti
//{
////    NSDictionary *aDict = [aNoti userInfo];
////    CGRect keyboardSize = [self.view convertRect:[[aDict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
////    keyboardSize.size.height = keyboardSize.size.height-90.0;
////    NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
////    NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
////    
////    [UIView beginAnimations:@"KeyboardWillShow" context:nil];
////    [UIView setAnimationBeginsFromCurrentState:YES];
////    [UIView setAnimationCurve:[animationCurve intValue]];
////    [UIView setAnimationDuration:[animationDuration doubleValue]];
////    
////    [self movePreviousContentOffset];
////    
////    [UIView commitAnimations];
//    
//    if (_selectedIndexPath) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_selectedIndexPath];
//        cell.detailTextLabel.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
//        _selectedIndexPath = nil;
//    }
//}

#pragma mark  A3KeyboardViewControllerDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    // 풋터뷰 필드(ADD/SUB모드)
    if (_selectedTextField==_footerCell.yearTextField || _selectedTextField==_footerCell.monthTextField || _selectedTextField==_footerCell.dayTextField) {
        NSDateComponents *changed = [[A3DateCalcStateManager currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                                fromDate:date];
        if (_selectedTextField==_footerCell.yearTextField) {
            self.offsetComp.year = changed.year;
        }
        else if (_selectedTextField==_footerCell.monthTextField) {
            self.offsetComp.month = changed.month;
        }
        else if (_selectedTextField==_footerCell.dayTextField) {
            self.offsetComp.day = changed.day;
        }
        
        [_footerCell setOffsetDateComp:self.offsetComp];
        
    }
    else {
        // From/To Cell
        if (self.selectedIndexPath.row==0) {
            if (self.isAddSubMode) {
                self.fromDate = date==nil? [NSDate date] : date;
            }
            else {
                self.fromDate = date==nil? [NSDate date] : date;
            }
            
            [self.tableView reloadData];
        }
        else {
            self.toDate = date==nil? [NSDate date] : date;
            [self.tableView reloadData];
        }
        
        if (_isSelectedFromToCell) {
            _isSelectedFromToCell = NO;
            [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
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
    if (_selectedTextField==self.fromToTextField) {
        A3DateKeyboardViewController * keyboardVC = [self dateKeyboardViewController];
        if (keyboardVC.yearButton.selected) {
            _datePrevShow = YES;
            _dateNextShow = YES;
            [keyboardVC switchToMonth];
        } else if (keyboardVC.monthButton.selected) {
            _datePrevShow = YES;
            _dateNextShow = NO;
            [keyboardVC switchToDay];
        }
    } else {
        if (_selectedTextField==_footerCell.yearTextField) {
            _selectedTextField = _footerCell.monthTextField;
            [_footerCell.monthTextField becomeFirstResponder];
        } else if (_selectedTextField==_footerCell.monthTextField) {
            _selectedTextField = _footerCell.dayTextField;
            [_footerCell.dayTextField becomeFirstResponder];
            
        } else if (_selectedTextField==_footerCell.dayTextField) {
            return;
        }
    }
}

- (void)prevButtonPressed{
    if (_selectedTextField==self.fromToTextField) {
        A3DateKeyboardViewController * keyboardVC = [self dateKeyboardViewController];
        if (keyboardVC.dayButton.selected) {
            _datePrevShow = YES;
            _dateNextShow = YES;
            [keyboardVC switchToMonth];
        } else if (keyboardVC.monthButton.selected) {
            _datePrevShow = NO;
            _dateNextShow = YES;
            [keyboardVC switchToYear];
        }
    } else {
        if (_selectedTextField==_footerCell.dayTextField) {
            _footerCell.dayTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.day];
            _selectedTextField = _footerCell.monthTextField;
            [_footerCell.monthTextField becomeFirstResponder];
            
        } else if (_selectedTextField==_footerCell.monthTextField) {
            _footerCell.monthTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.month];
            _selectedTextField = _footerCell.yearTextField;
            [_footerCell.yearTextField becomeFirstResponder];
            
        } else if (_selectedTextField==_footerCell.yearTextField) {
            _footerCell.yearTextField.text = [NSString stringWithFormat:@"%ld", (long)self.offsetComp.year];
            _selectedTextField = self.fromToTextField;
            [self.fromToTextField becomeFirstResponder];
            [self moveToFromDateCell];
        }
    }
    
    //    if (!self.isAddSubMode) {
    //        [self moveToFromDateCell];
    //
    //    } else {
    //        if (_selectedTextField==_footerCell.dayTextField) {
    //            _footerCell.dayTextField.text = [NSString stringWithFormat:@"%d", self.offsetComp.day];
    //            _selectedTextField = _footerCell.monthTextField;
    //            [_footerCell.monthTextField becomeFirstResponder];
    //
    //        } else if (_selectedTextField==_footerCell.monthTextField) {
    //            _footerCell.monthTextField.text = [NSString stringWithFormat:@"%d", self.offsetComp.month];
    //            _selectedTextField = _footerCell.yearTextField;
    //            [_footerCell.yearTextField becomeFirstResponder];
    //
    //        } else if (_selectedTextField==_footerCell.yearTextField) {
    //            _footerCell.yearTextField.text = [NSString stringWithFormat:@"%d", self.offsetComp.year];
    //            _selectedTextField = self.fromToTextField;
    //            [self.fromToTextField becomeFirstResponder];
    //            [self moveToFromDateCell];
    //        }
    //    }
}

- (void)A3KeyboardDoneButtonPressed
{
//    if ((IS_IPHONE && self.isAddSubMode) || (IS_IPAD && IS_LANDSCAPE)) {
//        self.tableView.contentOffset = CGPointMake(0.0, _oldTableOffset);
//    }
//    [self.tableView scrollRectToVisible:CGRectMake(0, _oldTableOffset, 1, 1) animated:YES];
    
//    [self.tableView setContentOffset:CGPointMake(0.0, _oldTableOffset) animated:YES];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [_footerCell.yearTextField resignFirstResponder];
    [_footerCell.monthTextField resignFirstResponder];
    [_footerCell.dayTextField resignFirstResponder];
    [self.fromToTextField resignFirstResponder];
    _isKeyboardShown = NO;
    
    [self.tableView reloadData];
    [self setResultToHeaderViewWithAnimation:YES];
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    
    if (keyInputDelegate != _selectedTextField) {
        return;
    }
    
    if (_selectedTextField==_footerCell.yearTextField || _selectedTextField==_footerCell.monthTextField || _selectedTextField==_footerCell.dayTextField) {
        
        if (_selectedTextField==_footerCell.yearTextField) {
            self.offsetComp.year = _selectedTextField.text.integerValue;
        } else if (_selectedTextField==_footerCell.monthTextField) {
            self.offsetComp.month = _selectedTextField.text.integerValue;
        } else if (_selectedTextField==_footerCell.dayTextField) {
            self.offsetComp.day = _selectedTextField.text.integerValue;
        }
        
        //[self.footerView setOffsetDate:self.offsetDate];
        [_footerCell setOffsetDateComp:self.offsetComp];
        [self setResultToHeaderViewWithAnimation:YES];
        [_selectedTextField resignFirstResponder];
        //[self.tableView setContentOffset:CGPointMake(0.0, -_tableYOffset) animated:YES];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    
    if ((IS_IPHONE) || (IS_IPAD && IS_LANDSCAPE)) {
        //self.tableView.contentOffset = CGPointMake(0.0, _oldTableOffset);
        
        //[self.tableView setContentOffset:CGPointMake(0.0, -_tableYOffset) animated:YES];
    }
    
    _isKeyboardShown = NO;
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    _selectedTextField.text = @"";
}

#pragma mark - UITableView Related
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionTitles count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if (self.isAddSubMode==YES && (section==2 || section==3)) {
    //        if (IS_IPAD)
    //            return 25.0;
    //        else
    //            return 9.5;
    //    }
    if (![self isAddSubMode]) {
        return section==0 ? 55 : 0;
    }
    
    return section==0 ? 55.0 : 25.0;
    
//    if (IS_RETINA) {
//        return section==0 ? 55.5 : 25.0;
//    } else {
//        return section==0 ? 55.0 : 25.0;
//    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (![self isAddSubMode]) {
        return 0;
    }
    
    return section == 3 ? (IS_RETINA ? 37.5 : 38) : 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (indexPath.section == 1 && indexPath.row == 3) {
//        // Advanced 섹션 첫번째 셀 높이, 하드코딩..
//        return IS_RETINA? 43.5 : 43.0;
//    }
//
//	return [self.root heightForRowAtIndexPath:indexPath];
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    CGFloat height;
//
//    switch (section) {
//        case 0:
//            // Header 텍스트 있는 경우.
//            height = 55;
//            break;
//        case 2:
//            height = 0.01;
//            break;
//        default:
//            // Header 텍스트 없는 경우.
//            height = 35;
//            break;
//    }
//
//    return height;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (self.isAddSubMode && section==1) {
//        return self.footerView;
//    }
//    return nil;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (self.isAddSubMode && section==1) {
//        return CGRectGetHeight(self.footerView.frame);
//    }
//    return 0.0;
//}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:  // From, To 날짜 입력 셀 섹션.
        {
            CGRect rect = cell.detailTextLabel.frame;
            //rect.origin.x = cell.contentView.bounds.size.width - cell.detailTextLabel.frame.size.width;
            rect.origin.x = 300;//cell.bounds.size.width - cell.detailTextLabel.frame.size.width;
            cell.detailTextLabel.frame = rect;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const cellIdentifier = @"Cell";
    static NSString *const cellAddSubCell1 = @"AddSubCell1";
    static NSString *const cellAddSubCell2 = @"AddSubCell2";
    
    if (self.isAddSubMode==YES) {
        if (indexPath.section==2 && indexPath.row==0) {
            // FooterViewCell - Add Sub Button Cell
            A3DateCalcAddSubCell1 *footerCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell1];
            if (!footerCell) {
                footerCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell1" owner:self options:nil] lastObject];
            }
            
            [footerCell.addModeButton addTarget:self action:@selector(addButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
            [footerCell.subModeButton addTarget:self action:@selector(subButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
            
            BOOL isMinusSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kDefault_didSelectMinus];
            footerCell.addModeButton.selected = isMinusSelected ? NO : YES;
            footerCell.subModeButton.selected = isMinusSelected ? YES : NO;
            
            [footerCell.addModeButton setBackgroundColor:footerCell.addModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
            [footerCell.subModeButton setBackgroundColor:footerCell.subModeButton.selected? kSelectedButtonColor : kDefaultButtonColor];
            _footerAddSubCell = footerCell;
            
            return footerCell;
            
        } else if (indexPath.section==3 && indexPath.row==0) {
            // FooterViewCell - Year Month Day, Input TextField Cell
            A3DateCalcAddSubCell2 *footerCell = [tableView dequeueReusableCellWithIdentifier:cellAddSubCell2];
            if (!footerCell) {
                footerCell = [[[NSBundle mainBundle] loadNibNamed:@"A3DateCalcAddSubCell2" owner:self options:nil] lastObject];
            }
            
            footerCell.yearTextField.delegate = self;
            footerCell.monthTextField.delegate = self;
            footerCell.dayTextField.delegate = self;
            
            if (self.offsetComp.year!=0 || self.offsetComp.month!=0 || self.offsetComp.day!=0) {
                [footerCell setOffsetDateComp:self.offsetComp];
            }
            
            _footerCell =  footerCell;
            
            return footerCell;
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
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
            
            [cell.detailTextLabel sizeToFit];
            
            // detailTextLabel 위치 조정, 실패.
            CGRect rect = cell.detailTextLabel.frame;
            //rect.origin.x = cell.contentView.bounds.size.width - cell.detailTextLabel.frame.size.width;
            rect.origin.x = 300;//cell.bounds.size.width - cell.detailTextLabel.frame.size.width;
            cell.detailTextLabel.frame = rect;
            
            // 선택된 셀로 이동.
            if (indexPath.section==_selectedIndexPath.section && indexPath.row==_selectedIndexPath.row && _isSelectedFromToCell) {
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            // 선택된 셀 텍스트 색상 편집 중에만 변경.
            if (_isKeyboardShown && _selectedIndexPath && (indexPath.row==_selectedIndexPath.row)) {
                cell.detailTextLabel.textColor = COLOR_TABLE_TEXT_TYPING;
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
        
    } else {
        
        //[self.tableView reloadData];
        
        
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self clearEverything];
        if ((self.isAddSubMode==YES && indexPath.row==kAddSubRowIndex) || (self.isAddSubMode==NO && indexPath.row==0)) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        } else {
            self.isAddSubMode = !self.isAddSubMode;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:!indexPath.row inSection:indexPath.section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            [self reloadTableViewData:NO];
        }
        
    } else if (indexPath.section == 1) {
        // From, To Date Input
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _selectedTextField = self.isAddSubMode ? nil : _fromToTextField; // + / - 모드에서만
        
        [self.fromToTextField becomeFirstResponder];
        [self.dateKeyboardViewController switchToYear];
        
        if (indexPath.row==0) {
            self.dateKeyboardViewController.date = self.fromDate;
            [self moveToFromDateCell];
        } else {
            self.dateKeyboardViewController.date = self.toDate;
            [self moveToToDateCell];
        }
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        
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
            [self enableBarButtons:NO];
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
            [self enableBarButtons:NO];
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
    [self enableBarButtons:YES];
}

-(void)dismissExcludeSettingViewController {
    [self enableBarButtons:YES];
}

-(void)dismissEditEventViewController {
    [self enableBarButtons:YES];
}

@end
