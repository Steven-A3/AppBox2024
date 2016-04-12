//
//  A3QRCodeTextViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeTextViewController.h"

@interface A3QRCodeTextViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation A3QRCodeTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = @"Text";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextView *)textView {
	if (!_textView) {
		_textView = [UITextView new];
		_textView.font = [UIFont systemFontOfSize:17];
		[self.view addSubview:_textView];

		UIView *superview = self.view;
		[_textView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left).with.offset(10);
			make.top.equalTo(superview.top);
			make.right.equalTo(superview.right).with.offset(-10);
			make.bottom.equalTo(superview.bottom);
		}];
	}
	return _textView;
}

- (void)setText:(NSString *)text {
	_text = [text copy];
	self.textView.text = text;
}


@end
