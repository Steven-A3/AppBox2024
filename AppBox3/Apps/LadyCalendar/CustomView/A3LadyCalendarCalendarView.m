//
//  A3LadyCalendarCalendarView.m
//  A3TeamWork
//
//  Created by coanyaa on 2014. 2. 25..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LadyCalendarCalendarView.h"
#import "A3DateHelper.h"
#import "A3LadyCalendarModelManager.h"
#import "LadyCalendarPeriod.h"
#import "A3AppDelegate+appearance.h"
#import "LadyCalendarAccount.h"

@implementation LineDisplayModel

- (id)init
{
    self = [super init];
    if ( self ) {
        self.lineRect = CGRectZero;
        self.lineColor = [UIColor whiteColor];
    }
    
    return self;
}

@end

@implementation CircleDisplayModel

- (id)init
{
    self = [super init];
    if ( self ) {
        self.circleRect = CGRectMake(0, 0, 15.0, 15.0);
        self.circleColor = [UIColor whiteColor];
        self.isAlphaCircleShow = NO;
    }
    
    return self;
}

@end

@interface A3LadyCalendarCalendarView ()
@property (strong, nonatomic) UIFont *dateFont;
@property (strong, nonatomic) UIColor *dateTextColor;
@property (strong, nonatomic) UIColor *weekendTextColor;
@property (readonly, nonatomic) NSInteger year;
@property (readonly, nonatomic) NSInteger month;
@end

@implementation A3LadyCalendarCalendarView {
	NSInteger _numberOfWeeks;
	NSInteger _firstDayStartIndex;
	NSInteger _lastDayIndex;
	NSInteger _lastWeekday;
	NSInteger _lastDay;

	NSInteger _dateBGHeight;
	NSArray *_periods;
	__strong NSMutableArray *_redLines;
	__strong NSMutableArray *_greenLines;
	__strong NSMutableArray *_yellowLines;
	__strong NSMutableArray *_circleArray;
	__block dispatch_queue_t _dQueue;
	BOOL _isCurrentMonth;
	NSInteger _today;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self initialize];
	}
	return self;
}

- (void)initialize {
	self.dateFont = [UIFont systemFontOfSize:(IS_IPHONE ? 14.0 : 18.0)];
	self.dateTextColor = [UIColor blackColor];
	self.weekendTextColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
	CGSizeMake(0, 0.5);
	_redLines = [NSMutableArray array];
	_greenLines = [NSMutableArray array];
	_yellowLines = [NSMutableArray array];
	_circleArray = [NSMutableArray array];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self initialize];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if ( self.dateMonth == nil )
        return;
    
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *textAttr = @{NSForegroundColorAttributeName : _dateTextColor,NSFontAttributeName : _dateFont,NSParagraphStyleAttributeName : paraStyle};
    NSDictionary *weekendTextAttr = @{NSForegroundColorAttributeName : _weekendTextColor,NSFontAttributeName : _dateFont,NSParagraphStyleAttributeName : paraStyle};
    NSDictionary *todayTextAttr = @{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : _dateFont,NSParagraphStyleAttributeName : paraStyle};

    // Calendar, 달력 그리기.
    NSInteger index = 0;
    for (NSInteger y=0; y < _numberOfWeeks; y++) {
        CGContextSetShouldAntialias(context , YES);
        for (NSInteger x=0; x < 7; x++,index++) {
            if ( index > _lastDayIndex )  continue;
            if ( index < _firstDayStartIndex ) {
                xPos += _cellSize.width;
                continue;
            }
            NSInteger day = index - _firstDayStartIndex + 1;
            NSString *str = (index == _firstDayStartIndex ? [A3DateHelper dateStringFromDate:_dateMonth withFormat:@"MMM d"] : [NSString stringWithFormat:@"%ld",(long)(index - _firstDayStartIndex + 1)]);
            if ( _isCurrentMonth && _today == day) {
				CGContextSaveGState(context);
				CGContextSetAllowsAntialiasing(context, NO);
				CGContextSetStrokeColorWithColor(context, [[[A3AppDelegate instance] themeColor] CGColor]);
                CGContextSetFillColorWithColor(context, [[[A3AppDelegate instance] themeColor] CGColor]);
                CGContextFillRect(context, CGRectMake(xPos, yPos, _cellSize.width, _dateBGHeight));
				CGContextSetAllowsAntialiasing(context, YES);
				[str drawInRect:CGRectMake(xPos, yPos + (IS_IPHONE ? 9.0 : 15.0), _cellSize.width, _dateBGHeight + 5.0) withAttributes:todayTextAttr];
				CGContextRestoreGState(context);
            }
            else {
                [str drawInRect:CGRectMake(xPos, yPos + (IS_IPHONE ? 9.0 : 15.0), _cellSize.width, _dateBGHeight + 5.0) withAttributes:(x==0 || x==6 ? weekendTextAttr :textAttr)];
            }
            xPos += _cellSize.width;
        }
        yPos += _cellSize.height;
        xPos = 0.0;
        
//        FNLOG(@"%s yPos:%f, weeks:%d/%d,height:%f,%@",__FUNCTION__,yPos,y+1,numberOfWeeks,_cellSize.height,NSStringFromCGRect(self.frame));
        CGContextSetShouldAntialias(context , NO);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(context, xPos, yPos );
        CGContextAddLineToPoint(context,( (y+1) == _numberOfWeeks ? xPos + _lastWeekday*_cellSize.width : rect.size.width), yPos);
        CGContextSetLineWidth(context, 1.0 / [[UIScreen mainScreen] scale]);
        CGContextStrokePath(context);
//        yPos += 0.5;
    }

    
    
    // Period 라인을 그린다.
    // 빨간선.
    for (LineDisplayModel *ldmObj in _redLines) {
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    // 녹색선.
    for (LineDisplayModel *ldmObj in _greenLines) {
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    
    // 노랑선.
    for (LineDisplayModel *ldmObj in _yellowLines) {
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    

    // Period Circle 을 그린다.
    UIColor *outlineColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    UIColor *outCircleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    CGContextSetShouldAntialias(context , YES);
    for (CircleDisplayModel *cdmObj in _circleArray) {
        if ( cdmObj.isAlphaCircleShow ) {
			// 31x31
            [outCircleColor setFill];
			CGFloat offset = IS_RETINA ? 8.0 : 7.5;
			CGFloat diameter = IS_RETINA ? 31.0 : 30.0;
            CGContextFillEllipseInRect(context,CGRectMake(cdmObj.circleRect.origin.x - offset, cdmObj.circleRect.origin.y - offset, diameter, diameter));
        }

		// 15
        [[UIColor whiteColor] setFill];
        CGContextFillEllipseInRect(context, cdmObj.circleRect);
		if (!cdmObj.isAlphaCircleShow) {
			CGContextSetStrokeColorWithColor(context, [outlineColor CGColor]);
			CGContextSetLineWidth(context, 1.0/[[UIScreen mainScreen] scale]);
			CGContextStrokeEllipseInRect(context,cdmObj.circleRect);
		}

		// 7
        CGContextSetFillColorWithColor(context, [cdmObj.circleColor CGColor]);
		CGFloat offset = IS_RETINA ? 4.0 : 3.75;
		CGFloat diameter = IS_RETINA ? 7.0 : 7.0;
        CGContextFillEllipseInRect(context, CGRectMake(cdmObj.circleRect.origin.x + offset, cdmObj.circleRect.origin.y + offset, diameter, diameter));
    }
}

- (void)updateDates
{
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_dateMonth];
    _year = components.year;
    _month = components.month;
    NSDate *date = [NSDate date];
	components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    if ( _year == components.year && _month == components.month )
        _isCurrentMonth = YES;
    else
        _isCurrentMonth = NO;
    _today = components.day;
}

- (void)setDateMonth:(NSDate *)dateMonth
{
    _dateMonth = dateMonth;
    [self updateDates];
    [self reload];
}

- (void)addLineFromDate:(NSDate*)stDate endDate:(NSDate*)edDate toArray:(NSMutableArray*)array withColor:(UIColor*)color isStartMargin:(BOOL)isStartMargin isEndMargin:(BOOL)isEndMargin
{
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:stDate];
    NSInteger stDay = components.day;
	components = [calendar components:NSCalendarUnitDay fromDate:edDate];
    NSInteger edDay = components.day;
    BOOL unlinkedAtLastWeekday = NO;

	// TODO: Locale 고려한 년 월 표시
    NSString *startMonthStr = [A3DateHelper dateStringFromDate:stDate withFormat:@"yyyyMM"];
    NSString *curMonthStr = [A3DateHelper dateStringFromDate:_dateMonth withFormat:@"yyyyMM"];
    NSString *endMonthStr = [A3DateHelper dateStringFromDate:edDate withFormat:@"yyyyMM"];
    
    if ( [startMonthStr integerValue] < [curMonthStr integerValue] ) {
        stDay = 1;
    }
    if ( [endMonthStr integerValue] > [curMonthStr integerValue] ) {
        edDay = [A3DateHelper lastDaysOfMonth:_dateMonth];

        NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:edDate];
        dateComp.day = 1;
        NSDate *firstDateOfMonth = [calendar dateFromComponents:dateComp];
        dateComp = [calendar components:NSWeekdayCalendarUnit fromDate:firstDateOfMonth];
        
        if ([dateComp weekday] == 1) {
            unlinkedAtLastWeekday = YES;
        }
    }
    NSInteger stWeek = ((stDay-1) + _firstDayStartIndex) / 7;
    NSInteger stWeekday = ((stDay-1) + _firstDayStartIndex) % 7;
    NSInteger edWeek = ((edDay-1) + _firstDayStartIndex) / 7;
    NSInteger edWeekday = ((edDay-1) + _firstDayStartIndex) % 7;
    
    CGFloat lineHeight = 5.0;

	CGFloat diffFromSeparator = IS_IPHONE ? 22.0 : 25.0;
    if ( stWeek == edWeek ) {
        LineDisplayModel *ldpModel = [[LineDisplayModel alloc] init];
		CGFloat diffFromSeparator2 = diffFromSeparator /*+ ((stWeek > 1) ? 0.5 : 0.0) */;
        ldpModel.lineColor = color;
        ldpModel.lineRect = CGRectMake(stWeekday * _cellSize.width + (isStartMargin ? 2.0 : 0.0),
                                       (stWeek +1) * _cellSize.height - (_isSmallCell ? 6.0 :diffFromSeparator2) - lineHeight ,
                                       (edWeekday-stWeekday+1)*_cellSize.width-(isEndMargin ? 2.0 : 0.0),
                                       lineHeight);
        
        if (unlinkedAtLastWeekday && (ldpModel.lineRect.origin.x + ldpModel.lineRect.size.width) != CGRectGetWidth(self.frame)) {
            CGRect lineRect = ldpModel.lineRect;
            lineRect.size.width = lineRect.size.width + (CGRectGetWidth(self.frame) - (ldpModel.lineRect.origin.x + ldpModel.lineRect.size.width));
            ldpModel.lineRect = lineRect;
        }
        
        [array addObject:ldpModel];
    }
    else {
        NSInteger totalWeek = (edWeek - stWeek)+1;
        for (NSInteger i=0; i < totalWeek; i++) {
            LineDisplayModel *ldpModel = [[LineDisplayModel alloc] init];
            ldpModel.lineColor = color;
			CGFloat diffFromSeparator2 = diffFromSeparator + ((i > 1) ? 0.5 : 0.0);
            if ( i == 0 ) {
                ldpModel.lineRect = CGRectMake((stWeekday+i) * _cellSize.width + (isStartMargin ? 2.0 : 0.0),
                                               (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 : diffFromSeparator2) - lineHeight ,
                                               (8-stWeekday)*_cellSize.width,
                                               lineHeight);
            }
            else if ( i == (totalWeek-1) ) {
                ldpModel.lineRect = CGRectMake(0,
                                               (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 :diffFromSeparator2) - lineHeight ,
                                               (edWeekday+1)*_cellSize.width - (isEndMargin ? 2.0 : 0.0),
                                               lineHeight);
            }
            else {
                ldpModel.lineRect = CGRectMake(0,
                                               (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 :diffFromSeparator2) - lineHeight,
                                               7 * _cellSize.width,
                                               lineHeight);
            }
            [array addObject:ldpModel];
			FNLOG(@"%ld %@", (long)i, NSStringFromCGRect(ldpModel.lineRect));
        }
    }
//    FNLOG(@"%s  %@/%@(%@/%ld,%ld-%ld) %ld/%ld, %ld/%ld (%ld) %@",__FUNCTION__,stDate,edDate,_dateMonth,(long)_month,(long)stDay,(long)edDay,(long)stWeek,(long)stWeekday,(long)edWeek,(long)edWeekday,(long)firstDayStartIndex,array);
}

- (void)addCircleAtDay:(NSDate *)date color:(UIColor *)circleColor isAlphaCircleShow:(BOOL)isAlphaCircleShow alignment:(NSTextAlignment)alignment toArray:(NSMutableArray*)array
{
	NSDateComponents *components = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitDay fromDate:date];
	NSInteger day = components.day;
	
    NSInteger week = ((day-1) + _firstDayStartIndex) / 7;
    NSInteger weekday = ((day-1) + _firstDayStartIndex) % 7;
    
    CircleDisplayModel *cdModel = [[CircleDisplayModel alloc] init];
    cdModel.isAlphaCircleShow = isAlphaCircleShow;
    cdModel.circleColor = circleColor;
    
    CGSize circleSize = CGSizeMake(15.0, 15.0);
    CGFloat lineHeight = 5.0;
    if ( alignment == NSTextAlignmentLeft ) {
        cdModel.circleRect = CGRectMake(weekday*_cellSize.width, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    else if ( alignment == NSTextAlignmentRight ) {
        cdModel.circleRect = CGRectMake((weekday+1)*_cellSize.width - circleSize.width, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    else if ( alignment == NSTextAlignmentCenter ) {
        cdModel.circleRect = CGRectMake( (weekday+1)*_cellSize.width - _cellSize.width*0.5 - circleSize.width*0.5, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    [array addObject:cdModel];
//    FNLOG(@"%s %@ %d/%d %@",__FUNCTION__,date,week,weekday,NSStringFromCGRect(cdModel.circleRect));
}

- (void)reload
{
    if ( _dateMonth == nil ) {
        _dateMonth = [NSDate date];
		[self updateDates];
    }
	_numberOfWeeks = [A3DateHelper numberOfWeeksOfMonth:_dateMonth];
	NSInteger weekday = [A3DateHelper weekdayFromDate:[A3DateHelper dateMakeMonthFirstDayAtDate:_dateMonth]];
	_firstDayStartIndex = weekday-1;
	_lastDay = [A3DateHelper lastDaysOfMonth:_dateMonth];
	_lastDayIndex = _firstDayStartIndex + _lastDay - 1;
	NSDate *lastDate = [A3DateHelper dateByAddingDays:(_lastDay-1) fromDate:_dateMonth];
	_lastWeekday = [A3DateHelper weekdayFromDate:lastDate];

	_dateBGHeight = (IS_IPHONE ? 25.0 : 36.0);
	_periods = [_dataManager periodListInRangeWithMonth:_dateMonth accountID:self.dataManager.currentAccount.uniqueID];
	[_redLines removeAllObjects];
	[_greenLines removeAllObjects];
	[_yellowLines removeAllObjects];
	[_circleArray removeAllObjects];

	for (LadyCalendarPeriod *period in _periods) {
		LadyCalendarPeriod *nextPeriod = [_dataManager nextPeriodFromDate:period.startDate];
		NSDate *nextStartDate = ( nextPeriod ? nextPeriod.startDate : [A3DateHelper dateByAddingDays:[period.cycleLength integerValue] fromDate:period.startDate] );
		NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:nextStartDate];

		NSDate *pregnantStartDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
		NSDate *pregnantEndDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];
		NSDate *prevOvulationDate = [A3DateHelper dateByAddingDays:-1 fromDate:ovulationDate];
		NSDate *nextOvulationDate = [A3DateHelper dateByAddingDays:1 fromDate:ovulationDate];

		CGFloat alphaForRed = [period.isPredict boolValue] ? 0.4 : 1.0;
		CGFloat alpha = !nextPeriod || [nextPeriod.isPredict boolValue] ? 0.4 : 1.0;
		UIColor *redColor = [UIColor colorWithRed:252.0/255.0 green:96.0/255.0 blue:66.0/255.0 alpha:alphaForRed];
		UIColor *greenColor = [UIColor colorWithRed:44.0/255.0 green:201.0/255.0 blue:144.0/255.0 alpha:alpha];
		UIColor *yellowColor = [UIColor colorWithRed:227.0/255.0 green:186.0/255.0 blue:5.0/255.0 alpha:alpha];

		NSDateComponents *startDateComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:period.startDate];
		NSDateComponents *endDateComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:period.endDate];
		NSDateComponents *prevOvulationComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:prevOvulationDate];
		NSDateComponents *pregnantStartDateComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:pregnantStartDate];
		if ( startDateComponents.month == _month || endDateComponents.month == _month ) {
			[self addLineFromDate:period.startDate
                          endDate:period.endDate
                          toArray:_redLines
                        withColor:redColor
                    isStartMargin:YES
                      isEndMargin:YES];
            
			if ( startDateComponents.month == _month )
				[self addCircleAtDay:period.startDate color:[UIColor colorWithRed:252.0 / 255.0 green:96.0 / 255.0 blue:66.0 / 255.0 alpha:alphaForRed] isAlphaCircleShow:NO alignment:NSTextAlignmentLeft toArray:_circleArray];
			if ( endDateComponents.month == _month )
				[self addCircleAtDay:period.endDate color:[UIColor colorWithRed:252.0 / 255.0 green:96.0 / 255.0 blue:66.0 / 255.0 alpha:alphaForRed] isAlphaCircleShow:NO alignment:NSTextAlignmentRight toArray:_circleArray];
		}

		if (pregnantStartDateComponents.month == _month || prevOvulationComponents.month == _month ) {
			[self addLineFromDate:pregnantStartDate endDate:prevOvulationDate toArray:_greenLines withColor:greenColor isStartMargin:YES isEndMargin:NO];
			if (pregnantStartDateComponents.month == _month )
				[self addCircleAtDay:pregnantStartDate color:[UIColor colorWithRed:44.0 / 255.0 green:201.0 / 255.0 blue:144.0 / 255.0 alpha:alpha] isAlphaCircleShow:NO alignment:NSTextAlignmentLeft toArray:_circleArray];
		}
		NSDateComponents *nextOvulationComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:nextOvulationDate];
		NSDateComponents *pregnantEndComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:pregnantEndDate];
		if (nextOvulationComponents.month == _month || pregnantEndComponents.month == _month ) {
			[self addLineFromDate:nextOvulationDate
                          endDate:pregnantEndDate
                          toArray:_greenLines
                        withColor:greenColor
                    isStartMargin:NO
                      isEndMargin:nextOvulationComponents.month != pregnantEndComponents.month ? NO : YES];
            
			if (pregnantEndComponents.month == _month )
				[self addCircleAtDay:pregnantEndDate color:[UIColor colorWithRed:44.0 / 255.0 green:201.0 / 255.0 blue:144.0 / 255.0 alpha:alpha] isAlphaCircleShow:NO alignment:NSTextAlignmentRight toArray:_circleArray];
		}
		NSDateComponents *ovulationComponents = [[[A3AppDelegate instance] calendar] components:NSCalendarUnitMonth fromDate:ovulationDate];
		if ( ovulationComponents.month == _month ) {
			[self addLineFromDate:ovulationDate endDate:ovulationDate toArray:_yellowLines withColor:yellowColor isStartMargin:NO isEndMargin:NO];
			[self addCircleAtDay:ovulationDate color:[UIColor colorWithRed:227.0 / 255.0 green:186.0 / 255.0 blue:5.0 / 255.0 alpha:alpha] isAlphaCircleShow:YES alignment:NSTextAlignmentCenter toArray:_circleArray];
		}
	}
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    NSInteger y = pos.y / _cellSize.height;
    NSInteger x = pos.x / _cellSize.width;
    NSInteger day = y * 7 + (x - _firstDayStartIndex) + 1;
    
    if ( day < 1 || day > _lastDay )
        return;
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDay:)])
        [self.delegate calendarView:self didSelectDay:day];
}

@end
