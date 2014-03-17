//
//  A3LoanCalcLoanInfo3Cell.m
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 17..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcLoanInfo3Cell.h"
#import "A3TripleCircleView.h"

@implementation A3LoanCalcLoanInfo3Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UILabel *valueLB in _downValueLBs) {
        float endX = self.bounds.size.width - 15;
        CGRect rect = valueLB.frame;
        rect.origin.x = endX-rect.size.width;
        valueLB.frame = rect;
    }
    
    if (IS_RETINA) {
        for (UIView *line in _hori1PxLines) {
            CGRect rect = line.frame;
            rect.size.height = 0.5;
            line.frame = rect;
        }
    }
}

- (void)setValueCount:(NSUInteger)valueCount
{
    _valueCount = valueCount;
    
    if (self.downTitleLBs) {
        for (UIView *lb in _downTitleLBs) {
            [lb removeFromSuperview];
        }
    }
    
    if (self.downValueLBs) {
        for (UIView *lb in _downValueLBs) {
            [lb removeFromSuperview];
        }
    }
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    UIFont *titleFont = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
    UIFont *valueFont = IS_IPAD ? [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline] : [UIFont systemFontOfSize:15.0];
    UIColor *titleColor = [UIColor blackColor];
    UIColor *valueColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    
    //float startX = IS_IPAD ? 73 : 60;
    float startX = IS_IPAD ? 28 : 15;
    float startY = IS_IPAD ? 96.0 : 96 - 23;
    float endX = self.bounds.size.width - 15;
    float titleWidth = 200;
    float valueWidth = 400;
    float titleHeight = 20.0;
    float valueHeight = 20.0;
    CGPoint titleStartPos = CGPointMake(startX, startY);
    CGPoint valueStartPos = CGPointMake(endX-valueWidth, startY);
    float yIncrease = 22.0;
    
    for (int i=0; i<_valueCount; i++) {
        CGRect titleRect = CGRectMake(titleStartPos.x, titleStartPos.y+yIncrease*i, titleWidth, titleHeight);
        CGRect valueRect = CGRectMake(valueStartPos.x, valueStartPos.y+yIncrease*i, valueWidth, valueHeight);;
        
        UILabel *titleLB = [[UILabel alloc] initWithFrame:titleRect];
        UILabel *valueLB = [[UILabel alloc] initWithFrame:valueRect];
        valueLB.textAlignment = NSTextAlignmentRight;
        
        titleLB.font = titleFont;
        valueLB.font = valueFont;
        
        titleLB.textColor = titleColor;
        valueLB.textColor = valueColor;
        
        titleLB.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        valueLB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [titles addObject:titleLB];
        [values addObject:valueLB];
        
        [self.contentView addSubview:titleLB];
        [self.contentView addSubview:valueLB];
    }
    
    self.downTitleLBs = titles;
    self.downValueLBs = values;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    A3TripleCircleView *circleView = [A3TripleCircleView new];
	circleView.frame = CGRectMake(0, 0, 31, 31);
	[_lineView addSubview:circleView];
    circleView.center = CGPointMake(_lineView.bounds.size.width, _lineView.bounds.size.height/2);
    circleView.centerColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
}

+ (float)heightForValueCount:(NSUInteger) count
{
    float baseHeight = IS_IPAD ? 194.0 : 194-23;
    
    switch (count) {
        case 4:
            return baseHeight;
            break;
        case 5:
            return baseHeight+22.0;
            break;
        case 6:
            return baseHeight+22.0*2;
            break;
        case 7:
            return baseHeight+22.0*3;
            break;
        case 8:
            return baseHeight+22.0*4;
            break;
            
        default:
            return baseHeight;
            break;
    }
}

@end
