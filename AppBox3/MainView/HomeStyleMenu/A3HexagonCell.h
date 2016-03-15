//
//  A3HexagonCell.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3HexagonCell : UICollectionViewCell

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, assign) BOOL enabled;

@end
