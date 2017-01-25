//
//  A3AbbreviationCollectionViewCell.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/12/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3AbbreviationCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIView *roundedRectView;
@property (nonatomic, weak) IBOutlet UILabel *groupTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row1TitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row1SubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row2TitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row2SubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row3TitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *row3SubtitleLabel;
@property (nonatomic, weak) IBOutlet UIView *firstLineView;
@property (nonatomic, weak) IBOutlet UIView *secondLineView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray<UIView *> *rows;

+ (NSString *)reuseIdentifier;

@end
