//
//  A3LoanCalcAmortizationViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/5/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3LoanCalcAmortizationViewController.h"
#import "LoanCalcHistory.h"
#import "NSNumberExtensions.h"
#import "LoanCalcHistory+calculation.h"
#import "NSString+conversion.h"
#import "common.h"


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
	}
	return _tableView;
}


- (UILabel *)labelWithFrame:(CGRect)frame withText:(NSString *)text {
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:18.0];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = text;
	return label;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	CGRect tableViewFrame = CGRectInset(self.view.bounds, 44.0, 0.0);
	tableViewFrame.origin.y += 52.0;
	tableViewFrame.size.height -= 96.0;
	FNLOG(@"%f, %f", tableViewFrame.size.width, tableViewFrame.size.height);
	self.tableView.frame = tableViewFrame;

	UIView *staticHeaderView = [self.view viewWithTag:2001];
	CGRect frame = _tableView.frame;
	frame.origin.y -= 32.0;
	frame.size.height = 30.0;
	staticHeaderView.frame = frame;

	frame = staticHeaderView.frame;
	frame.origin.y += 32.0;
	frame.size.height = 1.0;
	UIView *upperBorderLine = [self.view viewWithTag:2002];
	upperBorderLine.frame = frame;

	frame = tableViewFrame;
	frame.origin.y = frame.origin.y + frame.size.height;
	frame.size.height = 2.0;
	UIView *bottomLineView = [self.view viewWithTag:2003];
	bottomLineView.frame = frame;

	frame = tableViewFrame;
	frame.size.width = 1.0;
	for (NSInteger index = 0; index < 4; index++) {
		UIView *verticalLinView = [self.view viewWithTag:3001 + index];
		frame.origin.x += [_columnWidth[index] cgFloatValue];
		verticalLinView.frame = frame;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	FNLOG(@"Check");

	self.view.backgroundColor = [UIColor whiteColor];
	FNLOG(@"%f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
	CGRect tableViewFrame = CGRectInset(self.view.bounds, 44.0, 0.0);
	tableViewFrame.origin.y += 52.0;
	tableViewFrame.size.height -= 96.0;
	FNLOG(@"%f, %f", tableViewFrame.size.width, tableViewFrame.size.height);
	self.tableView.frame = tableViewFrame;
	[self.view addSubview:_tableView];
	_tableView.rowHeight = 31.0;

	_columnWidth = @[@96.0, @121.0, @122.0, @121.0, @167.0];

	NSArray *columnTitle = @[@"Date", @"Payment", @"Principal", @"Interest", @"Balance"];

	CGRect frame = _tableView.frame;
	frame.origin.y -= 32.0;
	frame.size.height = 30.0;
	UIView *staticHeaderView = [[UIView alloc] initWithFrame:frame];
	staticHeaderView.tag = 2001;
	staticHeaderView.backgroundColor = [UIColor colorWithRed:112.0/255.0 green:155.0/255.0 blue:192.0/255.0 alpha:1.0];
	[self.view addSubview:staticHeaderView];

	CGFloat offsetX = 0.0;
	for (NSInteger index = 0; index < 5; index++) {
		CGFloat width = [_columnWidth[index] cgFloatValue];
		frame = CGRectMake(offsetX, 0.0, width, 30.0);
		UILabel *titleLabel = [self labelWithFrame:frame withText:columnTitle[index]];
		[staticHeaderView addSubview:titleLabel];
		offsetX += width;
	}

	CGFloat height = tableViewFrame.size.height - 32.0;
	UIColor *verticalLineColor = [UIColor colorWithRed:181.0/255.0 green:204.0/255.0 blue:221.0/255.0 alpha:1.0];
	offsetX = 0.0;
	for (NSInteger index = 0; index < 4; index++) {
		offsetX += [_columnWidth[index] cgFloatValue];
		frame = CGRectMake(offsetX, 32.0, 1.0, height);
		UIView *verticalLineView = [[UIView alloc] initWithFrame:frame];
		verticalLineView.tag = 3001 + index;
		verticalLineView.backgroundColor = verticalLineColor;
		[self.view addSubview:verticalLineView];
	}

	frame = staticHeaderView.frame;
	frame.origin.y += 32.0;
	frame.size.height = 1.0;
	UIView *upperBorderLineView = [[UIView alloc] initWithFrame:frame];
	upperBorderLineView.tag = 2002;
	upperBorderLineView.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:132.0/255.0 blue:185.0/255.0 alpha:1.0];
	[self.view addSubview:upperBorderLineView];

	frame = staticHeaderView.frame;
	frame.origin.y = frame.origin.y + frame.size.height - 3.0;
	frame.size.height = 2.0;
	UIView *bottomLineView = [[UIView alloc] initWithFrame:frame];
	bottomLineView.tag = 2003;
	bottomLineView.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:162.0/255.0 blue:196.0/255.0 alpha:1.0];
	[self.view addSubview:bottomLineView];
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
		frame = CGRectMake(offsetX, -1.0, [_columnWidth[4] cgFloatValue], self.tableView.rowHeight - 1.0);
		UIView *rightBackground = [[UIView alloc] initWithFrame:frame];
		rightBackground.backgroundColor = [UIColor colorWithRed:214.0/255.0 green:228.0/255.0 blue:233.0/255.0 alpha:1.0];
		[cell insertSubview:rightBackground belowSubview:[cell viewWithTag:4]];

		frame = CGRectMake(0.0, self.tableView.rowHeight - 1, offsetX, 1.0);
		UIView *grayLineView = [[UIView alloc] initWithFrame:frame];
		grayLineView.backgroundColor = [UIColor lightGrayColor];
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
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(frame, 10.0, 5.0)];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:13.0];
	label.textColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0];
	label.textAlignment = NSTextAlignmentRight;
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
