//
//  A3PercentCalcMainViewController.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcMainViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3PercentCalcHeaderView.h"
#import "A3NumberKeyboardViewController.h"
#import "A3PercentCalcHistoryViewController.h"
#import "PercentCalcHistory.h"
#import "A3JHTableViewEntryCell.h"
#import "UIViewController+iPad_rightSideView.h"
#import "A3UserDefaults.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"


@interface A3PercentCalcMainViewController () <UITextFieldDelegate, A3PercentCalcHistoryDelegate>

@property (strong, nonatomic) A3PercentCalcHeaderView *headerView;
@property (strong, nonatomic) NSArray *sectionTitles;
@property (strong, nonatomic) NSArray *sections;
@property (assign, nonatomic) PercentCalcType calcType;
@property (copy, nonatomic) NSString *textBeforeEditingTextField;
@property (strong, nonatomic) UINavigationController *modalNavigationController;

@end

@implementation A3PercentCalcMainViewController
{
    NSNumber *_factorX1, *_factorY1;
    NSNumber *_factorX2, *_factorY2;
    NSNumber *_currentFactor;
    NSArray *_formattedFactorValues;
    
    CGFloat _tableYOffset, _oldTableOffset;
    A3NumberKeyboardViewController *_simpleNormalNumberKeyboard;
    NSIndexPath *_selectedIndexPath;
    NSIndexPath *_selectedOptionIndexPath;
    
    UILabel *_sectionALabel, *_sectionBLabel;
    UIImage *_blankImage;
    BOOL _prevShow, _nextShow;
    BOOL _isKeyboardShown;
	BOOL _cancelInputNewCloudDataReceived;
	BOOL _barButtonEnabled;
}

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		
	}
	
	return self;
}

- (void)cleanUp {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = IS_IPHONE ? NSLocalizedString(@"Percent Calculator_Short", nil) : NSLocalizedString(@"Percent Calculator", @"Percent Calculator");

	_barButtonEnabled = YES;

    [self leftBarButtonAppsButton];
    [self rightButtonHistoryButton];
    [self makeBackButtonEmptyArrow];
    
    if (IS_IPAD) {
        self.navigationItem.hidesBackButton = YES;
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
    } else {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
    }
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = COLOR_TABLE_SEPARATOR;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(15, 15), NO, 0);
    _blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self initSectionABMark];
    
    [self clearData];

    [self initHeaderView];
    [self reloadTableDataSource];
	[self reloadInputData];
    [self setBarButtonEnable:YES];

    self.automaticallyAdjustsScrollViewInsets = NO;
    if (IS_LANDSCAPE) {
        _oldTableOffset = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width;
        self.tableView.contentInset = UIEdgeInsetsMake(_oldTableOffset, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0.0, -_oldTableOffset);
    } else {
        _oldTableOffset = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        self.tableView.contentInset = UIEdgeInsetsMake(_oldTableOffset, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0.0, -_oldTableOffset);
    }
    
    _isKeyboardShown = NO;

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightSideViewWillHide) name:A3NotificationRightSideViewWillDismiss object:nil];
	}
    [self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudKeyValueStoreDidImport object:nil];
}

- (void)cloudStoreDidImport {
	if (self.firstResponder) {
		return;
	}
	[self reloadInputData];
	[self reloadTableDataSource];
	[self reloadTableHeaderView];
	[self.tableView reloadData];
	// 배경 설명
	// 아이패드에서 HistoryViewController가 나와 있는 상태에서 업데이트를 받은 경우,
	// apps button이 enable되는 것을 막기 위해서 barButton enable 상태를 기억하고
	// 상태에 따라서 button 의 상태를 결정한다.
	[self setBarButtonEnable:_barButtonEnabled];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudKeyValueStoreDidImport object:nil];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationRightSideViewWillDismiss object:nil];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)rightSideViewWillHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;
	if (enable) {
		[self setBarButtonEnable:YES];
	} else {
		[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
			[barButtonItem setEnabled:NO];
		}];
	}
	[self.navigationItem.leftBarButtonItem setEnabled:enable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contentSizeDidChange:(NSNotification *)notification {
    FNLOG(@"%@", notification);
    [_headerView setNeedsLayout];
}

-(void)initSectionABMark {
    _sectionALabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    _sectionALabel.hidden = NO;
    [_sectionALabel setTextAlignment:NSTextAlignmentCenter];
    [_sectionALabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];
    [_sectionALabel setTextColor:[UIColor whiteColor]];
    _sectionALabel.layer.masksToBounds = YES;
    _sectionALabel.layer.cornerRadius = _sectionALabel.bounds.size.width / 2.0;
    _sectionALabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _sectionALabel.adjustsFontSizeToFitWidth = NO;
    
    _sectionBLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
    _sectionBLabel.hidden = NO;
    [_sectionBLabel setTextAlignment:NSTextAlignmentCenter];
    [_sectionBLabel setBackgroundColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];
    [_sectionBLabel setTextColor:[UIColor whiteColor]];
    _sectionBLabel.layer.masksToBounds = YES;
    _sectionBLabel.layer.cornerRadius = _sectionBLabel.bounds.size.width / 2.0;
    _sectionBLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    _sectionBLabel.adjustsFontSizeToFitWidth = NO;
    
    [self.tableView addSubview:_sectionALabel];
    [self.tableView addSubview:_sectionBLabel];
}

- (void)initHeaderView {
    self.headerView = [[A3PercentCalcHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 157)];
    self.headerView.bottomLineView.backgroundColor = COLOR_TABLE_SEPARATOR;

    if ([self reloadInputData]) {
        _selectedOptionIndexPath = [NSIndexPath indexPathForRow:self.calcType inSection:1];
        self.headerView.calcType = self.calcType;
    } else {
        self.headerView.calcType = self.calcType;
        self.headerView.factorValues = [A3PercentCalcData new];
        self.headerView.factorValues.dataType = self.calcType;
        self.headerView.factorValues.values = @[@0, @0, @0, @0];
    }
    
    [self reloadTableHeaderView];
}

/*! NSUserDefaults 에 저장한 데이터를 읽어온다.
 * \param none
 * \returns 저장된 데이터가 있는 경우에는 YES, 아니면 NO
 */
- (BOOL)reloadInputData {
	NSData *inputData = [[A3SyncManager sharedSyncManager] objectForKey:A3PercentCalcUserDefaultsSavedInputData];
	if (inputData) {
		A3PercentCalcData *savedInputData = [NSKeyedUnarchiver unarchiveObjectWithData:inputData];

		if (savedInputData.dataType == PercentCalcType_5) {
			_factorX1 = savedInputData.values[ValueIdx_X1];
			_factorY1 = savedInputData.values[ValueIdx_Y1];
			_factorX2 = savedInputData.values[ValueIdx_X2];
			_factorY2 = savedInputData.values[ValueIdx_Y2];
		} else {
			_factorX1 = savedInputData.values[ValueIdx_X1];
			_factorY1 = savedInputData.values[ValueIdx_Y1];
		}

		self.calcType = savedInputData.dataType;
		self.headerView.factorValues.values = savedInputData.values;
		_formattedFactorValues = [savedInputData formattedStringValuesByCalcType];
		self.headerView.factorValues = savedInputData;
		_sectionALabel.hidden = YES;
		_sectionBLabel.hidden = YES;
		return YES;
	}
	return NO;
}

- (void)rightButtonHistoryButton {

    UIImage *image = [UIImage imageNamed:@"history"];
    //UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonAction:)];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveToHistory:)];
    
    UIBarButtonItem *paddingItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                  target:self
                                                                  action:nil];
    UIBarButtonItem *paddingItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                 target:self
                                                                                 action:nil];
    paddingItem1.width = -60.0;
    paddingItem2.width = 0;
    buttonItem.width = -44;
    saveItem.width = -44;
    
    
    //self.navigationItem.rightBarButtonItem = buttonItem;
    self.navigationItem.rightBarButtonItems = @[buttonItem, saveItem];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	[self enableControls:!self.A3RootViewController.showLeftView];
    [self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];
}

-(void)setBarButtonEnable:(BOOL)enable
{
	_barButtonEnabled = enable;
    if (enable) {
        // History 버튼, 히스토리가 있는 경우에만 활성.
        UIBarButtonItem *historyButton = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
        historyButton.enabled = [PercentCalcHistory MR_countOfEntities] > 0;
        
        
        // Compose 버튼, 헤더에 값이 있는 경우에만 활성하도록..
        UIBarButtonItem *compo = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        if (self.headerView.factorValues) {

            if (self.headerView.factorValues == nil || self.headerView.factorValues.values == nil) {
                compo.enabled = NO;
                return;
            }

            if (self.calcType == PercentCalcType_5 &&
                self.headerView.factorValues.values.count == 4 &&
                ![self.headerView.factorValues.values[0] isEqualToNumber:@0] &&
                ![self.headerView.factorValues.values[1] isEqualToNumber:@0] &&
                ![self.headerView.factorValues.values[2] isEqualToNumber:@0] &&
                ![self.headerView.factorValues.values[3] isEqualToNumber:@0] ) {
                
                compo.enabled = YES;
                return;
                
            } else if (self.calcType != PercentCalcType_5 &&
                       self.headerView.factorValues.values.count == 2 &&
                       ![self.headerView.factorValues.values[0] isEqualToNumber:@0] &&
                       ![self.headerView.factorValues.values[1] isEqualToNumber:@0] ) {
                
                compo.enabled = YES;
                return;
                
            } else {
                compo.enabled = NO;
                return;
            }
        }
        
    } else {
        UIBarButtonItem *historyButton = [self.navigationItem.rightBarButtonItems objectAtIndex:0];
        historyButton.enabled = NO;
    }
}

#pragma mark -

-(void)setCalcType:(PercentCalcType)calcType
{
    if (self.headerView) {
        self.headerView.calcType = calcType;
    }
    [[A3SyncManager sharedSyncManager] setObject:@(calcType) forKey:A3PercentCalcUserDefaultsCalculationType state:A3KeyValueDBStateModified];
}

-(PercentCalcType)calcType
{
    PercentCalcType result = (PercentCalcType) [[A3SyncManager sharedSyncManager] integerForKey:A3PercentCalcUserDefaultsCalculationType];
    return result;
}

-(void)clearData
{
    _factorX1 = @0;
    _factorY1 = @0;
    _factorX2 = @0;
    _factorY2 = @0;
    
    A3PercentCalcData *formattedData = [A3PercentCalcData new];
    formattedData.dataType = self.calcType;
    formattedData.values = @[_factorX1, _factorY1, _factorX2, _factorY2];
    _formattedFactorValues = [formattedData formattedStringValuesByCalcType];
}

-(void)historyButtonAction:(id)sender {
	[self.firstResponder resignFirstResponder];
	[self setFirstResponder:nil];

	A3PercentCalcHistoryViewController *viewController = [[A3PercentCalcHistoryViewController alloc] initWithStyle:UITableViewStylePlain];
	viewController.delegate = self;
	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyViewControllerDidDismiss) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
		[self enableControls:NO];
		[self.A3RootViewController presentRightSideViewController:viewController];
	}
}

- (void)historyViewControllerDidDismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationChildViewControllerDidDismiss object:_modalNavigationController.childViewControllers[0]];
	_modalNavigationController = nil;
}

-(void)saveToHistory:(id)sender
{
    [self saveCalcHistoryData:self.headerView.factorValues calcType:self.calcType];
    
    if (self.calcType==PercentCalcType_5) {
        
        _factorX1 = @0;
        _factorY1 = @0;
        _factorX2 = @0;
        _factorY2 = @0;
        
        A3PercentCalcData *factorData = [A3PercentCalcData new];
        factorData.dataType = self.calcType;
        factorData.values = @[_factorX1, _factorY1, _factorX2, _factorY2];
        _formattedFactorValues = [factorData formattedStringValuesByCalcType];

        self.headerView.factorValues = factorData;
        [self saveInputTextData:factorData calculated:YES];
        
    } else {
        
        _factorX1 = @0;
        _factorY1 = @0;
        
        A3PercentCalcData *factorData = [A3PercentCalcData new];
        factorData.dataType = self.calcType;
        factorData.values = @[_factorX1, _factorY1];
        _formattedFactorValues = [factorData formattedStringValuesByCalcType];
        self.headerView.factorValues = factorData;
        [self saveInputTextData:factorData calculated:YES];
    }
    
    [self.headerView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            [self.headerView setNeedsLayout];
                        } completion:^(BOOL finished) {
                            [self.tableView reloadData];
                        }];
    [self scrollToTopOfTableView];
    [self setBarButtonEnable:YES];
    
}

-(void)saveCalcHistoryData:(A3PercentCalcData *)aData calcType:(PercentCalcType)calcType {
    
    // 최근 데이터에 저장했던 데이터인지 체크.
    NSFetchRequest * fetch = [[NSFetchRequest alloc] initWithEntityName:@"PercentCalcHistory"];
    [fetch setFetchLimit:10];
    [fetch setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO]]];
    NSArray *fetchedRows = [PercentCalcHistory MR_executeFetchRequest:fetch];
    for (PercentCalcHistory * entity in fetchedRows) {
        A3PercentCalcData *entityHistory = [NSKeyedUnarchiver unarchiveObjectWithData:entity.historyItem];
        if (!entityHistory) {
            continue;
        }
//        if (calcType != entityHistory.dataType) {updateSection3EntryCell
//            continue;
//        }
        
        if ([aData.values isEqualToArray:entityHistory.values]) {
            // 최근에 저장한 데이터와 일치. 덮어쓰기.
            entity.updateDate = [NSDate date];
            entity.historyItem = [NSKeyedArchiver archivedDataWithRootObject:aData];

			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            return;
        }
    }
    
    // 신규 데이터, 히스토리에 저장.
    if (calcType==PercentCalcType_5) {
        if (_factorX1==nil || _factorY1==nil || _factorX2==nil || _factorY2==nil)
            return;
        
        
        if ([_factorX1 isEqualToNumber:@0]==NO && [_factorY1 isEqualToNumber:@0]==NO
            && [_factorX2 isEqualToNumber:@0]==NO && [_factorY2 isEqualToNumber:@0]==NO) {
            PercentCalcHistory *entity = [PercentCalcHistory MR_createEntity];
			entity.uniqueID = [[NSUUID UUID] UUIDString];
            entity.updateDate = [NSDate date];
            entity.historyItem = [NSKeyedArchiver archivedDataWithRootObject:aData];
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * barButton, NSUInteger idx, BOOL *stop) {
                barButton.enabled = YES;
            }];
        }
    } else {
        if (_factorX1==nil || _factorY1==nil)
            return;
        
        if ([_factorX1 isEqualToNumber:@0]==NO && [_factorY1 isEqualToNumber:@0]==NO) {
            PercentCalcHistory *entity = [PercentCalcHistory MR_createEntity];
			entity.uniqueID = [[NSUUID UUID] UUIDString];
            entity.updateDate = [NSDate date];
            entity.historyItem = [NSKeyedArchiver archivedDataWithRootObject:aData];
			[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * barButton, NSUInteger idx, BOOL *stop) {
                barButton.enabled = YES;
            }];
        }
    }
}

-(void)saveInputTextData:(A3PercentCalcData *)inputTextData calculated:(BOOL)calculated {
    inputTextData.calculated = calculated;
    
    if (inputTextData.dataType!=PercentCalcType_5 && inputTextData.values.count>2) {
        inputTextData.values = [NSArray arrayWithObjects:inputTextData.values[0], inputTextData.values[1], nil];
    }

	id inputData = [NSKeyedArchiver archivedDataWithRootObject:inputTextData];
	[[A3SyncManager sharedSyncManager] setObject:inputData forKey:A3PercentCalcUserDefaultsSavedInputData state:A3KeyValueDBStateModified];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier2 = @"Cell2";
    UITableViewCell *cell;
    A3JHTableViewEntryCell * cell2;
    @try {

        switch (indexPath.section) {
            case 0:
            case 1:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
                }
                
                return [self updateCell:cell forRowAtIndexPath:indexPath tableView:tableView];
            }
                break;
                
            case 2:
            case 3:
            {
                cell2 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
                if (!cell2) {
                    cell2 = [[A3JHTableViewEntryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2];
                    cell2.textField.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
                    cell2.textField.clearButtonMode = UITextFieldViewModeNever;
                    cell2.textField.font = [UIFont systemFontOfSize:17.0];
                }
                
                if (IS_IPAD) {
                    cell2.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
                    cell2.leftSeparatorInset = 28.0;
                } else {
                    cell2.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
                    cell2.leftSeparatorInset = 15.0;
                }
                cell2.textField.delegate = self;
                if (self.sections.count-1 < indexPath.section) {
                    return cell2;
                }
                //cell2.textLabel.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                cell2.textLabel.text = self.sections[indexPath.section][indexPath.row];
                
                
                if (indexPath.section==2) {
                    cell2 = [self updateSection2EntryCell:cell2 forRowAtIndexPath:indexPath tableView:tableView];
                } else if (indexPath.section==3) {
                    cell2 = [self updateSection3EntryCell:cell2 forRowAtIndexPath:indexPath tableView:tableView];
                }
                
                return cell2;
            }
                break;
                
            default:
                break;
        }
        
    }
    @catch (NSException *exception) {
        FNLOG(@"%@", exception);
    }
    @finally {
    }

    return nil;
}

-(UITableViewCell *)updateCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    if (IS_IPAD) {
        cell.separatorInset = UIEdgeInsetsMake(0, 28.0, 0, 0);
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 15.0, 0, 0);
    }
    
    cell.textLabel.text = self.sections[indexPath.section][indexPath.row];
    cell.accessoryType = indexPath.row==self.calcType ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    return cell;
}

-(A3JHTableViewEntryCell *)updateSection2EntryCell:(A3JHTableViewEntryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row==0) {
        FNLOG(@"check");
        cell.textField.text = _formattedFactorValues[ValueIdx_X1];
        cell.textField.tag = 0;
        
        if (self.calcType==PercentCalcType_5) {
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            if (IS_IPAD) {
                CGRect aRect = _sectionALabel.frame;
                aRect.origin.x = 28.0;
                aRect.origin.y = rect.origin.y + rect.size.height - aRect.size.height/2.0;
                
                _sectionALabel.frame = aRect;
                cell.separatorInset = UIEdgeInsetsMake(0, 63.0, 0, 0);
                cell.leftSeparatorInset = 63.0;
            } else {
                CGRect aRect = _sectionALabel.frame;
                aRect.origin.x = 15.0;
                aRect.origin.y = rect.origin.y + rect.size.height - aRect.size.height/2.0;
                
                _sectionALabel.frame = aRect;
                cell.separatorInset = UIEdgeInsetsMake(0, 50.0, 0, 0);
                cell.leftSeparatorInset = 50.0;
            }
            _sectionALabel.hidden = NO;
            _sectionALabel.text = NSLocalizedString(@"A", @"A");
        }
        
    } else if (indexPath.row==1) {
        FNLOG(@"check");
        cell.textField.text = _formattedFactorValues[ValueIdx_Y1];
        cell.textField.tag = 1;
        
        if (self.calcType==PercentCalcType_5) {
            if (IS_IPAD) {
                cell.separatorInset = UIEdgeInsetsMake(0, 63.0, 0, 0);
                cell.leftSeparatorInset = 63.0;
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0, 50.0, 0, 0);
                cell.leftSeparatorInset = 50.0;
            }
        }
    }
    
    cell.imageView.image = self.calcType==PercentCalcType_5? _blankImage : nil;
   return cell;
}

-(A3JHTableViewEntryCell *)updateSection3EntryCell:(A3JHTableViewEntryCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row==0) {
        FNLOG(@"formattedFactorValues: %@", _formattedFactorValues);
        if (_formattedFactorValues.count<4) {
            FNLOG();
            return cell;
        }
        cell.textField.text = _formattedFactorValues[ValueIdx_X2];
        cell.textField.tag = 2;
        
        if (self.calcType==PercentCalcType_5) {
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            if (IS_IPAD) {
                CGRect aRect = _sectionBLabel.frame;
                aRect.origin.x = 28.0;
                aRect.origin.y = rect.origin.y + rect.size.height - aRect.size.height/2.0;
                
                _sectionBLabel.frame = aRect;
                cell.separatorInset = UIEdgeInsetsMake(0, 63.0, 0, 0);
                cell.leftSeparatorInset = 63.0;
            } else {
                CGRect aRect = _sectionBLabel.frame;
                aRect.origin.x = 15.0;
                aRect.origin.y = rect.origin.y + rect.size.height - aRect.size.height/2.0;
                
                _sectionBLabel.frame = aRect;
                cell.separatorInset = UIEdgeInsetsMake(0, 50.0, 0, 0);
                cell.leftSeparatorInset = 50.0;
            }
            _sectionBLabel.hidden = NO;
            _sectionBLabel.text = NSLocalizedString(@"B", @"B");
        }
    } else if (indexPath.row==1) {
        FNLOG(@"check");
        cell.textField.text = _formattedFactorValues[ValueIdx_Y2];
        cell.textField.tag = 3;
        
        if (self.calcType==PercentCalcType_5) {
            if (IS_IPAD) {
                cell.separatorInset = UIEdgeInsetsMake(0, 63.0, 0, 0);
                cell.leftSeparatorInset = 63.0;
            } else {
                cell.separatorInset = UIEdgeInsetsMake(0, 50.0, 0, 0);
                cell.leftSeparatorInset = 50.0;
            }
        }
    }
    
    cell.imageView.image = self.calcType == PercentCalcType_5 ? _blankImage : nil;
    
   return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]==1) {
        if (!_selectedOptionIndexPath) {
            _selectedOptionIndexPath = [NSIndexPath indexPathForRow:self.calcType inSection:1];
        }
        UITableViewCell *oldOptionCell = [self.tableView cellForRowAtIndexPath:_selectedOptionIndexPath];
        if ([indexPath row] != [_selectedOptionIndexPath row] || [indexPath section] != [_selectedOptionIndexPath section]) {
            oldOptionCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        _selectedOptionIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    if (indexPath.section == 1) {
        
        if (self.calcType == PercentCalcType_1 + indexPath.row) {
            // 같은 옵션 선택시, 반환.
            return;
        }

        switch (indexPath.row) {
            case 0:
            case 1:
            case 2:
            case 3:
            {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                _sectionALabel.hidden = YES;
                _sectionBLabel.hidden = YES;

                if (self.calcType == PercentCalcType_5) {
                    self.calcType = PercentCalcType_1 + indexPath.row;
                    self.headerView.factorValues.dataType = self.calcType;
                    A3PercentCalcData *factorData = [A3PercentCalcData new];
                    factorData.dataType = self.calcType;
                    factorData.values = @[_factorX1, _factorY1];
                    [self saveInputTextData:factorData calculated:YES];
                    
                    _formattedFactorValues = [factorData formattedStringValuesByCalcType];
                    self.headerView.factorValues = factorData;
                    [self reloadTableDataSource];
                    
                    if (IS_IPHONE) {
                        [self reloadTableHeaderView];
                        [self.tableView reloadData];
                    }
                    else {
                        [UIView animateWithDuration:0.3 animations:^{
                            [self reloadTableHeaderView];
                        } completion:^(BOOL finished) {
                            [self.tableView reloadData];
                        }];
                    }
                }
                else {
                    self.calcType = PercentCalcType_1 + indexPath.row;
                    A3PercentCalcData *factorData = [A3PercentCalcData new];
                    factorData.dataType = self.calcType;
                    factorData.values = @[_factorX1, _factorY1];
					[self saveInputTextData:factorData calculated:YES];

                    _formattedFactorValues = [factorData formattedStringValuesByCalcType];
                    self.headerView.factorValues = factorData;
                    [self.tableView.tableHeaderView setNeedsLayout];
                    
                    switch ([_selectedIndexPath row]) {
                        case 0:
                        case 1:
                        {
                            A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
                            if (self.firstResponder != cell.textField) {
                                cell.textField.text = [_formattedFactorValues objectAtIndex:ValueIdx_X1];
                            }
                            
                            cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
                            if (self.firstResponder != cell.textField) {
                                cell.textField.text = [_formattedFactorValues objectAtIndex:ValueIdx_Y1];
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    if (!self.firstResponder) {
                        [self showKeyboardIfXFieldIsZeroAtTableView:self.tableView];
                    }
                }
            }
                break;
                
            case 4:     // Compare % Change from X to Y
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                if (self.calcType == PercentCalcType_5) {
                    break;
                }
                
                self.calcType = PercentCalcType_5;

                A3PercentCalcData *factorData = [A3PercentCalcData new];
                factorData.dataType = self.calcType;
                factorData.values = @[_factorX1, _factorY1, _factorX2, _factorY2];
                [self saveInputTextData:factorData calculated:YES];

                _formattedFactorValues = [factorData formattedStringValuesByCalcType];
                self.headerView.factorValues = factorData;
                [self reloadTableDataSource];

                A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [UIView animateWithDuration:0.3 animations:^{
                    [self reloadTableHeaderView];
                    
                } completion:^(BOOL finished) {
                    [self.tableView reloadData];
                }];
				break;
			}

            default:
                break;
        }
        
    } else {
        _selectedIndexPath = [indexPath copy];
        
        A3JHTableViewEntryCell * cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:_selectedIndexPath];
        [cell.textField becomeFirstResponder];
    }
    
}

- (void)reloadTableDataSource
{
    if (self.calcType == PercentCalcType_5) {
        self.sectionTitles = @[@"", @"", @"", @""];
        self.sections = @[
                          @[],
                          @[
								  NSLocalizedString(@"X is Y% of What", @"X is Y% of What"),
								  NSLocalizedString(@"What is X% of Y", @"What is X% of Y"),
								  NSLocalizedString(@"X is What % of Y", @"X is What % of Y"),
								  NSLocalizedString(@"% Change from X to Y", @"% Change from X to Y"),
								  NSLocalizedString(@"Compare % Change from X to Y", @"Compare % Change from X to Y")],
                          @[
								  @"X",
								  @"Y"
						  ],
                          @[
								  @"X",
								  @"Y"
						  ]
                          ];
    } else {
        self.sectionTitles = @[@"", @"", @""];
        self.sections = @[
                          @[],
                          @[
								  NSLocalizedString(@"X is Y% of What", @"X is Y% of What"),
								  NSLocalizedString(@"What is X% of Y", @"What is X% of Y"),
								  NSLocalizedString(@"X is What % of Y", @"X is What % of Y"),
								  NSLocalizedString(@"% Change from X to Y", @"% Change from X to Y"),
								  NSLocalizedString(@"Compare % Change from X to Y", @"Compare % Change from X to Y")
						  ],
                          @[
								  @"X",
								  @"Y"
						  ]
                          ];
    }
}

- (void)reloadTableHeaderView
{
    if (IS_IPHONE) {
        if (self.calcType == PercentCalcType_5) {
            self.headerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 166);
        } else {
            self.headerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 104);
        }

    } else {
        if (self.calcType == PercentCalcType_5) {
            self.headerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 226);
        } else {
            self.headerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 158);
        }

        [self.headerView setNeedsLayout];
    }

    [self.tableView setTableHeaderView:self.headerView];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)reloadAnimationEnded
{
    [self.tableView reloadData];
}

- (void)scrollTableViewToIndexPath:(NSIndexPath *)indexPath
{
    _oldTableOffset = self.tableView.contentOffset.y;
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    if ((cellRect.origin.y + cellRect.size.height + self.tableView.contentInset.top) < (self.tableView.frame.size.height-_simpleNormalNumberKeyboard.view.bounds.size.height))
        return;
    CGFloat offset = (cellRect.origin.y + cellRect.size.height) - (self.tableView.frame.size.height-(_simpleNormalNumberKeyboard.view.bounds.size.height));
    self.tableView.contentOffset = CGPointMake(0.0, offset);
}

-(void)scrollToTopOfTableView {
    if (IS_LANDSCAPE) {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width));
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:7];
        [UIView setAnimationDuration:0.35];
        self.tableView.contentOffset = CGPointMake(0.0, -(self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height));
        [UIView commitAnimations];
    }
}

-(BOOL)checkNeedToClearDetail {
    if (_selectedIndexPath.section==2) {
        if (_selectedIndexPath.row==0) {
            _currentFactor = _factorX1;
        } else if (_selectedIndexPath.row==1) {
            _currentFactor = _factorY1;
        }
    } else if (_selectedIndexPath.section==3) {
        if (_selectedIndexPath.row==0) {
            _currentFactor = _factorX2;
        } else if (_selectedIndexPath.row==1) {
            _currentFactor = _factorY2;
        }
    }
    
    return [_currentFactor isEqualToNumber:@0]==NO ? YES : NO;
}

-(void)showKeyboardIfXFieldIsZeroAtTableView:(UITableView *)tableView {
    // 옵션 선택시 무조건 키보드 올라오도록.
    if ([_factorX1 isEqualToNumber:@0] && [_factorY1 isEqualToNumber:@0]) {
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        _currentFactor = _factorX1;
        A3JHTableViewEntryCell * cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        [cell.textField becomeFirstResponder];
    }
    else {
        [self scrollToTopOfTableView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //FNLOG(@"scrollViewDidEndDragging: %@, decelerate: %d", NSStringFromUIEdgeInsets(scrollView.contentInset), decelerate);
    FNLOG(@"scrollViewDidEndDragging: %@, decelerate: %d", NSStringFromCGPoint(scrollView.contentOffset), decelerate);
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _isKeyboardShown = YES;
    self.firstResponder = textField;
    //textField.textColor = COLOR_TABLE_TEXT_TYPING;
    
    // 입력하려는 Cell에 이미 데이터가 있는 경우, 지우고 시작하기 위하여.
    switch (textField.tag) {
        case 0:
            _currentFactor = _factorX1;
            _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            break;
        case 1:
            _currentFactor = _factorY1;
            _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:2];
            break;
        case 2:
            _currentFactor = _factorX2;
            _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
            break;
        case 3:
            _currentFactor = _factorY2;
            _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:3];
            break;
        default:
            break;
    }

    if (_simpleNormalNumberKeyboard == nil) {
        _simpleNormalNumberKeyboard = [self simplePrevNextClearNumberKeyboard];
		_simpleNormalNumberKeyboard.keyboardType = A3NumberKeyboardTypeReal;
    }

    textField.inputView = _simpleNormalNumberKeyboard.view;
    _simpleNormalNumberKeyboard.textInputTarget = textField;
    _simpleNormalNumberKeyboard.delegate = self;
    
    [self reloadPrevNextButtonStatus];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.textBeforeEditingTextField = textField.text;
	textField.text = @"";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
	UITextField *textField = notification.object;
    
    if ([textField.text length] == 0) {
        return;
    }
    
    // 소수점 체크.
    NSArray *decimalCheck = [textField.text componentsSeparatedByString:@"."];
    if (decimalCheck.count>2) {
        textField.text = [NSString stringWithFormat:@"%@", @(textField.text.floatValue)];
        [self.tableView reloadData];
        return;
    }
    if (decimalCheck.count==2 && [decimalCheck[1] length]==0) {
        // 소수점이 2개이상 입력될 수 없음.
        return;
    }

    if (decimalCheck.count == 2 && ((NSString *)decimalCheck[1]).length > 3) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setRoundingMode:NSNumberFormatterRoundDown];
        if ([textField.text rangeOfString:@".000"].location==NSNotFound) {
            textField.text = [NSString stringWithFormat:@"%@", [formatter stringFromNumber:@([textField.text doubleValue])]];
        }
        else {
            textField.text = [NSString stringWithFormat:@"%@.000", [formatter stringFromNumber:@([textField.text doubleValue])]];
        }
        
        return;
    }
    
    // 입력 텍스트 길이 체크.
    //NSString * inputString = [NSNumberFormatter currencyStringExceptedSymbolFromNumber:@(textField.text.doubleValue)];
    NSString * inputString = textField.text;
    if (IS_IPAD && inputString.length > 16) {
        textField.text = [inputString substringToIndex:16];
        return;
    } else if (inputString.length > 9) {
        textField.text = [inputString substringToIndex:9];
        return;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    _isKeyboardShown = NO;
    if (textField == self.firstResponder) {
        [self setFirstResponder:nil];
    }

	if (_cancelInputNewCloudDataReceived) {
		_cancelInputNewCloudDataReceived = NO;
		return;
	}

	if (![textField.text length]) {
		if ([_textBeforeEditingTextField length]) {
			textField.text = _textBeforeEditingTextField;
		} else {
			textField.text = @"0";
		}
	}

    if ([textField.text length] > 0) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //    [formatter setRoundingMode:NSNumberFormatterRoundDown];
        NSString *value;
        value = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        value = [textField.text stringByReplacingOccurrencesOfString:@"%" withString:@""];
        
        switch (textField.tag) {
            case 0:
            {
                //_factorX1 = @(textField.text.doubleValue);
                //textField.text = [NSString stringWithFormat:@"%.03f", textField.text.doubleValue];
                
                _factorX1 = [formatter numberFromString:value];
                //textField.text = [formatter stringFromNumber:_factorX1];
                //textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                
                //            textField.text = _factorX1.stringValue;
                //            [formatter stringFromNumber:_factorX1];
                //            textField.text = [formatter stringFromNumber:_factorX1];
                //            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
                break;
            case 1:
            {
                //            _factorY1 = @(textField.text.doubleValue);
                
                _factorY1 = [formatter numberFromString:value];
                //                textField.text = [formatter stringFromNumber:_factorY1];
                //                textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                //            textField.text = [NSString stringWithFormat:@"%@", _factorY1];
                //            textField.text = _factorY1.stringValue;
                //            [formatter stringFromNumber:_factorX1];
                //            textField.text = [formatter stringFromNumber:_factorY1];
                //            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
                break;
            case 2:
            {
                //            _factorX2 = @(textField.text.doubleValue);
                
                _factorX2 = [formatter numberFromString:value];
                //                textField.text = [formatter stringFromNumber:_factorX2];
                //                textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                //            textField.text = [_factorX2 stringValue];
                //            [formatter stringFromNumber:_factorX1];
                //            textField.text = [formatter stringFromNumber:_factorX2];
                //            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
                break;
            case 3:
            {
                //            _factorY2 = @(textField.text.doubleValue);
                
                _factorY2 = [formatter numberFromString:value];
                //                textField.text = [formatter stringFromNumber:_factorY2];
                //                textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
                //            textField.text = [_factorY2 stringValue];
                //            [formatter stringFromNumber:_factorX1];
                //            textField.text = [formatter stringFromNumber:_factorY2];
                //            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
                break;
            default:
                break;
        }
    }
    
    if (self.calcType==PercentCalcType_5) {
        
        if (_factorX1==nil || _factorY1==nil || _factorX2==nil || _factorY2==nil)
            return;
        
        A3PercentCalcData *factorData = [A3PercentCalcData new];
        factorData.dataType = self.calcType;
        factorData.values = @[_factorX1, _factorY1, _factorX2, _factorY2];
        _formattedFactorValues = [factorData formattedStringValuesByCalcType];
        FNLOG();
        self.headerView.factorValues = factorData;
        [self saveInputTextData:factorData calculated:YES];
        
    } else {
        
        if (_factorX1==nil || _factorY1==nil)
            return;
        
        A3PercentCalcData *factorData = [A3PercentCalcData new];
        factorData.dataType = self.calcType;
        factorData.values = @[_factorX1, _factorY1];
        _formattedFactorValues = [factorData formattedStringValuesByCalcType];
        FNLOG();
        self.headerView.factorValues = factorData;
        [self saveInputTextData:factorData calculated:YES];
    }
    
    
    [self.headerView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            [self.headerView setNeedsLayout];
                        } completion:^(BOOL finished) {
                            //[self.tableView reloadData];
                        }];
    
    [self setBarButtonEnable:YES];
    
    if (_formattedFactorValues.count > textField.tag) {
        textField.text = _formattedFactorValues[textField.tag];
//        textField.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    }
    
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    if (![textField.text length])
        return;
}

#pragma mark

-(void)reloadPrevNextButtonStatus {
    if (_selectedIndexPath.section==2&&_selectedIndexPath.row==0) {
        _prevShow = NO;
        _nextShow = YES;

    } else if (_selectedIndexPath.section==2&&_selectedIndexPath.row==1) {
        if (self.calcType==PercentCalcType_5) {
            _prevShow = YES;
            _nextShow = YES;
        } else {
            _prevShow = YES;
            _nextShow = NO;
        }
        
    } else if (_selectedIndexPath.section==3&&_selectedIndexPath.row==0) {
        _prevShow = YES;
        _nextShow = YES;

    } else if (_selectedIndexPath.section==3&&_selectedIndexPath.row==1) {
        if (self.calcType==PercentCalcType_5) {
            _prevShow = YES;
            _nextShow = NO;
        }
    }
    
    [_simpleNormalNumberKeyboard reloadPrevNextButtons];
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	_textBeforeEditingTextField = @"";
	if ([keyInputDelegate isKindOfClass:[UITextField class]]) {
		UITextField *textField = (UITextField *) keyInputDelegate;
		textField.text = @"";
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	[keyInputDelegate resignFirstResponder];
    
    if (self.calcType==PercentCalcType_5) {
        if (_factorX1==nil || _factorY1==nil || _factorX2==nil || _factorY2==nil) {
            return;
        }
        
        if ((![_factorX1 isEqualToNumber:@0] && ![_factorY1 isEqualToNumber:@0] && ![_factorX2 isEqualToNumber:@0] && ![_factorY2 isEqualToNumber:@0]) ||
            ([_factorX1 isEqualToNumber:@0] && [_factorY1 isEqualToNumber:@0] && [_factorX2 isEqualToNumber:@0] && [_factorY2 isEqualToNumber:@0])) {
            [self scrollToTopOfTableView];
        }
    }
    else {
        if (_factorX1==nil || _factorY1==nil) {
            return;
        }

        if ((![_factorX1 isEqualToNumber:@0] && ![_factorY1 isEqualToNumber:@0]) ||
            ([_factorX1 isEqualToNumber:@0] && ![_factorY1 isEqualToNumber:@0]) ) {
            [self scrollToTopOfTableView];
        }
    }

    [self.tableView reloadData];
}

//-(void)keyboardWillShow:(NSNotification *)aNoti
//{
//    NSDictionary *aDict = [aNoti userInfo];
//    CGRect keyboardSize = [self.view convertRect:[[aDict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
//    keyboardSize.size.height = keyboardSize.size.height-90.0;
//    NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];    // 7
//    NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];  // 0.25
//    
//    [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationCurve:[animationCurve intValue]];
//    [UIView setAnimationDuration:[animationDuration doubleValue]];
//    
//    [self scrollTableViewToIndexPath:_selectedIndexPath];
//    
//    [UIView commitAnimations];
//}
//
//-(void)keyboardWillDisappear:(NSNotification *)aNoti
//{
//    NSDictionary *aDict = [aNoti userInfo];
//    CGRect keyboardSize = [self.view convertRect:[[aDict valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
//    keyboardSize.size.height = keyboardSize.size.height-90.0;
//    NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
//    NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
//    
//    [UIView beginAnimations:A3AnimationIDKeyboardWillShow context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationCurve:[animationCurve intValue]];
//    [UIView setAnimationDuration:[animationDuration doubleValue]];
//    
//    [self movePreviousContentOffset];
//    
//    [UIView commitAnimations];
//}

-(void)movePreviousContentOffset
{
    if (IS_LANDSCAPE) {
        _oldTableOffset = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.width;
        self.tableView.contentOffset = CGPointMake(0.0, -_oldTableOffset);
    } else {
        _oldTableOffset = self.navigationController.navigationBar.bounds.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
        self.tableView.contentOffset = CGPointMake(0.0, -_oldTableOffset);
    }
}

#pragma mark - NumberKeyabord

-(BOOL)isPreviousEntryExists{
    return _prevShow;
}

-(BOOL)isNextEntryExists{
    return _nextShow;
}

-(void)prevButtonPressed{
    A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    
//    A3PercentCalcData *factorData = [A3PercentCalcData new];
//    factorData.dataType = self.calcType;
//    factorData.values = @[_factorX1, _factorY1, _factorX2, _factorY2];
//    _formattedFactorValues = [factorData formattedStringValuesByCalcType];
    
    if ([_selectedIndexPath section] == 2 && [_selectedIndexPath row] == 0) {
//        cell.textField.text = _formattedFactorValues[ValueIdx_X1];
        _prevShow = NO;
        _nextShow = YES;
        
    } else if (_selectedIndexPath.section==2&&_selectedIndexPath.row==1) {
//        cell.textField.text = _formattedFactorValues[ValueIdx_Y1];
        _prevShow = NO;
        _nextShow = YES;
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        
    } else if (_selectedIndexPath.section==3&&_selectedIndexPath.row==0) {
//        cell.textField.text = _formattedFactorValues[ValueIdx_X2];
        _prevShow = YES;
        _nextShow = YES;
        _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:2];

    } else if (_selectedIndexPath.section==3&&_selectedIndexPath.row==1) {
//        cell.textField.text = _formattedFactorValues[ValueIdx_Y2];
        _prevShow = YES;
        _nextShow = YES;
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    }
    
//    _needToClearDetail = [self checkNeedToClearDetail];

//    cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
//    [cell.textField becomeFirstResponder];
    
    [UIView beginAnimations:@"scroll" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    [self scrollTableViewToIndexPath:_selectedIndexPath];
    cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    [cell.textField becomeFirstResponder];
    [UIView commitAnimations];
    
    [_simpleNormalNumberKeyboard reloadPrevNextButtons];
}

-(void)nextButtonPressed{
    A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];

    if (_selectedIndexPath.section == 2 && _selectedIndexPath.row == 0) {
        _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:2];
        if (self.calcType==PercentCalcType_5) {
            _prevShow = YES;
            _nextShow = YES;
        }
        else {
            _prevShow = YES;
            _nextShow = NO;
        }
    }
    else if (_selectedIndexPath.section == 2 && _selectedIndexPath.row == 1) {
        if (self.calcType==PercentCalcType_5) {
            _prevShow = YES;
            _nextShow = YES;
            _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];
        }
    }
    else if (_selectedIndexPath.section == 3 && _selectedIndexPath.row == 0) {
        _prevShow = YES;
        _nextShow = NO;
        _selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:3];
    }
    else if (_selectedIndexPath.section == 3 && _selectedIndexPath.row == 1) {

    }
    
    [UIView beginAnimations:@"scroll" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:2.5];
    [self scrollTableViewToIndexPath:_selectedIndexPath];
    cell = (A3JHTableViewEntryCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
    [cell.textField becomeFirstResponder];
    [UIView commitAnimations];
    
    [_simpleNormalNumberKeyboard reloadPrevNextButtons];
}

#pragma mark - A3PercentCalcHistoryViewController Delegate
-(void)setHistoryData:(A3PercentCalcData *)history {
    _formattedFactorValues = [history formattedStringValuesByCalcType];
    _factorX1 = [history.values objectAtIndex:ValueIdx_X1];
    _factorY1 = [history.values objectAtIndex:ValueIdx_Y1];
    _factorX2 = @0;
    _factorY2 = @0;
    if ([history dataType] == PercentCalcType_5) {
        _factorX2 = [history.values objectAtIndex:ValueIdx_X2];
        _factorY2 = [history.values objectAtIndex:ValueIdx_Y2];
    }
    
    FNLOG();
    self.calcType = history.dataType;
    self.headerView.factorValues = history;
    
    [self saveInputTextData:history calculated:YES];
    
    if (self.calcType != PercentCalcType_5) {
        _sectionALabel.hidden = YES;
        _sectionBLabel.hidden = YES;
    }

    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:500.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self reloadTableDataSource];
                         [self reloadTableHeaderView];
                     } completion:^(BOOL finished) {
                         //[self reloadTableDataSource];
                         [self.tableView reloadData];
                     }];
}

-(void)didDeleteHistory {
    [self setBarButtonEnable:YES];
}

-(void)dismissHistoryViewController {
    [self setBarButtonEnable:YES];
}

@end
