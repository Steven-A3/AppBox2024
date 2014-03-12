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
        //|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        self.contentLabel.textColor = self.isPositive ? [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] : COLOR_NEGATIVE;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        //self.contentLabel.lineBreakMode = NSLineBreakByClipping;
        self.arrowDirection = arrowDirection;

        self.backgroundColor = [UIColor clearColor];
        //self.contentMode = UIViewContentModeScaleAspectFit;
        //self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        [self addSubview:self.contentLabel];
    }
    
    return self;
}

//-(id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        self.arrowDirection = ArrowDirection_From;
//        [self.contentLabel setTextColor:self.isPositive? [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] : COLOR_NEGATIVE];
//        self.contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
//        self.contentLabel.autoresizingMask = ~0;
//
//        self.contentLabel.textColor = self.isPositive? [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] : COLOR_NEGATIVE;
//        self.contentLabel.textAlignment = NSTextAlignmentCenter;
//        self.contentLabel.backgroundColor = [UIColor clearColor];
//        [self.contentLabel setLineBreakMode:NSLineBreakByClipping];
//
//        if (IS_IPHONE) {
//            self.contentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
//        } else {
//            self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//        }
//        
//        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.contentLabel];
//        self.contentLabel.hidden = YES;
//    }
//    
//    return self;
//}

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
    CGRect rect = [_resultText boundingRectWithSize:CGSizeMake(280.0, 25.0)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    return rect.size;
}

-(void)setArrowDirection:(ArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
//    [self setNeedsDisplay];
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
        //cRect.origin.y = BOUND_PADDING;
        cRect.origin.y = LINE_WITH;
        cRect.size.width = ceilf(frame.size.width - CORNER_GAP + LINE_WITH);
        cRect.size.height = ceilf(frame.size.height - LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    }
    else {
        cRect.origin.x = roundf(frame.origin.x + CORNER_GAP + LINE_WITH);
        //cRect.origin.y = BOUND_PADDING;
        cRect.origin.y = LINE_WITH;
        cRect.size.width = roundf(frame.size.width - CORNER_GAP + LINE_WITH);
        cRect.size.height = roundf(frame.size.height - LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    }
    
    //frame.size.height = self.contentLabel.frame.size.height + BOUND_PADDING * 2;
    //frame.size.height = 23;
    //self.bounds = frame;
}

-(void)setIsPositive:(BOOL)isPositive
{
    _isPositive = isPositive;
    
    self.contentLabel.textColor = self.isPositive ? [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] : COLOR_NEGATIVE;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetShouldAntialias(context, NO);
//    CGContextSetAllowsAntialiasing(context, NO);
//    CGContextMoveToPoint(context, rect.origin.x, rect.size.height/2);
//    CGContextAddLineToPoint(context, rect.size.width, rect.size.height/2);
//    CGContextClosePath(context);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColorWithColor(context, self.isPositive? [COLOR_POSITIVE CGColor] : [COLOR_OVERALL CGColor]);
//    CGContextStrokePath(context);
    
//    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextSetShouldAntialias(context, NO);
//
//    CGFloat boundGap = LINE_WITH;
//    if (IS_RETINA) {
//        boundGap = 0.5;
//    }
//    
//    boundGap = 0.5;
//    
//    if (self.arrowDirection == ArrowDirection_To) {
////        CGContextMoveToPoint(context, rect.origin.x+boundGap, rect.origin.y+1);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.origin.y+1);
////        
////        CGContextMoveToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.origin.y+1);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height/2);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap);
//        
//        CGContextMoveToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.size.height+boundGap);
//        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height+boundGap);
//        //CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.origin.y+1);
//
////        CGContextMoveToPoint(context, rect.origin.x+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height/2);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height-boundGap);
//        
//    } else {
//        CGContextMoveToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+0.5);
//        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.origin.y+0.5);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap);
//        
////        CGContextMoveToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height/2);
////        CGContextAddLineToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+1);
//        
////        CGContextMoveToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height/2);
//    }
//    
////    if (self.arrowDirection == ArrowDirection_To) {
////        CGContextMoveToPoint(context, rect.origin.x+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height/2);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height-boundGap);
////        
////        CGContextMoveToPoint(context, rect.origin.x+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height/2);
////        CGContextAddLineToPoint(context, rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height-boundGap);
////
////    } else {
////        CGContextMoveToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height/2);
////        
////        CGContextMoveToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.origin.y+boundGap);
////        CGContextAddLineToPoint(context, rect.size.width-boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap);
////        CGContextAddLineToPoint(context, rect.origin.x+boundGap, rect.size.height/2);
////    }
//    
////    if (IS_RETINA) {
////        CGContextSetLineWidth(context, 0.5);
////    } else {
////        CGContextSetLineWidth(context, LINE_WITH);
////    }
//    CGContextSetLineWidth(context, 1.0);
//    CGContextSetStrokeColorWithColor(context, self.isPositive? [COLOR_POSITIVE CGColor] : [COLOR_OVERALL CGColor]);
//    CGContextStrokePath(context);
//    CGContextClosePath(context);

    
//    [[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] setFill];
//    [aBackgroundPath fill];

    
    
    
    
//    
//    
    UIBezierPath *aLinePath = [UIBezierPath bezierPath];
//    UIBezierPath *aBackgroundPath = [UIBezierPath bezierPath];
    CGFloat boundGap = LINE_WITH;
    
    //    if (IS_IPAD) {
    //        boundGap = LINE_WITH + 0.5;
    //    }
    if (IS_RETINA) {
        boundGap = 0.25;

        if (self.arrowDirection == ArrowDirection_To) {
            [aLinePath moveToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width - CORNER_GAP) - boundGap, 0.0 + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, round(rect.size.height / 2))];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - CORNER_GAP - boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath closePath];
            
//            [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x+boundGap, rect.origin.y+boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, rect.origin.y+boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height/2)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+boundGap, rect.size.height-boundGap)];
//            [aBackgroundPath closePath];
        } else {
            [aLinePath moveToPoint:CGPointMake(ceilf(rect.origin.x + CORNER_GAP) + boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, ceilf(rect.origin.y) + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.size.width) - boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x + CORNER_GAP) + boundGap, ceilf(rect.size.height) - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(ceilf(rect.origin.x) + boundGap, roundf(rect.size.height / 2))];
            [aLinePath closePath];
            
//            [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.origin.y+boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height-boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+boundGap, rect.size.height/2)];
//            [aBackgroundPath closePath];
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
            
//            [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x + LINE_WITH, rect.origin.y + LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width - CORNER_GAP - LINE_WITH, rect.origin.y + LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width - LINE_WITH, rect.size.height/2)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width - CORNER_GAP - LINE_WITH, rect.size.height - LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x + LINE_WITH, rect.size.height - LINE_WITH)];
//            [aBackgroundPath closePath];
        } else {
            [aLinePath moveToPoint:CGPointMake(rect.origin.x + CORNER_GAP, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - boundGap, rect.origin.y + boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.size.width - boundGap, rect.size.height - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.origin.x + CORNER_GAP, rect.size.height - boundGap)];
            [aLinePath addLineToPoint:CGPointMake(rect.origin.x, rect.size.height/2)];
            [aLinePath closePath];
            
//            [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x + CORNER_GAP + LINE_WITH, rect.origin.y + LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width - LINE_WITH, rect.origin.y + LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width - LINE_WITH, rect.size.height - LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x + CORNER_GAP + LINE_WITH, rect.size.height - LINE_WITH)];
//            [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x + LINE_WITH, rect.size.height/2)];
//            [aBackgroundPath closePath];
        }
    }
    
    
//    [[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] setFill];
//    [aBackgroundPath fill];

    
    if (IS_RETINA) {
        aLinePath.lineWidth = 0.5;
    } else {
        aLinePath.lineWidth = 1.0;
    }
    
    self.isPositive? [[UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:100.0/255.0 alpha:1.0] setStroke] : [COLOR_NEGATIVE setStroke];
    [aLinePath stroke];
}


@end
