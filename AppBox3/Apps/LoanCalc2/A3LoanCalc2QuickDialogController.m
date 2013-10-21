//
//  A3LoanCalc2QuickDialogController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalc2QuickDialogController.h"

@interface A3LoanCalc2QuickDialogController ()

@end

@implementation A3LoanCalc2QuickDialogController

/*! This will make root element inside, don't pass over rootElement
 * \param parameter will be ignored.
 * \returns instance
 */
- (QuickDialogController *)initWithRoot:(QRootElement *)rootElement {
	QRootElement *ownRootElement = [self rootElement];

	self = [super initWithRoot:ownRootElement];
	if (self) {

	}

	return self;
}

- (QRootElement *)rootElement {
	QRootElement *root = [QRootElement new];
	root.grouped = YES;

	return root;
}


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
	self.navigationItem.titleView = [self titleView];
}

- (UISegmentedControl *)titleView {
	UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:@[@"Loan", @"Comparison"]];
	titleView.selectedSegmentIndex = 0;
	return titleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
