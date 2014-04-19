//
//  A3WalletVideoItemViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "A3WalletVideoItemViewController.h"
#import "A3WalletItemEditViewController.h"
#import "A3WalletVideoItemTitleView.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletNoteCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletItem+Favorite.h"
#import "WalletField.h"
#import "NSDate+TimeAgo.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "WalletFieldItem.h"
#import "UIImage+Extension2.h"
#import "WalletFieldItem+initialize.h"

@interface A3WalletVideoItemViewController () <WalletItemEditDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *videoFieldItems;
@property (nonatomic, strong) NSMutableArray *normalFieldItems;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) A3WalletVideoItemTitleView *headerView;
@property (nonatomic, strong) NSMutableArray *photoThumbs;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIView *thumbListContainView;

@property (nonatomic, strong) NSMutableDictionary *noteItem;

@end

@implementation A3WalletVideoItemViewController

NSString *const A3WalletItemFieldCellID2 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID2 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemFieldNoteCellID2 = @"A3WalletNoteCell";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initializeViews];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTopInfo];
    [self updateVideoInfo];
}

- (void)initializeViews
{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
    self.navigationItem.rightBarButtonItem = editItem;
    
    [self.view addSubview:self.photoScrollView];
    
    float scrollHeight = (IS_IPAD) ? 506:300;
    
    float tbvHeight = self.view.bounds.size.height - (64+4+scrollHeight+44+1);
    if (self.photoThumbs.count < 2) {
        tbvHeight += 44;
    }
    
	_tableView.frame = CGRectMake(0, 64+4+scrollHeight, self.view.bounds.size.width, tbvHeight);
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = self.headerView;
    _tableView.contentOffset = CGPointZero;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.view insertSubview:self.toolBar belowSubview:_tableView];
    _toolBar.layer.anchorPoint = CGPointMake(0.5, 1);
    _toolBar.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height);
    
    float offsetX = (self.photoThumbs.count*(24+4))/2;
    for (int i=0; i<self.photoThumbs.count; i++) {
        UIImageView *thumbImgView = _photoThumbs[i];
        [self.thumbListContainView addSubview:thumbImgView];
        float centerX = 2+12+(24+4)*i;
        thumbImgView.center = CGPointMake(_thumbListContainView.bounds.size.width/2 + centerX - offsetX, _thumbListContainView.bounds.size.height/2);
    }
    [self makeThumbSelected:0];
}

- (NSMutableArray *)videoFieldItems
{
    if (!_videoFieldItems) {
        _videoFieldItems = [[NSMutableArray alloc] init];
        
        NSArray *fieldItems = [_item fieldItemsArray];
        for (int i=0; i<fieldItems.count; i++) {
            WalletFieldItem *fieldItem = fieldItems[i];
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo] && fieldItem.hasVideo) {
                [_videoFieldItems addObject:fieldItem];
            }
        }
    }
    
    return _videoFieldItems;
}

- (NSMutableArray *)normalFieldItems
{
    if (!_normalFieldItems) {
        _normalFieldItems = [[NSMutableArray alloc] init];
        
        NSArray *fieldItems = [_item fieldItemsArray];
        for (int i=0; i<fieldItems.count; i++) {
            WalletFieldItem *fieldItem = fieldItems[i];
            if (![fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                [_normalFieldItems addObject:fieldItem];
            }
        }
        
        // 데이타 없는 item은 표시하지 않는다.
        NSMutableArray *deletingObjects = [NSMutableArray new];
        for (WalletFieldItem *fieldItem in _normalFieldItems) {
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                if (fieldItem.date == nil) {
                    [deletingObjects addObject:fieldItem];
                }
            }
            else if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
				if (!fieldItem.image) {
					[deletingObjects addObject:fieldItem];
				}
            }
			else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
				if (![fieldItem.hasVideo boolValue]) {
					[deletingObjects addObject:fieldItem];
				}
			}
            else {
                if (![fieldItem.value length]) {
                    [deletingObjects addObject:fieldItem];
                }
            }
        }
		[_normalFieldItems removeObjectsInArray:deletingObjects];
        
        [_normalFieldItems addObject:self.noteItem];
    }
    
    return _normalFieldItems;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Note", @"order":@""}];
    }
    
    return _noteItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UIBarButtonItem *empty = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        empty.width = 40;
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *thumbItem = [[UIBarButtonItem alloc] initWithCustomView:self.thumbListContainView];
        
        _toolBar.items = @[empty, flex, thumbItem, flex];
    }
    
    return _toolBar;
}

- (UIView *)thumbListContainView
{
    if (!_thumbListContainView) {
        _thumbListContainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, IS_IPAD ? 400:200, 44)];
        _thumbListContainView.backgroundColor = [UIColor clearColor];
    }
    
    return _thumbListContainView;
}

- (A3WalletVideoItemTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletVideoItemTitleView_iPad":@"A3WalletVideoItemTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        CGRect frame = _headerView.frame;
        frame.size.height = 115;
        _headerView.frame = frame;
        
        [_headerView.favorButton addTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _headerView.titleTextField.delegate = self;
    }
    
    return _headerView;
}

- (void)refreshViews
{
    _videoFieldItems = nil;
    _normalFieldItems = nil;
    
    [self.photoScrollView removeFromSuperview];
    [self.toolBar removeFromSuperview];
    
    _photoScrollView = nil;
    _toolBar = nil;
    _photoThumbs = nil;
    _thumbListContainView = nil;
    
    [self initializeViews];
    [self updateTopInfo];
    
    [self.tableView reloadData];
    [self updateVideoInfo];
}

- (void)updateTopInfo
{
    _headerView.titleTextField.text = _item.name;
    CGSize textSize = [_item.name sizeWithAttributes:@{NSFontAttributeName:_headerView.titleTextField.font}];
    CGRect frame = _headerView.titleTextField.frame;
    frame.size.width = MIN(self.view.bounds.size.width- 30, textSize.width + 50);
    _headerView.titleTextField.frame = frame;
    
    _headerView.favorButton.selected = _item.favorite != nil;
    _headerView.timeLabel.text = [NSString stringWithFormat:@"Updated %@",  [_item.modificationDate timeAgo]];
}

- (void)updateVideoInfo {
    
    NSUInteger index = _photoScrollView.contentOffset.x/_photoScrollView.bounds.size.width;
    
    if (self.videoFieldItems.count <= index) {
        return;
    }
    
    WalletFieldItem *fieldItem = _videoFieldItems[index];
    
    float duration = [WalletData getDurationOfMovie:[fieldItem videoFilePath]];
    NSInteger dur = round(duration);
    _headerView.durationLB.text = [NSString stringWithFormat:@"Duration Time %lds", (long)dur];
    
    NSDate *createDate = [WalletData getCreateDateOfMovie:[fieldItem videoFilePath]];
    if (createDate) {
        _headerView.dateLB.text = [createDate timeAgo];
    }
    else {
        _headerView.dateLB.text = @"";
    }
}

- (UIScrollView *)photoScrollView
{
    float rectWidth = (IS_IPAD) ? 576:320;
    float rectHeight = (IS_IPAD) ? 506:300;
    
    if (!_photoScrollView) {
        CGRect photoFrame = CGRectMake((self.view.bounds.size.width-rectWidth)/2, 64+4, rectWidth, rectHeight);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:photoFrame];
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.bounces = NO;
        _photoScrollView.delegate = self;
        
        for (int i=0; i<self.videoFieldItems.count; i++) {
            WalletFieldItem *videoFieldItem = _videoFieldItems[i];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rectWidth*i, 0, rectWidth, rectHeight)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;
            UIImage *photoImg = [UIImage imageWithContentsOfFile:[videoFieldItem videoThumbnailPath]];
            photoImg = [photoImg imageByScalingProportionallyToMinimumSize:CGSizeMake(rectWidth*2, rectWidth*2)];
            photoImgView.image = photoImg;
            
            // photo cover
            UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectWidth, rectHeight)];
            coverView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.05];
            [photoImgView addSubview:coverView];
            
            UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            playBtn.frame = CGRectMake(0, 0, 70, 70);
            playBtn.tag = i;
            [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [photoImgView addSubview:playBtn];
            playBtn.center = CGPointMake(rectWidth/2.0, rectHeight/2.0);
            
            [_photoScrollView addSubview:photoImgView];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
        tap.numberOfTapsRequired = 1;
        [_photoScrollView addGestureRecognizer:tap];
        
        _photoScrollView.contentSize = CGSizeMake(rectWidth* _videoFieldItems.count, 0);
    }
    
    return _photoScrollView;
}

- (NSMutableArray *)photoThumbs
{
    if (!_photoThumbs) {
        _photoThumbs = [[NSMutableArray alloc] init];
        for (int i=0; i<self.videoFieldItems.count; i++) {
            WalletFieldItem *photoFieldItem = _videoFieldItems[i];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 ,24, 16)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;
            NSString *thumbFilePath = [photoFieldItem videoThumbnailPath];
            UIImage *photoImg = [UIImage imageWithContentsOfFile:thumbFilePath];
            photoImgView.image = photoImg;
            [_photoThumbs addObject:photoImgView];
        }
    }
    
    return _photoThumbs;
}

- (void)favorButtonAction:(UIButton *)favorButton
{
	[_item changeFavorite:_item.favorite == nil];
    _headerView.favorButton.selected = _item.favorite != nil;
}

-(void)videoFinished:(NSNotification*)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

- (void)editButtonAction:(id)sender
{
    NSString *nibName = (IS_IPHONE) ? @"WalletPhoneStoryBoard" : @"WalletPadStoryBoard";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:nibName bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
    viewController.delegate = self;
    viewController.item = self.item;
    viewController.hidesBottomBarWhenPushed = YES;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)makeThumbSelected:(NSUInteger) selectedIndex
{
    if (_photoThumbs.count<=selectedIndex) {
        return;
    }
    
    for (UIImageView *imgView in _photoThumbs) {
        CGPoint center = imgView.center;
        imgView.frame = CGRectMake(0, 0, 24, 16);
        imgView.center = center;
    }
    
    UIImageView *selectThumbImgView = _photoThumbs[selectedIndex];
    CGPoint center = selectThumbImgView.center;
    selectThumbImgView.frame = CGRectMake(0, 0, 36, 24);
    selectThumbImgView.center = center;
    [self.thumbListContainView bringSubviewToFront:selectThumbImgView];
}

- (void)photoTapped:(UITapGestureRecognizer *)tap
{
    NSUInteger index = _photoScrollView.contentOffset.x/_photoScrollView.bounds.size.width;
    WalletFieldItem *fieldItem = _videoFieldItems[index];
    
    if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
        if ([[fieldItem hasVideo] boolValue]) {
			NSString *filePath = [fieldItem videoFilePath];
			MPMoviePlayerViewController *pvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];

            // 재생후에 자동으로 닫히는 것 방지하고, 사용자가 닫을수있도록 함.
            [[NSNotificationCenter defaultCenter] removeObserver:pvc  name:MPMoviePlayerPlaybackDidFinishNotification object:pvc.moviePlayer];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:pvc.moviePlayer];
            
            NSError *_error = nil;
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
            
            [self presentViewController:pvc animated:YES completion:^{
                [pvc.moviePlayer play];
            }];
        }
    }
}

- (void)configureFloatingTextField:(JVFloatLabeledTextField *)txtFd
{
    txtFd.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    txtFd.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    txtFd.font = [UIFont systemFontOfSize:17.0];
    txtFd.floatingLabelFont = [UIFont systemFontOfSize:14];
    txtFd.floatingLabelYPadding = @(0);
    txtFd.delegate = self;
}

#pragma mark - walletItemEditDelegate

-(void)walletItemEdited:(WalletItem *)item
{
    [self refreshViews];
}

- (void)WalletItemDeleted
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - textField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.editing;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.photoScrollView) {
        NSUInteger page = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
        
        [self makeThumbSelected:page];
        [self updateVideoInfo];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.photoScrollView) {
        if (!decelerate) {
            NSUInteger page = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
            [self makeThumbSelected:page];
            [self updateVideoInfo];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.normalFieldItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (_normalFieldItems[indexPath.row] == self.noteItem) {
        
        // note
        A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID2 forIndexPath:indexPath];
        
        noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        noteCell.textView.editable = NO;
        noteCell.textView.bounces = NO;
        noteCell.textView.placeholder = @"Notes";
        noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        noteCell.textView.font = [UIFont systemFontOfSize:17];
        
        noteCell.textView.text = _item.note;
        
        cell = noteCell;
    }
    else if ([_normalFieldItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _normalFieldItems[indexPath.row];
        
        if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] || [fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
            
            A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID2 forIndexPath:indexPath];
            
            photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:photoCell.valueTxtFd];
            
            photoCell.valueTxtFd.placeholder = fieldItem.field.name;

			if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
				photoCell.valueTxtFd.text = @" ";
				photoCell.photoButton.hidden = NO;

				[self setImageToCell:photoCell imagePath:fieldItem.imageThumbnailPath];
				photoCell.photoButton.tag = indexPath.row;
			} else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
				photoCell.valueTxtFd.text = @" ";
				photoCell.photoButton.hidden = NO;

				[self setImageToCell:photoCell imagePath:fieldItem.videoThumbnailPath];
				photoCell.photoButton.tag = indexPath.row;
			} else {
				photoCell.valueTxtFd.text = @"None";
				photoCell.photoButton.hidden = YES;
			}

            cell = photoCell;
        }
        else if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
            
            A3WalletItemFieldCell *dateCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID2 forIndexPath:indexPath];
            
            dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:dateCell.valueTextField];
            
            dateCell.valueTextField.placeholder = fieldItem.field.name;
            if (fieldItem.date) {
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateStyle:NSDateFormatterMediumStyle];
                dateCell.valueTextField.text = [df stringFromDate:fieldItem.date];
            }
            else {
                dateCell.valueTextField.text = @"";
            }
            
            cell = dateCell;
        }
        else {
            
            A3WalletItemFieldCell *textCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID2 forIndexPath:indexPath];
            
            textCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:textCell.valueTextField];
            
            textCell.valueTextField.placeholder = fieldItem.field.name;
            textCell.valueTextField.text = fieldItem.value;
            
            if (fieldItem.value) {
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
                NSUInteger numberOfMatch = [detector numberOfMatchesInString:fieldItem.value options:0 range:NSMakeRange(0, fieldItem.value.length)];
                if (numberOfMatch > 0) {
                    textCell.valueTextField.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
                }
            }
            
            cell = textCell;
        }
    }
    
    return cell;
}

- (void)setImageToCell:(A3WalletItemPhotoFieldCell *)photoCell imagePath:(NSString *)path {
	NSData *img = [NSData dataWithContentsOfFile:path];
	UIImage *photo = [UIImage imageWithData:img];
	photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
	[photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
	[photoCell.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)photoButtonAction:(UIButton *)photoButtonAction {
	// TODO:
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.noteItem) {
		if (!_item.note) return 74.0;
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                         };
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
        UITextView *txtView = [[UITextView alloc] init];
        [txtView setAttributedText:attributedString];
        float margin = IS_IPAD ? 49:31;
        CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
        float cellHeight = txtViewSize.height + 20;
        
        float defaultCellHeight = 74.0;
        
        if (cellHeight < defaultCellHeight) {
            return defaultCellHeight;
        }
        else {
            return cellHeight;
        }
    }
    
    return 74.0;
}

/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 return self.topHeaderView;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
 {
 return 96;
 }
 */

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
