//
//  A3SalesCalcViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcViewController.h"

@interface A3SalesCalcViewController ()

@end

@implementation A3SalesCalcViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		QRootElement *myRoot = [[QRadioElement alloc] init];
		myRoot.title = @"Sales Calc";
		myRoot.grouped = YES;

		QRadioSection *section1 = [[QRadioSection alloc] init];
		[section1 setTitle:@"Select Known Value"];
		[section1 setItems:@[@"Original Price", @"Sale Price"]];
		[section1 setSelected:0];
		[myRoot addSection:section1];

		QSection *section2 = [[QSection alloc] init];
		QEntryElement *price = [[QEntryElement alloc] initWithTitle:@"Price:" Value:@"" Placeholder:@"$0.00 USD"];
		[section2 addElement:price];
		QEntryElement *discount = [[QEntryElement alloc] initWithTitle:@"Discount:" Value:@"" Placeholder:@"0%"];
		[section2 addElement:discount];
		QEntryElement *additionalOff = [[QEntryElement alloc] initWithTitle:@"Additional Off" Value:@"" Placeholder:@"0%"];
		[section2 addElement:additionalOff];
		QEntryElement *tax = [[QEntryElement alloc] initWithTitle:@"Tax:" Value:@"" Placeholder:@"0%"];
		[section2 addElement:tax];
		QMultilineElement *notes = [QMultilineElement new];
		notes.title = @"Notes:";
		[section2 addElement:notes];
		QButtonElement *simple = [[QButtonElement alloc] initWithTitle:@"Simple"];
		[simple setControllerAction:@"onChangeType"];
		[section2 addElement:simple];

		[myRoot addSection:section2];

		[self setRoot:myRoot];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onChangeType:(QButtonElement *)buttonElement {

}

#pragma mark - QuickDialogStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {

}


@end
