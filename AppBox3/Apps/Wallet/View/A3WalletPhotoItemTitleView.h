//
//  A3WalletPhotoItemTitleView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 8..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleView.h"

@interface A3WalletPhotoItemTitleView : UIView

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UILabel *mediaSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *takenDateLabel;

- (void)setupFonts;
- (CGFloat)calculatedHeight;

@end
