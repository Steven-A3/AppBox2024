//
//  A3WalletIconSelectViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletIconSelectViewController.h"
#import "A3AppDelegate+appearance.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "UIImage+imageWithColor.h"

@interface A3WalletIconSelectViewController ()
{
    UIButton *selectedIconButton;
}

@property (nonatomic, strong) NSArray *iconList;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *upperLine;
@property (weak, nonatomic) IBOutlet UIView *lowerLine;

@end

@implementation A3WalletIconSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Edit Image";
    
    if (IS_RETINA) {
        CGRect upLine = _upperLine.frame;
        CGRect belowLine = _lowerLine.frame;
        
        upLine.size.height = 0.5f;
        belowLine.size.height = 0.5f;
        belowLine.origin.y += 0.5f;
        
        _upperLine.frame = upLine;
        _lowerLine.frame = belowLine;
    }
    
    [self addIconImages];
}

- (void)addIconImages
{
    for (NSUInteger idx = 0; idx < self.iconList.count; idx++) {
        NSString *iconName = _iconList[idx];
        UIImage *icon = [[UIImage imageNamed:iconName] tintedImageWithColor:[UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30, 30);
        button.tag = idx;
        [button setImage:icon forState:UIControlStateNormal];
        NSString *onImgName = [iconName stringByAppendingString:@"_on"];
		UIImage *selectedIcon = [[UIImage imageNamed:onImgName] tintedImageWithColor:[A3AppDelegate instance].themeColor];
		[button setImage:selectedIcon forState:UIControlStateSelected];
        [button setImage:selectedIcon forState:UIControlStateHighlighted];
        
        [button addTarget:self action:@selector(iconButtonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(iconButtonTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(iconButtonTouchOutsideAction:) forControlEvents:UIControlEventTouchUpOutside];
        
        button.layer.anchorPoint = CGPointMake(0, 0);

        NSUInteger xIdx, yIdx;
        yIdx = idx / 5;
        xIdx = idx % 5;
        
        button.center = CGPointMake(xIdx*(35+30)+15, yIdx*(20+30)+20);
        
        if ([iconName isEqualToString:_selecteIconName]) {
            [button setSelected:YES];
            
            selectedIconButton = button;
        }
        
        [_contentView addSubview:button];
    }
}

- (NSArray *)iconList
{
    if (!_iconList) {
        _iconList = [WalletCategory iconList];
    }
    
    return _iconList;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(dismissedWalletIconController:)]) {
        [_delegate dismissedWalletIconController:self];
    }
    
	if (IS_IPAD) {
		[self.A3RootViewController dismissRightSideViewController];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)iconButtonTouchUpAction:(UIButton *)button
{
    FNLOG(@"%ld", (long)button.tag);
    
    [button setSelected:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletIconSelected:)]) {
        [_delegate walletIconSelected:_iconList[button.tag]];
    }
    
    [self doneButtonAction:nil];
}

- (void)iconButtonTouchOutsideAction:(UIButton *)button
{
    FNLOG(@"%ld", (long)button.tag);
    
    if (button.highlighted) {
        [self iconButtonTouchUpAction:button];
    }
    else {
        if (selectedIconButton) {
            [selectedIconButton setSelected:YES];
        }
    }
}

- (void)iconButtonTouchDownAction:(UIButton *)button
{
    FNLOG(@"%ld", (long)button.tag);
    
    if (selectedIconButton) {
        [selectedIconButton setSelected:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
