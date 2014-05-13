//
//  A3A3BatterStatusChooseColorCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3BatterStatusChooseColorCell.h"
#import "A3BatteryStatusManager.h"
#import "A3AppDelegate+appearance.h"
#import "UIImage+imageWithColor.h"

@implementation A3BatterStatusChooseColorCell
{
    NSArray * _colorArray;
    NSArray * _colorViewArray;
    NSInteger _selectedIndex;
    UIImageView * _selectMarkImageView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _selectedIndex = [A3BatteryStatusManager chosenThemeIndex];
        _colorArray = [NSArray arrayWithObjects:
                       [UIColor colorWithRed:253.0/255.0 green:158.0/255.0 blue:26.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:250.0/255.0 green:207.0/255.0 blue:37.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:165.0/255.0 green:222.0/255.0 blue:55.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:76.0/255.0 green:217.0/255.0 blue:76.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:32.0/255.0 green:214.0/255.0 blue:120.0/255.0 alpha:1.0],
                       
                       [UIColor colorWithRed:64.0/255.0 green:224.0/255.0 blue:208.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:90.0/255.0 green:200.0/255.0 blue:250.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:63.0/255.0 green:156.0/255.0 blue:250.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:107.0/255.0 green:105.0/255.0 blue:223.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:204.0/255.0 green:115.0/255.0 blue:225.0/255.0 alpha:1.0],
                       
                       [UIColor colorWithRed:246.0/255.0 green:104.0/255.0 blue:202.0/255.0 alpha:1.0],
                       [UIColor colorWithRed:198.0/255.0 green:156.0/255.0 blue:109.0/255.0 alpha:1.0],
                       nil];
        
        NSMutableArray * colorViewArray = [NSMutableArray new];
        NSInteger index = 0;
        for (UIColor *aColor in _colorArray) {
            UIButton * aView = [UIButton buttonWithType:UIButtonTypeCustom];
			aView.frame = CGRectMake(0.0, 0.0, 80.0, 88.0);
            aView.backgroundColor = aColor;
            aView.tag = index;
            [aView addTarget:self action:@selector(didSelectColorView:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:aView];
            [colorViewArray addObject:aView];
            
            index++;
        }
        _colorViewArray = colorViewArray;
        
        _selectMarkImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"check"] tintedImageWithColor:[A3AppDelegate instance].themeColor]];
        _selectMarkImageView.frame = CGRectMake(0.0, 0.0, 22.0, 22.0);
        [self.contentView addSubview:_selectMarkImageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self adjustConstraintLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)adjustConstraintLayout {

    NSInteger row;
    NSInteger column;
    NSInteger offsetX;
    NSInteger insetY;
    NSInteger inset;
    
//    if (IS_IPHONE) {
        row = 4;
        column = 3;
        offsetX = 20;
        insetY = 20;
        inset = 20;
//    } else {
//        row =3;
//        column = 4;
//        if (IS_PORTRAIT) {
//            offsetX = 40;
//            insetY = 54;
//            inset = 44;
//        } else {
//            offsetX = 32;
//            insetY = 62;
//            inset = 28;
//        }
//    }
    
    for (int i=0; i<_colorViewArray.count; i++) {
        UIButton * aView = [_colorViewArray objectAtIndex:i];
        CGRect rect = aView.frame;
        rect.origin.x = (aView.frame.size.width * (i % column)) + (offsetX * (i % column) + inset);
        rect.origin.y = (aView.frame.size.height * (i / column)) + (offsetX * (i / column) + insetY);
        aView.frame = rect;
        
        if (_selectedIndex == aView.tag) {
            //[self didSelectColorView:aView];
            aView.backgroundColor = [UIColor whiteColor];
            aView.layer.borderColor = [[_colorArray objectAtIndex:_selectedIndex] CGColor];
            aView.layer.borderWidth = 2.0;
            
            _selectMarkImageView.center = CGPointMake(aView.center.x, aView.center.y + 20.0);
        }
    }
}

- (void)didSelectColorView:(id)sender {
    UIButton * selectedButton = sender;
    if (_selectedIndex == selectedButton.tag) {
        return;
    }

    selectedButton.backgroundColor = [UIColor whiteColor];
    selectedButton.layer.borderColor = [[_colorArray objectAtIndex:selectedButton.tag] CGColor];
    selectedButton.layer.borderWidth = 2.0;
    
    _selectMarkImageView.center = CGPointMake(selectedButton.center.x, selectedButton.center.y + 10.0);
    
    UIButton * oldButton = [_colorViewArray objectAtIndex:_selectedIndex];
    oldButton.layer.borderWidth = 0.0;
    oldButton.backgroundColor = [_colorArray objectAtIndex:_selectedIndex];
    
    _selectedIndex = selectedButton.tag;
    [A3BatteryStatusManager setChosenTheme:[_colorArray objectAtIndex:_selectedIndex]];
    [A3BatteryStatusManager setChosenThemeIndex:_selectedIndex];

	[[NSNotificationCenter defaultCenter] postNotificationName:A3BatteryStatusThemeColorChanged object:nil];
}

@end
