//
//  A3MainViewController.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "CoolButton.h"

@interface A3MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet CoolButton *editButton;
@property (nonatomic, strong) IBOutlet CoolButton *plusButton;
@property (nonatomic, strong) IBOutlet UIView *hotMenuView;
@property (nonatomic, strong) IBOutlet UIView *leftGradientHotMenuView;
@property (nonatomic, strong) IBOutlet UIView *rightGradientHotMenuView;
@property (nonatomic, strong) IBOutlet UIView *leftGradientOnMenuView;
@property (nonatomic, strong) IBOutlet UIView *rightGradientOnMenuView;
@property (nonatomic, strong) IBOutlet UITableView *menuTableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (IBAction)plusButtonTouchUpInside:(UIButton *)sender;

@end
