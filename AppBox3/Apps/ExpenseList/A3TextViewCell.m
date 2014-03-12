//
//  A3TextViewCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 1/26/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3TextViewCell.h"

@implementation A3TextViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textView = [UITextView new];
        [self addSubview:_textView];
        
        [_textView makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@(self.leftSeparatorInset-5));
            make.trailing.equalTo(self.right).with.offset(15);
            make.top.equalTo(self.top); 
            make.bottom.equalTo(self.bottom);
        }];
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textView = [UITextView new];
        [self addSubview:_textView];
        
        [_textView makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@(self.leftSeparatorInset-5));
            make.trailing.equalTo(self.right).with.offset(-15);
            make.top.equalTo(self.top);
            make.bottom.equalTo(self.bottom);
        }];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
