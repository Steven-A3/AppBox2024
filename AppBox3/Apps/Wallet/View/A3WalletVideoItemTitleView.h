//
//  A3WalletVideoItemTitleView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 29..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleView.h"

@interface A3WalletVideoItemTitleView : UIView

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

- (void)setupFonts;
@end
