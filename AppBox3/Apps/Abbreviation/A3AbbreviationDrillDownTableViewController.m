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
#import "A3SharePopupViewController.h"
#import "A3AbbreviationCopiedViewController.h"
#import "NSMutableArray+MoveObject.h"
#import "UIViewController+A3Addition.h"

extern NSString *const A3AbbreviationKeyAbbreviation;
extern NSString *const A3AbbreviationKeyMeaning;

@interface A3AbbreviationDrillDownTableViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPreviewInteractionDelegate,
UIGestureRecognizerDelegate, A3SharePopupViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UIPreviewInteraction *previewInteraction;
@property (nonatomic, strong) A3SharePopupViewController *sharePopupViewController;
@property (nonatomic, assign) BOOL sharePopupViewControllerIsPresented;
@property (nonatomic, assign) BOOL previewIsPresented;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIViewPropertyAnimator *animator;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) A3AbbreviationCopiedViewController *copiedViewController;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation A3AbbreviationDrillDownTableViewController

+ (NSString *)storyboardID {
	return @"A3AbbreviationDrillDownTableViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
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

	} else if (IS_IPAD) {

	}
	[self setupRightBarButtonItem];
}

- (void)setupRightBarButtonItem {
	if (_allowsEditing && self.tableView) {
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
		viewController.dataSource = self.dataManager;
		viewController.titleString = _contentsArray[indexPath.row][A3AbbreviationKeyAbbreviation];
		[self presentViewController:viewController animated:YES completion:NULL];
	}
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
	viewController.titleString = _contentsArray[indexPath.row][A3AbbreviationKeyAbbreviation];
	[self presentViewController:viewController animated:YES completion:NULL];
	_copiedViewController = viewController;
}

#pragma mark - UIPreviewInteractionDelegate
// https://developer.apple.com/reference/uikit/uipreviewinteraction
// https://developer.apple.com/reference/uikit/uipreviewinteractiondelegate

- (BOOL)previewInteractionShouldBegin:(UIPreviewInteraction *)previewInteraction {
	return !self.presentedViewController && !self.tableView.isEditing;
}

- (void)previewInteraction:(UIPreviewInteraction *)previewInteraction didUpdatePreviewTransition:(CGFloat)transitionProgress ended:(BOOL)ended {
	if (!_previewIsPresented) {
		_previewIsPresented = YES;
		
		_blurEffectView = [[UIVisualEffectView alloc] init];
		_blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_blurEffectView.frame = self.view.bounds;
		[self.navigationController.view addSubview:_blurEffectView];
		
		_blurEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		
		_animator = [[UIViewPropertyAnimator alloc] initWithDuration:1.0 curve:UIViewAnimationCurveLinear animations:^{
			_blurEffectView.effect = nil;
		}];
		
		if (!ended) {
			CGPoint location = [previewInteraction locationInCoordinateSpace:_tableView];
			if ([_tableView pointInside:location withEvent:nil]) {
				CGPoint locationInTableView = [previewInteraction locationInCoordinateSpace:_tableView];
				NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:locationInTableView];
				if (indexPath) {
					_selectedRow = indexPath.row;
					A3AbbreviationDrillDownTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];

					cell.contentView.backgroundColor = [UIColor whiteColor];
					_previewView = [cell snapshotViewAfterScreenUpdates:YES];
					
					_previewView.frame = [self.view convertRect:cell.frame fromView:_tableView];
					[self.navigationController.view addSubview:_previewView];
				}
			}
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
		_sharePopupViewController = [A3SharePopupViewController storyboardInstanceWithBlurBackground:NO];
		_sharePopupViewController.presentationIsInteractive = YES;
		_sharePopupViewController.dataSource = self.dataManager;
		_sharePopupViewController.delegate = self;
		_sharePopupViewController.titleString = _contentsArray[_selectedRow][A3AbbreviationKeyAbbreviation];
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
	_sharePopupViewControllerIsPresented = NO;
	[self removePreviewView];
}

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController {
	_sharePopupViewControllerIsPresented = NO;
	[self removeBlurEffectView];
}

- (void)removePreviewView {
	[_previewView removeFromSuperview];
	_previewView = nil;
	_previewIsPresented = NO;
}

- (void)removeBlurEffectView {
	_animator = nil;
	[_blurEffectView removeFromSuperview];
	_blurEffectView = nil;
}

@end
