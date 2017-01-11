//
//  A3AbbreviationDrillDownTableViewCell.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/5/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3AbbreviationDrillDownTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

+ (NSString *)reuseIdentifier;

@end
