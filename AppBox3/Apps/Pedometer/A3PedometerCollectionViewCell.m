//
//  A3PedometerCollectionViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3PedometerCollectionViewCell.h"
#import "Pedometer.h"
#import "A3PedometerViewController.h"
#import "A3BarChartBarView.h"
#import "A3PedometerHandler.h"
#import "A3PedometerHandler.h"

@interface A3PedometerCollectionViewCell()

@property (nonatomic, strong) UILabel *numberOfStepsLabel;
@property (nonatomic, strong) A3BarChartBarView *barGraphView;
@property (nonatomic, strong) UIImageView *floorsImageView;
@property (nonatomic, strong) UILabel *floorsAscendedLabel;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) MASConstraint *barGraphHeightConstraint;

@end

@implementation A3PedometerCollectionViewCell

- (void)awakeFromNib {
	[super awakeFromNib];

	[self setupSubviews];
}

- (void)setupSubviews {
	UIView *superview = self;

	[self addSubview:self.barGraphView];
	[_barGraphView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom).with.offset(-35);
		_barGraphHeightConstraint = make.height.equalTo(@40);
	}];

	[self addSubview:self.numberOfStepsLabel];

	[_numberOfStepsLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.bottom.equalTo(_barGraphView.top).with.offset(-4);
	}];

	[self addSubview:self.distanceLabel];

	[_distanceLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.bottom.equalTo(_barGraphView.bottom).with.offset(-4);
	}];

	[self addSubview:self.floorsImageView];
	[_floorsImageView makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.right).multipliedBy(0.3);
		make.bottom.equalTo(_distanceLabel.top).with.offset(-5);
	}];

	[self addSubview:self.floorsAscendedLabel];

	[_floorsAscendedLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.right).multipliedBy(0.7);
		make.bottom.equalTo(_distanceLabel.top).with.offset(-5);
	}];

	[self addSubview:self.dateLabel];

	[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(superview.centerX);
		make.bottom.equalTo(superview.bottom).with.offset(-10);
	}];
}

- (UILabel *)numberOfStepsLabel {
	if (!_numberOfStepsLabel) {
		_numberOfStepsLabel = [UILabel new];
		_numberOfStepsLabel.textAlignment = NSTextAlignmentCenter;
		_numberOfStepsLabel.font = IS_IOS9 ? [UIFont fontWithName:@".SFUIDisplay-SemiBold" size:13] : [UIFont boldSystemFontOfSize:13];
	}
	return _numberOfStepsLabel;
}

- (A3BarChartBarView *)barGraphView {
	if (!_barGraphView) {
		_barGraphView = [A3BarChartBarView new];
		_barGraphView.backgroundColor = [UIColor greenColor];
		_barGraphView.layer.cornerRadius = 8;
		_barGraphView.layer.masksToBounds = YES;
	}
	return _barGraphView;
}

- (UIImageView *)floorsImageView {
	if (!_floorsImageView) {
		_floorsImageView = [UIImageView new];
		_floorsImageView.image = [UIImage imageNamed:@"floor"];
	}
	return _floorsImageView;
}

- (UILabel *)floorsAscendedLabel {
	if (!_floorsAscendedLabel) {
		_floorsAscendedLabel = [UILabel new];
		_floorsAscendedLabel.font = IS_IOS9 ? [UIFont fontWithName:@".SFUIDisplay-SemiBold" size:12] : [UIFont boldSystemFontOfSize:12];
		_floorsAscendedLabel.textColor = [UIColor whiteColor];
		_floorsAscendedLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _floorsAscendedLabel;
}

- (UILabel *)distanceLabel {
	if (!_distanceLabel) {
		_distanceLabel = [UILabel new];
		_distanceLabel.font = IS_IOS9 ? [UIFont fontWithName:@".SFUIDisplay-SemiBold" size:12] : [UIFont boldSystemFontOfSize:12];
		_distanceLabel.textAlignment = NSTextAlignmentCenter;
		_distanceLabel.textColor = [UIColor whiteColor];
	}
	return _distanceLabel;
}

- (UILabel *)dateLabel {
	if (!_dateLabel) {
		_dateLabel = [UILabel new];
		_dateLabel.textColor = [UIColor blackColor];
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		_dateLabel.font = [UIFont systemFontOfSize:12];
	}
	return _dateLabel;
}

- (void)setPedometerData:(Pedometer *)pedometerData {
	_pedometerData = pedometerData;

	_numberOfStepsLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:_pedometerData.numberOfSteps];
	_numberOfStepsLabel.hidden = NO;
	_floorsAscendedLabel.text = [self.pedometerHandler.numberFormatter stringFromNumber:_pedometerData.floorsAscended];
	_distanceLabel.text = [self.pedometerHandler stringFromDistance:_pedometerData.distance];

	// [UIColor colorWithRed:252.0/255.0 green:82.0/255.0 blue:42.0/255.0 alpha:1.0] // Less than 50%
	// [UIColor colorWithRed:250.0/255.0 green:119.0/255.0 blue:47.0/255.0 alpha:1.0] // Less than 100%
	// [UIColor colorWithRed:112.0/255.0 green:182.0/255.0 blue:45.0/255.0 alpha:1.0] // More than or equal to 100%

	// 130% : self.itemSize.height - 35 = 100% : x,
	// x * 1.3 = (self.itemSize.height - 35) * 1.0;
	// x = (self.itemSize.height - 35) / 1.3;
	// 100% steps = 10,000 Steps.
	CGFloat goalSteps = [[NSUserDefaults standardUserDefaults] floatForKey:A3PedometerSettingsNumberOfGoalSteps];
	CGFloat barPercent = MIN(1.1, [pedometerData.numberOfSteps floatValue] / goalSteps);
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
	CGFloat heightForGoal = (flowLayout.itemSize.height - 35) / 1.2;
	FNLOG(@"height for Goal : %f", heightForGoal);
	CGFloat barHeight = heightForGoal * barPercent;
	_barGraphHeightConstraint.equalTo(@(barHeight));
	
	if (barHeight < 40) {
		_floorsImageView.hidden = YES;
		_floorsAscendedLabel.hidden = YES;
	} else {
		_floorsImageView.hidden = NO;
		_floorsAscendedLabel.hidden = NO;
	}
	if (barHeight < 20) {
		_distanceLabel.hidden = YES;
	} else {
		_distanceLabel.hidden = NO;
	}
	
	_barGraphView.drawBreakMark = NO;
	UIColor *color = [self.pedometerHandler colorForPercent:barPercent];
	_barGraphView.backgroundColor = color;
	_numberOfStepsLabel.textColor = color;
	if ([pedometerData.numberOfSteps floatValue] / goalSteps > 1.15) {
		_barGraphView.drawBreakMark = YES;
	}
	[_barGraphView setNeedsDisplay];
	[self layoutIfNeeded];
}

- (void)prepareAnimate {
	_numberOfStepsLabel.hidden = YES;
	_floorsImageView.hidden = YES;
	_floorsAscendedLabel.hidden = YES;
	_distanceLabel.hidden = YES;
	_barGraphHeightConstraint.equalTo(@0);
	[self layoutIfNeeded];
}

- (void)animateBarCompletion:(void (^)(BOOL finished))completion {
	[UIView animateWithDuration:0.8
					 animations:^{
						 [self setPedometerData:_pedometerData];
					 } completion:completion];
}

@end
