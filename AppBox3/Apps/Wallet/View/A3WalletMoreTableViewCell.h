//
//  A3WalletMoreTableViewCell.h
//  AppBox3
//
//  Created by A3 on 4/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//



@interface A3WalletMoreTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkImageView;
@property (nonatomic, strong) UILabel *cellTitleLabel;
@property (nonatomic, strong) UIImageView *cellImageView;
@property (nonatomic, assign) BOOL showCheckImageView;

- (void)setShowCheckMark:(BOOL)showCheckMark;
@end
