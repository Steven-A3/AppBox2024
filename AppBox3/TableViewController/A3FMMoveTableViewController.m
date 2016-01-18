//
//  A3FMMoveTableViewController.m
//  AppBox3
//
//  Created by A3 on 6/12/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3FMMoveTableViewController.h"
#import "UIViewController+NumberKeyboard.h"

const CGFloat kVisibleWidth = 100.0;

@implementation A3FMMoveTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	_tableView = [[FMMoveTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	if ([_tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		_tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	[self.view addSubview:self.tableView];
}

// Setup a left and right swipe recognizer.
-(void)setupSwipeRecognizers
{
	UISwipeGestureRecognizer* leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.tableView addGestureRecognizer:leftSwipeRecognizer];

	UISwipeGestureRecognizer* rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
	rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.tableView addGestureRecognizer:rightSwipeRecognizer];

	[self setSwipedCells:[NSMutableSet set]];
}

// Called when a swipe is performed.
- (void)swipe:(UISwipeGestureRecognizer *)recognizer
{
	bool doneSwiping = recognizer && (recognizer.state == UIGestureRecognizerStateEnded);

	if (doneSwiping)
	{
		// find the swiped cell
		CGPoint location = [recognizer locationInView:self.tableView];
		NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:location];
		if (indexPath.row == 0 && self.firstResponder) {
			return;
		}
		UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3FMMoveTableViewSwipeCellDelegate> *) [self.tableView cellForRowAtIndexPath:indexPath];

		BOOL shouldShowMenu = NO;
		if ([swipedCell respondsToSelector:@selector(cellShouldShowMenu)]) {
			shouldShowMenu = [swipedCell cellShouldShowMenu];
		}
		if (!shouldShowMenu) return;

		CGFloat shiftLength = kVisibleWidth;
		if ([swipedCell respondsToSelector:@selector(menuWidth:)]) {
			shiftLength = [swipedCell menuWidth:[self.tableView numberOfRowsInSection:0] > 3 ];
		}
		if ((recognizer.direction==UISwipeGestureRecognizerDirectionLeft) && (swipedCell.frame.origin.x==0) )
		{
			[self shiftRight:self.swipedCells];  // animate all cells left
			[self shiftLeft:swipedCell];       // animate swiped cell right
		}
		else if ((recognizer.direction == UISwipeGestureRecognizerDirectionRight) && (swipedCell.frame.origin.x == -shiftLength))
		{
			[self shiftRight:[NSMutableSet setWithObject:swipedCell]]; // animate current cell left
		}

	}
}

// Animates the cells to the right.
-(void)shiftRight:(NSMutableSet*)cells
{
	if ([cells count]>0)
	{
		for (UITableViewCell<A3FMMoveTableViewSwipeCellDelegate>* cell in  cells)
		{
			// shift the cell left and remove its menu view
			CGRect newFrame;
			newFrame = CGRectOffset(cell.frame, -cell.frame.origin.x, 0.0);
			[UIView animateWithDuration:0.2 animations:^{
				cell.frame = newFrame;
			} completion:^(BOOL finished) {
				if ([cell respondsToSelector:@selector(removeMenuView)]) {
					if (cell.frame.origin.x == 0.0)
						[cell removeMenuView];
				}

				NSMutableArray *reloadRows = [NSMutableArray new];
				NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
				if (indexPath) {
					[reloadRows addObject:indexPath];
				}
				[self.tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
			}];
		}

		// update the set of swiped cells
		[self.swipedCells minusSet:cells];
	}
}


// Animates the cells to the left offset with kVisibleWidth
-(void)shiftLeft:(UITableViewCell<A3FMMoveTableViewSwipeCellDelegate> *)cell {
	bool cellAlreadySwiped = [self.swipedCells containsObject:cell];
	if (!cellAlreadySwiped) {
		// add the cell menu view and shift the cell to the right
		if ([cell respondsToSelector:@selector(addMenuView:)]) {
			[cell addMenuView:[self.tableView numberOfRowsInSection:0] > 3 ];
		}
		CGFloat shiftLength = kVisibleWidth;
		if ([cell respondsToSelector:@selector(menuWidth:)]) {
			shiftLength = [cell menuWidth:[self.tableView numberOfRowsInSection:0] > 3 ];
		}
		CGRect newFrame;
		newFrame = CGRectOffset(cell.frame, -shiftLength, 0.0);
		[UIView animateWithDuration:0.2 animations:^{
			cell.frame = newFrame;
		}];

		// update the set of swiped cells
		[self.swipedCells addObject:cell];
	}
}

#pragma mark - UIScrollViewDelegate

// un-swipe everything when the user scrolls
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	[self unSwipeAll];
}

- (void)unSwipeAll {
	[self shiftRight:self.swipedCells];
}

@end
