//
//  A3DaysCounterLocationPopupViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterLocationPopupViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "DaysCounterEventLocation.h"

@interface A3DaysCounterLocationPopupViewController ()
@property (strong, nonatomic) NSString *addressStr;
@property (nonatomic) BOOL isFullPrint;
@end

@implementation A3DaysCounterLocationPopupViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _locationItem.name;
    if ( self.showDoneButton )
        [self rightBarButtonDoneButton];
    
    self.addressStr = [[A3DaysCounterModelManager sharedManager] addressFromVenue:_locationItem isDetail:YES];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    if (IS_IPAD) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"information"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(detailInfoButtonTouchUp:)];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
//                                                                                  style:UIBarButtonItemStylePlain
//                                                                                 target:self
//                                                                                 action:@selector(doneButtonAction:)];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_shrinkPopoverViewBlock) {
        _shrinkPopoverViewBlock(self.view.frame.size);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.popoverVC = nil;
}

#pragma mark
- (void)detailInfoButtonTouchUp:(UIBarButtonItem *)item {
    self.isFullPrint = !_isFullPrint;
    if (self.resizeFrameBlock) {
        if (_isFullPrint) {
            _resizeFrameBlock(CGSizeMake(CGRectGetWidth(self.view.frame), self.tableView.contentSize.height));
        }
        else {
            _resizeFrameBlock(CGSizeMake(CGRectGetWidth(self.view.frame), 0));
        }
    }
}

- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self.popoverVC dismissPopoverAnimated:YES];
    if (_dismissCompletionBlock) {
        _dismissCompletionBlock(_locationItem);
    }
}
                                                  

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if ( cell == nil ) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterLocationDetailCell" owner:nil options:nil] lastObject];
    }
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:10];
    UILabel *detailTextLabel = (UILabel*)[cell viewWithTag:11];
    
    if ( indexPath.row == 0 ) {
        textLabel.text = @"Phone";
        detailTextLabel.text = _locationItem.contact;
        cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
    }
    else {
        textLabel.text = @"Address";
        detailTextLabel.text = _addressStr;
        cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(cell.contentView.frame), 0, 0);
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        NSString *str = (indexPath.row == 0 ? _locationItem.contact : _addressStr);
        CGRect rect = [str boundingRectWithSize:CGSizeMake(tableView.frame.size.width - 35.0, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] }
                                        context:nil];
        CGFloat retHeight = 15.0 + 17.0 + 10.0 + ceilf(rect.size.height) + 15.0;
        
        return retHeight;
    }
    
    return 44.0;
}



@end
