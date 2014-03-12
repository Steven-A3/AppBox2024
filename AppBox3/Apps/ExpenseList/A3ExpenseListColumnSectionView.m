//
//  A3ExpenseListColumnSectionView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 25..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListColumnSectionView.h"
#import "A3DefaultColorDefines.h"
#import "A3ExpenseListDefines.h"
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
    //_addItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _qtyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    //[_addItemButton setBackgroundImage:[UIImage imageNamed:@"add03"] forState:UIControlStateNormal];
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
    
//    _itemLabel.font = IS_IPHONE ? [UIFont fontWithName:@"Helvetica Neue" size:11.0] : FONT_TABLE_SECTION_TITLE;
//    _priceLabel.font = IS_IPHONE ? [UIFont fontWithName:@"Helvetica Neue" size:11.0] : FONT_TABLE_SECTION_TITLE;
//    _qtyLabel.font = IS_IPHONE ? [UIFont fontWithName:@"Helvetica Neue" size:11.0] : FONT_TABLE_SECTION_TITLE;
//    _subTotalLabel.font = IS_IPHONE ? [UIFont fontWithName:@"Helvetica Neue" size:11.0] : FONT_TABLE_SECTION_TITLE;
    
    //[self addSubview:_addItemButton];
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
//    NSNumber *leadingAdd;
//    NSNumber *leadingItem;
//    NSNumber *leadingPrice;
//    NSNumber *leadingQty;
//    NSNumber *leadingSubTotal;
    
//    float width = self.frame.size.width;
//    if (IS_IPHONE) {
//        leadingAdd = @(width/100.0 * (17.0/320.0*100));
//        //leadingItem = @(width/100.0 * (70.0/320.0*100));
//        leadingItem = @(width/100.0 * (62.5/320.0*100));
//        leadingPrice = @(width/100.0 * (166.0/320.0*100));
//        leadingQty = @(width/100.0 * (222.0/320.0*100));
//        leadingSubTotal = @(width/100.0 * (260.0/320.0*100));
//    } else {
//        leadingAdd = @(width/100.0 * (17.0/320.0*100));
//        leadingItem = @172;
//        leadingPrice = @409;
//        leadingQty = @518;
//        leadingSubTotal = @633;
//    }

    [_itemLabel makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE) {
            make.centerX.equalTo(self.left).with.offset(((SEP1_XPOS_IPHONE-15) / 2) + 15);
            
        } else {
            if (IS_LANDSCAPE) {
                _itemLabelConst = make.centerX.equalTo(self.left).with.offset(((SEP1_XPOS_IPAD_LAND - 28) / 2) + 28);
            } else {
                _itemLabelConst = make.centerX.equalTo(self.left).with.offset(((SEP1_XPOS_IPAD - 28) / 2) + 28);
            }
        }
        
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_priceLabel makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE) {
            make.centerX.equalTo(self.left).with.offset(SEP1_XPOS_IPHONE + ((SEP2_XPOS_IPHONE-SEP1_XPOS_IPHONE)/2));
            
        } else {
            if (IS_LANDSCAPE) {
                _priceLabelConst = make.centerX.equalTo(self.left).with.offset(SEP1_XPOS_IPAD_LAND + ((SEP2_XPOS_IPAD_LAND - SEP1_XPOS_IPAD_LAND) / 2));
            } else {
                _priceLabelConst = make.centerX.equalTo(self.left).with.offset(SEP1_XPOS_IPAD + ((SEP2_XPOS_IPAD - SEP1_XPOS_IPAD) / 2));
            }
        }
        
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_qtyLabel makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE) {
            make.centerX.equalTo(self.left).with.offset(SEP2_XPOS_IPHONE + ((SEP3_XPOS_IPHONE-SEP2_XPOS_IPHONE)/2));
            
        } else {
            if (IS_LANDSCAPE) {
                _qtyLabelConst = make.centerX.equalTo(self.left).with.offset(SEP2_XPOS_IPAD_LAND + ((SEP3_XPOS_IPAD_LAND - SEP2_XPOS_IPAD_LAND) / 2));
            } else {
                _qtyLabelConst = make.centerX.equalTo(self.left).with.offset(SEP2_XPOS_IPAD + ((SEP3_XPOS_IPAD - SEP2_XPOS_IPAD) / 2));
            }
        }
        
        make.centerY.equalTo(self.bottom).with.offset(-17);
    }];
    
    [_subTotalLabel makeConstraints:^(MASConstraintMaker *make) {
        
        if (IS_IPHONE) {
            make.centerX.equalTo(self.left).with.offset(SEP3_XPOS_IPHONE + ((self.frame.size.width-SEP3_XPOS_IPHONE)/2));
            
        } else {
            if (IS_LANDSCAPE) {
                _subTotalLabelConst = make.centerX.equalTo(self.left).with.offset(SEP3_XPOS_IPAD_LAND + ((self.frame.size.width - SEP3_XPOS_IPAD_LAND) / 2));
            } else {
                _subTotalLabelConst = make.centerX.equalTo(self.left).with.offset(SEP3_XPOS_IPAD + ((self.frame.size.width-SEP3_XPOS_IPAD)/2));
            }
        }
        
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
    
    if (IS_IPHONE) {
        _itemLabel.font = [UIFont systemFontOfSize:11.0];
        _priceLabel.font = [UIFont systemFontOfSize:11.0];
        _qtyLabel.font = [UIFont systemFontOfSize:11.0];
        _subTotalLabel.font = [UIFont systemFontOfSize:11.0];
        
    } else {
        
        if (IS_LANDSCAPE) {
            _itemLabelConst.equalTo(@0).with.offset(((SEP1_XPOS_IPAD_LAND - 28) / 2) + 28);
            _priceLabelConst.equalTo(@0).with.offset(SEP1_XPOS_IPAD_LAND + ((SEP2_XPOS_IPAD_LAND - SEP1_XPOS_IPAD_LAND) / 2));
            _qtyLabelConst.equalTo(@0).with.offset(SEP2_XPOS_IPAD_LAND + ((SEP3_XPOS_IPAD_LAND - SEP2_XPOS_IPAD_LAND) / 2));
            _subTotalLabelConst.equalTo(@0).with.offset(SEP3_XPOS_IPAD_LAND + ((self.frame.size.width - SEP3_XPOS_IPAD_LAND) / 2));
            
        } else {
            _itemLabelConst.equalTo(@0).with.offset(((SEP1_XPOS_IPAD - 28) / 2) + 28);
            _priceLabelConst.equalTo(@0).with.offset(SEP1_XPOS_IPAD + ((SEP2_XPOS_IPAD - SEP1_XPOS_IPAD) / 2));
            _qtyLabelConst.equalTo(@0).with.offset(SEP2_XPOS_IPAD + ((SEP3_XPOS_IPAD-SEP2_XPOS_IPAD) / 2));
            _subTotalLabelConst.equalTo(@0).with.offset(SEP3_XPOS_IPAD + ((self.frame.size.width-SEP3_XPOS_IPAD) / 2));
            
        }
        
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
