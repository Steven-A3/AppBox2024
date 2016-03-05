//
//  A3GridMenuCollectionViewCell.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3GridMenuCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, strong) UILabel *titleLabel;

@end
