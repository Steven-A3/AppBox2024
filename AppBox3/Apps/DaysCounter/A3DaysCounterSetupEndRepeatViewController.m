//
//  A3DaysCounterSetupEndRepeatViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupEndRepeatViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3Formatter.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"
#import "SFKImage.h"

@interface A3DaysCounterSetupEndRepeatViewController ()
@property (strong,nonatomic) NSArray *itemArray;
@property (strong, nonatomic) A3DateKeyboardViewController *keyboardVC;
@property (strong, nonatomic) NSDate *originalValue;

- (void)updateConstraints;
- (void)showKeyboard;
- (void)hideKeyboard;
- (void)cancelAction:(id)sender;
@end

@implementation A3DaysCounterSetupEndRepeatViewController
- (void)updateConstraints
{
    [self.view removeConstraints:self.view.constraints];
    if ( self.keyboardVC ) {
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.keyboardVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height - self.keyboardVC.view.frame.size.height);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.keyboardVC.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardVC.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:self.keyboardVC.view.frame.size.height]];
    }
    else {
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
}

- (void)showKeyboard
{
    //    if ( IS_IPHONE ) {
    if ( self.keyboardVC || [self.keyboardVC.view isDescendantOfView:self.view]) {
        return;
    }
    
    self.keyboardVC = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
    self.keyboardVC.delegate = self;
    self.keyboardVC.view.frame = CGRectMake(0, self.view.frame.size.height - self.keyboardVC.view.frame.size.height, self.keyboardVC.view.frame.size.width, self.keyboardVC.view.frame.size.height);
    [self.view addSubview:self.keyboardVC.view];
    //    }
    //    else {
    //        self.keyboardVC = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
    //        self.keyboardVC.delegate = self;
    //        [self.view addSubview:self.keyboardVC.view];
    //    }
}

- (void)hideKeyboard
{
    if ( IS_IPHONE ) {
        [self.keyboardVC.view removeFromSuperview];
        self.keyboardVC.delegate = nil;
        self.keyboardVC = nil;
        [self updateConstraints];
    }
    else {
        self.keyboardVC.delegate = nil;
        self.keyboardVC = nil;
    }
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
    // Do any additional setup after loading the view from its nib.
    if ( IS_IPAD ) {
        self.originalValue = [_eventModel objectForKey:EventItem_RepeatEndDate];
    }
    self.title = @"End Repeat";
    
    self.itemArray = @[@"Never",@"Custom"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"";
    if ( indexPath.row == ([_itemArray count] - 1) && [[_eventModel objectForKey:EventItem_RepeatEndDate] isKindOfClass:[NSDate class]]) {
        cell.detailTextLabel.text = [A3Formatter stringFromDate:[_eventModel objectForKey:EventItem_RepeatEndDate] format:DaysCounterDefaultDateFormat];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if ( indexPath.row == 0 && [[_eventModel objectForKey:EventItem_RepeatEndDate] isKindOfClass:[NSNull class]] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id prevValue = [_eventModel objectForKey:EventItem_RepeatEndDate];
    NSInteger prevIndex = 0;
    if ( [prevValue isKindOfClass:[NSNull class]] ) {
        prevIndex = 0;
    }
    else {
        prevIndex = 1;
    }
    
    id value = ( indexPath.row == 0 ? [NSNull null] : [NSDate date] );
    [_eventModel setObject:value forKey:EventItem_RepeatEndDate];
    [tableView beginUpdates];
    if ( prevIndex != indexPath.row ) {
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    if ( indexPath.row == ( [_itemArray count] -1 )) {
        [self showKeyboard];
    }
    else {
        [self hideKeyboard];
        [self doneButtonAction:nil];
    }
}

#pragma mark - A3DateKeyboardDelegate
- (void)dateKeyboardValueChangedDate:(NSDate *)date
{
    if ( date == nil ) {
        return;
    }
    
    [_eventModel setObject:date forKey:EventItem_RepeatEndDate];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dateKeyboardDoneButtonPressed:(A3DateKeyboardViewController *)keyboardViewController {
    [self doneButtonAction:nil];
}

#pragma mark - action method
- (void)cancelAction:(id)sender
{
    [_eventModel setObject:self.originalValue forKey:EventItem_RepeatEndDate];
    if ( IS_IPAD ) {
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    if ( IS_IPAD ) {
        [self.A3RootViewController dismissRightSideViewController];
        [self.A3RootViewController.centerNavigationController viewWillAppear:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock();
    }
}

@end
