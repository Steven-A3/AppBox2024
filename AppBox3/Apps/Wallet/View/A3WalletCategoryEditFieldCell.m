//
//  A3WalletCategoryEditFieldCell.m
//  AppBox3
//
//  Created by A3 on 4/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletCategoryEditFieldCell.h"

@interface A3WalletCategoryEditFieldCell ()
@property (nonatomic, weak) IBOutlet UIImageView *arrowImage;
@end

@implementation A3WalletCategoryEditFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect frame = self.textLabel.frame;
	frame.origin.x = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	self.textLabel.frame = frame;
	self.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);
}

@end
