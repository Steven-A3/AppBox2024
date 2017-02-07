//
//  A3KaomojiCollectionViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/6/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiCollectionViewCell.h"

@implementation A3KaomojiCollectionViewCell

+ (NSString *)reuseIdentifier {
	return @"kaomojiCollectionViewCell";
}

- (void)awakeFromNib {
	[super awakeFromNib];

	_roundedRectView.layer.cornerRadius = 10;
	_roundedRectView.layer.masksToBounds = YES;

}

@end
