//
//  A3RoundDateView.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3RoundDateView.h"
#import "A3DateHelper.h"

@implementation A3RoundDateView

- (void)awakeFromNib
{
    self.fillColor = [UIColor colorWithRed:1.0 green:204.0/255.0 blue:0.0 alpha:1.0];
    self.strokColor = self.fillColor;
    
    _dateLabelTop = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabelTop.backgroundColor = [UIColor clearColor];
    _dateLabelTop.textAlignment = NSTextAlignmentCenter;
    _dateLabelTop.textColor = [UIColor whiteColor];
    _dateLabelBottom = [[UILabel alloc] initWithFrame:CGRectZero];
    _dateLabelBottom.backgroundColor = [UIColor clearColor];
    _dateLabelBottom.textAlignment = NSTextAlignmentCenter;
    _dateLabelBottom.textColor = [UIColor whiteColor];
    if ( IS_IPHONE ) {
        _dateLabelTop.font = [UIFont systemFontOfSize:13.0];
        _dateLabelBottom.font = [UIFont systemFontOfSize:13.0];
    }
    else {
        _dateLabelTop.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _dateLabelBottom.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    _dateLabelTop.lineBreakMode = NSLineBreakByTruncatingTail;
    _dateLabelTop.adjustsFontSizeToFitWidth = YES;
    _dateLabelBottom.lineBreakMode = NSLineBreakByTruncatingTail;
    _dateLabelBottom.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:_dateLabelTop];
    [self addSubview:_dateLabelBottom];

    [_dateLabelTop makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.bottom.equalTo(self.centerY).with.offset(2);
    }];
    [_dateLabelBottom makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.top.equalTo(self.centerY).with.offset(-2);
    }];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, self.bounds);
    CGContextSetFillColorWithColor(context, [_fillColor CGColor]);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [_strokColor CGColor]);
    CGContextSetLineWidth(context, 0.5);
    CGContextAddArc(context, rect.size.width*0.5, rect.size.height*0.5, rect.size.width*0.5-0.5, 0.0, M_PI*2.0, YES);
    CGContextStrokePath(context);
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    _dateLabelTop.text = [NSString stringWithFormat:@"%ld", (long)[A3DateHelper dayFromDate:date]];
    _dateLabelBottom.text = [NSString stringWithFormat:@"%@", [A3DateHelper dateStringFromDate:date withFormat:@"EEE"]];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setStrokColor:(UIColor *)strokColor
{
    _strokColor = strokColor;
    [self setNeedsDisplay];
}

@end
