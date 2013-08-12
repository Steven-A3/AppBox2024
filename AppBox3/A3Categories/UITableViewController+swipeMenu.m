//
//  UITableViewController+swipeMenu.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <objc/runtime.h>
#import "UITableViewController+swipeMenu.h"
#import "common.h"

static char const *const KEY_A3TVC_SWIPED_CELLS	= "key_a3tvc_swiped_cells";
const CGFloat kVisibleWidth = 100.0;

@implementation UITableViewController (swipeMenu)

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
    FNLOG();
	bool doneSwiping = recognizer && (recognizer.state == UIGestureRecognizerStateEnded);

	if (doneSwiping)
	{
		// find the swiped cell
		CGPoint location = [recognizer locationInView:self.tableView];
		NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:location];
		UITableViewCell<A3TableViewSwipeCellDelegate> *swipedCell = (UITableViewCell <A3TableViewSwipeCellDelegate> *) [self.tableView cellForRowAtIndexPath:indexPath];

		CGFloat shiftLenth = kVisibleWidth;
		if ([swipedCell respondsToSelector:@selector(menuWidth)]) {
			shiftLenth = [swipedCell menuWidth];
		}
		if ((recognizer.direction==UISwipeGestureRecognizerDirectionLeft) && (swipedCell.frame.origin.x==0) )
		{
			[self shiftRight:self.swipedCells];  // animate all cells left
			[self shiftLeft:swipedCell];       // animate swiped cell right
		}
		else if ((recognizer.direction == UISwipeGestureRecognizerDirectionRight) && (swipedCell.frame.origin.x == -shiftLenth))
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
		for (UITableViewCell<A3TableViewSwipeCellDelegate>* cell in  cells)
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
			}];
		}

		// update the set of swiped cells
		[self.swipedCells minusSet:cells];
	}
}


// Animates the cells to the left offset with kVisibleWidth
-(void)shiftLeft:(UITableViewCell<A3TableViewSwipeCellDelegate> *)cell {
	FNLOG();

	bool cellAlreadySwiped = [self.swipedCells containsObject:cell];
	if (!cellAlreadySwiped) {
		// add the cell menu view and shift the cell to the right
		if ([cell respondsToSelector:@selector(addMenuView)]) {
			[cell addMenuView];
		}
		CGFloat shiftLength = kVisibleWidth;
		if ([cell respondsToSelector:@selector(menuWidth)]) {
			shiftLength = [cell menuWidth];
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
	[self unswipeAll];
}

- (void)unswipeAll {
    FNLOG();
	[self shiftRight:self.swipedCells];
}

#pragma mark - required variables

- (NSMutableSet *)swipedCells {
	NSMutableSet *swipedCells;
	swipedCells = objc_getAssociatedObject(self, KEY_A3TVC_SWIPED_CELLS);
	return swipedCells;
}

- (void)setSwipedCells:(NSMutableSet *)swipedCells {
	objc_setAssociatedObject(self, KEY_A3TVC_SWIPED_CELLS, swipedCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
