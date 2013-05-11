//
//  A3SelectItemTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//



@interface A3SelectItemTableViewCell : QTableViewCell

@property (nonatomic, strong) UILabel *checkMark;

- (id)initWithReuseIdentifier:(NSString *)identifier;
@end
