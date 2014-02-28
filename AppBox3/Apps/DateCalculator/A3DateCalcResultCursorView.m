//
//  A3DateCalcResultCursorView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcResultCursorView.h"

#define CORNER_GAP  10
#define BOUND_PADDING   5
#define COLOR_OVERALL [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:69.0/255.0 alpha:1.0]
//#define COLOR_POSITIVE  [UIColor colorWithRed:90.0 green:214.0/255.0 blue:83.0/255.0 alpha:1.0]
#define COLOR_POSITIVE  [UIColor colorWithRed:0.0/255.0 green:230.0/255.0 blue:101.0/255.0 alpha:1.0]
#define COLOR_SUB [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:69.0/255.0 alpha:1.0]

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
        self.arrowDirection = arrowDirection;
        [self.contentLabel setTextColor:self.isPositive? COLOR_POSITIVE : COLOR_OVERALL];
        self.contentLabel = [[UILabel alloc] initWithFrame:frame];
        self.contentLabel.autoresizingMask = ~0;
        self.contentLabel.textColor = self.isPositive? COLOR_POSITIVE : COLOR_OVERALL;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.contentLabel setLineBreakMode:NSLineBreakByClipping];
        //self.contentLabel.textAlignment = NSTextAlignmentCenter;
        //self.contentLabel.adjustsFontSizeToFitWidth = YES;
        if (IS_IPHONE) {
            self.contentLabel.font = [UIFont systemFontOfSize:15];
        } else {
            self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentLabel];

        
        [self setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.arrowDirection = ArrowDirection_From;
        [self.contentLabel setTextColor:self.isPositive? COLOR_POSITIVE : COLOR_OVERALL];
        self.contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.contentLabel.autoresizingMask = ~0;
        
//        UIViewAutoresizingFlexibleLeftMargin
//        UIViewAutoresizingFlexibleWidth        = 1 << 1,
//        UIViewAutoresizingFlexibleRightMargin  = 1 << 2,
//        UIViewAutoresizingFlexibleTopMargin    = 1 << 3,
//        UIViewAutoresizingFlexibleHeight       = 1 << 4,
//        UIViewAutoresizingFlexibleBottomMargin = 1 << 5
        
        self.contentLabel.textColor = self.isPositive? COLOR_POSITIVE : COLOR_OVERALL;
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.contentLabel setLineBreakMode:NSLineBreakByClipping];
        //self.contentLabel.textAlignment = NSTextAlignmentCenter;
        //self.contentLabel.adjustsFontSizeToFitWidth = YES;
        if (IS_IPHONE) {
            self.contentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
        } else {
            self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentLabel];
        self.contentLabel.hidden = YES;
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
    if (IS_IPHONE) {
        attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:15.0] };
    } else {
        attributes = @{ NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] };
    }
    CGRect rect = [_resultText boundingRectWithSize:CGSizeMake(280.0, 26.0)
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
 
    if (IS_IPHONE) {
        //self.contentLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
        self.contentLabel.font = [UIFont systemFontOfSize:15];
        [self.contentLabel sizeToFit];
    } else {
        self.contentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.contentLabel sizeToFit];
    }
    
    CGRect frame = self.bounds;
    CGRect cRect = self.contentLabel.frame;
    
    if (self.arrowDirection == ArrowDirection_To) {
        cRect.origin.x = frame.origin.x + LINE_WITH;
        //cRect.origin.y = BOUND_PADDING;
        cRect.origin.y = LINE_WITH;
        cRect.size.width = frame.size.width - (CORNER_GAP+LINE_WITH);
        cRect.size.height = frame.size.height - (LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    } else {
        cRect.origin.x = frame.origin.x + (CORNER_GAP+LINE_WITH);
        //cRect.origin.y = BOUND_PADDING;
        cRect.origin.y = LINE_WITH;
        cRect.size.width = frame.size.width - (CORNER_GAP+LINE_WITH);
        cRect.size.height = frame.size.height - (LINE_WITH * 2);
        [self.contentLabel setFrame:cRect];
    }
    
    //frame.size.height = self.contentLabel.frame.size.height + BOUND_PADDING * 2;
    //frame.size.height = 23;
    //self.bounds = frame;
}

-(void)setIsPositive:(BOOL)isPositive
{
    _isPositive = isPositive;
    
    self.contentLabel.textColor = self.isPositive? COLOR_POSITIVE : COLOR_OVERALL;
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
    UIBezierPath *aBackgroundPath = [UIBezierPath bezierPath];
    CGFloat boundGap = LINE_WITH;
    
    //    if (IS_IPAD) {
    //        boundGap = LINE_WITH + 0.5;
    //    }
    if (IS_RETINA) {
        boundGap = LINE_WITH + 0.5;
    } else {
        boundGap = LINE_WITH * 0.5;
    }
    
    if (self.arrowDirection == ArrowDirection_To) {
        [aLinePath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y+boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, 0.0+boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height/2)];
        [aLinePath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.origin.x, rect.size.height-boundGap)];
        [aLinePath closePath];
        
        [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x+boundGap, rect.origin.y+boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, rect.origin.y+boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height/2)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-CORNER_GAP-boundGap, rect.size.height-boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+boundGap, rect.size.height-boundGap)];
        [aBackgroundPath closePath];
    } else {
        [aLinePath moveToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.origin.y+boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height-boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap)];
        [aLinePath addLineToPoint:CGPointMake(rect.origin.x+boundGap, rect.size.height/2)];
        [aLinePath closePath];

        [aBackgroundPath moveToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.origin.y+boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.origin.y+boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.size.width-boundGap, rect.size.height-boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+CORNER_GAP+boundGap, rect.size.height-boundGap)];
        [aBackgroundPath addLineToPoint:CGPointMake(rect.origin.x+boundGap, rect.size.height/2)];
        [aBackgroundPath closePath];
    }
    
    if (IS_RETINA) {
        aLinePath.lineWidth = LINE_WITH - 0.5;
    } else {
        aLinePath.lineWidth = LINE_WITH;
    }
    
    self.isPositive? [[UIColor greenColor] setStroke] : [[UIColor redColor] setStroke];
    [aLinePath stroke];
    
    [[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] setFill];
    [aBackgroundPath fill];
}


@end
