//
//  A3DateCalcAddSubCell1.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcAddSubCell1.h"

@interface A3DateCalcAddSubCell1()
//@property (nonatomic, strong) MASConstraint *addLeftConst;
//@property (nonatomic, strong) MASConstraint *addRightConst;
//@property (nonatomic, strong) MASConstraint *addTopConst;
//@property (nonatomic, strong) MASConstraint *addBottomConst;
//
//@property (nonatomic, strong) MASConstraint *subLeftConst;
//@property (nonatomic, strong) MASConstraint *subRightConst;
//@property (nonatomic, strong) MASConstraint *subTopConst;
//@property (nonatomic, strong) MASConstraint *subBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonWidthConst;
@end

@implementation A3DateCalcAddSubCell1

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.addModeButton.isAddButton = YES;
    self.subModeButton.isAddButton = NO;
    
//    _addLeftConst.equalTo(@0);
//    _addTopConst.equalTo(@0);
//    _addBottomConst.equalTo(@(CGRectGetHeight(self.contentView.bounds)));
//    _addRightConst.equalTo(@(self.center.x));
//
//    _subLeftConst.equalTo(@(self.contentView.center.x));
//    _subTopConst.equalTo(@(0));
//    _subBottomConst.equalTo(@(CGRectGetHeight(self.contentView.bounds)));
//    _subRightConst.equalTo(@0);
    self.addButtonWidthConst.constant = CGRectGetWidth(self.contentView.bounds) / 2;
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
