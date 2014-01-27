//
//  A3ChooseColorPhone.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ChooseColorPhone.h"
#import "A3ClockDataManager.h"

@interface A3ChooseColorPhone ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *colors;

@end

@implementation A3ChooseColorPhone {
	CGSize _contentSize;
}

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors
{
    self = [super initWithFrame:frame];
    if (self) {
		_colors = colors;

        UIView* viewCaption = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.f)];
        [viewCaption setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewCaption];
        
        UILabel* lbCaption = [[UILabel alloc] initWithFrame:viewCaption.frame];
        
        lbCaption.center = CGPointMake(self.center.x + 16, viewCaption.center.y);
        lbCaption.textAlignment = NSTextAlignmentLeft;
        lbCaption.textColor = [UIColor colorWithRed:109.f/255.f green:109.f/255.f blue:114.f/255.f alpha:1.f];
        lbCaption.text = @"CHOOSE COLOR";
        [self addSubview:lbCaption];
        
        UIButton* btnX = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

		[btnX addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: btnX];
        [btnX makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).with.offset(0);
            make.right.equalTo(self.right).with.offset(0);
            make.width.equalTo(@44.f);
            make.height.equalTo(@44.f);
        }];

        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 130)];
		_scrollView.scrollEnabled = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView setBackgroundColor:[UIColor colorWithRed:239.f / 255.f green:239.f / 255.f blue:244.f / 255.f alpha:1.f]];
		[self addSubview:_scrollView];

        [_scrollView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(viewCaption.bottom);
			make.centerX.equalTo(self.centerX);
			make.width.equalTo(self.width);
			make.height.equalTo(@130);
		}];
        
        [self addColors];
    }
    return self;
}

- (void)addColors
{
	NSUInteger numberOfColors = [_colors count];
    UIButton* viewPre = nil;
    
    for(int i = 0; i < numberOfColors; i++)
    {
        UIColor* clr = [_colors objectAtIndex:i];
        
        UIButton* btnClr = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClr setBackgroundColor:clr];
		[btnClr addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchDown];

        [_scrollView addSubview:btnClr];
        
        [btnClr makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_scrollView.top).with.offset(20);
            
            if(viewPre == nil)
                make.left.equalTo(_scrollView.left).with.offset(15);
            else
                make.left.equalTo(viewPre.right).with.offset(10);
            
            make.width.equalTo(@44);
            make.height.equalTo(@88);
        }];
        
        viewPre = btnClr;
    }
	_contentSize = CGSizeMake(44 * numberOfColors + 10 * (numberOfColors - 1) + 30, _scrollView.bounds.size.height);
	_scrollView.contentSize = _contentSize;
	FNLOG(@"%f, %f", _scrollView.contentOffset.x, _scrollView.contentOffset.y);
	FNLOG(@"%d", _scrollView.bounces);
	FNLOG(@"%f, %f, %f, %f ", _scrollView.contentInset.top, _scrollView.contentInset.left, _scrollView.contentInset.right, _scrollView.contentInset.bottom);
	FNLOGRECT(_scrollView.frame);
	FNLOG(@"%f, %f", _scrollView.contentSize.width, _scrollView.contentSize.height);
}

- (void)layoutSubviews {
	[super layoutSubviews];

	FNLOG(@"%f, %f", _scrollView.contentSize.width, _scrollView.contentSize.height);
	_scrollView.contentSize = _contentSize;
}

@end
