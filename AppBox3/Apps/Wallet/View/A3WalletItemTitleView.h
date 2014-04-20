//
//  A3WalletItemTitleView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3WalletItemTitleView : UIView

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIButton *favoriteButton;

@property (nonatomic, assign) BOOL isEditMode;

@end
