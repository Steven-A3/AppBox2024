//
//  A3DateCalcResultCursorView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcResultCursorView.h"
#import "A3DefaultColorDefines.h"

#define CORNER_GAP  10
#define BOUND_PADDING   5

const CGFloat LINE_WITH = 1.0;

@implementation A3DateCalcResultCursorView
{
    NSString *_resultText;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame ArrowDirection:(ArrowDirection)arrowDirection
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentLabel = [[UILabel alloc] initWithFrame:frame];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
        self.contentLabel.textColor = self.isPositive ? [UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0] : COLOR_NEGATIVE;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.arrowDirection = arrowDirection;

        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentLabel];
    }
    
    return self;
}

- (void)setResultText:(NSString *)resultText
{
    _resultText = resultText;
    [self.contentLabel setText:_resultText];
}

- (CGSize)sizeOfResultText
{
    NSDictionary *attributes;
//    if (IS_IPHONE) {
//        attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:17] };
//    }
//    else {
//        attributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] };
//    }
    attributes = @{ NSFontAttributeName : self.contentLabel.font };
    CGRect rect = [_resultText boundingRectWithSize:CGSizeMake(IS_IPAD ? 500.0 : 300.0, 25.0)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    return rect.size;
}

-(void)setArrowDirection:(ArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
 
//    if (IS_IPHONE) {
//        //self.contentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
//        self.contentLabel.font = [UIFont systemFontOfSize:17];
//        [self.contentLabel sizeToFit];
//    }
//    else {
//        self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//        [self.contentLabel sizeToFit];
//    }
    
    CGRect frame = self.bounds;
    CGRect cRect = self.contentLabel.frame;
    
    if (self.arrowDirection == ArrowDirection_To) {
        cRect.origin.x = ceilf(frame.origin.x + LINE_WITH);
        cRect.origin.y = LINE_WITH;
        cRect.size.width = ceilf(frame.size.width - CORNER_GAP + LINE_WITH);
        cRect.size.height = ceilf(frame.size.height - LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    }
    else {
        cRect.origin.x = roundf(frame.origin.x + CORNER_GAP + LINE_WITH);
        cRect.origin.y = LINE_WITH;
        cRect.size.width = roundf(frame.size.width - CORNER_GAP + LINE_WITH);
        cRect.size.height = roundf(frame.size.height - LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    }
}

-(void)setIsPositive:(BOOL)isPositive
{
    _isPositive = isPositive;
    
    self.contentLabel.textColor = self.isPositive ? [UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0] : COLOR_NEGATIVE;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *aLinePath = [UIBezierPath bezierPath];
    CGFloat boundGap = LINE_WITH;

    if (IS_RETINA) {
        boundGap = 0.25;

        if (self.arrowDirection == ArrowDirection_To) {
            [aLinePath moveToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width - CORNER_GAP) - boundGap, 0.0 + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, round(rect.size.height / 2))];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - CORNER_GAP - boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath closePath];
        } else {
            [aLinePath moveToPoint:CGPointMake(ceilf(rect.origin.x + CORNER_GAP) + boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x + CORNER_GAP) + boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, roundf(rect.size.height / 2))];
            [aLinePath closePath];
        }
    }
    else {
        boundGap = 0.5;

        if (self.arrowDirection == ArrowDirection_To) {
            [aLinePath moveToPoint:CGPointMake(rect.origin.x + boundGap, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - CORNER_GAP, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height/2)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - CORNER_GAP, rect.size.height - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.origin.x + boundGap, rect.size.height - boundGap)];
            [aLinePath closePath];
        } else {
            [aLinePath moveToPoint:CGPointMake(rect.origin.x + CORNER_GAP, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - boundGap, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - boundGap, rect.size.height - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.origin.x + CORNER_GAP, rect.size.height - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.origin.x, rect.size.height/2)];
            [aLinePath closePath];
        }
    }
    
    if (IS_RETINA) {
        aLinePath.lineWidth = 0.5;
    } else {
        aLinePath.lineWidth = 1.0;
    }
    
    self.isPositive? [[UIColor colorWithRed:73.0/255.0 green:191.0/255.0 blue:31.0/255.0 alpha:1.0] setStroke] : [COLOR_NEGATIVE setStroke];
    [aLinePath stroke];
}


@end
