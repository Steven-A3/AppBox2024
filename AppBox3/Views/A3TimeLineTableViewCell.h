//
//  A3TimeLineTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/6/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3TimeLineTableViewCell : UITableViewCell
@property (nonatomic, strong) UIImage *photo;

- (void)setTitle:(NSString *)title;

- (void)setSubtitle:(NSString *)subtitle;

- (void)setDatetimeText:(NSString *)datetimeText;

- (void)setLocationText:(NSString *)locationText;


@end
