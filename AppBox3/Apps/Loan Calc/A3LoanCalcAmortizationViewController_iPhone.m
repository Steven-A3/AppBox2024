//
//  A3LoanCalcAmortizationViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcAmortizationViewController_iPhone.h"
#import "LoanCalcHistory.h"
#import "LoanCalcHistory+calculation.h"
#import "A3LoanCalcAmortizationViewController.h"
#import "common.h"
#import "UIViewController+A3AppCategory.h"

@interface A3LoanCalcAmortizationViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UILabel *head1Label;
@property (nonatomic, weak) IBOutlet UILabel *head2Label;
@property (nonatomic, weak) IBOutlet UIView *amortizationView;
@property (nonatomic, weak) IBOutlet UILabel *tailLabel;
@property (nonatomic, strong) A3LoanCalcAmortizationViewController *amortizationViewController;

@end

@implementation A3LoanCalcAmortizationViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = @"Monthly Data";
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self addTopGradientLayerToView:self.view position:1.0];

	_amortizationViewController = [[A3LoanCalcAmortizationViewController alloc] initWithNibName:nil bundle:nil];
	_amortizationViewController.object = _object;
	_amortizationViewController.view.frame = _amortizationView.bounds;
	[_amortizationView addSubview:_amortizationViewController.view];
	[self addChildViewController:_amortizationViewController];
	[self.view addConstraints:
			@[
					[NSLayoutConstraint constraintWithItem:_amortizationViewController.view
												 attribute:NSLayoutAttributeLeft
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationView
												 attribute:NSLayoutAttributeLeft
												multiplier:1.0
												  constant:0.0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewController.view
												 attribute:NSLayoutAttributeTop
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationView
												 attribute:NSLayoutAttributeTop
												multiplier:1.0
												  constant:0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewController.view
												 attribute:NSLayoutAttributeWidth
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationView
												 attribute:NSLayoutAttributeWidth
												multiplier:1.0
												  constant:0.0],
					[NSLayoutConstraint constraintWithItem:_amortizationViewController.view
												 attribute:NSLayoutAttributeHeight
												 relatedBy:NSLayoutRelationEqual
													toItem:_amortizationView
												 attribute:NSLayoutAttributeHeight
												multiplier:1.0
												  constant:0.0]
			]
	];

	[self setHead1WithObject:_object];
	[self setHead2WithObject:_object];
	[self setDetailWithObject:_object];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3LoanCalcAmortizationViewController *)amortizationViewController {
	if (nil == _amortizationViewController) {
		_amortizationViewController = [[A3LoanCalcAmortizationViewController alloc] init];
	}
	return _amortizationViewController;
}

- (void)setHead1WithObject:(LoanCalcHistory *)object {
	NSMutableAttributedString *head1 = [[NSMutableAttributedString alloc] init];

	NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Principal " attributes:self.grayAttribute];
	[head1 appendAttributedString:string];

	string = [[NSAttributedString alloc] initWithString:object.principal attributes:self.greenAttribute];
	[head1 appendAttributedString:string];

	string = [[NSAttributedString alloc] initWithString:@" Interest " attributes:self.grayAttribute];
	[head1 appendAttributedString:string];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%%", [numberFormatter stringFromNumber:object.interestRatePerYear]] attributes:self.orangeAttribute];
	[head1 appendAttributedString:string];

	string = [[NSAttributedString alloc] initWithString:@" term " attributes:self.grayAttribute];
	[head1 appendAttributedString:string];

	string = [[NSAttributedString alloc] initWithString:object.termString attributes:self.blueAttribute];
	[head1 appendAttributedString:string];

	self.head1Label.attributedText = head1;
}

- (void)setHead2WithObject:(LoanCalcHistory *)object {
	NSMutableAttributedString *head2 = [[NSMutableAttributedString alloc] init];

	NSAttributedString *string;

	string = [[NSAttributedString alloc] initWithString:@"Your payment will be " attributes:self.grayAttribute];
	[head2 appendAttributedString:string];

	string = [[NSAttributedString alloc] initWithString:object.monthlyPaymentString attributes:self.skyAttribute];
	[head2 appendAttributedString:string];

	self.head2Label.attributedText = head2;
}

- (void)setDetailWithObject:(LoanCalcHistory *)object {
	NSMutableAttributedString *tail = [[NSMutableAttributedString alloc] init];

	NSAttributedString *string;

	string = [[NSAttributedString alloc] initWithString:@"Total Amount " attributes:self.tallGrayAttribute];
	[tail appendAttributedString:string];

	NSNumberFormatter *cf = [[NSNumberFormatter alloc] init];
	[cf setNumberStyle:NSNumberFormatterCurrencyStyle];
	string = [[NSAttributedString alloc] initWithString:[cf stringFromNumber:object.totalAmount] attributes:self.blackAttribute];
	[tail appendAttributedString:string];

	self.tailLabel.attributedText = tail;
}

- (NSDictionary *)blackAttribute {
	return @{NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0],
			NSForegroundColorAttributeName:[UIColor colorWithRed:63.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1.0]};
}

- (NSDictionary *)tallGrayAttribute {
	return @{NSFontAttributeName:[UIFont systemFontOfSize:14.0],
			NSForegroundColorAttributeName:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]};
}

- (NSDictionary *)grayAttribute {
	return @{NSFontAttributeName:[UIFont systemFontOfSize:12.0],
			NSForegroundColorAttributeName:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]};
}

- (NSDictionary *)greenAttribute {
	return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0],
			NSForegroundColorAttributeName : [UIColor colorWithRed:95.0 / 255.0 green:148.0 / 255.0 blue:1.0 / 255.0 alpha:1.0]};
}

- (NSDictionary *)orangeAttribute {
	return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0],
			NSForegroundColorAttributeName : [UIColor colorWithRed:235.0 / 255.0 green:107.0 / 255.0 blue:12.0 / 255.0 alpha:1.0]};
}

- (NSDictionary *)blueAttribute {
	return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0],
			NSForegroundColorAttributeName : [UIColor colorWithRed:14.0 / 255.0 green:96.0 / 255.0 blue:235.0 / 255.0 alpha:1.0]};
}

- (NSDictionary *)skyAttribute {
	return @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0],
			NSForegroundColorAttributeName : [UIColor colorWithRed:0.0 / 255.0 green:182.0 / 255.0 blue:180.0 / 255.0 alpha:1.0]};
}

@end
