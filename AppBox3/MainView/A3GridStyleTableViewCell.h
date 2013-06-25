//
//  A3GridStyleTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/30/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3GridStyleTableViewCellDataSource, A3GridStyleTableViewCellDelegate;

@interface A3GridStyleTableViewCell : UITableViewCell

@property (nonatomic, weak)	IBOutlet id <A3GridStyleTableViewCellDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <A3GridStyleTableViewCellDelegate> delegate;
@property (nonatomic)		NSInteger tag;

- (CGFloat)heightForContents;

- (void)reload;


@end

@protocol A3GridStyleTableViewCellDataSource <NSObject>
@required
- (NSInteger)numberOfItemsInGridViewController:(A3GridStyleTableViewCell *)controller;
- (NSUInteger)numberOfColumnsInGridViewController:(A3GridStyleTableViewCell *)controller;
- (UIImage *)gridStyleTableViewCell:(A3GridStyleTableViewCell *)controller imageForIndex:(NSInteger)index;
- (NSString *)gridStyleTableViewCell:(A3GridStyleTableViewCell *)controller titleForIndex:(NSInteger)index;

@end

@protocol A3GridStyleTableViewCellDelegate <NSObject>
@required
- (void)gridStyleTableViewCell:(A3GridStyleTableViewCell *)controller didSelectItemAtIndex:(NSInteger)selectedIndex;

@end
