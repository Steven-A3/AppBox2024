//
//  A3LoanCalcAmortizationViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcAmortizationViewController.h"
#import "LoanCalcHistory.h"
#import "NSNumberExtensions.h"
#import "LoanCalcHistory+calculation.h"
#import "NSString+conversion.h"
#import "common.h"
#import "A3UIDevice.h"


@interface A3LoanCalcAmortizationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)	NSArray *columnWidth;
@property (nonatomic, strong)	NSArray *amortizationTable;
@property (nonatomic, strong)	UITableView *tableView;

@end

@implementation A3LoanCalcAmortizationViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableView *)tableView {
	if (nil == _tableView) {
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.separatorColor = [UIColor clearColor];
		_tableView.rowHeight = IS_IPAD ? 31.0 : 20.0;
		_tableView.allowsSelection = NO;
	}
	return _tableView;
}


- (UILabel *)labelWithFrame:(CGRect)frame withText:(NSString *)text {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	CGFloat fontSize = IS_IPAD ? 18.0 : 12.0;
	label.font = [UIFont boldSystemFontOfSize:fontSize];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = text;
	return label;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	[super willMoveToParentViewController:parent];

	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	CGFloat rowHeight = IS_IPAD ? 30.0 : 20.0;
	CGFloat bottomMargin = 3.0;
	CGFloat topMargin = 2.0;
	CGRect frame = self.view.bounds;
	frame.origin.y += rowHeight + topMargin;
	frame.size.height -= rowHeight + bottomMargin + topMargin;
	self.tableView.frame = frame;
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.tableView];

	[self.view addConstraints:
			@[
					[NSLayoutConstraint constraintWithItem:_tableView
												 attribute:NSLayoutAttributeLeft
												 relatedBy:NSLayoutRelationEqual
													toItem:self.view
												 attribute:NSLayoutAttributeLeft
												multiplier:1.0
												  constant:0.0],
					[NSLayoutConstraint constraintWithItem:_tableView
												 attribute:NSLayoutAttributeTop
												 relatedBy:NSLayoutRelationEqual
													toItem:self.view
												 attribute:NSLayoutAttributeTop
												multiplier:1.0
												  constant:rowHeight + topMargin],
					[NSLayoutConstraint constraintWithItem:_tableView
												 attribute:NSLayoutAttributeBottom
												 relatedBy:NSLayoutRelationEqual
													toItem:self.view
												 attribute:NSLayoutAttributeBottom
												multiplier:1.0
												  constant:-bottomMargin],
					[NSLayoutConstraint constraintWithItem:_tableView
												 attribute:NSLayoutAttributeWidth
												 relatedBy:NSLayoutRelationEqual
													toItem:self.view
												 attribute:NSLayoutAttributeWidth
												multiplier:1.0
												  constant:0.0],
			]
	];

	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.tableView.frame);

	if (IS_IPAD) {
		_columnWidth = @[@96.0, @121.0, @122.0, @121.0, @167.0];
	} else {
		_columnWidth = @[@56.0, @70.0, @60.0, @54.0, @80.0];
	}

	NSArray *columnTitle = @[@"Date", @"Payment", @"Principal", @"Interest", @"Balance"];

	frame = self.view.bounds;
	frame.size.height = rowHeight + 1;
	UIView *staticHeaderView = [[UIView alloc] initWithFrame:frame];
	staticHeaderView.backgroundColor = [UIColor colorWithRed:112.0/255.0 green:155.0/255.0 blue:192.0/255.0 alpha:1.0];
	[self.view addSubview:staticHeaderView];

	CGFloat offsetX = 0.0;
	for (NSInteger index = 0; index < 5; index++) {
		CGFloat width = [_columnWidth[index] cgFloatValue];
		frame = CGRectMake(offsetX, 0.0, width, rowHeight);
		UILabel *titleLabel = [self labelWithFrame:frame withText:columnTitle[index]];
		[staticHeaderView addSubview:titleLabel];
		offsetX += width;
	}

	CGFloat height = self.view.bounds.size.height - (rowHeight + topMargin + bottomMargin);
	UIColor *verticalLineColor = [UIColor colorWithRed:181.0/255.0 green:204.0/255.0 blue:221.0/255.0 alpha:1.0];
	offsetX = 0.0;
	for (NSInteger index = 0; index < 4; index++) {
		offsetX += [_columnWidth[index] cgFloatValue];
		frame = CGRectMake(offsetX, rowHeight + topMargin + bottomMargin, 1.0, height);
		UIView *verticalLineView = [[UIView alloc] initWithFrame:frame];
		verticalLineView.tag = 3001 + index;
		verticalLineView.backgroundColor = verticalLineColor;
		verticalLineView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:verticalLineView];
		[self.view addConstraints:@[
				[NSLayoutConstraint constraintWithItem:verticalLineView
											 attribute:NSLayoutAttributeTop
											 relatedBy:NSLayoutRelationEqual
												toItem:self.view
											 attribute:NSLayoutAttributeTop
											multiplier:1.0
											  constant:rowHeight + topMargin],
				[NSLayoutConstraint constraintWithItem:verticalLineView
											 attribute:NSLayoutAttributeLeft
											 relatedBy:NSLayoutRelationEqual
												toItem:self.view
											 attribute:NSLayoutAttributeLeft
											multiplier:1.0
											  constant:offsetX],
				[NSLayoutConstraint constraintWithItem:verticalLineView
											 attribute:NSLayoutAttributeBottom
											 relatedBy:NSLayoutRelationEqual
												toItem:self.view
											 attribute:NSLayoutAttributeBottom
											multiplier:1.0
											  constant:-bottomMargin],
				[NSLayoutConstraint constraintWithItem:verticalLineView
											 attribute:NSLayoutAttributeWidth
											 relatedBy:NSLayoutRelationEqual
												toItem:nil
											 attribute:NSLayoutAttributeNotAnAttribute
											multiplier:1.0
											  constant:1.0]
		]];
	}

	frame = staticHeaderView.frame;
	frame.origin.y += rowHeight + topMargin;
	frame.size.height = 1.0;
	UIView *upperBorderLineView = [[UIView alloc] initWithFrame:frame];
	upperBorderLineView.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:132.0/255.0 blue:185.0/255.0 alpha:1.0];
	[self.view addSubview:upperBorderLineView];

	frame = self.view.bounds;
	frame.origin.y = frame.origin.y + frame.size.height - bottomMargin;
	frame.size.height = bottomMargin;
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:162.0/255.0 blue:196.0/255.0 alpha:1.0];
	bottomLineView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:bottomLineView];

	[self.view addConstraints:@[
			[NSLayoutConstraint constraintWithItem:bottomLineView
										 attribute:NSLayoutAttributeLeft
										 relatedBy:NSLayoutRelationEqual
											toItem:self.view
										 attribute:NSLayoutAttributeLeft
										multiplier:1.0
										  constant:0],
			[NSLayoutConstraint constraintWithItem:bottomLineView
										 attribute:NSLayoutAttributeTop
										 relatedBy:NSLayoutRelationEqual
											toItem:self.view
										 attribute:NSLayoutAttributeBottom
										multiplier:1.0
										  constant:-3.0],
			[NSLayoutConstraint constraintWithItem:bottomLineView
										 attribute:NSLayoutAttributeWidth
										 relatedBy:NSLayoutRelationEqual
											toItem:self.view
										 attribute:NSLayoutAttributeWidth
										multiplier:1.0
										  constant:0.0],
			[NSLayoutConstraint constraintWithItem:bottomLineView
										 attribute:NSLayoutAttributeHeight
										 relatedBy:NSLayoutRelationEqual
											toItem:nil
										 attribute:NSLayoutAttributeNotAnAttribute
										multiplier:1.0
										  constant:bottomMargin],
	]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.view.superview.frame);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_amortizationTable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

		CGFloat offsetX = 0.0, width;
		CGRect frame = CGRectMake(0.0, 0.0,[_columnWidth[0] cgFloatValue], self.tableView.rowHeight);
		UIView *leftbBackground = [[UIView alloc] initWithFrame:frame];
		leftbBackground.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:246.0/255.0 blue:247.0/255.0 alpha:1.0];
		[cell addSubview:leftbBackground];

		for (NSInteger index = 0; index < 5; index++) {
			width = [_columnWidth[index] cgFloatValue];
			frame = CGRectMake(offsetX, 0.0, width, self.tableView.rowHeight);
			UILabel *label = [self valueLabelViewFrame:frame withTag:index + 1];
			[cell addSubview:label];

			offsetX += width;
		}
		offsetX -= [_columnWidth[4] cgFloatValue];
		frame = CGRectMake(offsetX, 0.0, [_columnWidth[4] cgFloatValue], self.tableView.rowHeight);
		UIView *rightBackground = [[UIView alloc] initWithFrame:frame];
		rightBackground.backgroundColor = [UIColor colorWithRed:214.0/255.0 green:228.0/255.0 blue:233.0/255.0 alpha:1.0];
		[cell insertSubview:rightBackground belowSubview:[cell viewWithTag:4]];

		frame = CGRectMake(0.0, self.tableView.rowHeight - 1, offsetX, 1.0);
		UIView *grayLineView = [[UIView alloc] initWithFrame:frame];
		grayLineView.backgroundColor = [UIColor colorWithRed:202.0 / 255.0 green:202.0 / 255.0 blue:202.0 / 255.0 alpha:1.0];
		[cell addSubview:grayLineView];

		frame = CGRectMake(offsetX, self.tableView.rowHeight - 1, [_columnWidth[4] cgFloatValue], 1.0);
		UIView *whiteLine = [[UIView alloc] initWithFrame:frame];
		whiteLine.opaque = YES;
		whiteLine.backgroundColor = [UIColor whiteColor];
		[cell addSubview:whiteLine];
	}
	NSArray *value = [_amortizationTable objectAtIndex:(NSUInteger) indexPath.row];
	for (NSUInteger index = 0; index < 5; index++) {
		UILabel *label = (UILabel *) [cell viewWithTag:index + 1];
		label.text = value[index];
	}

    return cell;
}

- (UILabel *)valueLabelViewFrame:(CGRect)frame withTag:(NSInteger)tag {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(frame, IS_IPAD ? 10.0 : 1.0, 3.0)];
	label.backgroundColor = [UIColor clearColor];
	if (tag == 5) {
		label.font = [UIFont boldSystemFontOfSize:IS_IPAD ? 13.0 : 11.0];
		label.textColor = [UIColor colorWithRed:73.0/255.0 green:98.0/255.0 blue:145.0/255.0 alpha:1.0];
	} else {
		label.font = [UIFont systemFontOfSize:IS_IPAD ? 13.0 : 11.0];
		label.textColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0];
	}
	label.textAlignment = IS_IPAD ? NSTextAlignmentRight : NSTextAlignmentCenter;
	label.minimumScaleFactor = 0.5;
	label.adjustsFontSizeToFitWidth = YES;
	label.adjustsLetterSpacingToFitWidth = YES;
	label.tag = tag;

	return label;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)setObject:(LoanCalcHistory *)object {
	_object = object;
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date = _object.startDate != nil ? _object.startDate : [NSDate date];

	NSDateComponents *diff = [[NSDateComponents alloc] init];
	diff.month = 1;

	float payment = _object.monthlyPayment.floatValueEx;
	float balance = _object.principal.floatValueEx;
	float interest, principal;

	NSUInteger numberOfPayment = (NSUInteger) _object.termInMonth;
	NSMutableArray *amortizationTable = [[NSMutableArray alloc] initWithCapacity:numberOfPayment];

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"MMM, y"];

	[amortizationTable addObject:@[
			[df stringFromDate:date],
			@"",
			@"",
			@"",
			[nf stringFromNumber:@(balance)]
	]];

	for (NSInteger index = 0; index < numberOfPayment; index++) {
		date = [calendar dateByAddingComponents:diff toDate:date options:0];
		interest = balance * _object.monthlyInterestRate;
		principal = payment - interest;
		balance -= principal;

		[amortizationTable addObject:@[
				[df stringFromDate:date],
				[nf stringFromNumber:@(payment)],
				[nf stringFromNumber:@(principal)],
				[nf stringFromNumber:@(interest)],
				[nf stringFromNumber:@(balance)]
		]];
	}
	_amortizationTable = [NSArray arrayWithArray:amortizationTable];
}

@end
