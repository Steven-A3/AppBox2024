//
//  A3WalletPhotoItemTitleView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 8..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemTitleView.h"

@interface A3WalletPhotoItemTitleView : UIView

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *mediaSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *takenDateLabel;

@property (strong, nonatomic) UIButton *favoriteButton;
/**
 *  A3WalletVideoItemViewController에서 사용 Video 저장이 가능한 경우 추가하여 Video를 Photos Album에 추가할 수 있도록 함
 *  버튼을 추가하기 전에 UIVideoAtPathIsCompatibleWithSavedPhotosAlbum 으로 저장 가능한지 확인해야 한다.
 */
@property (strong, nonatomic) UIButton *saveButton;

- (void)setupFonts;
- (CGFloat)calculatedHeight;
/**
 *  A3WalletVideoItemViewController에서 사용한다.
 *  Video를 PhotosAlbum에 저장할 수 있을 때 이 버튼을 추가해야 한다.
 */
- (void)addSaveButton;

@end
