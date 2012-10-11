//
//  A3CalendarListViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3CalendarListViewController.h"
#import "CoolButton.h"
#import "A3CalendarEventPropertyDelegateAndDataSource.h"
#import "A3CalendarEventsDelegateAndDataSource.h"

@interface A3CalendarListViewController ()

@property (nonatomic, strong) IBOutlet A3CalendarEventPropertyDelegateAndDataSource *eventPropertyDelegateAndDataSource;
@property (nonatomic, strong) IBOutlet A3CalendarEventsDelegateAndDataSource *eventsDelegateAndDataSource;
@property (nonatomic, strong) IBOutlet UITableView *eventsTableView;
@property (nonatomic, strong) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *eventDateLabel;
@property (nonatomic, strong) IBOutlet CoolButton *editButton;

@end

@implementation A3CalendarListViewController
@synthesize eventTitleLabel = _eventTitleLabel;
@synthesize eventDateLabel = _eventDateLabel;
@synthesize eventPropertyDelegateAndDataSource = _eventPropertyDelegateAndDataSource;
@synthesize eventsDelegateAndDataSource = _eventsDelegateAndDataSource;
@synthesize eventsTableView = _eventsTableView;
@synthesize editButton = _editButton;


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

	[self.eventsTableView.layer setBorderWidth:1.0f];
	[self.eventsTableView.layer setBorderColor:[UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.9f/255.0f alpha:1.0f].CGColor];
	[self.editButton setButtonColor:[UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)editButtonAction:(CoolButton *)editButton {

}

@end
