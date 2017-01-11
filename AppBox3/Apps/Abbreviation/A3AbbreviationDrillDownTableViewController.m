//
//  A3AbbreviationDrillDownTableViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/3/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationDrillDownTableViewController.h"
#import "A3AbbreviationDrillDownTableViewCell.h"
#import "A3AppDelegate.h"

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyMeaning;

@interface A3AbbreviationDrillDownTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation A3AbbreviationDrillDownTableViewController

+ (NSString *)storyboardID {
	return @"A3AbbreviationDrillDownTableViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_titleLabel.text = _contentsTitle;
	_backButton.tintColor = [[A3AppDelegate instance] themeColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(UIButton *)backButton {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender {
	
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contentsArray count];
}

/* Expected Dictionary
 (
 {
 abbreviation = B4N;
 meaning = "Bye For Now ";
 tags = Top24;
 },
 .... 생략
 )
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    A3AbbreviationDrillDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[A3AbbreviationDrillDownTableViewCell reuseIdentifier] forIndexPath:indexPath];
	NSDictionary *content = _contentsArray[indexPath.row];
	cell.titleLabel.text = content[A3AbbreviationKeyAbbreviation];
	cell.subtitleLabel.text = content[A3AbbreviationKeyMeaning];
    return cell;
}

#pragma mark - UITableViewDelegate


@end
