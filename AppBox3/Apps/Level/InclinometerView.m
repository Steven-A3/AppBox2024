//
//  InclinometerSurfaceView.m
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

#import "InclinometerView.h"
#import "InclinometerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface InclinometerView ()

@end

@implementation InclinometerView {
	NSUInteger _inclinometerMode;	// Surface or Bubble
	NSUInteger _unit;
	UIImageView *_bubbleView;
	UIImageView *_vialLinesView;
	UILabel *_degreeViewX;
	UILabel *_degreeViewY;
}

- (instancetype)initWithFrame:(CGRect)frame mode:(NSUInteger)mode {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		_unit = degrees;

		self.autoresizesSubviews = NO;

		_inclinometerMode = mode;

		UIImage *circleImage, *lineImage;
		CGFloat diffCircle, diffLine;
		if (_inclinometerMode == surfaceMode) {
			NSString *imageName = IS_IPHONE35 ? @"bg_Inclinometer_surface_480" : @"bg_Inclinometer_surface";
			UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
			imageView.frame = [A3UIDevice screenBoundsAdjustedWithOrientation];
			[self addSubview:imageView];
			
			circleImage = [UIImage imageNamed:@"surface_circle"];
			lineImage = [UIImage imageNamed:@"surface_grid"];
			diffCircle = 3.0;
			diffLine = 1.0;
			
			_bubbleView = [[UIImageView alloc] initWithImage:circleImage];
			_bubbleView.center = CGPointMake(self.center.x + 6.0, self.center.y + diffCircle);
			
			// set up vial lines view
			_vialLinesView = [[UIImageView alloc] initWithImage:lineImage];
			_vialLinesView.center = CGPointMake(self.center.x + 1.0, self.center.y + diffLine);
			
		} else {
			NSString *imageName = IS_IPHONE35 ? @"bg_Inclinometer_bubble_480" : @"bg_Inclinometer_bubble";
			UIImageView *imageViewBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
			imageViewBubble.frame = [A3UIDevice screenBoundsAdjustedWithOrientation];
			[self addSubview:imageViewBubble];
			
			circleImage = [UIImage imageNamed:@"bubble_circle"];
			lineImage = [UIImage imageNamed:@"bubble_bar"];
			diffCircle = 0.0;
			diffLine = 0.0;
			
			_bubbleView = [[UIImageView alloc] initWithImage:circleImage];
			_bubbleView.center = CGPointMake(self.center.x - 22.0, self.center.y + diffCircle);
			
			// set up vial lines view
			_vialLinesView = [[UIImageView alloc] initWithImage:lineImage];
			_vialLinesView.center = CGPointMake(self.center.x, self.center.y + diffLine);
			
		}
#define	LABEL_WIDTH		150
#define LABEL_HEIGHT	20
#define BAR_HEIGHT		30
		
		CGRect frameLabel = CGRectMake(CGRectGetWidth(frame)/2 - LABEL_WIDTH/2  - 50, 
									   CGRectGetHeight(frame)/2 - LABEL_HEIGHT/2, 
									   LABEL_WIDTH, 
									   LABEL_HEIGHT);
		_degreeViewX = [[UILabel alloc] initWithFrame:frameLabel];
		_degreeViewX.textColor = [UIColor whiteColor];
		_degreeViewX.backgroundColor = [UIColor clearColor];
		_degreeViewX.textAlignment = NSTextAlignmentCenter;
		_degreeViewX.font = [UIFont systemFontOfSize:24];

		if (_inclinometerMode == surfaceMode)
		{
			frameLabel = CGRectMake(CGRectGetWidth(frame)/2 - LABEL_WIDTH/2  - 50 + 25.0, 
									CGRectGetHeight(frame)/2 - LABEL_HEIGHT/2, 
									LABEL_WIDTH, 
									LABEL_HEIGHT);
			_degreeViewY = [[UILabel alloc] initWithFrame:frameLabel];
			_degreeViewY.textColor = [UIColor whiteColor];
			_degreeViewY.backgroundColor = [UIColor clearColor];
			_degreeViewY.textAlignment = NSTextAlignmentCenter;
			_degreeViewY.font = [UIFont systemFontOfSize:24];
		}
		else _degreeViewY = nil;

		// Transform for rotating textual display
		CATransform3D landscapeTransform = CATransform3DIdentity;
		landscapeTransform = CATransform3DRotate(landscapeTransform, DegreesToRadians(-90), 0, 0, 1);
		_degreeViewX.layer.transform = landscapeTransform;
		_degreeViewY.layer.transform = landscapeTransform;

		[self addSubview:_bubbleView];
		[self addSubview:_vialLinesView];
		[self addSubview:_degreeViewX];
		if (_inclinometerMode == surfaceMode) [self addSubview:_degreeViewY];
	}
    return self;
}

const float pitchVsDegree[] = {4.5, 9.5, 14.0, 18.5, 22.5, 26.5, 30.5, 33.75, 37.0, 40.0,42.5, 45, 47.3, 49.4, 51.3, 53.1, 54.8, 56.3, 57.7, 59.0, 60.3, 61.4, 62.4, 63.4};

#pragma mark -
#pragma mark === Actions ===
#pragma mark -

#define kMaxAngle				90.0
#define kHalfVialLengthBubble	94.0
#define kHalfVialLengthSurface	110.0

- (float) zoomAngle:(float)rads {
	float angle = -RadiansToDegrees(rads);
    float zoomAngle = angle * 3 ;  // real bubble floats up more rapidly than sine function
    
    if (zoomAngle > kMaxAngle) zoomAngle = kMaxAngle ;   // stop at the end
	if (zoomAngle < -kMaxAngle) zoomAngle = -kMaxAngle ; // stop at the other end
	
	return zoomAngle;
}

- (void)updateBubbleForRadian:(float)rads {
    float newY = self.center.y - sin(DegreesToRadians([self zoomAngle:rads])) * kHalfVialLengthBubble + 0.0;
    
    _bubbleView.center = CGPointMake(_bubbleView.center.x, newY);
}

- (NSString *) radianToPitchString:(float)radian {
	float angle = fabs(RadiansToDegrees(radian));
	int i;
	for (i = 0; i < 23; i++) {
		if (angle < (pitchVsDegree[i] + (pitchVsDegree[i+1] - pitchVsDegree[i])/2)) {
			break;
		}
	}
	NSString *pitch = [NSString stringWithFormat:@"%d/12",i+1];
	NSString *plusminus = (angle > pitchVsDegree[i])?@"+":@"-";
	return [pitch stringByAppendingString:plusminus];
}

- (NSString *) radianToAngleString:(float)radian {
	float angle = -RadiansToDegrees(radian);
	
    // limit it to no more or less than the maximum angle from level
    if (angle > kMaxAngle) angle = kMaxAngle;
    if (angle < -kMaxAngle) angle = -kMaxAngle;
    
    NSString *newAngleString = [NSString stringWithFormat:@"%0.1f", angle];
    return [newAngleString stringByAppendingString:@"º"];
}

- (NSString *) radianToSlopeString:(float)radian {
	float slope = 100*tan(radian);
	return [NSString stringWithFormat:@"%0.1f%%", slope];
}

- (void)updateReadoutForRadian:(float)radian {
	switch (_viewController.unit) {
		case degrees:
			_degreeViewX.text = [self radianToAngleString:radian];
			break;
		case slope:
			_degreeViewX.text = [self radianToSlopeString:-radian];
			break;
		case pitch:
			_degreeViewX.text = [self radianToPitchString:radian];
	}
}

- (void)updateBubbleForSurfaceWithRadianX:(float)radsX radianY:(float)radsY {
	float posX = sin(DegreesToRadians([self zoomAngle:radsX])) * kHalfVialLengthSurface;
	float posY = sin(DegreesToRadians([self zoomAngle:radsY])) * kHalfVialLengthSurface;
	float maxX;
	float maxY = sqrt(pow(kHalfVialLengthSurface, 2) - pow(posX, 2)) * ((posY < 0.0)?-1:1);
	if (posY > 0.0) maxY = fmin(posY, maxY); else maxY = fmax(posY, maxY);
	maxX = sqrt(pow(kHalfVialLengthSurface, 2) - pow(maxY, 2)) * ((posX < 0.0)?-1:1);
	if (posX > 0.0) maxX = fmin(posX, maxX); else maxX = fmax(posX, maxX);
    float newX = self.center.x - maxX + 6.0;
    float newY = self.center.y - maxY + 3.0;
	
    _bubbleView.center = CGPointMake(newX, newY);
}

- (void)updateReadoutForSurfaceWithRadianX:(float)radX radianY:(float)radY {
	switch (_viewController.unit) {
		case degrees:
			_degreeViewX.text = [self radianToAngleString:-radY];
			_degreeViewY.text = [self radianToAngleString:radX];
			break;
		case slope:
			_degreeViewX.text = [self radianToSlopeString:radY];
			_degreeViewY.text = [self radianToSlopeString:-radX];
			break;
		case pitch:
			_degreeViewX.text = [self radianToPitchString:radY];
			_degreeViewY.text = [self radianToPitchString:radX];
	}
}

- (void)updateToInclinationInRadians:(float)rads radianX:(float)radX radianY:(float)radY {
	if (_inclinometerMode == surfaceMode) {
		[self updateReadoutForSurfaceWithRadianX:-radX radianY:radY];
		[self updateBubbleForSurfaceWithRadianX:-radX radianY:-radY];
	} else {
        [self updateReadoutForRadian:rads];
        [self updateBubbleForRadian:rads];
	}
}

@end
