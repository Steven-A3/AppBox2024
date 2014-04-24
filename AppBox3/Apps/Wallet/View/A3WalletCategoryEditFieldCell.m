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

	FNLOGRECT(self.textLabel.frame);
	CGRect frame = self.textLabel.frame;
	frame.origin.x = 15;
	self.textLabel.frame = frame;
	FNLOG(@"%f", self.separatorInset.left);
	self.separatorInset = UIEdgeInsetsMake(0, 54, 0, 0);

	CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
	CGPoint center = _arrowImage.center;
	center.x = screenBounds.size.width - 118.0;
	_arrowImage.center = center;
}


@end
