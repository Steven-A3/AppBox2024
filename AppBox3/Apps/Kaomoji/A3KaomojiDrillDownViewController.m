//
//  A3KaomojiDrillDownViewController.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiDrillDownViewController.h"
#import "A3KaomojiDataManager.h"
#import "A3KaomojiDrillDownTableViewCell.h"
#import "A3AbbreviationCopiedViewController.h"
#import "NSMutableArray+MoveObject.h"
#import "A3DrillDownHelpViewController.h"
#import "UIViewController+A3Addition.h"
#import "A3UIDevice.h"

@interface A3KaomojiDrillDownViewController () <UITableViewDelegate, UITableViewDataSource, UIPreviewInteractionDelegate,
		UIGestureRecognizerDelegate, A3SharePopupViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIPreviewInteraction *previewInteraction;
@property (nonatomic, strong) A3SharePopupViewController *sharePopupViewController;
@property (nonatomic, assign) BOOL sharePopupViewControllerIsPresented;
@property (nonatomic, assign) BOOL previewIsPresented;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) A3AbbreviationCopiedViewController *copiedViewController;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *titleLabelBottomConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (nonatomic, strong) A3DrillDownHelpViewController *helpViewController;

@property (nonatomic, strong) UIPopoverController *sharePopoverController;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, copy) NSString *selectedStringToShare;
@property (nonatomic, assign) CGRect sourceRectForPopover;
@property (nonatomic, assign) BOOL popoverNeedBackground;

@end

@implementation A3KaomojiDrillDownViewController

+ (A3KaomojiDrillDownViewController *)storyboardInstance {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Kaomoji" bundle:nil];
	A3KaomojiDrillDownViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
	return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	_titleLabel.text = _contentsTitle;
	
	[self.navigationController setNavigationBarHidden:NO];
	UIImage *image = [UIImage new];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:image];

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9") && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
		_previewInteraction = [[UIPreviewInteraction alloc] initWithView:self.view];
		_previewInteraction.delegate = self;
	} else {
		UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressTableView:)];
		longPressGestureRecognizer.minimumPressDuration = 1.0;
		longPressGestureRecognizer.delegate = self;
		[self.tableView addGestureRecognizer:longPressGestureRecognizer];
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];

	if (IS_IPHONE_4_7_INCH) {
		_tableView.rowHeight = 54;
		_titleLabel.font = [UIFont boldSystemFontOfSize:21];
	} else if (IS_IPHONE_4_INCH || IS_IPHONE_3_5_INCH) {
		_tableView.rowHeight = 46;
		_titleLabel.font = [UIFont boldSystemFontOfSize:18];
	} else if (IS_IPAD_12_9_INCH) {
		[self.view removeConstraints:@[_titleLabelBottomConstraint, _tableViewTopConstraint]];
		
		NSLayoutConstraint *titleLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
																					  attribute:NSLayoutAttributeBaseline
																					  relatedBy:NSLayoutRelationEqual
																						 toItem:self.view
																					  attribute:NSLayoutAttributeBottom
																					 multiplier:[UIWindow interfaceOrientationIsPortrait] ? 0.09 : 0.12
																					   constant:0];
		NSLayoutConstraint *tableViewTopConstraint = [NSLayoutConstraint constraintWithItem:_tableView
																				  attribute:NSLayoutAttributeTop
																				  relatedBy:NSLayoutRelationEqual
																					 toItem:self.view
																				  attribute:NSLayoutAttributeBottom
																				 multiplier:[UIWindow interfaceOrientationIsPortrait] ? 0.11 : 0.14
																				   constant:0];
		[self.view addConstraints:@[titleLabelBottomConstraint, tableViewTopConstraint]];
		
		_titleLabelBottomConstraint = titleLabelBottomConstraint;
		_tableViewTopConstraint = tableViewTopConstraint;
	} else if (IS_IPAD) {
		[self.view removeConstraints:@[_titleLabelBottomConstraint, _tableViewTopConstraint]];
		
		NSLayoutConstraint *titleLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:_titleLabel
																					  attribute:NSLayoutAttributeBaseline
																					  relatedBy:NSLayoutRelationEqual
																						 toItem:self.view
																					  attribute:NSLayoutAttributeBottom
																					 multiplier:[UIWindow interfaceOrientationIsPortrait] ? 0.10 : 0.13
																					   constant:0];
		NSLayoutConstraint *tableViewTopConstraint = [NSLayoutConstraint constraintWithItem:_tableView
																				  attribute:NSLayoutAttributeTop
																				  relatedBy:NSLayoutRelationEqual
																					 toItem:self.view
																				  attribute:NSLayoutAttributeBottom
																				 multiplier:[UIWindow interfaceOrientationIsPortrait] ? 0.12 : 0.15
																				   constant:0];
		[self.view addConstraints:@[titleLabelBottomConstraint, tableViewTopConstraint]];
		
		_titleLabelBottomConstraint = titleLabelBottomConstraint;
		_tableViewTopConstraint = tableViewTopConstraint;
	}
	[self setupRightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self showHelpView];
	});
}

- (void)setContentsTitle:(NSString *)contentsTitle {
	_contentsTitle = [contentsTitle copy];

	_titleLabel.text = _contentsTitle;
}

- (void)setupRightBarButtonItem {
	if (_isFavoritesList && self.tableView) {
		if (!self.tableView.isEditing) {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																								   target:self
																								   action:@selector(editButtonAction:)];
		} else {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																								   target:self
																								   action:@selector(doneButtonAction:)];
		}
	}
}

- (void)editButtonAction:(UIBarButtonItem *)editButtonAction {
	[self.tableView setEditing:YES animated:YES];
	[self setupRightBarButtonItem];
}

- (void)doneButtonAction:(UIBarButtonItem *)editButtonAction {
	[self.tableView setEditing:NO animated:YES];
	[self setupRightBarButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didLongPressTableView:(UILongPressGestureRecognizer *)gesture {
	CGPoint location = [gesture locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
	if (indexPath) {
		A3SharePopupViewController *viewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:YES];
		viewController.delegate = self;
		viewController.dataSource = self.dataManager;
		viewController.titleString = _contentsArray[indexPath.row];

		_selectedStringToShare = [viewController.titleString copy];
		UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
		_sourceRectForPopover = [self.view convertRect:cell.frame fromView:_tableView];

		[self presentViewController:viewController animated:YES completion:NULL];
	}
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_contentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3KaomojiDrillDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[A3KaomojiDrillDownTableViewCell  reuseIdentifier] forIndexPath:indexPath];
	cell.titleLabel.text = _contentsArray[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return _isFavoritesList;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if ([_dataSource respondsToSelector:@selector(deleteItemForContent:)]) {
			NSDictionary *content = _contentsArray[indexPath.row];
			[_dataSource deleteItemForContent:content];
		}
		[_contentsArray removeObjectAtIndex:indexPath.row];
		[_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	NSDictionary *content = _contentsArray[sourceIndexPath.row];
	if ([_dataSource respondsToSelector:@selector(moveItemForContent:fromIndex:toIndex:)]) {
		[_dataSource moveItemForContent:content fromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
	}
	[_contentsArray moveObjectFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
	[self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (self.presentedViewController) {
		return;
	}

	A3AbbreviationCopiedViewController *viewController = [A3AbbreviationCopiedViewController storyboardInstance];
	viewController.titleString = _contentsArray[indexPath.row];
	[self presentViewController:viewController animated:YES completion:NULL];
	_copiedViewController = viewController;
}

#pragma mark - UIPreviewInteractionDelegate
// https://developer.apple.com/reference/uikit/uipreviewinteraction
// https://developer.apple.com/reference/uikit/uipreviewinteractiondelegate

- (BOOL)previewInteractionShouldBegin:(UIPreviewInteraction *)previewInteraction {
    FNLOG();
    if (self.presentedViewController || self.tableView.isEditing) {
        return NO;
    }
    CGPoint location = [previewInteraction locationInCoordinateSpace:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:location];
    _selectedRow = indexPath.row;
    return indexPath != nil;
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdatePreviewTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
    FNLOG(@"%f, %ld", transitionProgress, (long)ended);
	if (!_previewIsPresented) {
		_previewIsPresented = YES;
        
        _popoverNeedBackground = ended;

        CGPoint location = [previewInteraction locationInCoordinateSpace:_tableView];
        A3KaomojiDrillDownTableViewCell *cell;
        if ([_tableView pointInside:location withEvent:nil]) {
            CGPoint locationInTableView = [previewInteraction locationInCoordinateSpace:_tableView];
            NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:locationInTableView];
            if (indexPath) {
                _selectedRow = indexPath.row;
                cell = [_tableView cellForRowAtIndexPath:indexPath];
                
                _selectedStringToShare = [_contentsArray[_selectedRow] copy];
                _sourceRectForPopover = [self.view convertRect:cell.frame fromView:_tableView];
            }
        }
        FNLOG(@"%@", cell);
		if (!ended && cell) {
            _blurEffectView = [[UIVisualEffectView alloc] init];
            _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _blurEffectView.frame = self.view.bounds;
            [self.navigationController.view addSubview:_blurEffectView];
            
            _blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            
            _animator = [[UIViewPropertyAnimator alloc] initWithDuration:1.0 curve:UIViewAnimationCurveLinear animations:^{
                _blurEffectView.effect = nil;
            }];
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
            _previewView = [cell snapshotViewAfterScreenUpdates:YES];
            
            _previewView.frame = [self.view convertRect:cell.frame fromView:_tableView];
            [_blurEffectView.contentView addSubview:_previewView];
        }
	}

    _animator.fractionComplete = 1.0 - transitionProgress/4;

	if (ended) {
		[self removePreviewView];
	}
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdateCommitTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
	if (!self.sharePopupViewControllerIsPresented) {
		_sharePopupViewControllerIsPresented = YES;
		_sharePopupViewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:_popoverNeedBackground];
		_sharePopupViewController.presentationIsInteractive = YES;
		_sharePopupViewController.dataSource = self.dataManager;
		_sharePopupViewController.delegate = self;
		_sharePopupViewController.titleString = _contentsArray[_selectedRow];
		[self presentViewController:_sharePopupViewController animated:YES completion:NULL];
	}
	_sharePopupViewController.interactiveTransitionProgress = transitionProgress;

	if (ended) {
		[_sharePopupViewController completeCurrentInteractiveTransition];
	}
}

- (void)previewInteractionDidCancel:(UIPreviewInteraction *)previewInteraction {
	if (!self.presentedViewController) {
		[self removeBlurEffectView];
	}
	[_sharePopupViewController cancelCurrentInteractiveTransition];
	[self removePreviewView];
	_sharePopupViewControllerIsPresented = NO;
}

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController didTapShareButton:(BOOL)didTapShareButton {
    if (didTapShareButton) {
        _activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
        [_activityViewController view];
    }
}

- (void)sharePopupViewControllerDidDismiss:(A3SharePopupViewController *)viewController didTapShareButton:(BOOL)didTapShareButton {
	_sharePopupViewControllerIsPresented = NO;
	[self removeBlurEffectView];

	if (didTapShareButton) {
		if (IS_IPHONE) {
			[self presentViewController:_activityViewController animated:YES completion:NULL];
		} else {
			UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:_activityViewController];
			[popoverController presentPopoverFromRect:_sourceRectForPopover
											   inView:self.view
							 permittedArrowDirections:UIPopoverArrowDirectionAny
											 animated:YES];
			_sharePopoverController = popoverController;
		}
	}
}

- (void)sharePopupViewControllerContentsModified {
    if (_isFavoritesList) {
        self.contentsArray = [[self.dataManager favoritesArray] mutableCopy];
    }
    [_tableView reloadData];
}

- (void)removePreviewView {
	[_previewView removeFromSuperview];
	_previewView = nil;
	_previewIsPresented = NO;
}

- (void)removeBlurEffectView {
    [_animator stopAnimation:YES];
	_animator = nil;
	[_blurEffectView removeFromSuperview];
	_blurEffectView = nil;
}

- (IBAction)helpButtonAction:(id)sender {
	if (_helpViewController) {
		return;
	}
	_helpViewController = [A3DrillDownHelpViewController storyboardInstance];
	_helpViewController.imageName = @"KaomojiPopover";
    [self.navigationController addChildViewController:_helpViewController];
	[self.navigationController.view addSubview:_helpViewController.view];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnHelpView)];
	[_helpViewController.view addGestureRecognizer:tapGestureRecognizer];
	
	[_tableView scrollsToTop];
}

- (void)didTapOnHelpView {
	[_helpViewController.view removeFromSuperview];
	[_helpViewController removeFromParentViewController];
	_helpViewController = nil;
}

- (void)showHelpView {
	NSString *userDefaultKey = [NSString stringWithFormat:@"%@HelpDidShow", NSStringFromClass([self class])];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:userDefaultKey]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:userDefaultKey];
		
		[self helpButtonAction:self];
	}
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	return @"";
}

- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share information with you.", nil)
									   contents:_selectedStringToShare
										   tail:NSLocalizedString(@"You can find more in the AppBox Pro.", nil)];
	}
	return _selectedStringToShare;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(nullable UIActivityType)activityType {
    return [self.dataManager subjectForActivityType:activityType];
}

@end
