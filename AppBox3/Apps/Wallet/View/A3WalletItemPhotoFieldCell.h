//
//  A3WalletItemPhotoFieldCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField.h"

@interface A3WalletItemPhotoFieldCell : UITableViewCell


@property (strong, nonatomic) IBOutlet JVFloatLabeledTextField *valueTxtFd;
@property (strong, nonatomic) IBOutlet UIButton *photoButton;

@end
