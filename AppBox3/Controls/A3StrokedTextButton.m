//
//  A3StrokedTextButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3StrokedTextButton.h"
#import "common.h"

@interface A3StrokedTextButton ()
@property (nonatomic, strong) NSString *customTitle;

@end

@implementation A3StrokedTextButton

- (void)initialize {
    // Initialization code
    [self setTitle:@"" forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
        [self initialize];
	}

	return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	self.customTitle = title;
	[super setTitle:@"" forState:state];
}

- (void)drawRect:(CGRect)rect {
	CGSize size = [self.customTitle sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
	CGPoint drawingPoint = CGPointMake(CGRectGetWidth(rect)/2.0f - size.width/2.0f, CGRectGetHeight(rect)/2.0f - size.height/2.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextDrawingMode(context, kCGTextStroke);
	CGContextSetStrokeColorWithColor(context, [self titleColorForState:self.state].CGColor);
	[self.customTitle drawAtPoint:drawingPoint withAttributes:@{NSFontAttributeName:self.titleLabel.font}];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	[self setNeedsDisplay];
}

@end
