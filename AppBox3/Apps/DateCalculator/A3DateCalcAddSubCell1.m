//
//  A3DateCalcAddSubCell1.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcAddSubCell1.h"
#import "A3DateCalcAddSubButton.h"

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
        // Initialization code
//        [_addModeButton makeConstraints:^(MASConstraintMaker *make) {
//            _addLeftConst = make.leading.equalTo(self.contentView.left);
//            _addTopConst = make.top.equalTo(self.contentView.top);
//            _addBottomConst = make.bottom.equalTo(self.contentView.bottom);
//            _addRightConst = make.trailing.equalTo(self.contentView.centerX);
//        }];
//        
//        [_subModeButton makeConstraints:^(MASConstraintMaker *make) {
//            _subLeftConst = make.leading.equalTo(self.contentView.centerX);
//            _subTopConst = make.top.equalTo(self.contentView.top);
//            _subBottomConst = make.bottom.equalTo(self.contentView.bottom);
//            _subRightConst = make.trailing.equalTo(self.contentView.right);
//        }];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
//        [_addModeButton makeConstraints:^(MASConstraintMaker *make) {
//            self.addLeftConst = make.leading.equalTo(self.contentView.left);
//            self.addTopConst = make.top.equalTo(self.contentView.top);
//            self.addBottomConst = make.bottom.equalTo(self.contentView.bottom);
//            self.addRightConst = make.trailing.equalTo(self.contentView.centerX);
//        }];
//        
//        [_subModeButton makeConstraints:^(MASConstraintMaker *make) {
//            self.subLeftConst = make.leading.equalTo(self.contentView.centerX);
//            self.subTopConst = make.top.equalTo(self.contentView.top);
//            self.subBottomConst = make.bottom.equalTo(self.contentView.bottom);
//            self.subRightConst = make.trailing.equalTo(self.contentView.right);
//        }];
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
