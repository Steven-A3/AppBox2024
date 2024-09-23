//
//  A3TranslatorViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorViewController.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3TranslatorMessageViewController.h"
#import "TranslatorHistory.h"
#import "NSDate+TimeAgo.h"
#import "A3TranslatorCircleView.h"
#import "A3TranslatorFavoriteDataSource.h"
#import "A3TranslatorListCell.h"
#import "UIView+Screenshot.h"
#import "UIViewController+A3Addition.h"
#import "TranslatorGroup.h"
#import "A3TranslatorLanguage.h"
#import "TranslatorFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3InstructionViewController.h"
#import "A3UserDefaults.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "UIViewController+extension.h"
#import "A3SyncManager.h"
#import "A3AppDelegate.h"
#import "A3UIDevice.h"

@interface A3TranslatorViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate, A3TranslatorMessageViewControllerDelegate, A3TranslatorFavoriteDelegate, A3InstructionViewControllerDelegate, GADBannerViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) FMMoveTableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) A3TranslatorFavoriteDataSource *favoriteDataSource;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, strong) A3TranslatorLanguage *languageListManager;
@end

@implementation A3TranslatorViewController {
	BOOL _instructionPresentedVeryFirst;
	BOOL _viewWillAppearCalled;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.title = NSLocalizedString(A3AppName_Translator, nil);
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.languageListManager updateLangaugeListCompletion:NULL];
    
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.hidesBackButton = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    [self makeNavigationBarAppearanceDefault];
	[self makeBackButtonEmptyArrow];
	if (IS_IPAD || [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = YES;
	}
	[self setupSubviews];
	[self registerContentSizeCategoryDidChangeNotification];

	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainMenuDidHide) name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
    [self setupInstructionView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (A3TranslatorLanguage *)languageListManager {
    if (!_languageListManager) {
        _languageListManager = [A3TranslatorLanguage new];
    }
    return _languageListManager;
}

- (void)applicationDidEnterBackground {
	[self dismissInstructionViewController:nil];
}

- (void)cloudStoreDidImport {
	if (self.segmentedControl.selectedSegmentIndex == 0) {
		_fetchedResultsController = nil;
	} else {
		[_favoriteDataSource resetData];
	}
	[self.tableView reloadData];
}

- (void)prepareClose {
	if (self.presentedViewController) {
		[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
	}
}

- (void)removeObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[self removeContentSizeCategoryDidChangeNotification];
	if (IS_IPAD) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationMainMenuDidHide object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];
	
	if (!_viewWillAppearCalled) {
		_viewWillAppearCalled = YES;
		if (!_instructionViewController && [TranslatorGroup countOfEntities] == 0) {
			double delayInSeconds = 0.2;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self addButtonAction];
			});
		}
	}
	if (IS_IPHONE && [UIWindow interfaceOrientationIsPortrait]) {
		[self leftBarButtonAppsButton];
	}
	if ([self isMovingToParentViewController] || [self isBeingPresented]) {
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDTranslator keywords:@[@"translator", @"language"] adSize:IS_IPHONE ? GADAdSizeFluid : GADAdSizeLeaderboard delegate:self];
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self showNavigationBarOn:self.navigationController];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)cleanUp {
	[self dismissInstructionViewController:nil];
	[self removeObserver];

	_fetchedResultsController = nil;
	_segmentedControl = nil;
	_tableView = nil;
	_addButton = nil;
	_favoriteDataSource = nil;
}

- (BOOL)resignFirstResponder {
	NSString *startingAppName = [[A3UserDefaults standardUserDefaults] objectForKey:kA3AppsStartingAppName];
	if ([startingAppName length] && ![startingAppName isEqualToString:A3AppName_Translator]) {
		[self.instructionViewController.view removeFromSuperview];
		self.instructionViewController = nil;
	}
	return [super resignFirstResponder];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)mainMenuDidHide {
	[self enableControls:YES];
}

- (void)enableControls:(BOOL)enable {
	if (!IS_IPAD) return;

	[self.navigationItem.leftBarButtonItem setEnabled:enable];
	if (enable) {
		[_segmentedControl setTintColor:nil];
	} else {
		[_segmentedControl setTintColor:SEGMENTED_CONTROL_DISABLED_TINT_COLOR];
	}
	[self.addButton setEnabled:enable];
}

- (void)appsButtonAction:(UIBarButtonItem *)barButtonItem {
	[super appsButtonAction:barButtonItem];

	if (IS_IPAD) {
		[self enableControls:![[A3AppDelegate instance] rootViewController_iPad].showLeftView];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	if (IS_IPHONE && [UIWindow interfaceOrientationIsLandscape]) {
		[self leftBarButtonAppsButton];
	}
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForTranslator = @"A3V3InstructionDidShowForTranslator";

- (void)setupInstructionView
{
    if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForTranslator]) {
		_instructionPresentedVeryFirst = YES;
        [self showInstructionView];
    }
    self.navigationItem.rightBarButtonItem = [self instructionHelpBarButton];
}

- (void)showInstructionView
{
    if (_segmentedControl.selectedSegmentIndex != 0) {
        return;
    }

	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForTranslator];
	[[A3UserDefaults standardUserDefaults] synchronize];

    UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
    _instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"Translator"];
    self.instructionViewController.delegate = self;
    [self.navigationController.view addSubview:self.instructionViewController.view];
    self.instructionViewController.view.frame = self.navigationController.view.frame;
    self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
    [self.instructionViewController.view removeFromSuperview];
    self.instructionViewController = nil;

	if (_instructionPresentedVeryFirst && [TranslatorGroup countOfEntities] == 0) {
		double delayInSeconds = 0.2;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self addButtonAction];
		});
	}
}

#pragma mark - Setup Subview

- (void)setupSubviews {
	FNLOGRECT(self.view.frame);
	FNLOGRECT(self.navigationController.view.frame);

	_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Translator_All", @"All"), NSLocalizedString(@"Favorites", @"Favorites")]];
	_segmentedControl.selectedSegmentIndex = 0;
	[_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_segmentedControl];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = safeAreaInsets.top - 20;

    [_segmentedControl makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + 10.0 + verticalOffset);
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(@(IS_IPHONE ? 170.0 : 300.0));
		make.height.equalTo(@28);
	}];

	UIView *line = [[UIView alloc] init];
	line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.view.top).with.offset(64.0 + (IS_RETINA ? 47.5 : 47.0) + verticalOffset);
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(self.view.width);
		make.height.equalTo(IS_RETINA ? @0.5 : @1);
	}];

	_tableView = [[FMMoveTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	_tableView.separatorInset = A3UITableViewSeparatorInset;
	_tableView.separatorColor = A3UITableViewSeparatorColor;
	_tableView.rowHeight = 48.0;
	[self.view addSubview:_tableView];

	[_tableView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(line.bottom);
		make.bottom.equalTo(self.view.bottom);
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
	}];

	_addButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_addButton setImage:[UIImage imageNamed:@"add01"] forState:UIControlStateNormal];
	[_addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addButton];

    verticalOffset = -safeAreaInsets.bottom;

    [_addButton makeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
		make.bottom.equalTo(self.view.bottom).with.offset((IS_RETINA ? -10.5 : -10) + verticalOffset);
	}];
}

#pragma mark -------------- SegmentedControl

- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.tableView.dataSource = self;
		self.tableView.delegate = self;
		[self.tableView reloadData];

		[self.addButton setHidden:NO];
        self.navigationItem.rightBarButtonItem = [self instructionHelpBarButton];
	} else {
		self.navigationItem.rightBarButtonItem = nil;

		[self.favoriteDataSource resetData];
		self.tableView.dataSource = self.favoriteDataSource;
		self.tableView.delegate = self.favoriteDataSource;
		[self.tableView reloadData];

		[self.addButton setHidden:YES];
	}
}

- (A3TranslatorFavoriteDataSource *)favoriteDataSource {
	if (!_favoriteDataSource) {
		_favoriteDataSource = [A3TranslatorFavoriteDataSource new];
		_favoriteDataSource.delegate = self;
	}
	return _favoriteDataSource;
}

- (void)translatorFavoriteItemSelected:(TranslatorFavorite *)item {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];

	TranslatorHistory *history = [TranslatorHistory findFirstByAttribute:@"uniqueID" withValue:item.historyID];
	TranslatorGroup *group = [TranslatorGroup findFirstByAttribute:@"uniqueID" withValue:history.groupID];
	viewController.originalTextLanguage = group.sourceLanguage;
	viewController.translatedTextLanguage = group.targetLanguage;
	viewController.delegate = self;
	viewController.selectItem = history;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)addButtonAction {
	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Data Source

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [TranslatorGroup fetchAllSortedBy:@"order" ascending:YES withPredicate:nil groupBy:nil delegate:nil];
	}

	return _fetchedResultsController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.fetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	static NSString *cellIdentifier = @"TranslatorListCell";

	TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID == %@", group.uniqueID];
	TranslatorHistory *history = [TranslatorHistory findFirstWithPredicate:predicate sortedBy:@"updateDate" ascending:NO];
	NSDate *updateDate = history.updateDate;
	if (IS_IPHONE) {
		UITableViewCell *iPhone_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if(iPhone_cell == nil) {
			iPhone_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
		}

		iPhone_cell.textLabel.font = [UIFont systemFontOfSize:15];
		iPhone_cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		iPhone_cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];

		cell = iPhone_cell;
		cell.detailTextLabel.text = [updateDate timeAgo];
	} else {
		A3TranslatorListCell *iPad_cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if(iPad_cell == nil) {
			iPad_cell = [[A3TranslatorListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		cell = iPad_cell;
		iPad_cell.dateLabel.text = [updateDate timeAgo];
	}

	cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"),
													 [self.languageListManager localizedNameForCode:group.sourceLanguage],
													 [self.languageListManager localizedNameForCode:group.targetLanguage]];

	A3TranslatorCircleView *circleView = [[A3TranslatorCircleView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    circleView.textLabel.text = [NSString stringWithFormat:@"%ld", (long)[TranslatorHistory countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", group.uniqueID]]];
	cell.imageView.image = [circleView imageByRenderingView];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];
		[TranslatorHistory deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", group.uniqueID]];
		[TranslatorFavorite deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"groupID == %@", group.uniqueID]];
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        [context deleteObject:group];

		[self.fetchedResultsController performFetch:nil];

		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

		// Save를 호출하는 순간, Notification이 도착, data reload 됨 save는 UI animation이 모두 종료된 후에 ...
		// 가능한 가장 늦은 시점에 하도록 해야 함
        [context saveIfNeeded];
	}
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	A3TranslatorMessageViewController *viewController = [[A3TranslatorMessageViewController alloc] initWithNibName:nil bundle:nil];
	TranslatorGroup *group = self.fetchedResultsController.fetchedObjects[indexPath.row];

	viewController.originalTextLanguage = group.sourceLanguage;
	viewController.translatedTextLanguage = group.targetLanguage;
	viewController.delegate = self;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)translatorMessageViewControllerWillDismiss:(id)viewController {
	if (_segmentedControl.selectedSegmentIndex == 0) {
		[self.fetchedResultsController performFetch:nil];
	} else {
		[_favoriteDataSource resetData];
	}
	[self.tableView reloadData];
}

#pragma mark --- FMMoveTableVeiwDelegate

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableArray *mutableArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
	[mutableArray moveItemInSortedArrayFromIndex:fromIndexPath.row toIndex:toIndexPath.row];

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveIfNeeded];
	_fetchedResultsController = nil;
}

#pragma mark - AdMob

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view addSubview:bannerView];
	
    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = -safeAreaInsets.bottom;
    
	UIView *superview = self.view;
	[bannerView remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom).with.offset(verticalOffset);
		make.height.equalTo(@(bannerView.bounds.size.height));
	}];

	[_addButton remakeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.view.centerX);
		make.bottom.equalTo(self.view.bottom).with.offset(-(10 + (IS_IPHONE ? 50 : 90)) + verticalOffset);
		make.width.equalTo(@44);
		make.height.equalTo(@44);
	}];

	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.bottom = bannerView.bounds.size.height;
	self.tableView.contentInset = contentInset;

	[self.view layoutIfNeeded];
}

@end
