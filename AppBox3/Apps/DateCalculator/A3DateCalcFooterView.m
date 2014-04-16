//
//  A3DateCalcFooterView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcFooterView.h"
#import "A3DateKeyboardViewController.h"

#define kDefaultButtonColor     [UIColor colorWithRed:193.0/255.0 green:196.0/255.0 blue:200.0/255.0 alpha:1.0]
#define kSelectedButtonColor    [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:250.0/255.0 alpha:1.0]

@interface A3DateCalcFooterView ()
@property (weak, nonatomic) IBOutlet UIView *outputBackView;
@end


@implementation A3DateCalcFooterView
{
    UITextField *selectedTextField;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    
    return self;
}

-(void)layoutSubviews
{
    self.addModeButton.isAddButton = YES;
    self.subModeButton.isAddButton = NO;
    [super layoutSubviews];
    
    // Add Sub 버튼 부분
    if (IS_IPHONE) {
        CGRect rect = self.frame;
        rect.size.height = 172.0;
        self.frame = rect;
        NSLog(@"ori Y: %f", self.frame.origin.y);
        
        rect = self.addModeButton.frame;
        rect.size.height = 50.0;
        self.addModeButton.frame = rect;
        self.addModeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        rect = self.subModeButton.frame;
        rect.size.height = 50.0;
        self.subModeButton.frame = rect;
        self.subModeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        rect = self.outputBackView.frame;
        rect.origin.y = 70.0;
        self.outputBackView.frame = rect;
    }
    else {
        CGRect rect = self.frame;
        rect.size.height = 204.0;
        self.frame = rect;
        NSLog(@"ori Y: %f", self.frame.origin.y);
        
        rect = self.addModeButton.frame;
        rect.origin.x = 0.0;
        rect.size.width = self.bounds.size.width / 2.0;
        rect.size.height = 50.0;
        self.addModeButton.frame = rect;
        self.addModeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        rect = self.subModeButton.frame;
        rect.origin.x = self.bounds.size.width / 2.0;
        rect.size.width = self.bounds.size.width / 2.0;
        rect.size.height = 50.0;
        self.subModeButton.frame = rect;
        self.subModeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        rect = self.outputBackView.frame;
        rect.origin.y = 86.0;
        self.outputBackView.frame = rect;
    }
    
    // 하단 날짜 입력 부분
    if (IS_IPAD && IS_LANDSCAPE) {
        CGFloat width = self.bounds.size.width;
        CGFloat lWidth = width/3/2;
        CGRect rect;
        rect = _yearTextField.frame;
        rect.size.width = lWidth;
        _yearTextField.frame = rect;
        rect = _monthTextField.frame;
        rect.size.width = lWidth;
        _monthTextField.frame = rect;
        rect = _dayTextField.frame;
        rect.size.width = lWidth;
        _dayTextField.frame = rect;
        
        rect = _yearLabel.frame;
        rect.size.width = lWidth;
        _yearLabel.frame = rect;
        rect = _monthLabel.frame;
        rect.size.width = lWidth;
        _monthLabel.frame = rect;
        rect = _dayLabel.frame;
        rect.size.width = lWidth;
        _dayLabel.frame = rect;
        
        CGFloat centerOffset = width / 3 / 2 / 2;
        [_yearTextField setCenter:CGPointMake(ceilf(width / 3 / 2 - centerOffset), ceilf(_outputBackView.bounds.size.height / 2))];
        [_monthTextField setCenter:CGPointMake(ceilf(width / 2 - centerOffset), ceilf(_outputBackView.bounds.size.height / 2))];
        [_dayTextField setCenter:CGPointMake(ceilf(width - (width / 3 / 2) - centerOffset), ceilf(_outputBackView.bounds.size.height / 2))];

        [_yearLabel setCenter:CGPointMake(ceilf(width / 3 / 2 + centerOffset + 5), ceilf(_outputBackView.bounds.size.height / 2))];
        [_monthLabel setCenter:CGPointMake(ceilf(width / 2 + centerOffset + 5), ceilf(_outputBackView.bounds.size.height / 2))];
        [_dayLabel setCenter:CGPointMake(ceilf(width - (width / 3 / 2) + centerOffset + 5), ceilf(_outputBackView.bounds.size.height / 2))];
        
        [_yearTextField setTextAlignment:NSTextAlignmentRight];
        [_monthTextField setTextAlignment:NSTextAlignmentRight];
        [_dayTextField setTextAlignment:NSTextAlignmentRight];
        
        [_yearLabel setTextAlignment:NSTextAlignmentLeft];
        [_monthLabel setTextAlignment:NSTextAlignmentLeft];
        [_dayLabel setTextAlignment:NSTextAlignmentLeft];
    }
    else {
        CGFloat width = self.bounds.size.width;
        CGRect rect;
        rect = _yearTextField.frame;
        rect.size.width = width / 3;
        _yearTextField.frame = rect;
        rect = _monthTextField.frame;
        rect.size.width = width / 3;
        _monthTextField.frame = rect;
        rect = _dayTextField.frame;
        rect.size.width = width / 3;
        _dayTextField.frame = rect;
        
        [_yearTextField setCenter:CGPointMake(ceilf(width / 3 / 2), ceilf(_outputBackView.bounds.size.height / 2))];
        [_monthTextField setCenter:CGPointMake(ceilf(width / 2), ceilf(_outputBackView.bounds.size.height / 2))];
        [_dayTextField setCenter:CGPointMake(ceilf(width - (width / 3 / 2)), ceilf(_outputBackView.bounds.size.height / 2))];

        [_yearLabel setCenter:CGPointMake(ceilf(width / 3 / 2), ceilf(_yearTextField.frame.origin.y+_yearTextField.frame.size.height + (_yearLabel.bounds.size.height / 2)))];
        [_monthLabel setCenter:CGPointMake(ceilf(width / 2), ceilf(_monthTextField.frame.origin.y+_monthTextField.frame.size.height + (_monthLabel.bounds.size.height / 2)))];
        [_dayLabel setCenter:CGPointMake(ceilf(width - (width / 3 / 2)), ceilf(_dayTextField.frame.origin.y+_dayTextField.frame.size.height + (_dayLabel.bounds.size.height / 2)))];
        
        [_yearTextField setTextAlignment:NSTextAlignmentCenter];
        [_monthTextField setTextAlignment:NSTextAlignmentCenter];
        [_dayTextField setTextAlignment:NSTextAlignmentCenter];
        
        [_yearLabel setTextAlignment:NSTextAlignmentCenter];
        [_monthLabel setTextAlignment:NSTextAlignmentCenter];
        [_dayLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    _yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

-(void)setOffsetDate:(NSDate *)aDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:aDate];
    self.yearTextField.text = comp.year == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long)comp.year];
    self.monthTextField.text = comp.month == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long)comp.month];
    self.dayTextField.text = comp.day == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long)comp.day];
}

-(void)setOffsetDateComp:(NSDateComponents *)aDateComp
{
    self.yearTextField.text = aDateComp.year == 0 ? @"" : [NSString stringWithFormat:@"%ld", labs( (long)aDateComp.year )];
    self.monthTextField.text = aDateComp.month == 0 ? @"" : [NSString stringWithFormat:@"%ld", labs( (long)aDateComp.month )];
    self.dayTextField.text = aDateComp.day == 0 ? @"" : [NSString stringWithFormat:@"%ld", labs( (long)aDateComp.day )];
}
@end
