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
#import "UIImage+imageWithColor.h"
#import "WalletData.h"

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
    
    self.navigationItem.title = NSLocalizedString(@"Edit Image", @"Edit Image");

	UIView *superview = self.view;
	[_contentView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.top.equalTo(superview.top).with.offset(99);
		CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
		make.height.equalTo(@( ( ([self.iconList count] / 5 + 1) * (30 + 20) + 20) * scale ) );
	}];

	CGFloat lineHeight = 1.0 / [[UIScreen mainScreen] scale];
	[_upperLine makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_contentView.left);
		make.right.equalTo(_contentView.right);
		make.top.equalTo(_contentView.top);
		make.height.equalTo( @(lineHeight) );
	}];
	
	[_lowerLine makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(_contentView.left);
		make.right.equalTo(_contentView.right);
		make.bottom.equalTo(_contentView.bottom);
		make.height.equalTo(@(lineHeight));
	}];
	
    [self addIconImages];
}

- (void)addIconImages
{
	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
    for (NSUInteger idx = 0; idx < self.iconList.count; idx++) {
        NSString *iconName = _iconList[idx];
        UIImage *icon = [[UIImage imageNamed:iconName] tintedImageWithColor:[UIColor colorWithRed:146.0/255.0 green:146.0/255.0 blue:146.0/255.0 alpha:1.0]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 30 * scale, 30 * scale);
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
        
        button.center = CGPointMake((xIdx*(35 + 30) + 15) * scale, (yIdx*(20 + 30) + 20) * scale);
        
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
        _iconList = [WalletData iconList];
    }
    
    return _iconList;
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(dismissedWalletIconController:)]) {
        [_delegate dismissedWalletIconController:self];
    }
    
	if (IS_IPAD) {
		[[[A3AppDelegate instance] rootViewController_iPad] dismissRightSideViewController];
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
