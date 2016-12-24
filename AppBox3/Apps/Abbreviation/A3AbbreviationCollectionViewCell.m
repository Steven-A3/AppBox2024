//
//  A3AbbreviationCollectionViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationCollectionViewCell.h"

@interface A3AbbreviationCollectionViewCell ()

@end

@implementation A3AbbreviationCollectionViewCell

+ (NSString *)reuseIdentifier {
	return @"abbreviationCollectionViewCell";
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	_roundedRectView.layer.cornerRadius = 10;
	_roundedRectView.layer.masksToBounds = YES;
}

@end
