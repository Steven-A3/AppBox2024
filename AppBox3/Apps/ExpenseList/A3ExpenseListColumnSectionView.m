//
//  A3ExpenseListColumnSectionView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 25..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListColumnSectionView.h"
#import "A3DefaultColorDefines.h"
#import "SFKImage.h"

@interface A3ExpenseListColumnSectionView()

@property (nonatomic, strong) UILabel *itemLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *qtyLabel;
@property (nonatomic, strong) UILabel *subTotalLabel;
@property (nonatomic, strong) MASConstraint *itemLabelConst;
@property (nonatomic, strong) MASConstraint *priceLabelConst;
@property (nonatomic, strong) MASConstraint *qtyLabelConst;
@property (nonatomic, strong) MASConstraint *subTotalLabelConst;

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@end

@implementation A3ExpenseListColumnSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:244.0/255.0 alpha:1.0];
        [self initializeSubviews];
        [self setupConstraintLayout];
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
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustLayoutSubviews];
    [super layoutSubviews];
}

- (void)initializeSubviews {
    _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _qtyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    if (IS_IPHONE) {
        _itemLabel.text = @"ITEM";
        _priceLabel.text = @"PRICE";
        _qtyLabel.text = @"QTY";
        _subTotalLabel.text = @"SUBTOTAL";
    } else {
        _itemLabel.text = @"ITEM";
        _priceLabel.text = @"PRICE";
        _qtyLabel.text = @"QUANTITY";
        _subTotalLabel.text = @"SUBTOTAL";
    }
    
    _itemLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    _priceLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    _qtyLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    _subTotalLabel.textColor = [UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:114.0/255.0 alpha:1.0];
    
    [self addSubview:_itemLabel];
    [self addSubview:_priceLabel];
    [self addSubview:_qtyLabel];
    [self addSubview:_subTotalLabel];
    
    _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _topLineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _bottomLineView.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [self addSubview:_topLineView];
    [self addSubview:_bottomLineView];
}

-(void)setupConstraintLayout
{
    CGFloat leftInset = IS_IPHONE ? 15 : 28;
    CGFloat sep1_Item = ceilf(CGRectGetWidth(self.frame) * 0.33);
    CGFloat sep2_Price = ceilf(CGRectGetWidth(self.frame) * 0.26);
    CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.frame) * 0.11);
    CGFloat sep4_Subtotal = leftInset + sep1_Item + sep2_Price + sep3_Quantity;
    
    [_itemLabel makeConstraints:^(MASConstraintMaker *make) {
        _itemLabelConst = make.centerX.equalTo(self.left).with.offset(leftInset + ceilf(sep1_Item / 2));
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_priceLabel makeConstraints:^(MASConstraintMaker *make) {
        _priceLabelConst = make.centerX.equalTo(self.left).with.offset(leftInset + sep1_Item + ceilf(sep2_Price / 2));
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_qtyLabel makeConstraints:^(MASConstraintMaker *make) {
        _qtyLabelConst = make.centerX.equalTo(self.left).with.offset(leftInset + sep1_Item + sep2_Price + ceilf(sep3_Quantity / 2));
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_subTotalLabel makeConstraints:^(MASConstraintMaker *make) {
        _subTotalLabelConst = make.centerX.equalTo(self.left).with.offset(sep4_Subtotal + (ceilf((CGRectGetWidth(self.frame) - sep4_Subtotal) / 2)) );
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_topLineView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.top.equalTo(self.top);
        make.height.equalTo(@0.5);
    }];
    [_bottomLineView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(@0.5);
    }];
}

-(void)adjustLayoutSubviews
{
    CGFloat leftInset = IS_IPHONE ? 15 : 28;
    CGFloat sep1_Item = ceilf(CGRectGetWidth(self.frame) * 0.33);
    CGFloat sep2_Price = ceilf(CGRectGetWidth(self.frame) * 0.26);
    CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.frame) * 0.11);
    CGFloat sep4_Subtotal = leftInset + sep1_Item + sep2_Price + sep3_Quantity;

    _itemLabelConst.equalTo(@0).with.offset(leftInset + ceilf(sep1_Item / 2));
    _priceLabelConst.equalTo(@0).with.offset(leftInset + sep1_Item + ceilf(sep2_Price / 2));
    _qtyLabelConst.equalTo(@0).with.offset(leftInset + sep1_Item + sep2_Price + ceilf(sep3_Quantity / 2));
    _subTotalLabelConst.equalTo(@0).with.offset(sep4_Subtotal + (ceilf((CGRectGetWidth(self.frame) - sep4_Subtotal) / 2)) );
    
    if (IS_IPHONE) {
        _itemLabel.font = [UIFont systemFontOfSize:11.0];
        _priceLabel.font = [UIFont systemFontOfSize:11.0];
        _qtyLabel.font = [UIFont systemFontOfSize:11.0];
        _subTotalLabel.font = [UIFont systemFontOfSize:11.0];
    }
    else {
        _itemLabel.font = [UIFont systemFontOfSize:14.0];
        _priceLabel.font = [UIFont systemFontOfSize:14.0];
        _qtyLabel.font = [UIFont systemFontOfSize:14.0];
        _subTotalLabel.font = [UIFont systemFontOfSize:14.0];
    }
    
    [_itemLabel sizeToFit];
    [_priceLabel sizeToFit];
    [_qtyLabel sizeToFit];
    [_subTotalLabel sizeToFit];
    
    
}
@end
