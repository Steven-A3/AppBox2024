//
//  A3ChooseColorPhone.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ChooseColorPhone.h"
#import "A3ClockDataManager.h"

@interface A3ChooseColorPhone () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *colorsArray;
@property (nonatomic, strong) UIImageView *selectedMarkView;

@end

@implementation A3ChooseColorPhone {
	NSUInteger _selectedIndex;
}

NSString *const ClockColorChooseCell = @"ClockColorCell";

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors selectedIndex:(NSUInteger)selectedIndex {
    self = [super initWithFrame:frame];
    if (self) {
		_colorsArray = colors;
		_selectedIndex = selectedIndex;

        UIView* viewCaption = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.f)];
		viewCaption.layer.borderColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0].CGColor;
		viewCaption.layer.borderWidth = 1;
        [viewCaption setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewCaption];

		[viewCaption makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.left).with.offset(-1);
			make.top.equalTo(self.top);
			make.right.equalTo(self.right).with.offset(1);
			make.height.equalTo(@44);
		}];
        
        UILabel* lbCaption = [[UILabel alloc] initWithFrame:viewCaption.frame];
        
        lbCaption.center = CGPointMake(self.center.x + 16, viewCaption.center.y);
        lbCaption.textAlignment = NSTextAlignmentLeft;
        lbCaption.textColor = [UIColor colorWithRed:109.f/255.f green:109.f/255.f blue:114.f/255.f alpha:1.f];
		lbCaption.font = [UIFont systemFontOfSize:16];
        lbCaption.text = @"CHOOSE COLOR";
        [self addSubview:lbCaption];
        
        UIButton* btnX = [UIButton buttonWithType:UIButtonTypeSystem];
		[btnX setImage:[UIImage imageNamed:@"delete02"] forState:UIControlStateNormal];
		[btnX addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: btnX];

        [btnX makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).with.offset(0);
            make.right.equalTo(self.right);
            make.width.equalTo(@44.f);
            make.height.equalTo(@44.f);
        }];

		UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];

		if (IS_IPHONE) {
			flowLayout.itemSize = CGSizeMake(44, 88);
			flowLayout.sectionInset = UIEdgeInsetsMake(20, 15, 20, 15);
			flowLayout.minimumInteritemSpacing = 10;
			flowLayout.minimumLineSpacing = 10;
			flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		} else {
			flowLayout.itemSize = CGSizeMake(88, 88);
			flowLayout.sectionInset = UIEdgeInsetsMake(20, 28, 20, 28);
			flowLayout.minimumInteritemSpacing = 30;
			flowLayout.minimumLineSpacing = 20;
			flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
		}

		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
		_collectionView.dataSource = self;
		_collectionView.delegate = self;
		_collectionView.backgroundColor = [UIColor colorWithRed:239.f / 255.f green:239.f / 255.f blue:244.f / 255.f alpha:1.f];
		_collectionView.showsHorizontalScrollIndicator = NO;
		[_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ClockColorChooseCell];

		[self addSubview:_collectionView];
		[_collectionView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(viewCaption.bottom);
			make.left.equalTo(self.left);
			make.right.equalTo(self.right);
			make.height.equalTo(IS_IPHONE ? @128 : @236);
		}];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
	return [_colorsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	// we're going to use a custom UICollectionViewCell, which will hold an image and its label
	//
	UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:ClockColorChooseCell forIndexPath:indexPath];
	if (indexPath.row == _selectedIndex) {
		UIColor *selectedColor = _colorsArray[(NSUInteger) indexPath.row];
		cell.layer.borderColor = selectedColor.CGColor;
		cell.layer.borderWidth = 1.0;
		cell.backgroundColor = [UIColor whiteColor];
		[cell addSubview:self.selectedMarkView];

		[self.selectedMarkView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(cell.centerX);
			make.centerY.equalTo(cell.centerY).with.offset(10);
		}];
	} else {
		if (self.selectedMarkView.superview == cell) {
			[self.selectedMarkView removeFromSuperview];
		}
		cell.backgroundColor = _colorsArray[(NSUInteger) indexPath.row];
		cell.layer.borderWidth = 0.0;
	}

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	_selectedIndex = (NSUInteger) indexPath.row;
	id <A3ChooseColorDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(chooseColorDidSelect:selectedIndex:)]) {
		[o chooseColorDidSelect:_colorsArray[indexPath.row] selectedIndex:(NSUInteger) indexPath.row];
	}
	[collectionView reloadData];
}

- (UIImageView *)selectedMarkView {
	if (!_selectedMarkView) {
		_selectedMarkView = [UIImageView new];
		_selectedMarkView.image = [UIImage imageNamed:@"check"];
		[_selectedMarkView sizeToFit];
	}
	return _selectedMarkView;
}

@end
