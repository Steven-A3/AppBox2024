//
//  A3WalletPhotoItemTitleView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 8..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleView.h"

@interface A3WalletPhotoItemTitleView : A3WalletItemTitleView

@property (strong, nonatomic) IBOutlet UILabel *fileNameLB;
@property (strong, nonatomic) IBOutlet UILabel *imgSizeLB;
@property (strong, nonatomic) IBOutlet UILabel *fileSizeLB;
@property (strong, nonatomic) IBOutlet UILabel *takenDateLB;

@end
