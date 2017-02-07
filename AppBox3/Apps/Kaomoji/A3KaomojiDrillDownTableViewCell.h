//
//  A3KaomojiDrillDownTableViewCell.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3KaomojiDrillDownTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+ (NSString *)reuseIdentifier;

@end
