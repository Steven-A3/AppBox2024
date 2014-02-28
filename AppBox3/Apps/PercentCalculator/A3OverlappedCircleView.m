//
//  A3OverlapedCircleView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3OverlappedCircleView.h"
// 반투명 그림자
#define COLOR_ELLIPSE_0     [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]
// 중앙 흰색
#define COLOR_ELLIPSE_1     [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
// 중앙 흰색 보더
#define COLOR_ELLIPSE_1_BORDER     [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]

@implementation A3OverlappedCircleView
{
    CALayer *centerCircleLayer;
	CALayer *_centerCircle, *_middleCircle, *_backgroundCirlce;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];
    }
    
    return self;
}

-(void)setFocused:(BOOL)focused
{
    _focused = focused;
    
    _backgroundCirlce.backgroundColor = _focused==YES ? [[COLOR_ELLIPSE_0 colorWithAlphaComponent:0.375] CGColor] : [[UIColor clearColor] CGColor];
}

-(void)setCenterColorType:(CenterColorType)aCenterColorType
{
    _centerColorType = aCenterColorType;
    
    switch (_centerColorType) {
        case CenterColorType_Positive:
            _centerCircle.backgroundColor = [COLOR_POSITIVE CGColor];
            break;
     
        case CenterColorType_Negative:
            _centerCircle.backgroundColor = [COLOR_NEGATIVE CGColor];
            break;
        case CenterColorType_Neutral:
            _centerCircle.backgroundColor = [COLOR_ELLIPSE_0 CGColor];
            
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setupLayer {
	// Outer Circle size 31, 31
    self.backgroundColor = [UIColor clearColor];
    
    if (IS_RETINA) {
        _backgroundCirlce = [CALayer layer];
        _backgroundCirlce.frame = CGRectMake(self.center.x - 15.5, self.center.y - 15.5, 31, 31);
        _backgroundCirlce.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
        _backgroundCirlce.cornerRadius = 15.5;
        [self.layer addSublayer:_backgroundCirlce];
        
        
        _middleCircle = [CALayer layer];
        _middleCircle.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
        //_middleCircle.frame = CGRectMake(8, 8, 15, 15);
        _middleCircle.frame = CGRectMake(self.frame.size.width - (self.frame.size.width/2.0 + 7.5), self.frame.size.height - (self.frame.size.height/2.0 + 7.5), 15, 15);
        _middleCircle.cornerRadius = IS_RETINA ? 7.5 : 8.5;
        
        _middleCircle.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
        _middleCircle.borderWidth = 1.0;
        _middleCircle.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        [self.layer addSublayer:_middleCircle];
        
        
        _centerCircle = [CALayer layer];
        _centerCircle.backgroundColor = _centerColor ? _centerColor.CGColor : [UIColor colorWithRed:0 green:128.0/255.0 blue:252.0/255.0 alpha:1.0].CGColor;
        
        _centerCircle.frame = CGRectMake(self.frame.size.width - (self.frame.size.width/2 + 3.5), self.frame.size.height - (self.frame.size.height/2 + 3.5), 7, 7);
        _centerCircle.cornerRadius = IS_RETINA ? 3.5 : 4.5;
        [self.layer addSublayer:_centerCircle];
        
    } else {
        _backgroundCirlce = [CALayer layer];
        _backgroundCirlce.frame = CGRectMake(self.center.x - 16, self.center.y - 16, 32, 32);
        _backgroundCirlce.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05].CGColor;
        _backgroundCirlce.cornerRadius = 16;
        [self.layer addSublayer:_backgroundCirlce];
        
        
        _middleCircle = [CALayer layer];
        _middleCircle.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
        //_middleCircle.frame = CGRectMake(8, 8, 15, 15);
        _middleCircle.frame = CGRectMake(self.frame.size.width - (self.frame.size.width/2.0 + 7.5), self.frame.size.height - (self.frame.size.height/2.0 + 7.5), 15, 15);
        _middleCircle.cornerRadius = IS_RETINA ? 7.5 : 8.5;
        
        _middleCircle.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
        _middleCircle.borderWidth = 1.0;
        _middleCircle.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        [self.layer addSublayer:_middleCircle];
        
        
        _centerCircle = [CALayer layer];
        _centerCircle.backgroundColor = _centerColor ? _centerColor.CGColor : [UIColor colorWithRed:0 green:128.0/255.0 blue:252.0/255.0 alpha:1.0].CGColor;
        
        _centerCircle.frame = CGRectMake(self.frame.size.width - (self.frame.size.width/2 + 3.5), self.frame.size.height - (self.frame.size.height/2 + 3.5), 7, 7);
        _centerCircle.cornerRadius = IS_RETINA ? 3.5 : 4.5;
        [self.layer addSublayer:_centerCircle];
    }
}

- (void)setCenterColor:(UIColor *)centerColor {
	_centerColor = centerColor;
	_centerCircle.backgroundColor = _centerColor.CGColor;
}

@end
