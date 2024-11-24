//
//  A3ClockWaveCircleView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockWaveCircleMiddleView.h"
#import "A3ClockWaveCircleView.h"
#import "A3ClockWaveCircleTimeView.h"
#import "A3ClockDataManager.h"
#import "A3UserDefaults+A3Defaults.h"
#import "UIImage+imageWithColor.h"

@interface A3ClockWaveCircleView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *waveImageView;

@end

@implementation A3ClockWaveCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
		self.backgroundColor = [UIColor whiteColor];
		self.layer.masksToBounds = YES;

        self.isShowWave = NO;
        
        self.layer.cornerRadius = frame.size.width * 0.5f;
		self.layer.borderColor = [UIColor whiteColor].CGColor;
		self.layer.borderWidth = _lineWidth;
        self.layer.masksToBounds = YES;
        
        self.isMustChange = NO;

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture)];
		tapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:tapGestureRecognizer];

		_waveImageView = [UIImageView new];
		[self addSubview:_waveImageView];

		_textLabel = [UILabel new];
		[self addSubview:_textLabel];

		[_textLabel makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(self.centerX);
            self->_textLabelCenterY = make.centerY.equalTo(self.top).with.offset(frame.size.height / 2);
		}];
	}
    
    return self;
}

#pragma mark - properties

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	self.layer.cornerRadius = bounds.size.width * 0.5f;
	self.layer.borderWidth = _lineWidth;

	self.textLabel.font = self.position == ClockWaveLocationBig ? self.bigFont : self.smallFont;

	if (self.isShowWave) {
		[self setFillPercent:self.fillPercent];
	} else {
		self.textLabelCenterY.offset(bounds.size.height / 2);
		[self.textLabel setTextColor:self.superview.backgroundColor];
	}

	[self layoutIfNeeded];
}

- (void)setFillPercent:(float)fillPercent
{
    _fillPercent = MAX(fillPercent, 0.0);

	NSString *imageName;
	UIEdgeInsets slicingEdge;
	CGFloat waveHeight;
	if (IS_IPHONE) {
		imageName = _position == ClockWaveLocationBig ? @"wave" : @"wave_small";
		waveHeight = _position == ClockWaveLocationBig ? 6 : 4;
	} else {
		imageName = _position == ClockWaveLocationBig ? @"wave_large" : @"wave";
		waveHeight = _position == ClockWaveLocationBig ? 11 : 6;
	}
	slicingEdge = UIEdgeInsetsMake(waveHeight, 0, 0, 0);

	CGRect frame = self.bounds;
	if (_fillPercent == 0.0) {
		frame.origin.y = frame.size.height;
	} else if (fillPercent == 1.0) {
		frame.origin.y = frame.origin.y - waveHeight;
		frame.size.height = frame.size.height + waveHeight;
	} else {
		frame.origin.y = (1.0 - _fillPercent) * frame.size.height;
		frame.size.height = fillPercent * frame.size.height;
	}
	_waveImageView.frame = frame;

	UIImage *tintedImage = [[UIImage imageNamed:imageName] tintedImageWithColor:[[A3UserDefaults standardUserDefaults] clockWaveColor]];
	_waveImageView.image = [tintedImage resizableImageWithCapInsets:slicingEdge resizingMode:UIImageResizingModeTile];

	CGSize textSize = [[self.textLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.textLabel font], NSForegroundColorAttributeName:[UIColor blackColor]}];

	CGFloat rate = textSize.height > 200.0 ? 0.4 : 0.5;
	CGFloat offset = self.position == ClockWaveLocationBig ? textSize.height * rate : textSize.height / 2 + (IS_IPHONE ? 0 : 10);
	CGFloat centerY;
	if(self.fillPercent < 0.35f || self.fillPercent > 0.65f) {
		centerY = self.frame.size.height * 0.5;
	}
	else if(self.fillPercent <= 0.5f)
	{
		centerY = self.frame.size.height * (1 - self.fillPercent) - offset;
	}
	else
	{
		centerY = self.frame.size.height * (1.f - self.fillPercent) + offset;
	}
	_textLabelCenterY.offset(centerY);
	if (_colonViewCenterY) {
		_colonViewCenterY.offset(centerY);
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
		_smallFont = [UIFont systemFontOfSize:IS_IPHONE ? 20 : 36];
	}
	return _smallFont;
}

- (UIFont *)bigFont {
	if (!_bigFont) {
		_bigFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:IS_IPHONE ? 88 : 176];
	}
	return _bigFont;
}

- (void)addColonView {

}

- (void)setColonColor:(UIColor *)color {

}

@end
