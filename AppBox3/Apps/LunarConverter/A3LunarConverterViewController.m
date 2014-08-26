//
//  A3LunarConverterViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LunarConverterViewController.h"
#import "A3LunarConverterCellView.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "NSDate+LunarConverter.h"
#import "NSDate+formatting.h"
#import "UIViewController+A3Addition.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSDateFormatter+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIColor+A3Addition.h"
#import "A3SettingsLunarViewController.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSString+conversion.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"


@interface A3LunarConverterViewController () <UIScrollViewDelegate, A3DateKeyboardDelegate, UITextFieldDelegate, UIPopoverControllerDelegate, UIActivityItemSource, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) A3DateKeyboardViewController *dateKeyboardVC;
@property (strong, nonatomic) NSDateComponents *firstPageResultDateComponents;
@property (strong, nonatomic) NSDateComponents *secondPageResultDateComponents;
@property (strong, nonatomic) NSDateComponents *inputDateComponents;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) SQLiteWrapper *dbManager;
@property (strong, nonatomic) MASConstraint *keyboardHeightConstraint, *keyboardTopConstraint;
@property (strong, nonatomic) NSMutableArray *cellHeightConstraints;
@property (weak, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSMutableArray *addToDaysCounterButtons;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *firstPageView;
@property (strong, nonatomic) IBOutlet UIView *secondPageView;

@end

@implementation A3LunarConverterViewController {
	BOOL _isLunarInput;
	BOOL _isShowKeyboard;
}

- (void)cleanUp
{
	[self removeObserver];

	[self.dateKeyboardVC.view removeFromSuperview];
	_dbManager = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[self leftBarButtonAppsButton];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonAction:)];
    shareButton.tag = A3RightBarButtonTagShareButton;
	UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"general"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
    settings.tag = A3RightBarButtonTagShareButton;
    self.navigationItem.rightBarButtonItems = @[settings, shareButton];

	self.title = IS_IPHONE ? NSLocalizedString(@"Lunar Converter_Short", nil) : NSLocalizedString(@"Lunar Converter", nil);
	_pageControl.hidden = YES;
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		[self.cellHeightConstraints addObject:make.top.equalTo(self.view.top).with.offset(IS_IPHONE35 ? 234.5 : 315)];
	}];

	NSString *dataFilePath = [@"LunarConverter.sqlite" pathInCachesDataDirectory];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
		_dbManager = [[SQLiteWrapper alloc] initWithPath:dataFilePath];
	}
	[self setAutomaticallyAdjustsScrollViewInsets:NO];

	CGFloat viewHeight = 84 * 3 + 1;

	[_mainScrollView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.top.equalTo(self.view.top).with.offset(64);
		make.height.equalTo(@(viewHeight));
	}];

	[_mainScrollView addSubview:_firstPageView];

	[_firstPageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_mainScrollView.left);
		make.top.equalTo(_mainScrollView.top);
		make.width.equalTo(_mainScrollView.width);
		make.height.equalTo(_mainScrollView.height);
	}];
	[_mainScrollView addSubview:_secondPageView];

	[_secondPageView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_firstPageView.right);
		make.top.equalTo(_firstPageView.top);
		make.width.equalTo(_mainScrollView.width);
		make.height.equalTo(_mainScrollView.height);
	}];

	[self initPageView:_firstPageView];
	[self initPageView:_secondPageView];
	[self.view layoutIfNeeded];

	// Init data
	_calendar = [[A3AppDelegate instance] calendar];

	[self reloadDataFromStore];
	_isShowKeyboard = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuBecameFirstResponder) name:A3MainMenuBecameFirstResponder object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewDidAppear) name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillDismiss) name:A3NotificationRightSideViewWillDismiss object:nil];
    }
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)cloudStoreDidImport {
	BOOL oldIsLunarInput = _isLunarInput;
	[self reloadDataFromStore];

	if (oldIsLunarInput != _isLunarInput) {
		_isLunarInput = oldIsLunarInput;
		[self swapAction:nil];
	}
	[self calculateDate];
}

- (void)reloadDataFromStore {
	_inputDateComponents = [[A3SyncManager sharedSyncManager] dateComponentsForKey:A3LunarConverterLastInputDateComponents];
	if (!_inputDateComponents) {
		_inputDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
	}
	_isLunarInput = [[A3SyncManager sharedSyncManager] boolForKey:A3LunarConverterLastInputDateIsLunar];
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3MainMenuBecameFirstResponder object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewDidAppear object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
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

- (NSMutableArray *)addToDaysCounterButtons {
	if (!_addToDaysCounterButtons) {
		_addToDaysCounterButtons = [NSMutableArray new];
	}
	return _addToDaysCounterButtons;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self calculateDate];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self calculateDate];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self addDateKeyboard];
    [self shrinkCellScrollView:animated];

	if ( _dbManager )
		[_dbManager open];
}

- (void)mainMenuBecameFirstResponder {
	[self dateKeyboardDoneButtonPressed:nil ];
}

- (void)mainMenuDidHide {
	[self showKeyboardAnimated:YES];
	[self enableControls:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ( IS_IPAD ){
		[self layoutKeyboardToOrientation:toInterfaceOrientation];
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	_mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, _mainScrollView.bounds.size.height);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [NSDateFormatter new];
	}
	return _dateFormatter;
}

- (void)initPageView:(UIView*)pageView
{
	UIView *line1,*line2,*line3,*line4;
	UIView *topCell, *middleCell, *bottomCell;
	line1 = [pageView viewWithTag:200];
	line2 = [pageView viewWithTag:201];
	line3 = [pageView viewWithTag:202];
	line4 = [pageView viewWithTag:203];

	A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[pageView viewWithTag:100];
	topCell = cellView;
	cellView.dateLabel.textColor = [A3AppDelegate instance].themeColor;
	cellView.descriptionLabel.text = NSLocalizedString(@"Solar", @"Solar");

	cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
	bottomCell = cellView;
	UIButton *addToDaysCounterButton = [UIButton buttonWithType:UIButtonTypeSystem];
	addToDaysCounterButton.bounds = CGRectMake(0, 0, 44, 44);
	UIImage *buttonImage = [UIImage imageNamed:@"addToDaysCounter"];
	[addToDaysCounterButton setImage:buttonImage forState:UIControlStateNormal];

	[addToDaysCounterButton addTarget:self action:@selector(addToDaysCounterAction:) forControlEvents:UIControlEventTouchUpInside];
	[cellView setActionButton:addToDaysCounterButton];
	[self.addToDaysCounterButtons addObject:addToDaysCounterButton];

	cellView.descriptionLabel.text = NSLocalizedString(@"Lunar", @"Lunar");

	middleCell = [pageView viewWithTag:102];

	CGFloat scale = [[UIScreen mainScreen] scale];

	BOOL isIPHONE35 = IS_IPHONE35;
	CGFloat topCellHeight = isIPHONE35 ? 64 : (IS_RETINA ? 83 : 82);
	CGFloat middleHeight = isIPHONE35 ? 47 : (IS_RETINA ? 83.5 : 83);
	CGFloat bottomCellHeight = isIPHONE35 ? 64.5 : (IS_RETINA ? 83.5 : 83);
	CGFloat lineWidth = 1.0 / scale;

	[line1 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.top.equalTo(pageView.top);
		make.height.equalTo(@(lineWidth));
	}];
	[topCell makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.top.equalTo(line1.bottom);
		[_cellHeightConstraints addObject:make.height.equalTo(@(topCellHeight))];
	}];
	[line2 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.height.equalTo(@(lineWidth));
		make.top.equalTo(topCell.bottom);
	}];
	[middleCell makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.top.equalTo(line2.bottom);
		[_cellHeightConstraints addObject:make.height.equalTo(@(middleHeight))];
	}];
	[line3 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.height.equalTo(@(lineWidth));
		make.top.equalTo(middleCell.bottom);
	}];
	[bottomCell makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.top.equalTo(line3.bottom);
		[_cellHeightConstraints addObject:make.height.equalTo( @(bottomCellHeight) )];
	}];
	[line4 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.top.equalTo(bottomCell.bottom);
		make.height.equalTo(@(lineWidth));
	}];
}

- (void)rightSideViewDidAppear {
	[self enableControls:NO];
}

- (void)rightSideViewWillDismiss {
	[self enableControls:YES];
    [self calculateDate];
}

- (void)settingsButtonAction:(id)sender {
    [self hideKeyboardAnimate:YES];
    UIStoryboard *settingsStoryBoard = [UIStoryboard storyboardWithName:@"A3Settings" bundle:nil];
    A3SettingsLunarViewController *settingsViewController = [settingsStoryBoard instantiateViewControllerWithIdentifier:@"SettingsLunarViewController"];
    if (IS_IPHONE) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
        [self presentViewController:nav animated:YES completion:NULL];
    } else {
        [self enableControls:NO];
        [self.A3RootViewController presentRightSideViewController:settingsViewController];
    }
}

#pragma mark - Keyboard Layout

- (void)addDateKeyboard {
	_isShowKeyboard = YES;

	if (IS_IPAD) {
		self.dateKeyboardVC = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
	} else {
		self.dateKeyboardVC = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
	}
	self.dateKeyboardVC.delegate = self;

	UIView *superview;
	if ( IS_IPAD ){
		UIViewController *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController.view addSubview:self.dateKeyboardVC.view];

		superview = rootViewController.view;
	} else {
		[self.view addSubview:self.dateKeyboardVC.view];
		superview = self.view;
	}
	CGFloat keyboardHeight = [self keyboardHeight];
	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		_keyboardTopConstraint =  make.top.equalTo(superview.bottom);
		_keyboardHeightConstraint =  make.height.equalTo(@(keyboardHeight));
	}];
	[superview layoutIfNeeded];

	[UIView animateWithDuration:0.3 animations:^{
		[self layoutKeyboardToOrientation:self.interfaceOrientation];
	}];

	self.dateKeyboardVC.dateComponents = _inputDateComponents;
	self.dateKeyboardVC.isLunarDate = _isLunarInput;
}

- (CGFloat)keyboardHeight {
	if (IS_IPHONE) {
		return 216;
	} else {
		return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 352 : 264;
	}
}

- (void)layoutKeyboardToOrientation:(UIInterfaceOrientation)toOrientation
{
	if (!_isShowKeyboard) return;

	CGFloat keyboardHeight;

	if (IS_IPHONE) {
		keyboardHeight = 216;
	} else {
		keyboardHeight = UIInterfaceOrientationIsLandscape(toOrientation) ? 352 : 264;
	}

	[_keyboardTopConstraint uninstall];
	[_keyboardHeightConstraint uninstall];
	[self.dateKeyboardVC.view updateConstraints:^(MASConstraintMaker *make) {
		_keyboardTopConstraint =  make.top.equalTo(self.dateKeyboardVC.view.superview.bottom).with.offset(_isShowKeyboard ? -keyboardHeight : 0);;
		_keyboardHeightConstraint = make.height.equalTo(@(keyboardHeight));
	}];
	[self.dateKeyboardVC.view.superview layoutIfNeeded];

	[self.dateKeyboardVC rotateToInterfaceOrientation:toOrientation];
}

- (NSMutableArray *)cellHeightConstraints {
	if (!_cellHeightConstraints) {
		_cellHeightConstraints = [NSMutableArray new];
	}
	return _cellHeightConstraints;
}

- (void)uninstallCellHeightConstraints {
	for (MASConstraint *constraint in _cellHeightConstraints) {
		[constraint uninstall];
	}
	[_cellHeightConstraints removeAllObjects];
}

- (void)shrinkCellScrollView:(BOOL)animated
{
	// pageControl.top = 234.5 (iphone 35)
	// pageControl.top = 315.0
    
    NSTimeInterval duration = (animated ? 0.3 : 0.0);
    
	if (IS_IPHONE35) {
		[self uninstallCellHeightConstraints];
        
		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			[self.cellHeightConstraints addObject:make.top.equalTo(@234.5)];
		}];
		for (UIView *pageView in @[_firstPageView, _secondPageView]) {
			UIView *topCell = [pageView viewWithTag:100];
			[topCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@64)];
			}];
            
			UIView *middleCell = [pageView viewWithTag:102];
			[middleCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@47.0)];
			}];
            
			UIView *bottomCell = [pageView viewWithTag:101];
			[bottomCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@64.5)];
			}];
		}
		if (_pageControl.currentPage != 0) duration = 0;
	}
    
	[_keyboardTopConstraint uninstall];
    
	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		_keyboardTopConstraint =  make.top.equalTo(self.dateKeyboardVC.view.superview.bottom).with.offset(-self.dateKeyboardVC.view.frame.size.height);
	}];
    
	NSInteger currentPage = _pageControl.currentPage;
	if (IS_IPHONE35 && _pageControl.currentPage != 0) {
		[self.view layoutIfNeeded];
		[self.dateKeyboardVC.view.superview layoutIfNeeded];
		[_mainScrollView setContentOffset:CGPointMake(_mainScrollView.frame.size.width * currentPage, 0)];
	} else {
		[UIView animateWithDuration:(duration) animations:^{
			[self.view layoutIfNeeded];
			[self.dateKeyboardVC.view.superview layoutIfNeeded];
			[_mainScrollView setContentOffset:CGPointMake(_mainScrollView.frame.size.width * currentPage, 0)];
		}];
	}
}

- (void)showKeyboardAnimated:(BOOL)animated
{
	self.dateKeyboardVC.isLunarDate = _isLunarInput;

	UIView *superview;
	if ( IS_IPAD ){
		UIViewController *rootViewController = [[A3AppDelegate instance] rootViewController];
		[rootViewController.view addSubview:self.dateKeyboardVC.view];

		superview = rootViewController.view;
	} else {
		[self.view addSubview:self.dateKeyboardVC.view];
		superview = self.view;
	}
	CGFloat keyboardHeight = [self keyboardHeight];
	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		_keyboardTopConstraint =  make.top.equalTo(superview.bottom);
		_keyboardHeightConstraint =  make.height.equalTo(@(keyboardHeight));
	}];
	[self layoutKeyboardToOrientation:self.interfaceOrientation];
	[superview layoutIfNeeded];

	_isShowKeyboard = YES;

    [self shrinkCellScrollView:animated];
}

- (void)hideKeyboardAnimate:(BOOL)animated
{
	if (!_isShowKeyboard) return;

	_isShowKeyboard = NO;

	// pageControl.top = 310.0 (iphone 35)

	NSTimeInterval duration = (animated ? 0.3 : 0.0);
	if (IS_IPHONE35) {
		[self uninstallCellHeightConstraints];

		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			[self.cellHeightConstraints addObject:make.top.equalTo(@310)];
		}];
		CGFloat topCellHeight = IS_RETINA ? 83 : 82;
		CGFloat middleHeight = 83.5;
		CGFloat bottomCellHeight = 83.5;

		for (UIView *pageView in @[_firstPageView, _secondPageView]) {
			UIView *topCell = [pageView viewWithTag:100];
			[topCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@(topCellHeight))];
			}];

			UIView *bottomCell = [pageView viewWithTag:101];
			[bottomCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@(bottomCellHeight))];
			}];

			UIView *middleCell = [pageView viewWithTag:102];
			[middleCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@(middleHeight))];
			}];
		}
		if (_pageControl.currentPage != 0) duration = 0;
	}
	[_keyboardTopConstraint uninstall];
	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		_keyboardTopConstraint =  make.top.equalTo(self.view.bottom);
	}];

	NSInteger currentPage = _pageControl.currentPage;
	if (IS_IPHONE35 && _pageControl.currentPage != 0) {
		[self.view layoutIfNeeded];
		[self.dateKeyboardVC.view.superview layoutIfNeeded];
		[_mainScrollView setContentOffset:CGPointMake(_mainScrollView.frame.size.width * currentPage, 0)];
	} else {
		[UIView animateWithDuration:(duration) animations:^{
			[self.view layoutIfNeeded];
			[self.dateKeyboardVC.view.superview layoutIfNeeded];
			[_mainScrollView setContentOffset:CGPointMake(_mainScrollView.frame.size.width * currentPage, 0)];
		} completion:^(BOOL finished) {
			[self.dateKeyboardVC.view removeFromSuperview];
			[_keyboardHeightConstraint uninstall];
			_keyboardHeightConstraint = nil;
		}];
	}
}

#pragma mark ---- Page Handling

- (void)moveToPage:(NSInteger)page
{
	FNLOG();
	[_mainScrollView scrollRectToVisible:CGRectMake(page * _mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
}


- (void)showSecondPage
{
	_pageControl.hidden = NO;
	[_mainScrollView setScrollEnabled:YES];
}

- (void)hideSecondPage
{
	FNLOG();
	_pageControl.currentPage = 0;
	_pageControl.hidden = YES;
	[_mainScrollView scrollsToTop];
	[_mainScrollView setScrollEnabled:NO];
}

#pragma mark ---- Date Conversion

- (NSString*)yearNameForLunar:(NSInteger)year
{
    static NSString *nameArray[] = {@"甲子",@"乙丑",@"丙寅",@"丁卯",@"戊辰",@"己巳",@"庚午",@"辛未",@"壬申",@"癸酉",
                                  @"甲戌",@"乙亥",@"丙子",@"丁丑",@"戊寅",@"己卯",@"庚辰",@"辛巳",@"壬午",@"癸未",
                                  @"甲申",@"乙酉",@"丙戌",@"丁亥",@"戊子",@"己丑",@"庚寅",@"辛卯",@"壬辰",@"癸巳",
                                  @"甲午",@"乙未",@"丙申",@"丁酉",@"戊戌",@"己亥",@"庚子",@"辛丑",@"壬寅",@"癸卯",
                                  @"甲辰",@"乙巳",@"丙午",@"丁未",@"戊申",@"己酉",@"庚戌",@"辛亥",@"壬子",@"癸丑",
                                  @"甲寅",@"乙卯",@"丙辰",@"丁巳",@"戊午",@"己未",@"庚申",@"辛酉",@"壬戌",@"癸亥"};
    NSInteger index = 0;
    if ( year < 1504 )
        index = 60 - ((1504 - year) % 60);
    else
        index = (year-1504) % 60;
    return [nameArray[index] stringByAppendingString:@"年"];
}


- (BOOL)isLeapMonthAtDateComponents:(NSDateComponents *)dateComponents gregorianToLunar:(BOOL)gregorianToLunar
{
    if ( dateComponents == nil )
        return NO;

    BOOL resultLeapMonth = NO;
    [NSDate lunarCalcWithComponents:dateComponents
				   gregorianToLunar:gregorianToLunar
						  leapMonth:YES
							 korean:[A3UIDevice useKoreanLunarCalendarForConversion]
					resultLeapMonth:&resultLeapMonth];

    return resultLeapMonth;
}

- (NSAttributedString*)descriptionStringFromDateComponents:(NSDateComponents *)dateComponents isLunar:(BOOL)isLunar isLeapMonth:(BOOL)isLeapMonth
{
    NSString *retStr = @"";
    NSString *leapMonthStr = ( isLeapMonth ? NSLocalizedString(@"Leap Month", @"Leap Month") : @"" );
    NSString *typeStr = (isLunar ? NSLocalizedString(@"Lunar", @"Lunar") : NSLocalizedString(@"Solar", @"Solar"));
    NSString *yearStr = @"";
    NSString *monthStr = @"";
    NSString *dayStr = @"";
    NSString *subStr = @"";

    retStr = typeStr;
    if ( isLunar ) {
        if ( [leapMonthStr length] > 0 )
            retStr = [typeStr stringByAppendingFormat:@", %@",leapMonthStr];

        yearStr = [self yearNameForLunar:[dateComponents year]];
        if ( [yearStr length] > 0 ) {
            retStr = [retStr stringByAppendingString:@","];
            subStr = [subStr stringByAppendingFormat:@" %@",yearStr];
        }

		monthStr = [self lunarMonthGanjiNameFromDateComponents:dateComponents isLeapMonth:isLeapMonth];
		if ( [monthStr length] > 0) {
			subStr = [subStr stringByAppendingFormat:@" %@",monthStr];
		}
		dayStr = [self lunarDayGanjiNameFromDateComponents:dateComponents isLeapMonth:isLeapMonth];
		if ( [dayStr length] > 0) {
			subStr = [subStr stringByAppendingFormat:@" %@",dayStr];
		}

        retStr = [retStr stringByAppendingString:subStr];
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:retStr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [typeStr length])];
    if ( isLunar ){
        NSInteger startIndex = [typeStr length];
        if ( [leapMonthStr length] > 0 ){
			NSRange range = NSMakeRange([typeStr length]+2, [leapMonthStr length]);
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0] range:range];
			[attrStr addAttribute:NSFontAttributeName value:IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] range:range];
            startIndex = startIndex + 2 + [leapMonthStr length];
        }

        if ( [yearStr length] > 0 || [monthStr length] > 0 || [dayStr length] > 0 ){
			NSRange range = NSMakeRange(startIndex+1, [subStr length]);
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:137.0/255.0 green:138.0/255.0 blue:136.0/255.0 alpha:1.0] range:range];
			[attrStr addAttribute:NSFontAttributeName value:IS_IPHONE ? [UIFont systemFontOfSize:13] : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote] range:range];
        }
    }

    return attrStr;
}

- (NSString *)stringFromDateComponents:(NSDateComponents *)components {
	if (IS_IPHONE) {
		[self.dateFormatter setDateFormat:[self.dateFormatter customFullStyleFormat]];
	} else {
		[self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
	}
	return [self.dateFormatter stringFromDateComponents:components];
}

- (void)updatePageData:(UIView *)pageView resultDate:(NSDateComponents *)resultDateComponents isInputLeapMonth:(BOOL)isInputLeapMonth isResultLeapMonth:(BOOL)isResultLeapMonth
{
    A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[pageView viewWithTag:100];
    cellView.hidden = NO;
    BOOL isLeapMonth = NO;
    if (_inputDateComponents ){
        if ( _isLunarInput ){
            isLeapMonth = isInputLeapMonth;
        }
        cellView.dateLabel.text = [self stringFromDateComponents:_inputDateComponents];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDateComponents:_inputDateComponents isLunar:_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        cellView.dateLabel.text = @"";
        cellView.descriptionLabel.text = (_isLunarInput ? NSLocalizedString(@"Lunar", @"Lunar") : NSLocalizedString(@"Solar", @"Solar"));
    }

    cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
    cellView.hidden = NO;
    if (resultDateComponents){
        if ( !_isLunarInput ){
            isLeapMonth = isResultLeapMonth;
        }
        cellView.dateLabel.text = [self stringFromDateComponents:resultDateComponents];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDateComponents:resultDateComponents isLunar:!_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        if ( [_inputDateComponents year] < 1900 || [_inputDateComponents year] > 2043)
            cellView.dateLabel.text = NSLocalizedString(@"Lunar calendar is available from year 1901 to 2042.", nil);
        if ( _isLunarInput ){
            NSInteger monthDay = [NSDate lastMonthDayForLunarYear:[_inputDateComponents year]
															month:[_inputDateComponents month]
														 isKorean:[A3UIDevice useKoreanLunarCalendarForConversion]];
            if ( monthDay < 0 ){
                cellView.dateLabel.text = NSLocalizedString(@"Lunar calendar is available from year 1901 to 2042.", nil);
            }
            else if ( [_inputDateComponents day] > monthDay ){
                cellView.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Year %ld month %ld has %ld days.", @"%ld년 %ld월은 %ld일까지만 있습니다."), (long) [_inputDateComponents year], (long) [_inputDateComponents month], (long) monthDay];
            }
        }
        cellView.descriptionLabel.text = (_isLunarInput ? NSLocalizedString(@"Solar", @"Solar") : NSLocalizedString(@"Lunar", @"Lunar"));
    }
}

- (NSString*)lunarDayGanjiNameFromDateComponents:(NSDateComponents *)dateComponents isLeapMonth:(BOOL)isLeapMonth
{
    if (([dateComponents year] < 1900) || ([dateComponents year] > 2043))
        return @"";

	if (!_dbManager) return @"";

    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%ld and cd_lm=%ld and cd_ld=%ld and %@", (long)[dateComponents year], (long)[dateComponents month], (long)[dateComponents day], (isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];
    NSArray *result = [_dbManager executeSql:query];
    if ( [result count] < 1 )
        return @"";

    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hdganjee"];
    if ( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"日"];
    return retStr;
}

- (NSString*)lunarMonthGanjiNameFromDateComponents:(NSDateComponents *)dateComponents isLeapMonth:(BOOL)isLeapMonth
{
    if (([dateComponents year] < 1900) || ([dateComponents year] > 2043) || isLeapMonth)
        return @"";

	if (!_dbManager) return @"";

    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%ld and cd_lm=%ld and cd_ld=%ld and %@", (long)[dateComponents year], (long)[dateComponents month], (long)[dateComponents day],(isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];

    NSArray *result = [_dbManager executeSql:query];
    if ( [result count] < 1 )
        return @"";

    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hmganjee"];
    if ( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"月"];
    return retStr;
}

- (void)calculateDate
{
    BOOL isInputLeapMonth = ( _isLunarInput ? [NSDate isLunarLeapMonthAtDateComponents:self.inputDateComponents isKorean:[A3UIDevice useKoreanLunarCalendarForConversion] ] : NO );
    BOOL isResultLeapMonth = ( _isLunarInput ? NO : [self isLeapMonthAtDateComponents:self.inputDateComponents gregorianToLunar:!_isLunarInput]);
    
    if ( self.inputDateComponents ) {
		[[A3SyncManager sharedSyncManager] setDateComponents:self.inputDateComponents forKey:A3LunarConverterLastInputDateComponents state:A3DataObjectStateModified];

        // 첫 페이지의 결과값
        // 첫페이지의 입력이 양력일 경우 leapmonth = NO
        // 첫페이지 입력이 양력이고 결과에 윤달이 있으면 leapmonth = YES
        // 첫페이지의 입력이 음력일 경우 leapmonth = NO
        self.firstPageResultDateComponents = [NSDate lunarCalcWithComponents:self.inputDateComponents
															gregorianToLunar:!_isLunarInput
																   leapMonth:(_isLunarInput ? NO : isResultLeapMonth)
																	  korean:[A3UIDevice useKoreanLunarCalendarForConversion]
															 resultLeapMonth:&isResultLeapMonth];
		if (_isLunarInput && self.firstPageResultDateComponents) {
			_inputDateComponents.weekday = self.firstPageResultDateComponents.weekday;
		}
        
        // 두번째 페이지뷰를 만든다.
        if ( _isLunarInput && isInputLeapMonth ) {
            [self showSecondPage];
            self.secondPageResultDateComponents = [NSDate lunarCalcWithComponents:self.inputDateComponents
																 gregorianToLunar:NO
																		leapMonth:YES
																		   korean:[A3UIDevice useKoreanLunarCalendarForConversion]
																  resultLeapMonth:&isResultLeapMonth];
			[self updatePageData:_secondPageView resultDate:self.secondPageResultDateComponents isInputLeapMonth:isInputLeapMonth isResultLeapMonth:NO];
        }
        else {
            [self hideSecondPage];
            [self moveToPage:0];
            self.secondPageResultDateComponents = nil;
        }
    } else {
        self.firstPageResultDateComponents = nil;
    }

	[self updatePageData:_firstPageView resultDate:self.firstPageResultDateComponents isInputLeapMonth:(_isLunarInput ? NO : isInputLeapMonth) isResultLeapMonth:isResultLeapMonth];
}

#pragma mark - A3DateKeyboardViewControllerDelegate

- (void)dateKeyboardValueChangedDateComponents:(NSDateComponents *)dateComponents {
	self.inputDateComponents = dateComponents;

	[self calculateDate];
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController {
    [self hideKeyboardAnimate:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	_pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
	FNLOG();
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
	[self showKeyboardAnimated:YES];
	[self enableControls:YES];
}

#pragma mark - action method
- (void)addToDaysCounterAction:(id)sender
{
    FNLOG();
}

- (void)shareButtonAction:(UIBarButtonItem *)sender
{
	[self enableControls:NO];
	[self dateKeyboardDoneButtonPressed:nil];

	if (IS_IOS7) {
		self.popoverVC = [self presentActivityViewControllerInOS7WithActivityItems:@[self] fromBarButtonItem:sender];
		self.popoverVC.delegate = self;
	} else {
		UIActivityViewController *activityViewController = [self presentActivityViewControllerWithActivityItems:@[self] fromBarButtonItem:sender];
		UIPopoverPresentationController *popoverPresentationController = [activityViewController popoverPresentationController];
		popoverPresentationController.delegate = self;
	}
    if (IS_IPAD) {
        self.popoverVC.delegate = self;
    }
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
	[self showKeyboardAnimated:YES];
	[self enableControls:YES];
}

#pragma mark Share Activities

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Lunar Converter using AppBox Pro", @"Lunar Converter using AppBox Pro");
	}
    
	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
        [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a conversion with you.", nil)
									   contents:[[self shareString] stringByAppendingString:@"<br/>"]
										   tail:NSLocalizedString(@"You can convert more in the AppBox Pro.", nil)];
	} else {
		NSMutableString *txt = [NSMutableString new];
		
        if ([NSDate isFullStyleLocale]) {
            [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
        }
        else {
            [self.dateFormatter setDateFormat:[self.dateFormatter customFullStyleFormat]];
        }
        
        [txt appendString:[[self shareString] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]];
		return txt;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Lunar Converter Data", @"Share Lunar Converter Data");
}

- (NSString *)shareString
{
    NSDateComponents *outputComponents = (_pageControl.currentPage > 0 ? self.secondPageResultDateComponents : self.firstPageResultDateComponents);
    NSMutableString *txt =[NSMutableString new];

    BOOL isInputLeapMonth = [NSDate isLunarLeapMonthAtDateComponents:_inputDateComponents isKorean:[A3UIDevice useKoreanLunarCalendarForConversion]];
    BOOL isOutputLeapMonth = [NSDate isLunarLeapMonthAtDateComponents:outputComponents isKorean:[A3UIDevice useKoreanLunarCalendarForConversion]];

    if (_isLunarInput) {
        BOOL resultLeapMonth = NO;
        // Lunar Month
        NSDateComponents *solarFromLunarComp;
        solarFromLunarComp = [NSDate lunarCalcWithComponents:_inputDateComponents
                                            gregorianToLunar:NO
                                                   leapMonth:NO
                                                      korean:[A3UIDevice useKoreanLunarCalendarForConversion]
											 resultLeapMonth:&resultLeapMonth];
        NSString *prefix = [self stringOfLunarPrefixForDateComponents:_inputDateComponents leapMonth:NO];
		[txt appendFormat:@"%@(%@) %@", NSLocalizedString(@"Lunar", @"Lunar"), prefix, [_dateFormatter stringFromDateComponents:_inputDateComponents]];
		[txt appendFormat:@" = %@ %@", NSLocalizedString(@"Solar", @"Solar"), [_dateFormatter stringFromDateComponents:solarFromLunarComp]];
        
        if (isInputLeapMonth) {
            NSDateComponents *solarFromLeapComp;
            solarFromLeapComp = [NSDate lunarCalcWithComponents:_inputDateComponents
                                               gregorianToLunar:NO
                                                      leapMonth:YES
                                                         korean:[A3UIDevice useKoreanLunarCalendarForConversion]
                                                resultLeapMonth:&resultLeapMonth];
            NSString *prefix = [self stringOfLunarPrefixForDateComponents:_inputDateComponents leapMonth:NO];
            [txt appendString:@"<br/>"];
			[txt appendFormat:@"%@(%@, %@) %@", NSLocalizedString(@"Lunar", @"Lunar"), NSLocalizedString(@"Leap Month", @"Leap Month"), prefix, [_dateFormatter stringFromDateComponents:_inputDateComponents]];
			[txt appendFormat:@" = %@ %@", NSLocalizedString(@"Solar", @"Solar"), [_dateFormatter stringFromDateComponents:solarFromLeapComp]];
        }
    }
    else {
		[txt appendFormat:@"%@ %@", NSLocalizedString(@"Solar", @"Solar"), [_dateFormatter stringFromDateComponents:_inputDateComponents]];

        if (isOutputLeapMonth) {
            NSString *prefix = [self stringOfLunarPrefixForDateComponents:_inputDateComponents leapMonth:YES];
			[txt appendFormat:@" = %@(%@, %@) %@", NSLocalizedString(@"Lunar", @"Lunar"), NSLocalizedString(@"Leap Month", @"Leap Month"), prefix, [_dateFormatter stringFromDateComponents:outputComponents]];
        }
        else {
            NSString *prefix = [self stringOfLunarPrefixForDateComponents:_inputDateComponents leapMonth:NO];
			[txt appendFormat:@" = %@(%@) %@", NSLocalizedString(@"Lunar", @"Lunar"), prefix, [_dateFormatter stringFromDateComponents:outputComponents]];
        }
    }

    return txt;
}

- (NSString *)stringOfLunarPrefixForDateComponents:(NSDateComponents *)dateComp leapMonth:(BOOL)isLeapMonth
{
    NSMutableArray *result = [NSMutableArray new];
    NSString *yearStr = [self yearNameForLunar:[dateComp year]];
    NSString *monthStr = [self lunarMonthGanjiNameFromDateComponents:dateComp isLeapMonth:isLeapMonth];
    NSString *dayStr = [self lunarDayGanjiNameFromDateComponents:dateComp isLeapMonth:isLeapMonth];
    if ([yearStr length] > 0) {
        [result addObject:yearStr];
    }
    if ([monthStr length] > 0) {
        [result addObject:monthStr];
    }
    if ([dayStr length] > 0) {
        [result addObject:dayStr];
    }
    
    return [result componentsJoinedByString:@" "];
}

#pragma mark -

- (IBAction)swapAction:(id)sender {
	UIButton *button = (UIButton*)sender;
	button.enabled = NO;
	_isLunarInput = !_isLunarInput;

	// swap 애니메이션
	UIView *baseView = !_pageControl.currentPage ? _firstPageView : _secondPageView;
	A3LunarConverterCellView *topView = (A3LunarConverterCellView*)[baseView viewWithTag:100];
	topView.descriptionLabel.hidden = YES;

	UILabel *topLabel = [[UILabel alloc] initWithFrame:topView.descriptionLabel.bounds];
	topLabel.font = [UIFont systemFontOfSize:topView.descriptionLabel.font.pointSize];
	topLabel.attributedText = topView.descriptionLabel.attributedText;
	topLabel.frame = [baseView convertRect:topView.descriptionLabel.frame fromView:topView];
	topLabel.textAlignment = topView.descriptionLabel.textAlignment;
	[baseView addSubview:topLabel];

	A3LunarConverterCellView *bottomView = (A3LunarConverterCellView*)[baseView viewWithTag:101];
	bottomView.descriptionLabel.hidden = YES;
	UILabel *bottomLabel = [[UILabel alloc] initWithFrame:bottomView.descriptionLabel.bounds];
	bottomLabel.font = [UIFont systemFontOfSize:bottomView.descriptionLabel.font.pointSize];
	bottomLabel.attributedText = bottomView.descriptionLabel.attributedText;
	bottomLabel.frame = [baseView convertRect:bottomView.descriptionLabel.frame fromView:bottomView];
	bottomLabel.textAlignment = bottomView.descriptionLabel.textAlignment;
	[baseView addSubview:bottomLabel];

	[topLabel makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPAD) {
            make.right.equalTo(bottomView.right).with.offset(-15);
			make.centerY.equalTo(bottomView.centerY);
		} else {
			make.left.equalTo(bottomView.left).with.offset(15);
			make.right.equalTo(bottomView.right).with.offset(15);
			make.bottom.equalTo(bottomView.bottom).with.offset(-10);
		}
	}];

	[bottomLabel makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPAD) {
			make.right.equalTo(topView.right).with.offset(-15);
			make.centerY.equalTo(topView.centerY);
		} else {
			make.left.equalTo(topView.left).with.offset(15);
			make.right.equalTo(topView.right).with.offset(15);
			make.bottom.equalTo(topView.bottom).with.offset(-10);
		}
	}];

	[UIView animateWithDuration:0.35 animations:^{
		[baseView layoutIfNeeded];
	} completion:^(BOOL finished) {
		button.enabled = YES;
		A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[baseView viewWithTag:100];
		cellView.descriptionLabel.attributedText = bottomLabel.attributedText;
		cellView.descriptionLabel.hidden = NO;

		cellView = (A3LunarConverterCellView*)[baseView viewWithTag:101];
		cellView.descriptionLabel.attributedText = topLabel.attributedText;
		cellView.descriptionLabel.hidden = NO;

		[topLabel removeFromSuperview];
		[bottomLabel removeFromSuperview];

		if (_isLunarInput) {
			BOOL isKorean = [A3UIDevice useKoreanLunarCalendarForConversion];
			NSInteger maxDay = [NSDate lastMonthDayForLunarYear:_inputDateComponents.year month:_inputDateComponents.month isKorean:isKorean];
			if (_inputDateComponents.day > maxDay) {
				_inputDateComponents.day = maxDay;
			}
		} else {
			NSDateComponents *verifyingComponents = [_inputDateComponents copy];
			verifyingComponents.day = 1;
			NSDate *verifyingDate = [self.calendar dateFromComponents:verifyingComponents];
			NSRange range = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:verifyingDate];
			if (_inputDateComponents.day > range.length) {
				_inputDateComponents.day = range.length;
			}
		}

		[self calculateDate];
		self.dateKeyboardVC.isLunarDate = _isLunarInput;
	}];
}

- (IBAction)pageChangedAction:(id)sender {
    UIPageControl *pageCtrl = (UIPageControl*)sender;
    [self moveToPage:pageCtrl.currentPage];
}

- (IBAction)handleTapGesture:(id)sender {
    if ( !_isShowKeyboard ){
        [self showKeyboardAnimated:YES];
    }
}

- (BOOL)resignFirstResponder {
	[self dateKeyboardDoneButtonPressed:nil ];
	return [super resignFirstResponder];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	[self enableControls:!self.A3RootViewController.showLeftView];
	if (IS_IPAD) {
		[self dateKeyboardDoneButtonPressed:nil ];
	}
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	[self.navigationItem.rightBarButtonItem setEnabled:enable];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButton, NSUInteger idx, BOOL *stop) {
        switch ([barButton tag]) {
            case A3RightBarButtonTagShareButton:
                barButton.enabled = enable;
                break;
            case A3RightBarButtonTagSettingsButton:
                barButton.enabled = YES;
                break;
            default:
                break;
        }
    }];

	[self.addToDaysCounterButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		[button setEnabled:enable];
	}];
	[[self dateLabelInView:_firstPageView] setTextColor: enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255] ];
	[[self dateLabelInView:_secondPageView] setTextColor: enable ? [[A3AppDelegate instance] themeColor] : [UIColor colorWithRGBRed:201 green:201 blue:201 alpha:255] ];
}

- (UILabel *)dateLabelInView:(UIView *)view {
	A3LunarConverterCellView *cellView = (A3LunarConverterCellView *) [view viewWithTag:100];
	return cellView.dateLabel;
}

@end
