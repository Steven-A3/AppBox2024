//
//  A3HolidaysCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//


typedef NS_ENUM(NSUInteger, A3HolidayCellType) {
	A3HolidayCellTypeSingleLine = 0,	// Name -P Date
	A3HolidayCellTypeDoubleLine,		// Long Name
										// P Date
	A3HolidayCellTypeLunar1,			// Name	 - P Date
										// 		 -  Lunar
	A3HolidayCellTypeLunar2				// Name
										// P Date - Lunar
};

@interface A3HolidaysCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *lunarDateLabel;

@property (nonatomic, strong) UIView *publicMarkView;
@property (nonatomic, strong) UILabel *publicLabel;
@property (nonatomic, strong) UIImageView *lunarImageView;
@property (nonatomic) A3HolidayCellType	cellType;
@property (nonatomic, assign) BOOL showPublic;

- (void)assignFontsToLabels;
@end
