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
#import "A3Formatter.h"
#import "NSDate+LunarConverter.h"
#import "UIViewController+A3Addition.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults.h"
#import "SFKImage.h"
#import "A3DateHelper.h"


@interface A3LunarConverterViewController ()
@property (strong, nonatomic) A3DateKeyboardViewController *dateKeyboardVC;
@property (strong, nonatomic) NSDate *firstPageResultDate;
@property (strong, nonatomic) NSDate *secondPageResultDate;
@property (strong, nonatomic) NSDate *inputDate;
@property (strong, nonatomic) NSMutableArray *keyboardConstraints;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) NSMutableArray *dateInputHistory;

- (void)hideKeyboardAnimate:(BOOL)animated;
- (void)showKeyboardAnimated:(BOOL)animated;
- (NSString*)yearNameForLunar:(NSInteger)year;
- (void)moveToPage:(NSInteger)page;
- (void)showSecondPage;
- (void)hideSecondPage;
- (BOOL)isLeapMonthAtDate:(NSDate*)date gregorianToLunar:(BOOL)gregorianToLunar;
- (NSString*)resultDateString:(NSDate*)date;
- (NSAttributedString*)descriptionStringFromDate:(NSDate*)date isLunar:(BOOL)isLunar isLeapMonth:(BOOL)isLeapMonth;
- (void)updatePageData:(UIView*)pageView resultDate:(NSDate*)resultDate isInputLeapMonth:(BOOL)isInputLeapMonth isResultLeapMonth:(BOOL)isResultLeapMonth;
- (void)addConstraintsToPage:(UIView*)pageView itemView:(UIView*)itemView;
- (void)initPageView:(UIView*)pageView;
- (void)changeLayoutPageView:(UIView*)pageView;
- (void)addPageView:(UIView*)pageView page:(NSInteger)page;
- (void)setupKeyboardConstraintsToView:(UIView*)parentView;
- (void)locateKeyboardToOrientation:(UIInterfaceOrientation)toOrientation;
- (NSString*)lunarDayGanjiNameFromDate:(NSDate*)date isLeapMonth:(BOOL)isLeapMonth;
- (NSString*)lunarMonthGanjiNameFromDate:(NSDate*)date isLeapMonth:(BOOL)isLeapMonth;

- (void)addToDaysCounterAction:(id)sender;
- (void)shareAction;
- (void)backspaceAction;
@end

@implementation A3LunarConverterViewController
- (void)hideKeyboardAnimate:(BOOL)animated
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if( appFrame.size.height <= 480.0 ){
        _mainScrollViewHeightConst.constant = 254.0;
        for(UIView *pageView in @[_firstPageView,_secondPageView] ){
            UIView *topCell = [pageView viewWithTag:100];
            UIView *bottomCell = [pageView viewWithTag:101];
            [topCell mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(83.0));
            }];
            [bottomCell mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(83.0));
            }];
        }
    }
    [UIView animateWithDuration:(animated ? 0.35 : 0.0) animations:^{
        self.dateKeyboardVC.view.alpha = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.dateKeyboardVC.view.hidden = YES;
    }];
}

- (void)showKeyboardAnimated:(BOOL)animated
{
    self.dateKeyboardVC.view.hidden = NO;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    if( appFrame.size.height <= 480.0 ){
        _mainScrollViewHeightConst.constant = 166.0;
    }
    for(UIView *pageView in @[_firstPageView,_secondPageView] ){
        UIView *topCell = [pageView viewWithTag:100];
        UIView *bottomCell = [pageView viewWithTag:101];
        [topCell mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((appFrame.size.height <= 480.0 ? 66.0 : 83)));
        }];
        [bottomCell mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@((appFrame.size.height <= 480.0 ? 66.0 : 83)));
        }];
    }
    [UIView animateWithDuration:(animated ? 0.35 : 0.0) animations:^{
        self.dateKeyboardVC.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (NSDate*)dateFromComponents:(NSDateComponents*)comps
{
    [comps setLeapMonth:NO];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:comps];
}

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

- (void)moveToPage:(NSInteger)page
{
    [_mainScrollView scrollRectToVisible:CGRectMake(page * _mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
}

- (void)showSecondPage
{
    _mainScrollView.contentSize = CGSizeMake(_firstPageView.frame.size.width+_secondPageView.frame.size.width, _mainScrollView.frame.size.height);
    _pageControl.hidden = NO;
}

- (void)hideSecondPage
{
    _pageControl.currentPage = 0;
    _pageControl.hidden = YES;
    _mainScrollView.contentSize = CGSizeMake(_firstPageView.frame.size.width, _mainScrollView.frame.size.height);
    [self moveToPage:0];
}


- (BOOL)isLeapMonthAtDate:(NSDate*)date gregorianToLunar:(BOOL)gregorianToLunar
{
    if( date == nil )
        return NO;
    
    NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    BOOL resultLeapMonth = NO;
    
    [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:gregorianToLunar leapMonth:YES korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&resultLeapMonth];
    
    return resultLeapMonth;
}


- (NSString*)resultDateString:(NSDate*)date
{
    BOOL isKorean = [A3DateHelper isCurrentLocaleIsKorea];
	if (IS_IPHONE) {
		return [A3DateHelper dateStringFromDate:date withFormat:(isKorean ? @"yyyy년 MMMM d일 (EEE)" : @"EEEE, MMMM d, yyyy")];
	} else {
        return [A3DateHelper dateStringFromDate:date withFormat:(isKorean ? @"yyyy년 MMMM d일 (EEE)" : @"EEEE, MMMM d, yyyy")];
//		return [A3Formatter fullStyleDateStringFromDate:date];
	}
}

- (NSAttributedString*)descriptionStringFromDate:(NSDate*)date isLunar:(BOOL)isLunar isLeapMonth:(BOOL)isLeapMonth
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
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
        if( [leapMonthStr length] > 0 )
            retStr = [typeStr stringByAppendingFormat:@", %@",leapMonthStr];

        yearStr = [self yearNameForLunar:[comp year]];
        if( [yearStr length] > 0 ){
            retStr = [retStr stringByAppendingString:@","];
            subStr = [subStr stringByAppendingFormat:@" %@",yearStr];
        }
        
        if( [A3DateHelper isCurrentLocaleIsKorea] ){
            monthStr = [self lunarMonthGanjiNameFromDate:date isLeapMonth:isLeapMonth];
            if( [monthStr length] > 0)
                subStr = [subStr stringByAppendingFormat:@" %@",monthStr];
            dayStr = [self lunarDayGanjiNameFromDate:date isLeapMonth:isLeapMonth];
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
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:137.0/255.0 green:138.0/255.0 blue:136.0/255.0 alpha:1.0] range:NSMakeRange(startIndex+1, [subStr length])];
        }
    }
    
    return attrStr;
}

- (void)updatePageData:(UIView*)pageView resultDate:(NSDate*)resultDate isInputLeapMonth:(BOOL)isInputLeapMonth isResultLeapMonth:(BOOL)isResultLeapMonth
{
    A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[pageView viewWithTag:100];
    cellView.hidden = NO;
    NSDate *inputDate = self.inputDate;
    BOOL isLeapMonth = NO;
    if( inputDate ){
        if( _isLunarInput ){
            isLeapMonth = isInputLeapMonth;
        }
        cellView.dateLabel.text = [self resultDateString:inputDate];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDate:inputDate isLunar:_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        cellView.dateLabel.text = @"";
        cellView.descriptionLabel.text = (_isLunarInput ? @"Lunar" : @"Solar");
    }
    
    cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
    cellView.hidden = NO;
    NSDate *outputDate = resultDate;
    if(outputDate){
        if( !_isLunarInput ){
            isLeapMonth = isResultLeapMonth;
        }
        cellView.dateLabel.text = [self resultDateString:outputDate];
        cellView.descriptionLabel.attributedText = [self descriptionStringFromDate:outputDate isLunar:!_isLunarInput isLeapMonth:isLeapMonth];
    }
    else{
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:inputDate];
        if( [comp year] < 1900 || [comp year] > 2043)
            cellView.dateLabel.text = @"1900년부터 2043년까지만 지원합니다.";
        if( _isLunarInput ){
            NSInteger monthDay = [NSDate lastMonthDayForLunarYear:[comp year] month:[comp month] isKorean:[A3DateHelper isCurrentLocaleIsKorea]];
            if( monthDay < 0 ){
                cellView.dateLabel.text = @"1900년부터 2043년까지만 지원합니다.";
            }
            else if( [comp day] > monthDay ){
                cellView.dateLabel.text = [NSString stringWithFormat:@"%d년 %d월은 %d일까지만 있습니다.",[comp year],[comp month],monthDay];
            }
        }
        cellView.descriptionLabel.text = (_isLunarInput ? @"Solar" : @"Lunar");
    }
}

- (void)addConstraintsToPage:(UIView*)pageView itemView:(UIView*)itemView
{
    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:itemView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:pageView
                                                                attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:itemView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:pageView
                                                                attribute:NSLayoutAttributeTop multiplier:1.0 constant:itemView.frame.origin.y]];
    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:itemView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:pageView
                                                                attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];

    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:itemView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight multiplier:1.0 constant:itemView.frame.size.height]];
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
    UIButton *btn = [[UIButton alloc] initWithFrame:(IS_IPAD ? CGRectMake(644, 20, 44, 44) : CGRectMake(276, 6, 44, (pageView.frame.size.height < 254.0 ? 36 : 44)))];
    UIImage *btnImage = [UIImage imageNamed:@"addToDaysCounter"];
    [btn setImage:btnImage forState:UIControlStateNormal];
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, btn.frame.size.width - btnImage.size.width, 0, 0);
    [btn addTarget:self action:@selector(addToDaysCounterAction:) forControlEvents:UIControlEventTouchUpInside];
    [cellView setActionButton:btn];
    cellView.descriptionLabel.text = @"Lunar";
    
    middleCell = [pageView viewWithTag:102];
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    [pageView removeConstraints:pageView.constraints];
    CGFloat cellHeight = (pageView.frame.size.height < 254.0 ? 66 : 83);
    CGFloat middleHeight = (pageView.frame.size.height < 254.0 ? 30 : 83);
    CGFloat yPos = 0;
    line1.frame = CGRectMake(0, yPos, pageView.frame.size.width, 1.0 / scale);
    yPos += line1.frame.size.height;
    topCell.frame = CGRectMake(0, yPos, pageView.frame.size.width, cellHeight);
    yPos += topCell.frame.size.height;
    line2.frame = CGRectMake(0, yPos, pageView.frame.size.width, 1.0 / scale);
    yPos += line2.frame.size.height;
    middleCell.frame = CGRectMake(0, yPos, pageView.frame.size.width, middleHeight);
    yPos += middleCell.frame.size.height;
    line3.frame = CGRectMake(0, yPos, pageView.frame.size.width, 1.0 / scale);
    yPos += line3.frame.size.height;
    bottomCell.frame = CGRectMake(0, yPos, pageView.frame.size.width, cellHeight);
    yPos += bottomCell.frame.size.height;
    line4.frame = CGRectMake(0, yPos, pageView.frame.size.width, 1.0 / scale);
    
    [line1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.top.equalTo(pageView.top);
        make.height.equalTo(@(line1.frame.size.height));
        make.bottom.equalTo(topCell.top);
    }];
    [topCell makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.top.equalTo(line1.bottom);
        make.bottom.equalTo(line2.top);
        make.height.equalTo(@(topCell.frame.size.height));
    }];
    [line2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.height.equalTo(@(line2.frame.size.height));
        make.bottom.equalTo(middleCell.top);
        make.top.equalTo(topCell.bottom);
    }];
    [middleCell makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.bottom.equalTo(line3.top);
        make.top.equalTo(line2.bottom);
    }];
    [line3 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.height.equalTo(@(line3.frame.size.height));
        make.bottom.equalTo(bottomCell.top);
        make.top.equalTo(middleCell.bottom);
    }];
    [bottomCell makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.bottom.equalTo(line4.top);
        make.top.equalTo(line3.bottom);
        make.height.equalTo(@(bottomCell.frame.size.height));
    }];
    [line4 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pageView.left);
        make.right.equalTo(pageView.right);
        make.height.equalTo(@(line4.frame.size.height));
        make.bottom.equalTo(pageView.bottom);
        make.top.equalTo(bottomCell.bottom);
    }];
//    [self addConstraintsToPage:pageView itemView:line1];
//    [self addConstraintsToPage:pageView itemView:topCell];
//    [self addConstraintsToPage:pageView itemView:line2];
//    [self addConstraintsToPage:pageView itemView:middleCell];
//    [self addConstraintsToPage:pageView itemView:line3];
//    [self addConstraintsToPage:pageView itemView:bottomCell];
//    [self addConstraintsToPage:pageView itemView:line4];
}

- (void)changeLayoutPageView:(UIView*)pageView
{
    A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[pageView viewWithTag:100];
    [cellView setPadStyle:IS_IPAD];
//    cellView.frame = CGRectMake(cellView.frame.origin.x, cellView.frame.origin.y, pageView.frame.size.width, cellView.frame.size.height);
    
    cellView = (A3LunarConverterCellView*)[pageView viewWithTag:101];
    [cellView setPadStyle:IS_IPAD];
//    cellView.frame = CGRectMake(cellView.frame.origin.x, cellView.frame.origin.y, pageView.frame.size.width, cellView.frame.size.height);
}

- (void)addPageView:(UIView*)pageView page:(NSInteger)page
{
    [pageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    pageView.frame = CGRectMake(page*_mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
    [_mainScrollView addSubview:pageView];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:pageView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_mainScrollView
                                                                attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
}

- (void)setupKeyboardConstraintsToView:(UIView*)parentView
{
    UIView *keyboardView = self.dateKeyboardVC.view;
    [keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [parentView removeConstraints:self.keyboardConstraints];
    [self.keyboardConstraints removeAllObjects];
    [self.keyboardConstraints addObject:[NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    
    [self.keyboardConstraints addObject:[NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.keyboardConstraints addObject:[NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.keyboardConstraints addObject:[NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:keyboardView.frame.size.height]];
    [parentView addConstraints:self.keyboardConstraints];
    [parentView layoutIfNeeded];
}

- (void)locateKeyboardToOrientation:(UIInterfaceOrientation)toOrientation
{
    if( self.keyboardConstraints == nil ){
        self.keyboardConstraints = [NSMutableArray array];
    }
    
    UIViewController *viewCtrl = [[A3AppDelegate instance] rootViewController];
    CGSize viewSize = ( UIInterfaceOrientationIsLandscape(toOrientation) ? CGSizeMake(viewCtrl.view.frame.size.height, viewCtrl.view.frame.size.width) : CGSizeMake(viewCtrl.view.frame.size.width, viewCtrl.view.frame.size.height));
    UIView *parentView = viewCtrl.view;
    UIView *keyboardView = self.dateKeyboardVC.view;
    
    CGFloat keyboardHeight = (UIInterfaceOrientationIsLandscape(toOrientation) ? 352 : 264);

    [self.dateKeyboardVC rotateToInterfaceOrientation:toOrientation];
    keyboardView.frame = CGRectMake(0, viewSize.height - keyboardHeight, viewSize.width, keyboardHeight);
    [self setupKeyboardConstraintsToView:parentView];
}

- (NSString*)lunarDayGanjiNameFromDate:(NSDate*)date isLeapMonth:(BOOL)isLeapMonth
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    if (([comp year] < 1900) || ([comp year] > 2043))
        return @"";

    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%d and cd_lm=%d and cd_ld=%d and %@",[comp year],[comp month],[comp day],(isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];
    NSArray *result = [_dbManager executeSql:query];
    if( [result count] < 1 )
        return @"";
    
    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hdganjee"];
    if( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"日"];
    return retStr;
}

- (NSString*)lunarMonthGanjiNameFromDate:(NSDate*)date isLeapMonth:(BOOL)isLeapMonth
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    if (([comp year] < 1900) || ([comp year] > 2043) || isLeapMonth)
        return @"";
    
    NSString *query = [NSString stringWithFormat:@"select * from calendar_data WHERE cd_ly=%d and cd_lm=%d and cd_ld=%d and %@",[comp year],[comp month],[comp day],(isLeapMonth ? @"cd_leap_month > 1" : @"cd_leap_month < 2")];
    
    NSArray *result = [_dbManager executeSql:query];
    if( [result count] < 1 )
        return @"";
    
    NSString *retStr = [[result objectAtIndex:0] objectForKey:@"cd_hmganjee"];
    if( [retStr length] > 0 )
        retStr = [retStr stringByAppendingString:@"月"];
    return retStr;
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
        [self leftBarButtonAppsButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    }
    
    self.title = @"Lunar Converter";
    _pageControl.hidden = YES;
    
    _dbManager = [[SQLiteWrapper alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"LunarConverter" ofType:@"sqlite"]];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.dateInputHistory = [NSMutableArray array];
}

- (void)dealloc
{
    [self.dateKeyboardVC.view removeFromSuperview];
    _dbManager = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( self.dateKeyboardVC == nil ){
        [self addPageView:_firstPageView page:0];
        _secondPageView.frame = CGRectMake(_firstPageView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
        [_secondPageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_mainScrollView addSubview:_secondPageView];
        [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_secondPageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_firstPageView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
        [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_secondPageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_mainScrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_secondPageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_firstPageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        [_mainScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_secondPageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_firstPageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        if( IS_IPHONE && appFrame.size.height <= 480 ){
            _firstPageView.frame = CGRectMake(_firstPageView.frame.origin.x, _firstPageView.frame.origin.y, _firstPageView.frame.size.width, 166.0);
            _secondPageView.frame = CGRectMake(_secondPageView.frame.origin.x, _secondPageView.frame.origin.y, _secondPageView.frame.size.width, 166.0);
        }
        [self initPageView:_firstPageView];
        [self initPageView:_secondPageView];
        [self.view layoutIfNeeded];
        
        NSDate *initDate = [[NSUserDefaults standardUserDefaults] objectForKey:A3LunarConverterLastInputDate];
        _isLunarInput = [[NSUserDefaults standardUserDefaults] boolForKey:A3LunarConverterLastInputDateIsLunar];
        if( initDate == nil )
            initDate = [NSDate date];
        self.inputDate = initDate;
        [self.dateInputHistory addObject:initDate];
        
//        [self A3KeyboardDoneButtonPressed];
        [self calculateDate];
		self.dateKeyboardVC.inputLunarDate = _isLunarInput;
    }
    if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
        [self leftBarButtonAppsButton];
    else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if( self.dateKeyboardVC == nil ){
//        _mainScrollView.contentInset = UIEdgeInsetsZero;
//        _mainScrollView.contentOffset = CGPointZero;
        
        [self changeLayoutPageView:_firstPageView];
        [self changeLayoutPageView:_secondPageView];
        [self showKeyboardAnimated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if( _dbManager )
        [_dbManager open];
    if( self.dateKeyboardVC == nil ){
        if (IS_IPAD) {
			self.dateKeyboardVC = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:30.0]];
		} else {
			self.dateKeyboardVC = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17.0]];
		}
		self.dateKeyboardVC.delegate = self;
        self.dateKeyboardVC.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
        
        CGSize viewSize = CGSizeZero;
        if( IS_IPAD ){
            UIViewController *viewCtrl = [[A3AppDelegate instance] rootViewController];
            viewSize = ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? CGSizeMake(viewCtrl.view.frame.size.height, viewCtrl.view.frame.size.width) : CGSizeMake(viewCtrl.view.frame.size.width, viewCtrl.view.frame.size.height));
            if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ){
                self.dateKeyboardVC.view.frame = CGRectMake(0, viewSize.height - 352, self.dateKeyboardVC.view.frame.size.width, 352);
            }
            else{
                self.dateKeyboardVC.view.frame = CGRectMake(0, viewSize.height - 264, self.dateKeyboardVC.view.frame.size.width, 264);
            }

            [viewCtrl.view addSubview:self.dateKeyboardVC.view];
            [self locateKeyboardToOrientation:self.interfaceOrientation];
        }
        else{
            viewSize = self.view.frame.size;
            self.dateKeyboardVC.view.frame = CGRectMake(0, self.view.frame.size.height - self.dateKeyboardVC.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:self.dateKeyboardVC.view];
        }
        UIView *keyboardView = self.dateKeyboardVC.view;
        CGPoint originalPosition = keyboardView.frame.origin;
        keyboardView.frame = CGRectMake(keyboardView.frame.origin.x, viewSize.height, keyboardView.frame.size.width, keyboardView.frame.size.height);
        [UIView animateWithDuration:0.35 animations:^{
            keyboardView.frame = CGRectMake(keyboardView.frame.origin.x, originalPosition.y, keyboardView.frame.size.width, keyboardView.frame.size.height);
        } completion:^(BOOL finished) {
            if( _pageControl.hidden )
                _mainScrollView.contentSize = _mainScrollView.frame.size;
            else{
                _mainScrollView.contentSize = CGSizeMake(_firstPageView.frame.size.width+_secondPageView.frame.size.width, _mainScrollView.frame.size.height);
            }
            keyboardView.clipsToBounds = YES;
        }];
        self.dateKeyboardVC.date = self.inputDate;
		self.dateKeyboardVC.inputLunarDate = _isLunarInput;
        
        if (IS_IPAD) {
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:30.0]];
		} else {
            [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:17.0]];
		}
        [SFKImage setDefaultColor:[UIColor blackColor]];
        
        [_dateKeyboardVC.prevButton setImage:[SFKImage imageNamed:@"r"] forState:UIControlStateNormal];
        [_dateKeyboardVC.nextButton setImage:[SFKImage imageNamed:@"q"] forState:UIControlStateNormal];
        [_dateKeyboardVC.prevButton setEnabled:YES];
        [_dateKeyboardVC.nextButton setEnabled:YES];
        if( IS_IPAD ){
            [SFKImage setDefaultFont:[UIFont fontWithName:@"LigatureSymbols" size:30.0]];
            [_dateKeyboardVC.blank2Button setImage:[SFKImage imageNamed:@"backspace"] forState:UIControlStateNormal];
            [_dateKeyboardVC.blank2Button setEnabled:YES];
        }
        [_dateKeyboardVC.blank2Button addTarget:self action:@selector(backspaceAction) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _mainScrollView.contentSize = CGSizeMake((_pageControl.hidden ? _firstPageView.frame.size.width : _firstPageView.frame.size.width + _secondPageView.frame.size.width), _mainScrollView.frame.size.height);
    if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) )
        [self leftBarButtonAppsButton];
    else{
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if( IS_IPAD ){
        [self locateKeyboardToOrientation:toInterfaceOrientation];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)calculateDate
{
    BOOL isInputLeapMonth = ( _isLunarInput ? [NSDate isLunarLeapMonthAtDate:self.inputDate isKorean:[A3DateHelper isCurrentLocaleIsKorea]] : NO );
    BOOL isResultLeapMonth = ( _isLunarInput ? NO : [self isLeapMonthAtDate:self.inputDate gregorianToLunar:!_isLunarInput]);
    
    if( self.inputDate ){
        [[NSUserDefaults standardUserDefaults] setObject:self.inputDate forKey:A3LunarConverterLastInputDate];
        [[NSUserDefaults standardUserDefaults] setBool:_isLunarInput forKey:A3LunarConverterLastInputDateIsLunar];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDateComponents *dateComp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.inputDate];
        
        // 첫 페이지의 결과값
        // 첫페이지의 입력이 양력일 경우 leapmonth = NO
        // 첫페이지 입력이 양력이고 결과에 윤달이 있으면 leapmonth = YES
        // 첫페이지의 입력이 음력일 경우 leapmonth = NO
        self.firstPageResultDate = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:!_isLunarInput leapMonth:(_isLunarInput ? NO : isResultLeapMonth) korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
        
        // 두번째 페이지뷰를 만든다.
        if( _isLunarInput && isInputLeapMonth ){
            [self showSecondPage];
            
            self.secondPageResultDate = [NSDate lunarCalcWithComponents:dateComp gregorianToLunar:NO leapMonth:YES korean:[A3DateHelper isCurrentLocaleIsKorea] resultLeapMonth:&isResultLeapMonth];
            [self updatePageData:_secondPageView resultDate:self.secondPageResultDate isInputLeapMonth:isInputLeapMonth isResultLeapMonth:NO];
        }
        else{
            [self hideSecondPage];
            [self moveToPage:0];
            self.secondPageResultDate = nil;
        }
    }
    else {
        self.firstPageResultDate = nil;
    }
    
    [self updatePageData:_firstPageView resultDate:self.firstPageResultDate isInputLeapMonth:(_isLunarInput ? NO : isInputLeapMonth) isResultLeapMonth:isResultLeapMonth];
}

#pragma mark - A3DateKeyboardViewControllerDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date element:(QEntryElement *)element
{
    NSLog(@"%s %@",__FUNCTION__,element);
    self.inputDate = date;
    [self.dateInputHistory addObject:date];
    [self calculateDate];
//    [self A3KeyboardDoneButtonPressed];
}

- (void)A3KeyboardDoneButtonPressed
{
    [self hideKeyboardAnimate:YES];
    [self calculateDate];
}

- (BOOL)prevAvailableForElement:(QEntryElement *)element
{
    NSLog(@"%s",__FUNCTION__);
    if( self.inputDate == nil )
        return NO;
    return YES;
}

- (BOOL)nextAvailableForElement:(QEntryElement *)element
{
    NSLog(@"%s",__FUNCTION__);
    if( self.inputDate == nil )
        return NO;
    
    return YES;
}

- (void)prevButtonPressedWithElement:(QEntryElement *)element
{
    NSLog(@"%s",__FUNCTION__);
    if( self.inputDate == nil )
        return;
    NSDate *date = [A3DateHelper dateByAddingDays:-1 fromDate:self.inputDate];
    self.inputDate = date;
    [self calculateDate];
//    [self A3KeyboardDoneButtonPressed];
}

- (void)nextButtonPressedWithElement:(QEntryElement *)element
{
    NSLog(@"%s",__FUNCTION__);
    if( self.inputDate == nil )
        return;
    NSDate *date = [A3DateHelper dateByAddingDays:1 fromDate:self.inputDate];
    self.inputDate = date;
    [self calculateDate];
//    [self A3KeyboardDoneButtonPressed];
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
    NSDate *inDate = self.inputDate;
    NSDate *outDate = (_pageControl.currentPage > 0 ? self.secondPageResultDate : self.firstPageResultDate);
    
    NSArray *activityItems = @[[NSString stringWithFormat:@"%@ Date: %@ converted to %@ date %@",(_isLunarInput ? @"Lunar" : @"Solar"),[A3Formatter stringFromDate:inDate format:@"yyyy.MM.dd"],(_isLunarInput ? @"Solar" : @"Lunar"),[A3Formatter stringFromDate:outDate format:@"yyyy.MM.dd"] ]];
    
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
    
        UIView *animPage = button.superview.superview;
        A3LunarConverterCellView *topView = (A3LunarConverterCellView*)[animPage viewWithTag:100];
        topView.descriptionLabel.hidden = YES;

        UILabel *topLabel = [[UILabel alloc] initWithFrame:topView.descriptionLabel.bounds];
        topLabel.font = [UIFont systemFontOfSize:topView.descriptionLabel.font.pointSize];
        topLabel.attributedText = topView.descriptionLabel.attributedText;
        topLabel.frame = CGRectMake(topView.frame.origin.x + topView.descriptionLabel.frame.origin.x, topView.frame.origin.y + topView.descriptionLabel.frame.origin.y, topView.descriptionLabel.frame.size.width, topView.descriptionLabel.frame.size.height);
        topLabel.textAlignment = topView.descriptionLabel.textAlignment;
        
        A3LunarConverterCellView *bottomView = (A3LunarConverterCellView*)[animPage viewWithTag:101];
        bottomView.descriptionLabel.hidden = YES;
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:bottomView.descriptionLabel.bounds];
        bottomLabel.font = [UIFont systemFontOfSize:bottomView.descriptionLabel.font.pointSize];
        bottomLabel.attributedText = bottomView.descriptionLabel.attributedText;
        bottomLabel.frame = CGRectMake(bottomView.frame.origin.x + bottomView.descriptionLabel.frame.origin.x, bottomView.frame.origin.y + bottomView.descriptionLabel.frame.origin.y, bottomView.descriptionLabel.frame.size.width, bottomView.descriptionLabel.frame.size.height);
        bottomLabel.textAlignment = bottomView.descriptionLabel.textAlignment;

        [topLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [animPage addSubview:topLabel];
        
        NSLayoutConstraint *topLabelTopConst = [NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeTop multiplier:1.0 constant:topLabel.frame.origin.y];
        NSLayoutConstraint *topLabelTrailingConst = [NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-(animPage.frame.size.width - (topLabel.frame.origin.x+topLabel.frame.size.width))];
        NSLayoutConstraint *topLabelLeadingConst = [NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeLeading multiplier:1.0 constant:topLabel.frame.origin.x];

        [animPage addConstraint:topLabelTopConst];
        [animPage addConstraint:topLabelTrailingConst];
        [animPage addConstraint:topLabelLeadingConst];
        [animPage addConstraint:[NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:topLabel.frame.size.height]];

        [bottomLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [animPage addSubview:bottomLabel];
        NSLayoutConstraint *bottomLabelTopConst = [NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeTop multiplier:1.0 constant:bottomLabel.frame.origin.y];
        NSLayoutConstraint *bottomLabelTrailingConst = [NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-(animPage.frame.size.width - (bottomLabel.frame.origin.x+bottomLabel.frame.size.width))];
        NSLayoutConstraint *bottomLabelLeadingConst = [NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:animPage attribute:NSLayoutAttributeLeading multiplier:1.0 constant:bottomLabel.frame.origin.x];
        [animPage addConstraint:bottomLabelTopConst];
        [animPage addConstraint:bottomLabelTrailingConst];
        [animPage addConstraint:bottomLabelLeadingConst];
        [animPage addConstraint:[NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:bottomLabel.frame.size.height]];
        
        CGFloat diffWidth = topLabel.frame.size.width - bottomLabel.frame.size.width;
        CGFloat bottomTopValue = bottomLabelTopConst.constant;
        
        bottomLabelTrailingConst.constant += diffWidth;
        topLabelTrailingConst.constant -= diffWidth;
        bottomLabelTopConst.constant = topLabelTopConst.constant;
        topLabelTopConst.constant = bottomTopValue;
        topLabelLeadingConst.constant -= diffWidth;
        bottomLabelLeadingConst.constant += diffWidth;
        
        [animPage setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.35 animations:^{
            [animPage layoutIfNeeded];
        } completion:^(BOOL finished) {
            button.enabled = YES;
            A3LunarConverterCellView *cellView = (A3LunarConverterCellView*)[animPage viewWithTag:100];
            cellView.descriptionLabel.attributedText = bottomLabel.attributedText;
            cellView.descriptionLabel.hidden = NO;
            
            cellView = (A3LunarConverterCellView*)[animPage viewWithTag:101];
            cellView.descriptionLabel.attributedText = topLabel.attributedText;
            cellView.descriptionLabel.hidden = NO;
            
            [topLabel removeFromSuperview];
            [bottomLabel removeFromSuperview];
            [self calculateDate];
//            [self A3KeyboardDoneButtonPressed];
			self.dateKeyboardVC.inputLunarDate = _isLunarInput;
        }];
	}
}

- (IBAction)pageChangedAction:(id)sender {
    UIPageControl *pageCtrl = (UIPageControl*)sender;
    [self moveToPage:pageCtrl.currentPage];
}

- (IBAction)handleTapgesture:(id)sender {
    if( self.dateKeyboardVC.view.hidden ){
        [self showKeyboardAnimated:YES];
    }
}

- (void)backspaceAction
{
    if( [self.dateInputHistory count] <= 1)
        return;
    [self.dateInputHistory removeLastObject];
    self.inputDate = [self.dateInputHistory lastObject];
    [self calculateDate];
}

@end
