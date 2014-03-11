//
//  A3WalletListPhotoCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WalletListPhotoCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *thumbImgViews;
@property (nonatomic, strong) UILabel *rightLabel;

- (void)resetThumbImages;
- (void)addThumbImage:(UIImage *)thumb;

@end
