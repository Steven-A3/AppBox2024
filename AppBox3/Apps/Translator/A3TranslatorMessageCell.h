//
//  A3TranslatorMessageCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TranslatorHistory;
@class A3TranslatorMessageCell;

@protocol A3TranslatorMessageCellDelegate <NSObject>
- (void)cell:(A3TranslatorMessageCell *)cell longPressGestureRecognized:(UILongPressGestureRecognizer *)longPressGestureRecognizer;
@end

@interface A3TranslatorMessageCell : UITableViewCell

@property (nonatomic, strong) TranslatorHistory *messageEntity;
@property (nonatomic, strong) UIImageView *rightMessageView;
@property (nonatomic, strong) UIImageView *leftMessageView;
@property (nonatomic, weak) id<A3TranslatorMessageCellDelegate> delegate;

+ (CGFloat)cellHeightWithData:(TranslatorHistory *)data bounds:(CGRect)bounds;
@end
