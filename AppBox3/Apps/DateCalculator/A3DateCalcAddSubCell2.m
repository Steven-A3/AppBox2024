//
//  A3DateCalcAddSubCell2.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcAddSubCell2.h"
#import "A3AppDelegate.h"
#import "A3DateMainTableViewController.h"
#import "A3SyncManager.h"
#import "A3UserDefaults.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@implementation A3DateCalcAddSubCell2

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    return self;
}

- (void)awakeFromNib {
	self.yearLabel.text = NSLocalizedString(@"Year(s)", nil);
	self.monthLabel.text = NSLocalizedString(@"Month(s)", nil);
	self.dayLabel.text = NSLocalizedString(@"Day(s)", nil);

	if (IS_IPHONE) {
		[_yearLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.left).with.offset(320 / 3 / 2);
		}];
		[_monthLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
		}];
		[_dayLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.right).with.offset(- 320 / 3 / 2);
		}];
	}
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 하단 날짜 입력 부분
    if (IS_IPAD && IS_LANDSCAPE) {
        CGFloat width = self.bounds.size.width;
        CGFloat lWidth = ceilf(width / 3 / 2);
        CGRect rect;
        rect = _yearTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
        _yearTextField.frame = rect;
        rect = _monthTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
        _monthTextField.frame = rect;
        rect = _dayTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
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
        
        CGFloat centerOffset = width/3/2/2;
        [_yearTextField setCenter:CGPointMake(ceilf(width / 3 / 2 - centerOffset), ceilf(self.bounds.size.height / 2))];
        [_monthTextField setCenter:CGPointMake(ceilf(width / 2 - centerOffset), ceilf(self.bounds.size.height / 2))];
        [_dayTextField setCenter:CGPointMake(ceilf(width - (width / 3 / 2) - centerOffset), ceilf(self.bounds.size.height / 2))];
        
        [_yearLabel setCenter:CGPointMake(ceilf(width / 3 / 2 + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        [_monthLabel setCenter:CGPointMake(ceilf(width / 2 + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        [_dayLabel setCenter:CGPointMake(ceilf(width - (width / 3 / 2) + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        
        [_yearTextField setTextAlignment:NSTextAlignmentRight];
        [_monthTextField setTextAlignment:NSTextAlignmentRight];
        [_dayTextField setTextAlignment:NSTextAlignmentRight];
        
        [_yearLabel setTextAlignment:NSTextAlignmentLeft];
        [_monthLabel setTextAlignment:NSTextAlignmentLeft];
        [_dayLabel setTextAlignment:NSTextAlignmentLeft];
    }
    else if (IS_IPAD && IS_PORTRAIT) {
        CGFloat width = self.bounds.size.width;
        CGFloat lWidth = ceilf(width / 3 / 2);
        CGRect rect;
        rect = _yearTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
        _yearTextField.frame = rect;
        rect = _monthTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
        _monthTextField.frame = rect;
        rect = _dayTextField.frame;
        rect.size.width = lWidth;
        rect.size.height = self.bounds.size.height;
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
        
        CGFloat centerOffset = width/3/2/2;
        [_yearTextField setCenter:CGPointMake(ceilf(width / 3 / 2 - centerOffset), ceilf(self.bounds.size.height / 2))];
        [_monthTextField setCenter:CGPointMake(ceilf(width / 2 - centerOffset), ceilf(self.bounds.size.height / 2))];
        [_dayTextField setCenter:CGPointMake(ceilf(width - (width / 3 / 2) - centerOffset), ceilf(self.bounds.size.height / 2))];
        
        [_yearLabel setCenter:CGPointMake(ceilf(width / 3 / 2 + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        [_monthLabel setCenter:CGPointMake(ceilf(width / 2 + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        [_dayLabel setCenter:CGPointMake(ceilf(width - (width / 3 / 2) + centerOffset + 5), ceilf(self.bounds.size.height / 2))];
        
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
//        rect = _yearTextField.frame;
//        rect.size.width = ceilf(width / 3);
////        rect.size.height = self.bounds.size.height;
//        _yearTextField.frame = rect;
//        
//        rect = _monthTextField.frame;
//        rect.size.width = ceilf(width / 3);
////        rect.size.height = self.bounds.size.height;
//        _monthTextField.frame = rect;
//        
//        rect = _dayTextField.frame;
//        rect.size.width = ceilf(width / 3);
////        rect.size.height = self.bounds.size.height;
//        _dayTextField.frame = rect;
//        
//        [_yearTextField setCenter:CGPointMake(ceilf(width / 3 / 2), ceilf(15.0 + _yearTextField.frame.size.height / 2.0))];
//        [_monthTextField setCenter:CGPointMake(ceilf(width / 2), ceilf(15.0 + _monthTextField.frame.size.height / 2.0))];
//        [_dayTextField setCenter:CGPointMake(ceilf(width - (width / 3 / 2)), ceilf(15.0 + _dayTextField.frame.size.height / 2.0))];
//        
//        [_yearLabel setCenter:CGPointMake(ceilf(width / 3 / 2), ceilf(_yearTextField.frame.origin.y + _yearTextField.frame.size.height + (_yearLabel.bounds.size.height / 2)))];
//        [_monthLabel setCenter:CGPointMake(ceilf(width / 2), ceilf(_monthTextField.frame.origin.y + _monthTextField.frame.size.height + (_monthLabel.bounds.size.height / 2)))];
//        [_dayLabel setCenter:CGPointMake(ceilf(width - (width / 3 / 2)), ceilf(_dayTextField.frame.origin.y + _dayTextField.frame.size.height + (_dayLabel.bounds.size.height / 2)))];
        
        
        rect = _yearTextField.frame;
        rect.origin.x = 0;
        rect.origin.y = 15;
        rect.size.width = ceilf(width / 3);
        rect.size.height = CGRectGetHeight(self.bounds) - 15.0;
        _yearTextField.frame = rect;
        
        rect = _monthTextField.frame;
        rect.origin.x = ceilf(width / 3);
        rect.origin.y = 15;
        rect.size.width = ceilf(width / 3);
        rect.size.height = CGRectGetHeight(self.bounds) - 15.0;
        _monthTextField.frame = rect;
        
        rect = _dayTextField.frame;
        rect.origin.x = ceilf(width / 3) * 2;
        rect.origin.y = 15;
        rect.size.width = ceilf(width / 3);
        rect.size.height = CGRectGetHeight(self.bounds) - 15.0;
        _dayTextField.frame = rect;
        
        _yearTextField.textAlignment = NSTextAlignmentCenter;
        _monthTextField.textAlignment = NSTextAlignmentCenter;
        _dayTextField.textAlignment = NSTextAlignmentCenter;
        _yearTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _monthTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        _dayTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    }
    
    // Set Font
    if (IS_IPHONE) {
        _yearLabel.font = [UIFont systemFontOfSize:13];
        _monthLabel.font = [UIFont systemFontOfSize:13];
        _dayLabel.font = [UIFont systemFontOfSize:13];
    }
    else {
        _yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _monthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _dayLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }
    
    [super layoutSubviews];
    
    if (IS_RETINA) {
        CGRect rect;
        rect = _topLineView.bounds;
        rect.size.height = 0.5;
        _topLineView.bounds = rect;
        rect = _sep1LineView.bounds;
        rect.size.width = 0.5;
        _sep1LineView.bounds = rect;
        rect = _sep2LineView.bounds;
        rect.size.width = 0.5;
        _sep2LineView.bounds = rect;
        rect = _bottomLineView.bounds;
        rect.size.height = 0.5;
        _bottomLineView.bounds = rect;
    }
}

+(NSDateComponents *)dateComponentBySavedText {
    NSDateComponents * date = [NSDateComponents new];
    NSString *year = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsSavedYear];
    NSString *month = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsSavedMonth];
    NSString *day = [[A3SyncManager sharedSyncManager] objectForKey:A3DateCalcDefaultsSavedDay];
    date.year = year.integerValue;
    date.month = month.integerValue;
    date.day = day.integerValue;
    if (!year && !month && !day) {
        date.month = 1;
    }
    
    date.hour = 0;
    
    return date;
}

-(void)saveInputedTextField:(UITextField *)textField {
	NSString *key, *value;
    if (textField == _yearTextField) {
		key = A3DateCalcDefaultsSavedYear;
		value = _yearTextField.text;
    }
    else if (textField == _monthTextField) {
		key = A3DateCalcDefaultsSavedMonth;
		value = _monthTextField.text;
    }
    else if (textField == _dayTextField) {
		key = A3DateCalcDefaultsSavedDay;
		value = _dayTextField.text;
    }
    else {
        return;
    }

	[[A3SyncManager sharedSyncManager] setObject:value forKey:key state:A3DataObjectStateModified];
}

-(BOOL)hasEqualTextField:(UITextField *)textField {
    if (textField == _yearTextField || textField == _monthTextField || textField == _dayTextField ) {
        return YES;
    }
    
    return NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOffsetDateComp:(NSDateComponents *)aDateComp
{
	NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
	[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.yearTextField.text = [decimalFormatter stringFromNumber:@(aDateComp.year)];
    self.monthTextField.text = [decimalFormatter stringFromNumber:@(aDateComp.month)];
    self.dayTextField.text = [decimalFormatter stringFromNumber:@(aDateComp.day)];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *lastTouch = event.allTouches.allObjects.lastObject;
    FNLOG(@"lastTouch: %@", lastTouch);
    CGPoint point = [lastTouch locationInView:self.contentView];
    CGFloat sepWidth = self.contentView.frame.size.width / 3.0;
    if (point.x < sepWidth) {
        [self.yearTextField becomeFirstResponder];
    } else if (point.x < (sepWidth * 2)) {
        [self.monthTextField becomeFirstResponder];
    } else if (point.x < (sepWidth * 3)) {
        [self.dayTextField becomeFirstResponder];
    }
}

@end
