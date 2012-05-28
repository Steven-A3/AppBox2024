//
//  A3MainViewController.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 4/25/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "CoolButton.h"

@interface A3MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet CoolButton *editButton;
@property (weak, nonatomic) IBOutlet CoolButton *plusButton;
@property (weak, nonatomic) IBOutlet UIView *hotMenuView;
@property (weak, nonatomic) IBOutlet UIView *leftGradientHotMenuView;
@property (weak, nonatomic) IBOutlet UIView *rightGradientHotMenuView;
@property (weak, nonatomic) IBOutlet UIView *leftGradientOnMenuView;
@property (weak, nonatomic) IBOutlet UIView *rightGradientOnMenuView;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

- (IBAction)editButtonTouchUpInside:(UIButton *)sender;

@end
