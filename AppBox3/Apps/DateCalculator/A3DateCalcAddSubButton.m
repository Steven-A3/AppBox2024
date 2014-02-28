//
//  A3DateCalcAddSubButton.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 28..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcAddSubButton.h"

@implementation A3DateCalcAddSubButton
{
    UIColor *strokeColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
#define LINE_LENGTH 23.0
- (void)drawRect:(CGRect)rect
{
    strokeColor = self.selected ? [UIColor whiteColor] : [UIColor blackColor];
    
    //[super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, [strokeColor CGColor]);
    if (self.isAddButton) {

        CGContextMoveToPoint(context, self.center.x - (LINE_LENGTH/2.0), self.bounds.size.height / 2.0);
        CGContextAddLineToPoint(context, self.center.x + (LINE_LENGTH/2.0), self.bounds.size.height / 2.0);
        CGContextMoveToPoint(context, self.center.x, self.bounds.size.height / 2.0 - (LINE_LENGTH/2.0));
        CGContextAddLineToPoint(context, self.center.x, self.bounds.size.height / 2.0 + (LINE_LENGTH/2.0));

    } else {
        CGContextMoveToPoint(context, self.bounds.size.width / 2.0 - (LINE_LENGTH/2.0), self.bounds.size.height / 2.0);
        CGContextAddLineToPoint(context, self.bounds.size.width / 2.0 + (LINE_LENGTH/2.0), self.bounds.size.height / 2.0);
    }
    CGContextStrokePath(context);

}


@end
