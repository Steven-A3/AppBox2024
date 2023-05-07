//
//  A3BatterStatusBatteryPanelView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatterStatusBatteryPanelView.h"
#import "A3BatteryStatusManager.h"
#import "SFKImage.h"
#import "A3DefaultColorDefines.h"
#import "A3UIDevice.h"

@implementation A3BatterStatusBatteryPanelView
{
    NSInteger _remainingPercent;
    UILabel * _remainPercentLabel;
    UIImageView * _chargingImageView;
    UIView * _bottomLineView;
	MASConstraint *_remainPercentTopConst;
	MASConstraint *_chargingImageTopConst;
    
	CGFloat _batteryCenterY;
    CGFloat xpos;
    CGFloat ypos;
    CGFloat height;
    CGFloat width;
    CGFloat kCornerPoint;
    
    CGFloat headGap;
    CGFloat headWidth;
    CGFloat headHeight;
    CGFloat headCornerPoint;

    
    UIColor *_batteryBackgroundColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        _remainingPercent = 40;
        _batteryColor = [A3BatteryStatusManager chosenTheme];
        _batteryBackgroundColor = COLOR_BATTERY_BACKGROUND;

        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustConstraintLayout];
    [super layoutSubviews];
}

-(void)initializeSubviews
{
    _remainPercentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _remainPercentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)_remainingPercent];
    if (IS_IPHONE) {
        _remainPercentLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:76.0];
    } else {
        _remainPercentLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:88.0];
    }
    
    _chargingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:62]];
    [SFKImage setDefaultColor:COLOR_BATTERY_CHARGING];
    UIImage *charge = [SFKImage imageNamed:@"c"];
    _chargingImageView.image = charge;
    //_chargingImageView.contentMode = UIViewContentModeScaleAspectFit;
    //_chargingImageView.contentMode = UIViewContentModeScaleToFill;
    
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomLineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];

    [self addSubview:_remainPercentLabel];
    [self addSubview:_chargingImageView];
    [self addSubview:_bottomLineView];
    
    [_remainPercentLabel sizeToFit];
}

-(void)setupConstraintLayout
{
    [_remainPercentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        if (IS_IPHONE) {
            _remainPercentTopConst = make.top.equalTo(@12);
        } else {
            if (IS_LANDSCAPE) {
                _remainPercentTopConst = make.top.equalTo(@22);
            } else {
                _remainPercentTopConst = make.top.equalTo(@42);
            }
        }
        
    }];
    
    [_chargingImageView makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPHONE) {
            make.width.equalTo(@48);
            make.height.equalTo(@62);
            make.centerX.equalTo(self.centerX).with.offset(135);
            _chargingImageTopConst = make.centerY.equalTo(self.top);
            
        } else {
            make.width.equalTo(@58);
            make.height.equalTo(@76);
            make.centerX.equalTo(self.centerX).with.offset(176);
            _chargingImageTopConst = make.centerY.equalTo(self.top);
        }
    }];
    
    [_bottomLineView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
    }];
}

-(void)adjustConstraintLayout
{
    xpos = 53.0;
    ypos = 105.0;
    height = 81.0;
    width = 206.0;
    kCornerPoint = width / 100.0 * 4.0;
    headGap = 3.0;
    headWidth = 6.0;
    headHeight = 31.0;
    headCornerPoint = 5.0;
    
    
    if (IS_IPAD) {
        width = 268.0;
        height = 106.0;
        
        if (IS_LANDSCAPE) {
            ypos = 128.0;
        } else {
            ypos = 153.0;
        }
        //xpos = (self.frame.size.width / 2.0) - (width / 2.0);
    }
    
    xpos = (self.frame.size.width / 2.0) - (width / 2.0) - ((headGap + headWidth) / 2.0);
	
	_batteryCenterY = ypos + (height / 2.0);
    
    if (IS_IPHONE) {
        _remainPercentTopConst.equalTo(@12);
    } else {
        if (IS_LANDSCAPE) {
            _remainPercentTopConst.equalTo(@22);
        } else {
            _remainPercentTopConst.equalTo(@42);
        }
    }
    [_remainPercentLabel sizeToFit];

	//_chargingImageTopConst.equalTo(@(_batteryCenterY)).with.offset(-(_chargingImageView.frame.size.height / 2.0));
    _chargingImageTopConst.equalTo(@0).with.offset(_batteryCenterY);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//#define kCornerPoint 10.0
- (void)drawRect:(CGRect)rect
{
    // Draw Battery Background
    UIBezierPath * batteryPath = [UIBezierPath bezierPath];
    batteryPath.lineWidth = 1.0;
    
    [batteryPath moveToPoint:CGPointMake(xpos, ypos + kCornerPoint)];
    [batteryPath addCurveToPoint:CGPointMake(xpos + kCornerPoint, ypos)
            controlPoint1:CGPointMake(xpos, ypos + kCornerPoint)
            controlPoint2:CGPointMake(xpos, ypos)];
    
    [batteryPath addLineToPoint:CGPointMake(xpos + width - (kCornerPoint * 2), ypos)];
    
    [batteryPath addCurveToPoint:CGPointMake(xpos + width, ypos + kCornerPoint)
            controlPoint1:CGPointMake(xpos + width - kCornerPoint, ypos)
            controlPoint2:CGPointMake(xpos + width, ypos)];
    
    [batteryPath addLineToPoint:CGPointMake(xpos + width, ypos + height - (kCornerPoint * 2))];
    
    [batteryPath addCurveToPoint:CGPointMake(xpos + width - kCornerPoint, ypos + height)
            controlPoint1:CGPointMake(xpos + width, ypos + height - kCornerPoint)
            controlPoint2:CGPointMake(xpos + width, ypos + height)];
    
    [batteryPath addLineToPoint:CGPointMake(xpos + kCornerPoint, ypos + height)];
    
    [batteryPath addCurveToPoint:CGPointMake(xpos, ypos + height - kCornerPoint)
            controlPoint1:CGPointMake(xpos + kCornerPoint, ypos + height)
            controlPoint2:CGPointMake(xpos, ypos + height)];
    
    [batteryPath addLineToPoint:CGPointMake(xpos, ypos + kCornerPoint)];
    [batteryPath closePath];

    [_batteryBackgroundColor setFill];
    [batteryPath fill];
    

    
    // Draw Battery Gauge
    UIBezierPath * gaugePath = [UIBezierPath bezierPath];
    gaugePath.lineWidth = 1.0;
    CGFloat gauge = width / 100.0 * _remainingPercent;
    CGFloat leftCornerPoint = kCornerPoint;
    CGFloat rightCornerPoint;
    
    if (gauge < leftCornerPoint) {
        // 수정필요;;
        leftCornerPoint = gauge;
        ypos = ypos + leftCornerPoint ;
        height = height - (leftCornerPoint * 2.0);
    }
    if (gauge > (width - kCornerPoint)) {
        rightCornerPoint = gauge - (width - kCornerPoint);
    } else {
        rightCornerPoint = 0.0;
    }
    
    [gaugePath moveToPoint:CGPointMake(xpos, ypos + leftCornerPoint)];
    
    [gaugePath addCurveToPoint:CGPointMake(xpos + leftCornerPoint, ypos)
                 controlPoint1:CGPointMake(xpos, ypos + leftCornerPoint)
                 controlPoint2:CGPointMake(xpos, ypos)];
    
    [gaugePath addLineToPoint:CGPointMake(xpos + gauge - rightCornerPoint, ypos)];
    
    [gaugePath addCurveToPoint:CGPointMake(xpos + gauge, ypos + rightCornerPoint)
                 controlPoint1:CGPointMake(xpos + gauge - rightCornerPoint, ypos)
                 controlPoint2:CGPointMake(xpos + gauge, ypos)];
    
    [gaugePath addLineToPoint:CGPointMake(xpos + gauge, ypos + height - (rightCornerPoint * 2))];
    
    [gaugePath addCurveToPoint:CGPointMake(xpos + gauge - rightCornerPoint, ypos + height)
                 controlPoint1:CGPointMake(xpos + gauge, ypos + height - rightCornerPoint)
                 controlPoint2:CGPointMake(xpos + gauge, ypos + height)];
    
    [gaugePath addLineToPoint:CGPointMake(xpos + leftCornerPoint, ypos + height)];
    
    [gaugePath addCurveToPoint:CGPointMake(xpos, ypos + height - leftCornerPoint)
                 controlPoint1:CGPointMake(xpos + leftCornerPoint, ypos + height)
                 controlPoint2:CGPointMake(xpos, ypos + height)];
    
    [gaugePath addLineToPoint:CGPointMake(xpos, ypos + leftCornerPoint)];
    [gaugePath closePath];
    
    [_batteryColor setFill];
    [gaugePath fill];
    
    
    
    // Draw Battery Head
    UIBezierPath * headPath = [UIBezierPath bezierPath];
//    CGFloat headGap = 3.0;
//    CGFloat headWidth = 6.0;
//    CGFloat headHeight = 31.0;
//    CGFloat headCornerPoint = 5.0;

    if (IS_IPAD) {
        headWidth = 8.0;
        headHeight = 41.0;
        headCornerPoint = 7.0;
    }

    CGFloat headXpos = xpos + width + headGap;
    CGFloat headYpos = ypos + (height / 2.0) - (headHeight / 2.0);

    [headPath moveToPoint:CGPointMake(headXpos, headYpos)];

    [headPath addCurveToPoint:CGPointMake(headXpos + headWidth, headYpos + headCornerPoint)
                controlPoint1:CGPointMake(headXpos, headYpos)
                controlPoint2:CGPointMake(headXpos + headWidth, headYpos)];

    [headPath addLineToPoint:CGPointMake(headXpos + headWidth, headYpos + headHeight - (headCornerPoint * 2.0))];

    [headPath addCurveToPoint:CGPointMake(headXpos, headYpos + headHeight)
                controlPoint1:CGPointMake(headXpos + headWidth, headYpos + headHeight - headCornerPoint)
                controlPoint2:CGPointMake(headXpos + headWidth, headYpos + headHeight)];

    [_batteryColor setFill];
//    if (_remainingPercent==100) {
//        [_batteryColor setFill];
//    } else {
//        [[UIColor colorWithRed:220.0/255.0 green:223.0/255.0 blue:226.0/255.0 alpha:1.0] setFill];
//    }

    [headPath closePath];
    [headPath fill];
}

-(void)setBatteryRemainingPercent:(NSInteger)percent state:(UIDeviceBatteryState)batteryState
{
    _remainingPercent = percent;
    _remainPercentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)percent];
    [_remainPercentLabel sizeToFit];

    if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) {
        _chargingImageView.hidden = NO;
        if (_remainingPercent <= 20) {
            [SFKImage setDefaultColor:COLOR_BATTERY_RUNNINGOUT];
        } else {
            [SFKImage setDefaultColor:batteryState == UIDeviceBatteryStateCharging ? COLOR_BATTERY_CHARGING : [A3BatteryStatusManager chosenTheme]];
        }

        _chargingImageView.image = [SFKImage imageNamed:@"c"];
        
    } else {
        _chargingImageView.hidden = YES;
    }
    
    if (_remainingPercent <= 20) {
        _batteryColor = COLOR_BATTERY_RUNNINGOUT;
    } else {
        _batteryColor = [A3BatteryStatusManager chosenTheme];
        //_batteryColor = batteryState == UIDeviceBatteryStateCharging ? COLOR_BATTERY_CHARGING : [A3BatteryStatusManager chosenTheme];
    }
    
    //_batteryBackgroundColor = batteryState == UIDeviceBatteryStateCharging ? [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:76.0/255.0 alpha:1.0] : [UIColor colorWithRed:220.0/255.0 green:223.0/255.0 blue:226.0/255.0 alpha:1.0];
    
    [self setNeedsDisplay];
}

-(void)setBatteryColor:(UIColor *)batteryColor
{
    _batteryColor = [batteryColor copy];
    
    [self setNeedsDisplay];
}

@end
