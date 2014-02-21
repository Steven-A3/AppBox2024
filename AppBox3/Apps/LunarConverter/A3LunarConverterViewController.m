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
#import "UIViewController+A3Addition.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"
#import "A3DateHelper.h"
#import "NSDateFormatter+LunarDate.h"
#import "NSUserDefaults+A3Addition.h"
#import "NSDateFormatter+A3Addition.h"


@interface A3LunarConverterViewController ()

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.dateKeyboardVC.view removeFromSuperview];
	_dbManager = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[self leftBarButtonAppsButton];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];

	self.title = @"Lunar Converter";
	_pageControl.hidden = YES;
	[_pageControl makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
	}];

	_dbManager = [[SQLiteWrapper alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"LunarConverter" ofType:@"sqlite"]];
	[self setAutomaticallyAdjustsScrollViewInsets:NO];

	CGFloat viewHeight = 84 * 3 + 1;
	if(IS_IPHONE35) {
		viewHeight = 180;
	}

	[_mainScrollView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.top.equalTo(self.view.top).with.offset(64);
		[self.cellHeightConstraints addObject:make.height.equalTo(@(viewHeight))];
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

	_inputDateComponents = [[NSUserDefaults standardUserDefaults] dateComponentsForKey:A3LunarConverterLastInputDateComponents];
	if (!_inputDateComponents) {
		_inputDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
	}
	_isLunarInput = [[NSUserDefaults standardUserDefaults] boolForKey:A3LunarConverterLastInputDateIsLunar];

	_isShowKeyboard = YES;

	[self addDateKeyboard];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
		[self leftBarButtonAppsButton];
	else{
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}

	[self calculateDate];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuBecameFirstResponder) name:A3MainMenuBecameFirstResponder object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuResignFirstResponder) name:A3MainMenuResignFirstResponder object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self showKeyboardAnimated:YES];

	if( _dbManager )
		[_dbManager open];
}

- (void)mainMenuBecameFirstResponder {
	[self A3KeyboardDoneButtonPressed];
}

- (void)mainMenuResignFirstResponder {
	FNLOG();
	[self showKeyboardAnimated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if( IS_IPAD ){
		[self layoutKeyboardToOrientation:toInterfaceOrientation];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
		[self leftBarButtonAppsButton];
	else{
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
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
	cellView.dateLabel.textColor = [UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0];
	cellView.descriptionLabel.text = @"Solar";

	cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
	bottomCell = cellView;
	UIButton *addToDaysCounterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addToDaysCounterButton.bounds = CGRectMake(0, 0, 44, 44);
	UIImage *buttonImage = [UIImage imageNamed:@"addToDaysCounter"];
	[addToDaysCounterButton setImage:buttonImage forState:UIControlStateNormal];

	[addToDaysCounterButton addTarget:self action:@selector(addToDaysCounterAction:) forControlEvents:UIControlEventTouchUpInside];
	[cellView setActionButton:addToDaysCounterButton];
	cellView.descriptionLabel.text = @"Lunar";

	middleCell = [pageView viewWithTag:102];

	CGFloat scale = [[UIScreen mainScreen] scale];

	BOOL isIPHONE35 = IS_IPHONE35;
	CGFloat cellHeight = isIPHONE35 ? 66 : 84;
	CGFloat middleHeight = isIPHONE35 ? 48 : 84;
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
		[_cellHeightConstraints addObject:make.height.equalTo(@(cellHeight))];
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
		[_cellHeightConstraints addObject:make.height.equalTo(@(cellHeight))];
	}];
	[line4 makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(pageView.left);
		make.right.equalTo(pageView.right);
		make.bottom.equalTo(pageView.bottom);
		make.height.equalTo(@(lineWidth));
	}];
}

#pragma mark - Keyboard Layout

- (void)addDateKeyboard {
	if (IS_IPAD) {
		self.dateKeyboardVC = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
	} else {
		self.dateKeyboardVC = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
	}
	self.dateKeyboardVC.delegate = self;

	UIView *superview;
	if( IS_IPAD ){
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
	FNLOGRECT(self.view.frame);

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
	CGFloat keyboardHeight;

	if (IS_IPHONE) {
		keyboardHeight = 216;
	} else {
		keyboardHeight = UIInterfaceOrientationIsLandscape(toOrientation) ? 352 : 264;
	}

	_keyboardTopConstraint.offset(-keyboardHeight);

	[_keyboardHeightConstraint uninstall];
	[self.dateKeyboardVC.view updateConstraints:^(MASConstraintMaker *make) {
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

- (void)showKeyboardAnimated:(BOOL)animated
{
	FNLOG();

	self.dateKeyboardVC.isLunarDate = _isLunarInput;

	_isShowKeyboard = YES;

	if (IS_IPHONE35) {
		[self uninstallCellHeightConstraints];

		[self.mainScrollView updateConstraints:^(MASConstraintMaker *make) {
			[_cellHeightConstraints addObject:make.height.equalTo(@(180))];
		}];
		for (UIView *pageView in @[_firstPageView, _secondPageView]) {
			UIView *topCell = [pageView viewWithTag:100];
			[topCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@66)];
			}];

			UIView *bottomCell = [pageView viewWithTag:101];
			[bottomCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@66)];
			}];

			UIView *middleCell = [pageView viewWithTag:102];
			[middleCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@48)];
			}];
		}
	}

	[_keyboardTopConstraint uninstall];

	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		_keyboardTopConstraint =  make.top.equalTo(self.dateKeyboardVC.view.superview.bottom).with.offset(-self.dateKeyboardVC.view.frame.size.height);
	}];

	[UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
		[self.view layoutIfNeeded];
		[self.dateKeyboardVC.view.superview layoutIfNeeded];
	}];
}

- (void)hideKeyboardAnimate:(BOOL)animated
{
	_isShowKeyboard = NO;

	if (IS_IPHONE35) {
		[self uninstallCellHeightConstraints];

		[self.mainScrollView makeConstraints:^(MASConstraintMaker *make) {
			[_cellHeightConstraints addObject:make.height.equalTo(@(84 * 3 + 1))];
		}];
		for (UIView *pageView in @[_firstPageView, _secondPageView]) {
			UIView *topCell = [pageView viewWithTag:100];
			[topCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@84)];
			}];

			UIView *bottomCell = [pageView viewWithTag:101];
			[bottomCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@84)];
			}];

			UIView *middleCell = [pageView viewWithTag:102];
			[middleCell makeConstraints:^(MASConstraintMaker *make) {
				[_cellHeightConstraints addObject:make.height.equalTo(@84)];
			}];
		}
	}
	[_keyboardTopConstraint uninstall];
	[self.dateKeyboardVC.view makeConstraints:^(MASConstraintMaker *make) {
		_keyboardTopConstraint =  make.top.equalTo(self.view.bottom);
	}];

	[UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
		[self.view layoutIfNeeded];
		[self.dateKeyboardVC.view.superview layoutIfNeeded];
    }];
}

#pragma mark ---- Page Handling

- (void)moveToPage:(NSInteger)page
{
	[_mainScrollView scrollRectToVisible:CGRectMake(page * _mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
}


- (void)showSecondPage
{
	_pageControl.hidden = NO;
	[_mainScrollView setScrollEnabled:YES];
}

- (void)hideSecondPage
{
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
    if( year < 1504 )
        index = 60 - ((1504 - year) % 60);
    else
        index = (year-1504) % 60;
    return [nameArray[index] stringByAppendingString:@"年"];
}


- (BOOL)isLeapMonthAtDateComponents:(NSDateComponents *)dateComponents gregorianToLunar:(BOOL)gregorianToLunar
{
    if( dateComponents == nil )
        return NO;

    BOOL resultLeapMonth = NO;

    [NSDate lunarCalcWithComponents:dateComponents gregorianToLunar:gregorianToLunar leapMonth:YES korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&resultLeapMonth];

    return resultLeapMonth;
}

- (NSAttributedString*)descriptionStringFromDateComponents:(NSDateComponents *)dateComponents isLunar:(BOOL)isLunar isLeapMonth:(BOOL)isLeapMonth
{
    NSString *retStr = @"";
    NSString *leapMonthStr = ( isLeapMonth ? @"Leap Month" : @"" );
    NSString *typeStr = (isLunar ? @"Lunar" : @"Solar");
    NSString *yearStr = @"";
    NSString *monthStr = @"";
    NSString *dayStr = @"";
    NSString *subStr = @"";

    retStr = typeStr;
    if( isLunar ){
        if( [leapMonthStr length] > 0 )
            retStr = [typeStr stringByAppendingFormat:@", %@",leapMonthStr];

        yearStr = [self yearNameForLunar:[dateComponents year]];
        if( [yearStr length] > 0 ){
            retStr = [retStr stringByAppendingString:@","];
            subStr = [subStr stringByAppendingFormat:@" %@",yearStr];
        }

        if( [A3DateHelper isCurrentLocaleIsKorea] ){
            monthStr = [self lunarMonthGanjiNameFromDateComponents:dateComponents isLeapMonth:isLeapMonth];
            if( [monthStr length] > 0)
                subStr = [subStr stringByAppendingFormat:@" %@",monthStr];
            dayStr = [self lunarDayGanjiNameFromDateComponents:dateComponents isLeapMonth:isLeapMonth];
            if( [dayStr length] > 0)
                subStr = [subStr stringByAppendingFormat:@" %@",dayStr];
        }
        retStr = [retStr stringByAppendingString:subStr];
    }

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:retStr];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [typeStr length])];
    if( isLunar ){
        NSInteger startIndex = [typeStr length];
        if( [leapMonthStr length] > 0 ){
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1.0 green:45.0/255.0 blue:85.0/255.0 alpha:1.0] range:NSMakeRange([typeStr length]+2, [leapMonthStr length])];
            startIndex = startIndex + 2 + [leapMonthStr length];
        }

        if( [yearStr length] > 0 || [monthStr length] > 0 || [dayStr length] > 0 ){
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
    if(_inputDateComponents ){
        if( _isLunarInput ){
            isLeapMonth = isInputLeapMonth;
        }
        cellView.dateLabel.text = [self stringFromDateComponents:_inputDateComponents];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDateComponents:_inputDateComponents isLunar:_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        cellView.dateLabel.text = @"";
        cellView.descriptionLabel.text = (_isLunarInput ? @"Lunar" : @"Solar");
    }

    cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
    cellView.hidden = NO;
    if(resultDateComponents){
        if( !_isLunarInput ){
            isLeapMonth = isResultLeapMonth;
        }
        cellView.dateLabel.text = [self stringFromDateComponents:resultDateComponents];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDateComponents:resultDateComponents isLunar:!_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        if( [_inputDateComponents year] < 1900 || [_inputDateComponents year] > 2043)
            cellView.dateLabel.text = @"1900년부터 2043년까지만 지원합니다.";
        if( _isLunarInput ){
            NSInteger monthDay = [NSDate lastMonthDayForLunarYear:[_inputDateComponents year] month:[_inputDateComponents month] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
            if( monthDay < 0 ){
                cellView.dateLabel.text = @"1900년부터 2043년까지만 지원합니다.";
            }
            else if( [_inputDateComponents day] > monthDay ){
                cellView.dateLabel.text = [NSString stringWithFormat:@"%ld년 %ld월은 %ld일까지만 있습니다.", (long)[_inputDateComponents year], (long)[_inputDateComponents month], (long)monthDay];
            }
        }
        cellView.descriptionLabel.text = (_isLunarInput ? @"Solar" : @"Lunar");
    }
}

- (NSString*)lunarDayGanjiNameFromDateComponents:(NSDateComponents *)dateComponents isLeapMonth:(BOOL)isLeapMonth
{
    if (([dateComponents year] < 1900) || ([dateComponents year] > 2043))
        return @"";

    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%ld and cd_lm=%ld and cd_ld=%ld and %@", (long)[dateComponents year], (long)[dateComponents month], (long)[dateComponents day], (isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];
    NSArray *result = [_dbManager executeSql:query];
    if( [result count] < 1 )
        return @"";

    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hdganjee"];
    if( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"日"];
    return retStr;
}

- (NSString*)lunarMonthGanjiNameFromDateComponents:(NSDateComponents *)dateComponents isLeapMonth:(BOOL)isLeapMonth
{
    if (([dateComponents year] < 1900) || ([dateComponents year] > 2043) || isLeapMonth)
        return @"";

    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%ld and cd_lm=%ld and cd_ld=%ld and %@", (long)[dateComponents year], (long)[dateComponents month], (long)[dateComponents day],(isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];

    NSArray *result = [_dbManager executeSql:query];
    if( [result count] < 1 )
        return @"";

    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hmganjee"];
    if( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"月"];
    return retStr;
}

- (void)calculateDate
{
    BOOL isInputLeapMonth = ( _isLunarInput ? [NSDate isLunarLeapMonthAtDate:self.inputDateComponents isKorean:[A3DateHelper isCurrentLocaleIsKorea]] : NO );
    BOOL isResultLeapMonth = ( _isLunarInput ? NO : [self isLeapMonthAtDateComponents:self.inputDateComponents gregorianToLunar:!_isLunarInput]);
    
    if( self.inputDateComponents ){
		[[NSUserDefaults standardUserDefaults] setDateComponents:self.inputDateComponents forKey:A3LunarConverterLastInputDateComponents];
        [[NSUserDefaults standardUserDefaults] setBool:_isLunarInput forKey:A3LunarConverterLastInputDateIsLunar];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // 첫 페이지의 결과값
        // 첫페이지의 입력이 양력일 경우 leapmonth = NO
        // 첫페이지 입력이 양력이고 결과에 윤달이 있으면 leapmonth = YES
        // 첫페이지의 입력이 음력일 경우 leapmonth = NO
        self.firstPageResultDateComponents = [NSDate lunarCalcWithComponents:self.inputDateComponents gregorianToLunar:!_isLunarInput leapMonth:(_isLunarInput ? NO : isResultLeapMonth) korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
		if (_isLunarInput && self.firstPageResultDateComponents) {
			_inputDateComponents.weekday = self.firstPageResultDateComponents.weekday;
		}
        
        // 두번째 페이지뷰를 만든다.
        if( _isLunarInput && isInputLeapMonth ){
            [self showSecondPage];
            
            self.secondPageResultDateComponents = [NSDate lunarCalcWithComponents:self.inputDateComponents gregorianToLunar:NO leapMonth:YES korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
			[self updatePageData:_secondPageView resultDate:self.secondPageResultDateComponents isInputLeapMonth:isInputLeapMonth isResultLeapMonth:NO];
        } else {
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

- (void)A3KeyboardDoneButtonPressed
{
    [self hideKeyboardAnimate:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}

#pragma mark - action method
- (void)addToDaysCounterAction:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)shareAction
{
    NSDateComponents *outputComponents = (_pageControl.currentPage > 0 ? self.secondPageResultDateComponents : self.firstPageResultDateComponents);
	[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];

	NSArray *activityItems = @[[NSString stringWithFormat:@"%@ Date: %@ converted to %@ date %@",(_isLunarInput ? @"Lunar" : @"Solar"),
					[_dateFormatter stringFromDateComponents:_inputDateComponents],
					(_isLunarInput ? @"Solar" : @"Lunar"),
					[_dateFormatter stringFromDateComponents:outputComponents] ]];
    
    self.popoverVC = [self presentActivityViewControllerWithActivityItems:activityItems fromBarButtonItem:self.navigationItem.rightBarButtonItem];
    if( self.popoverVC )
        self.popoverVC.delegate = self;
}

- (IBAction)swapAction:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.enabled = NO;
    _isLunarInput = !_isLunarInput;
    
    // swap 애니메이션
    @autoreleasepool {
    
        UIView *baseView = button.superview.superview;
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
				make.right.equalTo(bottomView.actionButton.left);
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
				BOOL isKorean = [[NSUserDefaults standardUserDefaults] boolForKey:A3SettingsUseKoreanCalendarForLunarConversion];
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
}

- (IBAction)pageChangedAction:(id)sender {
    UIPageControl *pageCtrl = (UIPageControl*)sender;
    [self moveToPage:pageCtrl.currentPage];
}

- (IBAction)handleTapGesture:(id)sender {
    if( !_isShowKeyboard ){
        [self showKeyboardAnimated:YES];
    }
}

- (BOOL)resignFirstResponder {
	[self A3KeyboardDoneButtonPressed];
	return [super resignFirstResponder];
}

- (void)appsButtonAction {
	[super appsButtonAction];

	if (IS_IPAD) {
		[self A3KeyboardDoneButtonPressed];
	}
}

@end
