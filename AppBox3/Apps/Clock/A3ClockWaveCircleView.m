//
//  A3ClockWaveCircleView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleView.h"
#import "A3ClockWaveCircleTimeView.h"
#import "A3ClockDataManager.h"

@interface A3ClockWaveCircleView () <UIGestureRecognizerDelegate>

@end

@implementation A3ClockWaveCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
		self.backgroundColor = [UIColor clearColor];
		self.layer.masksToBounds = YES;

        self.isShowWave = NO;
        
        self.layer.cornerRadius = frame.size.width * 0.5f;
        self.layer.masksToBounds = YES;
        
        self.isMustChange = NO;

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture)];
		tapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:tapGestureRecognizer];

		_textLabel = [UILabel new];
		[self addSubview:_textLabel];

		[_textLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
			_textLabelCenterY = make.centerY.equalTo(self.top).with.offset(frame.size.height / 2);
		}];
	}
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);

    UIColor *color = [UIColor whiteColor];
    [color set];
    
    CGContextSetLineWidth(context, self.nLineWidth);
    // 원의 끝부분이 짤린다.
    CGContextStrokeEllipseInRect(context, CGRectMake(rect.origin.x + (self.nLineWidth*0.5f),
                                                     rect.origin.y + (self.nLineWidth*0.5f),
                                                     rect.size.width - self.nLineWidth,
                                                     rect.size.height - self.nLineWidth));
    // start 0.65
    // middle 0.5f
    // end   3.65
//    self.fillPercent = 0.7f;
    float fHeightTemp = self.frame.size.height - (self.frame.size.height * self.fillPercent);

    if(_isShowWave)
    {
        BOOL isFirst = YES;

        CGContextSetLineWidth(context, self.nLineWidth);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        float width = self.frame.size.width;
        float fStart = (self.frame.size.width - width) * 0.5f;
        const CGFloat amplitude = rect.size.width / 100.f;   // 웨이브 세로
        CGFloat cntWave = _position == ClockWaveLocationBig ? 17 : 10;                       // 웨이브 갯수(가운데일때)
        for(CGFloat x = fStart; x < width + fStart; x += 0.5f)
        {
            CGFloat y = amplitude * sinf(2 * M_PI * (x / width) * cntWave) + fHeightTemp;
            
            if(isFirst)
            {
                CGContextMoveToPoint(context, x, y);
                CGContextAddLineToPoint(context, x, 0);
                CGContextMoveToPoint(context, x, y);
                isFirst = NO;
            }
            else
            {
                CGContextAddLineToPoint(context, x, y);
                CGContextAddLineToPoint(context, x, 0);
                CGContextMoveToPoint(context, x, y);
            }
        }
		CGContextClosePath(context);
		CGContextStrokePath(context);
    }
	CGContextRestoreGState(context);
}

#pragma mark - properties

- (void)setFillPercent:(float)fillPercent
{
    _fillPercent = fillPercent;

	CGSize textSize = [[self.textLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.textLabel font]}];

	if(self.fillPercent < 0.35f || self.fillPercent > 0.65f) {
		_textLabelCenterY.offset(self.frame.size.height * 0.5);
	}
	else if(self.fillPercent <= 0.5f)
	{
		_textLabelCenterY.offset(self.frame.size.height * (1 - self.fillPercent) - (textSize.height * 0.5f));
	}
	else
	{
		_textLabelCenterY.offset(self.frame.size.height * (1.f - self.fillPercent) + (textSize.height * 0.5f));
	}

	if (_fillPercent <= 0.5) {
		[self.textLabel setTextColor:self.superview.backgroundColor];
		[self setColonColor:self.superview.backgroundColor];
	} else {
		[self.textLabel setTextColor:[UIColor whiteColor]];
		[self setColonColor:[UIColor whiteColor]];
	}
	[self layoutIfNeeded];
}

#pragma mark - button event

- (void)onTapGesture {
	FNLOG();
	if ([_delegate respondsToSelector:@selector(clockWaveCircleTapped:)]) {
		[_delegate clockWaveCircleTapped:self];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	FNLOG(@"%lu", (unsigned long)self.position);
	return (self.position != ClockWaveLocationBig);
}

- (void)setPosition:(A3ClockWaveLocation)position
{
	_position = position;
}

- (UIFont *)smallFont {
	if (!_smallFont) {
		_smallFont = [UIFont systemFontOfSize:20];
	}
	return _smallFont;
}

- (UIFont *)bigFont {
	if (!_bigFont) {
		_bigFont = [UIFont fontWithName:@".HelveticaNeueInterface-UltraLightP2" size:88];
	}
	return _bigFont;
}

- (void)addColonView {

}

- (void)setColonColor:(UIColor *)color {

}


@end
