//
//  A3MainViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3MainViewController.h"
#import "MenuItem.h"
#import "MenuGroup.h"
#import "common.h"

@interface A3MainViewController ()

@property (strong, nonatomic, readonly) NSFetchedResultsController *menusFetchedResultsController;

- (IBAction)editButtonTouchUpInside:(UIButton *)sender;

@end

@implementation A3MainViewController {
	NSFetchedResultsController *_menusFetchedResultsController;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize editButton = _editButton;
@synthesize plusButton = _plusButton;
@synthesize hotMenuView = _hotMenuView;
@synthesize leftGradientHotMenuView = _leftGradientHotMenuView;
@synthesize rightGradientHotMenuView = _rightGradientHotMenuView;
@synthesize leftGradientOnMenuView = _leftGradientOnMenuView;
@synthesize rightGradientOnMenuView = _rightGradientOnMenuView;
@synthesize menuTableView = _menuTableView;


- (void)addGradientLayer {
	CAGradientLayer *leftGradientHotMenuLayer = [CAGradientLayer layer];
	[leftGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(id)[[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:9.0/255.0 alpha:0.8] CGColor],
					(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[leftGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[leftGradientHotMenuLayer setBounds:[self.leftGradientHotMenuView bounds]];
	[leftGradientHotMenuLayer setStartPoint:CGPointMake(0.0, 0.5)];
	[leftGradientHotMenuLayer setEndPoint:CGPointMake(1.0, 0.5)];
	[[self.leftGradientHotMenuView layer] insertSublayer:leftGradientHotMenuLayer atIndex:1];

	CAGradientLayer *rightGradientHotMenuLayer = [CAGradientLayer layer];
	[rightGradientHotMenuLayer setColors:
			[NSArray arrayWithObjects:
					(id)[[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:9.0/255.0 alpha:0.8] CGColor],
					(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[rightGradientHotMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[rightGradientHotMenuLayer setBounds:[self.rightGradientHotMenuView bounds]];
	[rightGradientHotMenuLayer setStartPoint:CGPointMake(1.0, 0.5)];
	[rightGradientHotMenuLayer setEndPoint:CGPointMake(0.0, 0.5)];
	[[self.rightGradientHotMenuView layer] insertSublayer:rightGradientHotMenuLayer atIndex:1];

	CAGradientLayer *leftGradientOnMenuLayer = [CAGradientLayer layer];
	[leftGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(id)[[UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:0.8] CGColor],
					(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[leftGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[leftGradientOnMenuLayer setBounds:[self.leftGradientOnMenuView bounds]];
	[leftGradientOnMenuLayer setStartPoint:CGPointMake(0.0, 0.5)];
	[leftGradientOnMenuLayer setEndPoint:CGPointMake(1.0, 0.5)];
	[[self.leftGradientOnMenuView layer] insertSublayer:leftGradientOnMenuLayer atIndex:1];

	CAGradientLayer *rightGradientOnMenuLayer = [CAGradientLayer layer];
	[rightGradientOnMenuLayer setColors:
			[NSArray arrayWithObjects:
					(id)[[UIColor colorWithRed:32.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:0.8] CGColor],
					(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor],
					nil ] ];
	[rightGradientOnMenuLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[rightGradientOnMenuLayer setBounds:[self.rightGradientOnMenuView bounds]];
	[rightGradientOnMenuLayer setStartPoint:CGPointMake(1.0, 0.5)];
	[rightGradientOnMenuLayer setEndPoint:CGPointMake(0.0, 0.5)];
	[[self.rightGradientOnMenuView layer] insertSublayer:rightGradientOnMenuLayer atIndex:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self.editButton setButtonColor:[UIColor blackColor]];
    [self.plusButton setButtonColor:[UIColor blackColor]];

	[self addGradientLayer];
}

- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setPlusButton:nil];
    [self setHotMenuView:nil];
    [self setLeftGradientHotMenuView:nil];
    [self setRightGradientHotMenuView:nil];
    [self setLeftGradientOnMenuView:nil];
    [self setRightGradientOnMenuView:nil];
    [self setMenuTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	NSInteger numberOfSections = [[self.menusFetchedResultsController sections] count];
	FNLOG(@"%d", numberOfSections);

    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.menusFetchedResultsController sections] objectAtIndex:section];
	NSInteger numberOfRow = [sectionInfo numberOfObjects];
	FNLOG(@"number of rows in section %d = %d", section, numberOfRow);
	return numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
    
	MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:indexPath];
	
    // Configure the cell...
	cell.textLabel.text = menuItem.name;
	cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section {
	MenuItem *menuItem = [self.menusFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
	return menuItem.menuGroup.name;
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - UIAction selectors

- (IBAction)editButtonTouchUpInside:(UIButton *)sender {
    
}

- (NSFetchedResultsController *)menusFetchedResultsController {
	if (_menusFetchedResultsController == nil) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:[NSEntityDescription entityForName:@"MenuItem" inManagedObjectContext:self.managedObjectContext]];

		NSString *sectionNameKeyPath = @"menuGroup.order";
		NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"menuGroup.order" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES], nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		_menusFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];

		NSError *error;
		BOOL success = [_menusFetchedResultsController performFetch:&error];
		NSAssert3(success, @"Unhandled error performing fetch at %s, line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
	}
	return _menusFetchedResultsController;
}

@end
