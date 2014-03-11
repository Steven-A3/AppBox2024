//
//  A3WalletListBigPhotoCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WalletListBigPhotoCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *thumbImgViews;
@property (nonatomic, strong) UILabel *rightLabel;

- (void)resetThumbImages;
- (void)addThumbImage:(UIImage *)thumb;

@end
