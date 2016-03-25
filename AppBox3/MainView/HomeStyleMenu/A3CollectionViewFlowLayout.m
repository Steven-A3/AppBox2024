//
//  A3CollectionViewFlowLayout.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "common.h"
#import "A3CollectionViewFlowLayout.h"
#import "A3MovingCollectionViewCell.h"

@interface A3CollectionViewFlowLayout () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) A3MovingCollectionViewCell *cellFakeView;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic, assign) CGPoint fakeCellCenter;

@end

@implementation A3CollectionViewFlowLayout {
	BOOL _scrollInProgress;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		[self configureObserver];
	}
	
	return self;
}

#pragma mark - UICollectionViewLayout Subclass hooks

- (void)prepareLayout
{
	[super prepareLayout];
	
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray *layoutAttributes = [[NSMutableArray alloc] init];
	NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
	
	for (NSInteger i = 0 ; i < numberOfItems; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
		UICollectionViewLayoutAttributes *layoutAttribute = [self layoutAttributesForItemAtIndexPath:indexPath];
		if ([indexPath isEqual:_cellFakeView.indexPath]) {
			CGFloat cellAlpha = 0;
			if (_dataSource && [_dataSource respondsToSelector:@selector(reorderingItemAlpha:inSection:)]) {
				cellAlpha = [_dataSource reorderingItemAlpha:self.collectionView inSection:layoutAttribute.indexPath.section];
			}
			layoutAttribute.alpha = cellAlpha;
		}
		
		[layoutAttributes addObject:layoutAttribute];
	}
	
	return layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

- (void)dealloc{
	[self removeObserver:self forKeyPath:@"collectionView"];
}

#pragma mark - setup

- (void)configureObserver{
	[self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setUpGestureRecognizers{
	if (self.collectionView == nil) {
		return;
	}
	_longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
	_longPress.delegate = self;
	_longPress.minimumPressDuration = 0.3;

	_panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
	_panGesture.delegate = self;
	_panGesture.maximumNumberOfTouches = 1;

	NSArray *gestures = [self.collectionView gestureRecognizers];
	[gestures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
			[(UIGestureRecognizer *)obj requireGestureRecognizerToFail:_longPress];
		}
	}];
	
	[self.collectionView addGestureRecognizer:_longPress];
	[self.collectionView addGestureRecognizer:_panGesture];
}

- (void)invalidateDisplayLink{
	[_displayLink invalidate];
	_displayLink = nil;
}

- (void)changePageIfNeededWithPanRecognizer:(UIPanGestureRecognizer *)pan {
	if (!_cellFakeView || _scrollInProgress) {
		return;
	}
	CGFloat coordinateInPage = _cellFakeView.frame.origin.x - self.collectionView.contentOffset.x;
	CGFloat screenWidth = [A3UIDevice screenBoundsAdjustedWithOrientation].size.width;
	if (self.collectionView.contentOffset.x != 0 && coordinateInPage < -30) {
		[UIView animateWithDuration:0.3 animations:^{
			_scrollInProgress = YES;
			[self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x - screenWidth, self.collectionView.contentOffset.y) animated:YES];
			_fakeCellCenter.x -= screenWidth;
			CGPoint center = _cellFakeView.center;
			center.x -= screenWidth;
			_cellFakeView.center = center;
		} completion:^(BOOL finished) {
			_scrollInProgress = NO;
			[self moveItemIfNeeded];
		}];
		return;
	}
	coordinateInPage = MAX(0, _cellFakeView.frame.origin.x + _cellFakeView.frame.size.width - self.collectionView.contentOffset.x);
	if ((self.collectionView.contentSize.width - (self.collectionView.contentOffset.x + screenWidth)) <= 0) {
		[self moveItemIfNeeded];
		return;
	}
	if ((screenWidth - coordinateInPage) < -30) {
		[UIView animateWithDuration:0.3 animations:^{
			_scrollInProgress = YES;
			[self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + screenWidth, self.collectionView.contentOffset.y) animated:YES];
			_fakeCellCenter.x += screenWidth;
			CGPoint center = _cellFakeView.center;
			center.x += screenWidth;
			_cellFakeView.center = center;
		} completion:^(BOOL finished) {
			_scrollInProgress = NO;
			[self moveItemIfNeeded];
		}];
		return;
	}
	[self moveItemIfNeeded];
}

// move item
- (void)moveItemIfNeeded {
	NSIndexPath *atIndexPath;
	NSIndexPath *toIndexPath;
	if (_cellFakeView) {
		atIndexPath = _cellFakeView.indexPath;
		toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
	}
	
	if (atIndexPath == nil || toIndexPath == nil) {
		return;
	}
	
	if ([atIndexPath isEqual:toIndexPath]) {
		return;
	}
	
	// can move item
	if ([_delegate respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
		
		if (![_delegate collectionView:self.collectionView canMoveItemAtIndexPath:toIndexPath]) {
			return;
		}
	}
	
	// will move item
	if ([_delegate respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)]) {
		[_delegate collectionView:self.collectionView itemAtIndexPath:atIndexPath willMoveToIndexPath:toIndexPath];
	}
	
	UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:toIndexPath];
	[self.collectionView performBatchUpdates:^{
		_cellFakeView.indexPath = toIndexPath;
		_cellFakeView.cellFrame = attribute.frame;
		[_cellFakeView changeBoundsIfNeeded:attribute.bounds];
		[self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
		
		if ([_delegate respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)]) {
			[_delegate collectionView:self.collectionView itemAtIndexPath:atIndexPath didMoveToIndexPath:toIndexPath];
		}
	} completion:nil];
}

- (BOOL)deleteItemIfNeeded {
	CGPoint point = [self.collectionView convertPoint:_cellFakeView.center toView:self.collectionView.backgroundView];
	if ([_deleteZoneView pointInside:point withEvent:nil]) {
		if ([_delegate respondsToSelector:@selector(collectionView:layout:didSelectDeleteAtIndexPath:)]) {
			return [_delegate collectionView:self.collectionView layout:self didSelectDeleteAtIndexPath:_cellFakeView.indexPath];
		}
		return YES;
	}
	return YES;
}

- (void)cancelDrag:(NSIndexPath *)toIndexPath {
	if (_cellFakeView == nil) {
		return;
	}

	BOOL pushBackCellFakeView = [self deleteItemIfNeeded];
	// will end drag item
	if ([_delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
		[_delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:toIndexPath];
	}
	
	self.collectionView.scrollsToTop = YES;
	
	_fakeCellCenter = CGPointZero;
	
	[self invalidateDisplayLink];

	if (pushBackCellFakeView) {
		[_cellFakeView pushBackView:^{
			[_cellFakeView removeFromSuperview];
			_cellFakeView = nil;
			[self invalidateLayout];
			if ([_delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
				[_delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:toIndexPath];
			}
		}];
	} else {
		if ([_delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
			[_delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:toIndexPath];
		}
	}
}

- (void)removeCellFakeView:(void(^)(void))completion {
	[UIView animateWithDuration:0.3 animations:^{
		[_cellFakeView setAlpha:0.0];
	} completion:^(BOOL finished) {
		[_cellFakeView removeFromSuperview];
		[_cellFakeView setAlpha:1.0];
		_cellFakeView = nil;
		[self.collectionView reloadData];
		if (completion) {
			completion();
		}
	}];
}

#pragma mark - gesture
// long press gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
	CGPoint location = [longPress locationInView:self.collectionView];
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
	
	if (_cellFakeView != nil) {
		indexPath = self.cellFakeView.indexPath;
	}
	
	if (indexPath == nil) {
		return;
	}
	
	switch (longPress.state) {
		case UIGestureRecognizerStateBegan:{
			// will begin drag item
			if ([_delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
				[_delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
			}
			
			self.collectionView.scrollsToTop = NO;
			
			UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
			
			_cellFakeView = [[A3MovingCollectionViewCell alloc] initWithCell:currentCell];
			_cellFakeView.indexPath = indexPath;
			_cellFakeView.originalCenter = currentCell.center;
			_cellFakeView.cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
			[self.collectionView addSubview:self.cellFakeView];
			
			_fakeCellCenter = self.cellFakeView.center;
			
			[self invalidateLayout];
			
			[_cellFakeView pushFowardView];
			
			// did begin drag item
			if ([_delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
				[_delegate collectionView:self.collectionView layout:self didBeginDraggingItemAtIndexPath:indexPath];
			}
		}
			break;
		case UIGestureRecognizerStateCancelled:
			
		case UIGestureRecognizerStateEnded:
			[self cancelDrag: indexPath];
		default:
			break;
	}
}

// pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
	_panTranslation = [pan translationInView:self.collectionView];
	if (_cellFakeView != nil) {
		switch (pan.state) {
			case UIGestureRecognizerStateChanged:{
				CGPoint center = _cellFakeView.center;
				center.x = self.fakeCellCenter.x + self.panTranslation.x;
				center.y = self.fakeCellCenter.y + self.panTranslation.y;
				_cellFakeView.center = center;

				if (self.collectionView.pagingEnabled) {
					[self changePageIfNeededWithPanRecognizer:pan];
				} else {
					[self moveItemIfNeeded];
				}
			}
				break;
			case UIGestureRecognizerStateCancelled:
			case UIGestureRecognizerStateEnded:
				[self invalidateDisplayLink];
			default:
				break;
		}
	}
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
		CGPoint location = [touch locationInView:self.collectionView];
		NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
		if (indexPath) {
			if ([_delegate respondsToSelector:@selector(collectionView:layout:willTouchesBeginItemAtIndexPath:)]) {
				[_delegate collectionView:self.collectionView layout:self willTouchesBeginItemAtIndexPath:indexPath];
			}
		}
	}
	return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
	
	// allow move item
	CGPoint location = [gestureRecognizer locationInView:self.collectionView];
	NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
	if (indexPath) {
		if ([_delegate respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
			BOOL canMove = [_delegate collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
			if (!canMove) {
				return NO;
			}
		}
	}

	if([gestureRecognizer isEqual:_longPress]){
		if (self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStatePossible && self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStateFailed) {
			return NO;
		}
	}else if([gestureRecognizer isEqual:_panGesture]){
		if (_longPress.state == UIGestureRecognizerStatePossible || _longPress.state == UIGestureRecognizerStateFailed) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if ([_panGesture isEqual:gestureRecognizer]) {
		if ([_longPress isEqual:otherGestureRecognizer]) {
			return YES;
		}else{
			return NO;
		}
	}else if ([_longPress isEqual:gestureRecognizer]) {
		if ([_panGesture isEqual:otherGestureRecognizer]) {
			return YES;
		}
	}else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
		if (_longPress.state == UIGestureRecognizerStatePossible || _longPress.state == UIGestureRecognizerStateFailed) {
			return NO;
		}
	}
	return YES;
}

#pragma mark - observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqualToString:@"collectionView"]) {
		[self setUpGestureRecognizers];
	}else{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - setter

- (void)setDelegate:(id<A3ReorderableLayoutDelegate>)delegate{
	_delegate = delegate;
	self.collectionView.delegate = delegate;
}

- (void)setDataSource:(id<A3ReorderableLayoutDataSource>)dataSource{
	_dataSource = dataSource;
	self.collectionView.dataSource = dataSource;
}

- (UIView *)deleteZoneView {
	if (!_deleteZoneView) {
		_deleteZoneView = [UIView new];
	}
	return _deleteZoneView;
}

- (void)insertDeleteZoneToView:(UIView *)targetView {
	UIView *superview = targetView;
	
	[superview addSubview:self.deleteZoneView];
	
	[_deleteZoneView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(superview.top);
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.height.equalTo(IS_IPHONE ? @70 : @80);
	}];
	
	UILabel *textLabel = [UILabel new];
	textLabel.text = NSLocalizedString(@"Drag here to hide", @"Drag here to hide");
	textLabel.textColor = [UIColor whiteColor];
	textLabel.font = [UIFont systemFontOfSize:24];
	textLabel.adjustsFontSizeToFitWidth = YES;
	textLabel.minimumScaleFactor = 0.4;
	textLabel.textAlignment = NSTextAlignmentCenter;
	[_deleteZoneView addSubview:textLabel];
	
	[textLabel makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_deleteZoneView.bottom).with.offset(-10);
		make.left.equalTo(_deleteZoneView.left).with.offset(10);
		make.right.equalTo(_deleteZoneView.right).with.offset(-10);
	}];
}

@end
