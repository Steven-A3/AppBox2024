//
//  A3GridStyleTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3GridStyleTableViewCell.h"
#import "A3GradientView.h"
#import "CommonUIDefinitions.h"
#import "common.h"

@interface A3GridStyleTableViewCell ()

@end

@implementation A3GridStyleTableViewCell {
	NSUInteger numberOfColumns;
	NSUInteger numberOfItems;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
//		self.backgroundColor = [UIColor yellowColor];
	}

	return self;
}

#define	A3_GRID_VIEW_LEFT_MARGIN		12.0f
#define A3_GRID_VIEW_TOP_MARGIN			18.0f
#define A3_GRID_VIEW_BOTTOM_MARGIN		8.0f
#define A3_GRID_VIEW_CELL_IMAGE_WIDTH	57.0f
#define A3_GRID_VIEW_CELL_IMAGE_HEIGHT	57.0f
#define A3_GRID_VIEW_LABEL_HEIGHT		20.0f

- (CGFloat)heightForContents {
	CGFloat height;

	numberOfColumns = [self.dataSource numberOfColumnsInGridViewController:self];
	numberOfItems = [self.dataSource numberOfItemsInGridViewController:self];

	height = A3_GRID_VIEW_TOP_MARGIN + ((numberOfItems - 1) / numberOfColumns + 1.0f) * (A3_GRID_VIEW_CELL_IMAGE_HEIGHT + A3_GRID_VIEW_LABEL_HEIGHT) + A3_GRID_VIEW_BOTTOM_MARGIN;

	return height;
}

- (void)reload {
	[self setFrame:CGRectMake(0.0f, 0.0f, A3_MENU_TABLE_VIEW_WIDTH, [self heightForContents])];

	// Remove all subviews from self.view
	for (UIView *subview in [self subviews]) {
        if (subview.tag) {
            [subview removeFromSuperview];
        }

	}
	A3GradientView *gradientView = [[A3GradientView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), 2.0f)];
	NSArray *gradientColors = @[(__bridge id)[[UIColor colorWithRed:215.0f/255.0f green:217.0f/255.0f blue:219.0f/255.0f alpha:1.0f] CGColor],
	(__bridge id)[[UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:237.0f/255.0f alpha:1.0f] CGColor]];
	gradientView.gradientColors = gradientColors;
    gradientView.tag = 1;
	[self addSubview:gradientView];

	CGFloat columnWidth = (CGRectGetWidth(self.bounds) - A3_GRID_VIEW_LEFT_MARGIN * 2.0f) / numberOfColumns;
	CGFloat rowHeight = A3_GRID_VIEW_CELL_IMAGE_HEIGHT + A3_GRID_VIEW_LABEL_HEIGHT;

	UIFont *labelFont = [UIFont systemFontOfSize:12.0f];
	UIColor *textColor = [UIColor colorWithRed:118.0f/255.0f green:118.0f/255.0f blue:118.0f/255.0f alpha:1.0f];
	UIColor *backgroundColor = [UIColor clearColor];
	for (NSInteger index = 0; index < numberOfItems; index++) {
		UIImage *image = [self.dataSource gridStyleTableViewCell:self imageForIndex:index];
		NSString *title = [self.dataSource gridStyleTableViewCell:self titleForIndex:index];

		if (image && title) {
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.tag = index + 333993;
			[button addTarget:self action:@selector(touchUpInsideButton:) forControlEvents:UIControlEventTouchUpInside];
			[button setFrame:CGRectMake(((index % numberOfColumns) + 1) * columnWidth - columnWidth / 2.0f + A3_GRID_VIEW_LEFT_MARGIN - A3_GRID_VIEW_CELL_IMAGE_WIDTH / 2.0f,
					A3_GRID_VIEW_TOP_MARGIN + rowHeight * (index / numberOfColumns),
					A3_GRID_VIEW_CELL_IMAGE_WIDTH,
					A3_GRID_VIEW_CELL_IMAGE_HEIGHT)];
			[button setImage:image forState:UIControlStateNormal];
			[self addSubview:button];

			CGRect labelFrame = CGRectMake(A3_GRID_VIEW_LEFT_MARGIN + columnWidth * (index % numberOfColumns),
					A3_GRID_VIEW_TOP_MARGIN + rowHeight * (index / numberOfColumns) + A3_GRID_VIEW_CELL_IMAGE_HEIGHT,
					columnWidth, A3_GRID_VIEW_LABEL_HEIGHT - 3.0f);
			UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
			label.text = title;
			label.textColor = textColor;
			label.backgroundColor = backgroundColor;
			label.font = labelFont;
			label.textAlignment = NSTextAlignmentCenter;
            label.tag = 1;
			[self addSubview:label];
		}
	}
}

- (void)touchUpInsideButton:(UIButton *)button {
	if ([self.delegate respondsToSelector:@selector(gridStyleTableViewCell:didSelectItemAtIndex:)]) {
		[self.delegate gridStyleTableViewCell:self didSelectItemAtIndex:button.tag - 333993];
	}
}

@end
