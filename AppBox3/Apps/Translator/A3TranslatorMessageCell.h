//
//  A3TranslatorMessageCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TranslatorHistory;

@interface A3TranslatorMessageCell : UITableViewCell

@property (nonatomic, strong) TranslatorHistory *messageEntity;

+ (CGFloat)cellHeightWithData:(TranslatorHistory *)data bounds:(CGRect)bounds;
@end
