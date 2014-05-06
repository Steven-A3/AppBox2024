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
#import "LadyCalendarAccount.h"
#import "LadyCalendarPeriod.h"

@implementation LineDisplayModel

- (id)init
{
    self = [super init];
    if( self ){
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
    if( self ){
        self.circleRect = CGRectMake(0, 0, 15.0, 15.0);
        self.circleColor = [UIColor whiteColor];
        self.isAlphaCircleShow = NO;
    }
    
    return self;
}

@end

@interface A3LadyCalendarCalendarView ()
@property (assign, nonatomic) UIFont *dateFont;
@property (strong, nonatomic) UIColor *dateTextColor;
@property (strong, nonatomic) UIColor *weekendTextColor;
@property (readonly, nonatomic) NSInteger year;
@property (readonly, nonatomic) NSInteger month;
@end

@implementation A3LadyCalendarCalendarView {
	NSInteger numberOfWeeks;
	NSInteger firstDayStartIndex;
	NSInteger lastDayIndex;
	NSInteger lastWeekday;
	NSInteger lastDay;

	NSInteger dateBGHeight;
	NSArray *periods;
	__strong NSMutableArray *redLines;
	__strong NSMutableArray *greenLines;
	__strong NSMutableArray *yellowLines;
	__strong NSMutableArray *circleArray;
	__block dispatch_queue_t dQueue;
	BOOL isCurrentMonth;
	NSInteger today;
}

- (void)awakeFromNib
{
	self.dateFont = [UIFont systemFontOfSize:(IS_IPHONE ? 14.0 : 18.0)];
    self.dateTextColor = [UIColor blackColor];
    self.weekendTextColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    CGSizeMake(0, 0.5);
	redLines = [NSMutableArray array];
    greenLines = [NSMutableArray array];
    yellowLines = [NSMutableArray array];
    circleArray = [NSMutableArray array];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if( self.dateMonth == nil )
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

    NSInteger index = 0;
    for(NSInteger y=0; y < numberOfWeeks; y++){
        CGContextSetShouldAntialias(context , YES);
        for(NSInteger x=0; x < 7; x++,index++){
            if( index > lastDayIndex )  continue;
            if( index < firstDayStartIndex ){
                xPos += _cellSize.width;
                continue;
            }
            NSInteger day = index - firstDayStartIndex + 1;
            NSString *str = (index == firstDayStartIndex ? [A3DateHelper dateStringFromDate:_dateMonth withFormat:@"MMM d"] : [NSString stringWithFormat:@"%ld",(long)(index - firstDayStartIndex + 1)]);
            if( isCurrentMonth && today == day){
                CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor]);
                CGContextFillRect(context, CGRectMake(xPos, yPos, _cellSize.width, dateBGHeight));
                [str drawInRect:CGRectMake(xPos, yPos+5.0, _cellSize.width, dateBGHeight-5.0) withAttributes:todayTextAttr];
            }
            else{
                [str drawInRect:CGRectMake(xPos, yPos+5.0, _cellSize.width, dateBGHeight-5.0) withAttributes:(x==0 || x==6 ? weekendTextAttr :textAttr)];
            }
            xPos += _cellSize.width;
        }
        yPos += _cellSize.height;
        xPos = 0.0;
        
//        NSLog(@"%s yPos:%f, weeks:%d/%d,height:%f,%@",__FUNCTION__,yPos,y+1,numberOfWeeks,_cellSize.height,NSStringFromCGRect(self.frame));
        CGContextSetShouldAntialias(context , NO);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor]);
        CGContextMoveToPoint(context, xPos, yPos );
        CGContextAddLineToPoint(context,( (y+1) == numberOfWeeks ? xPos + lastWeekday*_cellSize.width : rect.size.width), yPos);
        CGContextSetLineWidth(context, 1.0 / [[UIScreen mainScreen] scale]);
        CGContextStrokePath(context);
        yPos += 0.5;
    }
    
    // 빨간선을 그린다.
    for(LineDisplayModel *ldmObj in redLines){
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    
    for(LineDisplayModel *ldmObj in greenLines){
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    
    
    for(LineDisplayModel *ldmObj in yellowLines){
        CGContextSetFillColorWithColor(context, [ldmObj.lineColor CGColor]);
        CGContextFillRect(context, ldmObj.lineRect);
    }
    
    // 라인을 그린다.
    UIColor *outlineColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    UIColor *outCircleColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    CGContextSetShouldAntialias(context , YES);
    for(CircleDisplayModel *cdmObj in circleArray){
        if( cdmObj.isAlphaCircleShow ){
            [outCircleColor setFill];
            CGContextFillEllipseInRect(context,CGRectMake(cdmObj.circleRect.origin.x - cdmObj.circleRect.size.width*0.25, cdmObj.circleRect.origin.y - cdmObj.circleRect.size.height*0.25, cdmObj.circleRect.size.width*1.5, cdmObj.circleRect.size.height*1.5));
        }
        
        [[UIColor whiteColor] setFill];
        CGContextFillEllipseInRect(context, cdmObj.circleRect);
        CGContextSetStrokeColorWithColor(context, [outlineColor CGColor]);
        CGContextSetLineWidth(context, 1.0/[[UIScreen mainScreen] scale]);
        CGContextStrokeEllipseInRect(context,cdmObj.circleRect);
        
        CGContextSetFillColorWithColor(context, [cdmObj.circleColor CGColor]);
        CGContextFillEllipseInRect(context, CGRectMake(cdmObj.circleRect.origin.x + cdmObj.circleRect.size.width*0.25, cdmObj.circleRect.origin.y + cdmObj.circleRect.size.height*0.25, cdmObj.circleRect.size.width*0.5, cdmObj.circleRect.size.height*0.5));
    }
}

- (void)updateDates
{
    _year = [A3DateHelper yearFromDate:_dateMonth];
    _month = [A3DateHelper monthFromDate:_dateMonth];
    NSDate *date = [NSDate date];
    if( _year == [A3DateHelper yearFromDate:date] && _month == [A3DateHelper monthFromDate:date] )
        isCurrentMonth = YES;
    else
        isCurrentMonth = NO;
    today = [A3DateHelper dayFromDate:date];
}

- (void)setDateMonth:(NSDate *)dateMonth
{
    _dateMonth = dateMonth;
    [self updateDates];
    [self reload];
}

- (void)addLineFromDate:(NSDate*)stDate endDate:(NSDate*)edDate toArray:(NSMutableArray*)array withColor:(UIColor*)color isStartMargin:(BOOL)isStartMargin isEndMargin:(BOOL)isEndMargin
{
    NSInteger stDay = [A3DateHelper dayFromDate:stDate];
    NSInteger edDay = [A3DateHelper dayFromDate:edDate];
    
    NSString *startMonthStr = [A3DateHelper dateStringFromDate:stDate withFormat:@"yyyyMM"];
    NSString *curMonthStr = [A3DateHelper dateStringFromDate:_dateMonth withFormat:@"yyyyMM"];
    NSString *endMonthStr = [A3DateHelper dateStringFromDate:edDate withFormat:@"yyyyMM"];
    
    if( [startMonthStr integerValue] < [curMonthStr integerValue] ){
        stDay = 1;
    }
    if( [endMonthStr integerValue] > [curMonthStr integerValue] ){
        edDay = [A3DateHelper lastDaysOfMonth:_dateMonth];
    }
    NSInteger stWeek = ((stDay-1) + firstDayStartIndex) / 7;
    NSInteger stWeekday = ((stDay-1) + firstDayStartIndex) % 7;
    NSInteger edWeek = ((edDay-1) + firstDayStartIndex) / 7;
    NSInteger edWeekday = ((edDay-1) + firstDayStartIndex) % 7;
    
    CGFloat lineHeight = 5.0;
    
    if( stWeek == edWeek ){
        LineDisplayModel *ldpModel = [[LineDisplayModel alloc] init];
        ldpModel.lineColor = color;
        ldpModel.lineRect = CGRectMake(stWeekday * _cellSize.width+(isStartMargin ? 2.0 : 0.0), (stWeek +1) * _cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight , (edWeekday-stWeekday+1)*_cellSize.width-(isEndMargin ? 2.0 : 0.0), lineHeight);
        [array addObject:ldpModel];
    }
    else{

        NSInteger totalWeek = (edWeek - stWeek)+1;
        for(NSInteger i=0; i < totalWeek; i++){
            LineDisplayModel *ldpModel = [[LineDisplayModel alloc] init];
            ldpModel.lineColor = color;
            if( i == 0 ){
                ldpModel.lineRect = CGRectMake((stWeekday+i) * _cellSize.width + (isStartMargin ? 2.0 : 0.0), (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight , (8-stWeekday)*_cellSize.width, lineHeight);
            }
            else if( i == (totalWeek-1) ){
                ldpModel.lineRect = CGRectMake(0, (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight , (edWeekday+1)*_cellSize.width - (isEndMargin ? 2.0 : 0.0), lineHeight);
            }
            else{
                ldpModel.lineRect = CGRectMake(0, (stWeek+i +1) * _cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight, 7 * _cellSize.width, lineHeight);
            }
            [array addObject:ldpModel];
//            NSLog(@"%s %d %@",__FUNCTION__,i,NSStringFromCGRect(ldpModel.lineRect));
        }
    }
    NSLog(@"%s  %@/%@(%@/%ld,%ld-%ld) %ld/%ld, %ld/%ld (%ld) %@",__FUNCTION__,stDate,edDate,_dateMonth,(long)_month,(long)stDay,(long)edDay,(long)stWeek,(long)stWeekday,(long)edWeek,(long)edWeekday,(long)firstDayStartIndex,array);
}

- (void)addCircleAtDay:(NSDate *)date color:(UIColor *)circleColor isAlphaCircleShow:(BOOL)isAlphaCircleShow alignment:(NSTextAlignment)alignment toArray:(NSMutableArray*)array
{
    NSInteger day = [A3DateHelper dayFromDate:date];
//    if( [A3DateHelper monthFromDate:date] != _month )
//        return;
    
    NSInteger week = ((day-1) + firstDayStartIndex) / 7;
    NSInteger weekday = ((day-1) + firstDayStartIndex) % 7;
    
    CircleDisplayModel *cdModel = [[CircleDisplayModel alloc] init];
    cdModel.isAlphaCircleShow = isAlphaCircleShow;
    cdModel.circleColor = circleColor;
    
    CGSize circleSize = CGSizeMake(15.0, 15.0);
    CGFloat lineHeight = 5.0;
    if( alignment == NSTextAlignmentLeft ){
        cdModel.circleRect = CGRectMake(weekday*_cellSize.width, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    else if( alignment == NSTextAlignmentRight ){
        cdModel.circleRect = CGRectMake((weekday+1)*_cellSize.width - circleSize.width, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    else if( alignment == NSTextAlignmentCenter ){
        cdModel.circleRect = CGRectMake( (weekday+1)*_cellSize.width - _cellSize.width*0.5 - circleSize.width*0.5, (week+1)*_cellSize.height - (_isSmallCell ? 6.0 :(IS_IPHONE ? 22.0 : 25.0)) - lineHeight*0.5 - circleSize.height*0.5, circleSize.width, circleSize.height);
    }
    [array addObject:cdModel];
//    NSLog(@"%s %@ %d/%d %@",__FUNCTION__,date,week,weekday,NSStringFromCGRect(cdModel.circleRect));
}

- (void)reload
{
    if( _dateMonth == nil ){
        _dateMonth = [NSDate date];
    }
    [self updateDates];
	numberOfWeeks = [A3DateHelper numberOfWeeksOfMonth:_dateMonth];
	NSInteger weekday = [A3DateHelper weekdayFromDate:[A3DateHelper dateMakeMonthFirstDayAtDate:_dateMonth]];
	firstDayStartIndex = weekday-1;
	lastDay = [A3DateHelper lastDaysOfMonth:_dateMonth];
	lastDayIndex = firstDayStartIndex + lastDay - 1;
	NSDate *lastDate = [A3DateHelper dateByAddingDays:(lastDay-1) fromDate:_dateMonth];
	lastWeekday = [A3DateHelper weekdayFromDate:lastDate];

	dateBGHeight = (IS_IPHONE ? 25.0 : 36.0);
	periods = [_dataManager periodListInRangeWithMonth:_dateMonth accountID:self.dataManager.currentAccount.uniqueID];
	NSLog(@"%s %@",__FUNCTION__,periods);
	[redLines removeAllObjects];
	[greenLines removeAllObjects];
	[yellowLines removeAllObjects];
	[circleArray removeAllObjects];

	for(LadyCalendarPeriod *period in periods){
		NSLog(@"%s cur month:%@ period %@ / %@",__FUNCTION__,_dateMonth,period.startDate,period.endDate);
		LadyCalendarPeriod *nextPeriod = [_dataManager nextPeriodFromDate:period.startDate accountID:_dataManager.currentAccount.uniqueID];
		NSDate *nextStartDate = ( nextPeriod ? nextPeriod.startDate : [A3DateHelper dateByAddingDays:[period.cycleLength integerValue] fromDate:period.startDate] );
		NSDate *ovulationDate = [A3DateHelper dateByAddingDays:-14 fromDate:nextStartDate];

		NSDate *pregStDate = [A3DateHelper dateByAddingDays:-4 fromDate:ovulationDate];
		NSDate *pregEdDate = [A3DateHelper dateByAddingDays:5 fromDate:ovulationDate];
		NSDate *prevOvuDate = [A3DateHelper dateByAddingDays:-1 fromDate:ovulationDate];
		NSDate *nextOvDate = [A3DateHelper dateByAddingDays:1 fromDate:ovulationDate];

		UIColor *redColor = [UIColor colorWithRed:252.0/255.0 green:96.0/255.0 blue:66.0/255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0];
		UIColor *greenColor = [UIColor colorWithRed:44.0/255.0 green:201.0/255.0 blue:144.0/255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0];
		UIColor *yellowColor = [UIColor colorWithRed:238.0/255.0 green:230.0/255.0 blue:87.0/255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0];

		NSLog(@"%s menstural date %@",__FUNCTION__,_dateMonth);
		if( [A3DateHelper monthFromDate:period.startDate] == _month || [A3DateHelper monthFromDate:period.endDate] == _month ){
			[self addLineFromDate:period.startDate endDate:period.endDate toArray:redLines withColor:redColor isStartMargin:YES isEndMargin:YES];
			if( [A3DateHelper monthFromDate:period.startDate] == _month )
				[self addCircleAtDay:period.startDate color:[UIColor colorWithRed:252.0 / 255.0 green:96.0 / 255.0 blue:66.0 / 255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0] isAlphaCircleShow:NO alignment:NSTextAlignmentLeft toArray:circleArray];
			if( [A3DateHelper monthFromDate:period.endDate] == _month )
				[self addCircleAtDay:period.endDate color:[UIColor colorWithRed:252.0 / 255.0 green:96.0 / 255.0 blue:66.0 / 255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0] isAlphaCircleShow:NO alignment:NSTextAlignmentRight toArray:circleArray];
		}

		NSLog(@"%s preg date %@",__FUNCTION__,_dateMonth);
		if( [A3DateHelper monthFromDate:pregStDate] == _month || [A3DateHelper monthFromDate:prevOvuDate] == _month ){
			[self addLineFromDate:pregStDate endDate:prevOvuDate toArray:greenLines withColor:greenColor isStartMargin:YES isEndMargin:NO];
			if( [A3DateHelper monthFromDate:pregStDate] == _month )
				[self addCircleAtDay:pregStDate color:[UIColor colorWithRed:44.0 / 255.0 green:201.0 / 255.0 blue:144.0 / 255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0] isAlphaCircleShow:NO alignment:NSTextAlignmentLeft toArray:circleArray];
		}
		if( [A3DateHelper monthFromDate:nextOvDate] == _month || [A3DateHelper monthFromDate:pregEdDate] == _month ){
			[self addLineFromDate:nextOvDate endDate:pregEdDate toArray:greenLines withColor:greenColor isStartMargin:NO isEndMargin:YES];
			if( [A3DateHelper monthFromDate:pregEdDate] == _month )
				[self addCircleAtDay:pregEdDate color:[UIColor colorWithRed:44.0 / 255.0 green:201.0 / 255.0 blue:144.0 / 255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0] isAlphaCircleShow:NO alignment:NSTextAlignmentRight toArray:circleArray];
		}
		NSLog(@"%s ovulation date %@/%@",__FUNCTION__,_dateMonth,ovulationDate);
		if( [A3DateHelper monthFromDate:ovulationDate] == _month ){
			[self addLineFromDate:ovulationDate endDate:ovulationDate toArray:yellowLines withColor:yellowColor isStartMargin:NO isEndMargin:NO];
			[self addCircleAtDay:ovulationDate color:[UIColor colorWithRed:238.0 / 255.0 green:230.0 / 255.0 blue:87.0 / 255.0 alpha:[period.isPredict boolValue] ? 0.4 : 1.0] isAlphaCircleShow:YES alignment:NSTextAlignmentCenter toArray:circleArray];
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
    NSInteger day = y * 7 + (x - firstDayStartIndex) + 1;
    
    if( day < 1 || day > lastDay )
        return;
    
    if( self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDay:)])
        [self.delegate calendarView:self didSelectDay:day];
}

@end
