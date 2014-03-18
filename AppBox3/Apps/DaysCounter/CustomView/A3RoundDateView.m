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
    
    _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.numberOfLines = 0;
    _dateLabel.textColor = [UIColor whiteColor];
    if( IS_IPHONE )
        _dateLabel.font = [UIFont systemFontOfSize:13.0];
    else
        _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _dateLabel.adjustsFontSizeToFitWidth = YES;

    [self addSubview:_dateLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
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
    _dateLabel.text = [NSString stringWithFormat:@"%ld\n%@",(long)[A3DateHelper dayFromDate:date],[A3DateHelper dateStringFromDate:date withFormat:@"EEE"]];
    
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
