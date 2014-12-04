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
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletNoteCell.h"
#import "NSDate+formatting.h"
#import "WalletData.h"
#import "WalletCategory.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletItem+Favorite.h"
#import "UIViewController+NumberKeyboard.h"
#import "WalletFieldItem.h"
#import "UIImage+Extension2.h"
#import "WalletFieldItem+initialize.h"
#import "A3WalletPhotoItemTitleView.h"
#import "NSDateFormatter+A3Addition.h"
#import "WalletFavorite.h"
#import "WalletFavorite+initialize.h"
#import "WalletField.h"

@interface A3WalletVideoItemViewController () <WalletItemEditDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *videoFieldItems;
@property (nonatomic, strong) NSMutableArray *normalFieldItems;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) A3WalletPhotoItemTitleView *metadataView;
@property (nonatomic, strong) NSMutableArray *photoThumbs;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIView *thumbListContainView;

@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) NSMutableDictionary *photoItem;
@property (nonatomic, strong) NSMutableDictionary *metadataItem;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerViewController;

@end

@implementation A3WalletVideoItemViewController {
	BOOL _itemDeleted;
}

extern NSString *const A3TableViewCellDefaultCellID;
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
	self.title = NSLocalizedString(@"Details", @"Detail");

    [self initializeViews];
    
    [self registerContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidEnterBackground {
	if (_moviePlayerViewController) {
		[self dismissMoviePlayerViewControllerAnimated];
		_moviePlayerViewController = nil;
	}
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	if (_moviePlayerViewController) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerViewController.moviePlayer];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
	[self.metadataView setupFonts];
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (_itemDeleted) return;

	if (![self isMovingToParentViewController]) {
		[self refreshViews];
	}
	[self updateMetadataViewWithPage:0];
}

- (void)initializeViews
{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
    self.navigationItem.rightBarButtonItem = editItem;
    
    CGFloat tbvHeight = self.view.bounds.size.height - 44 - 64;
    if (self.photoThumbs.count < 2) {
        tbvHeight += 44;
    }
    
	_tableView.frame = CGRectMake(0, 64, self.view.bounds.size.width, tbvHeight);
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	if (![_item.note length]) {
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38)];
		_tableView.tableFooterView = footerView;
	} else {
		_tableView.tableFooterView = nil;
	}

	if ([self.videoFieldItems count] > 1) {
		[self.view insertSubview:self.toolBar belowSubview:_tableView];
		_toolBar.layer.anchorPoint = CGPointMake(0.5, 1);
		_toolBar.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height);

		CGFloat offsetX = (self.photoThumbs.count*(14 + 1))/2;
		for (NSUInteger idx = 0; idx < self.photoThumbs.count; idx++) {
			UIImageView *thumbImgView = _photoThumbs[idx];
			[self.thumbListContainView addSubview:thumbImgView];
			float centerX = 7 + (14 + 1)* idx;
			thumbImgView.center = CGPointMake(_thumbListContainView.bounds.size.width/2 + centerX - offsetX, _thumbListContainView.bounds.size.height/2);
		}
		[self makeThumbSelected:0];
	}
}

- (WalletCategory *)category {
	if (!_category) {
		_category = [WalletData categoryItemWithID:_item.categoryID inContext:nil];
	}
	return _category;
}

- (NSMutableArray *)videoFieldItems
{
	if (_itemDeleted) return nil;
    if (!_videoFieldItems) {
        _videoFieldItems = [[NSMutableArray alloc] init];
        
        NSArray *fieldItems = [_item fieldItemsArraySortedByFieldOrder];
        for (int i=0; i<fieldItems.count; i++) {
            WalletFieldItem *fieldItem = fieldItems[i];
			WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
            if ([field.type isEqualToString:WalletFieldTypeVideo]) {
                [_videoFieldItems addObject:fieldItem];
            }
        }
    }
    
    return _videoFieldItems;
}

- (NSMutableArray *)normalFieldItems
{
	if (_itemDeleted) return nil;
    if (!_normalFieldItems) {
		_normalFieldItems = [[NSMutableArray alloc] init];

		[_normalFieldItems addObject:self.photoItem];
		[_normalFieldItems addObject:self.metadataItem];

		NSArray *fieldItems = [_item fieldItemsArraySortedByFieldOrder];
		for (NSUInteger idx = 0; idx < fieldItems.count; idx++) {
			WalletFieldItem *fieldItem = fieldItems[idx];
			WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
			if ([field.type isEqualToString:WalletFieldTypeDate] && !fieldItem.date) {
				continue;
			}
			if ([field.type isEqualToString:WalletFieldTypeVideo] || ![fieldItem.value length]) {
				continue;
			}
			[_normalFieldItems addObject:fieldItem];
		}

		if ([_item.note length]) {
			[_normalFieldItems addObject:self.noteItem];
		}
    }
    
    return _normalFieldItems;
}

- (NSMutableDictionary *)photoItem {
	if (!_photoItem) {
		_photoItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Photo", @"Photo"), @"order" : @""}];
	}
	return _photoItem;
}

- (NSMutableDictionary *)metadataItem {
	if (!_metadataItem) {
		_metadataItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"metadata", @"order" : @""}];
	}
	return _metadataItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Note", @"Note"), @"order" : @""}];
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

- (A3WalletPhotoItemTitleView *)metadataView
{
    if (!_metadataView) {
        NSString *nibName = IS_IPAD ? @"A3WalletPhotoItemTitleView_iPad":@"A3WalletPhotoItemTitleView";
        _metadataView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        CGRect frame = _metadataView.frame;
        frame.size.height = 115;
        _metadataView.frame = frame;
        
        [_metadataView.favoriteButton addTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _metadataView.titleTextField.delegate = self;
    }
    
    return _metadataView;
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
	[self updateMetadataViewWithPage:0];
	[self.tableView reloadData];
}

- (void)updateMetadataViewWithPage:(NSInteger)page {
	self.metadataView.titleTextField.text = [_item.name length] ? _item.name : NSLocalizedString(@"New Item", @"New Item");
	CGSize textSize = [_metadataView.titleTextField.text sizeWithAttributes:@{NSFontAttributeName: _metadataView.titleTextField.font}];
	CGRect frame = _metadataView.titleTextField.frame;
	frame.size.width = MIN(self.view.bounds.size.width- 30, textSize.width + 50);
	_metadataView.titleTextField.frame = frame;

	_metadataView.favoriteButton.selected = [WalletFavorite isFavoriteForItemID:_item.uniqueID];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    if (IS_IPAD || [NSDate isFullStyleLocale]) {
        dateFormatter.dateStyle = NSDateFormatterFullStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    }
    else {
        dateFormatter.dateFormat = [dateFormatter customFullWithTimeStyleFormat];
    }
	_metadataView.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [dateFormatter stringFromDate:_item.updateDate]];

    if (self.videoFieldItems.count <= page) {
        return;
    }
    
    WalletFieldItem *fieldItem = _videoFieldItems[page];

	if (fieldItem) {
		CGFloat duration = [WalletData getDurationOfMovie:[fieldItem videoFileURLInOriginal:YES ]];
		NSInteger dur = round(duration);
		_metadataView.mediaSizeLabel.text = [NSString stringWithFormat:@"%@ %lds", NSLocalizedString(@"Duration Time", @"Duration Time"), (long) dur];

        // Media CreationDate
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (IS_IPAD || [NSDate isFullStyleLocale]) {
            dateFormatter.dateStyle = NSDateFormatterFullStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
        }
        else {
            dateFormatter.dateFormat = [dateFormatter customFullWithTimeStyleFormat];
        }
		NSDate *createDate = [WalletData getCreateDateOfMovie:[fieldItem videoFileURLInOriginal:YES ]];
		if (createDate) {
			_metadataView.takenDateLabel.text = [dateFormatter stringFromDate:createDate];
		}
		else {
            _metadataView.takenDateLabel.text = [dateFormatter stringFromDate:fieldItem.videoCreationDate];
		}
	} else {
		_metadataView.mediaSizeLabel.text = @"";
		_metadataView.takenDateLabel.text = @"";
	}
	[_metadataView layoutIfNeeded];
}

- (UIScrollView *)photoScrollView
{
    CGFloat rectWidth = IS_IPAD ? 576 : 320;
    CGFloat rectHeight = IS_IPAD ? 506 : 300;
    
    if (!_photoScrollView) {
        CGRect photoFrame = CGRectMake((self.view.bounds.size.width-rectWidth)/2, 4, rectWidth, rectHeight);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:photoFrame];
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.bounces = NO;
        _photoScrollView.delegate = self;
        
        for (NSUInteger idx = 0; idx < self.videoFieldItems.count; idx++) {
            WalletFieldItem *videoFieldItem = _videoFieldItems[idx];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rectWidth* idx, 0, rectWidth, rectHeight)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;
            UIImage *photoImg = [UIImage imageWithContentsOfFile:[videoFieldItem videoThumbnailPathInOriginal:YES ]];
            photoImg = [photoImg imageByScalingProportionallyToMinimumSize:CGSizeMake(rectWidth*2, rectWidth*2)];
            photoImgView.image = photoImg;
            
            // photo cover
            UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectWidth, rectHeight)];
            coverView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.05];
            [photoImgView addSubview:coverView];
            
            UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            playBtn.frame = CGRectMake(0, 0, 70, 70);
            playBtn.tag = idx;
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
		for (NSUInteger idx = 0; idx < self.videoFieldItems.count; idx++) {
			WalletFieldItem *photoFieldItem = _videoFieldItems[idx];
			UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 ,34, 25)];
			photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
			photoImageView.layer.borderWidth = 1.0;
			photoImageView.layer.masksToBounds = YES;
			photoImageView.contentMode = UIViewContentModeScaleAspectFill;
			photoImageView.tag = idx;
			UIImage *photoImg = [UIImage imageWithContentsOfFile:[photoFieldItem videoThumbnailPathInOriginal:YES]];
			photoImageView.image = photoImg;
			photoImageView.userInteractionEnabled = YES;

			UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbImageTapped:)];
			[photoImageView addGestureRecognizer:tapGestureRecognizer];
			[_photoThumbs addObject:photoImageView];
		}
	}

	return _photoThumbs;
}

- (void)thumbImageTapped:(UITapGestureRecognizer *)gestureRecognizer {
	NSInteger page = (NSInteger) floorf(_photoScrollView.contentOffset.x / _photoScrollView.frame.size.width);
	if (page == gestureRecognizer.view.tag) return;

	page = gestureRecognizer.view.tag;
	CGFloat x = page * _photoScrollView.bounds.size.width;
	[self.photoScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
	[self makeThumbSelected:page];
	[self updateMetadataViewWithPage:page];
}

- (void)favorButtonAction:(UIButton *)favorButton
{
	BOOL isFavorite = ![WalletFavorite isFavoriteForItemID:_item.uniqueID];
	[_item changeFavorite:isFavorite];
    _metadataView.favoriteButton.selected = isFavorite;
}

- (void)videoFinished:(NSNotification*)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerViewController.moviePlayer];
        [self dismissMoviePlayerViewControllerAnimated];
        _moviePlayerViewController = nil;
    }
}

- (void)editButtonAction:(id)sender
{
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
    viewController.delegate = self;
    viewController.item = [self.item MR_inContext:[NSManagedObjectContext MR_defaultContext]];
    viewController.hidesBottomBarWhenPushed = YES;
	viewController.alwaysReturnToOriginalCategory = self.alwaysReturnToOriginalCategory;
    
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
        imgView.frame = CGRectMake(0, 0, 14, 11);
        imgView.center = center;
    }
    
    UIImageView *selectThumbImgView = _photoThumbs[selectedIndex];
    CGPoint center = selectThumbImgView.center;
    selectThumbImgView.frame = CGRectMake(0, 0, 36, 25);
    selectThumbImgView.center = center;
    [self.thumbListContainView bringSubviewToFront:selectThumbImgView];
}

- (void)photoTapped:(UITapGestureRecognizer *)tap
{
    NSUInteger index = _photoScrollView.contentOffset.x/_photoScrollView.bounds.size.width;
    WalletFieldItem *fieldItem = _videoFieldItems[index];
    WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
    if ([field.type isEqualToString:WalletFieldTypeVideo]) {
        if (fieldItem) {
			NSURL *fileURL = [fieldItem videoFileURLInOriginal:YES ];
			_moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];

			// 재생후에 자동으로 닫히는 것 방지하고, 사용자가 닫을수있도록 함.
			[[NSNotificationCenter defaultCenter] removeObserver:_moviePlayerViewController name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerViewController.moviePlayer];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerViewController.moviePlayer];
            
            NSError *_error = nil;
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];

			[self presentViewController:_moviePlayerViewController animated:YES completion:^{
				[_moviePlayerViewController.moviePlayer play];
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
	_itemDeleted = YES;
    [self.navigationController popViewControllerAnimated:NO];
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
        NSInteger page = (NSInteger) floor(scrollView.contentOffset.x / scrollView.frame.size.width);
        
        [self makeThumbSelected:page];
		[self updateMetadataViewWithPage:page];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.photoScrollView) {
        if (!decelerate) {
            NSInteger page = (NSInteger) floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
            [self makeThumbSelected:page];
			[self updateMetadataViewWithPage:page];
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

	if (_normalFieldItems[indexPath.row] == self.photoItem) {
		UITableViewCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
		[photoCell addSubview:self.photoScrollView];

		[_photoScrollView makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(photoCell.centerX);
			make.top.equalTo(photoCell.top).with.offset(4);
			make.width.equalTo(IS_IPAD ? @576 : @320);
			make.height.equalTo(IS_IPAD ? @506 : @300);
		}];

		[photoCell layoutIfNeeded];
		cell = photoCell;

		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else if (_normalFieldItems[indexPath.row] == self.metadataItem) {
		UITableViewCell *metadataCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
		[metadataCell addSubview:self.metadataView];

		cell = metadataCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    else if (_normalFieldItems[indexPath.row] == self.noteItem) {
        // note
        A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID2 forIndexPath:indexPath];
        [noteCell setupTextView];
        noteCell.textView.editable = NO;

		[noteCell setNoteText:_item.note];
		[noteCell showTopSeparator:YES];

        cell = noteCell;
    }
    else if ([_normalFieldItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _normalFieldItems[indexPath.row];
		WalletField *field = [WalletData fieldOfFieldItem:fieldItem];;
        if ([field.type isEqualToString:WalletFieldTypeImage] || [field.type isEqualToString:WalletFieldTypeVideo]) {
            
            A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID2 forIndexPath:indexPath];
            
            photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
			[self configureFloatingTextField:photoCell.valueTextField];
            
            photoCell.valueTextField.placeholder = field.name;

			if ([field.type isEqualToString:WalletFieldTypeImage]) {
				photoCell.valueTextField.text = @" ";
				photoCell.photoButton.hidden = NO;

				[self setImageToCell:photoCell image:[fieldItem thumbnailImage]];
				photoCell.photoButton.tag = indexPath.row;
			} else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
				photoCell.valueTextField.text = @" ";
				photoCell.photoButton.hidden = NO;

				[self setImageToCell:photoCell image:[fieldItem thumbnailImage]];
				photoCell.photoButton.tag = indexPath.row;
			} else {
				photoCell.valueTextField.text = NSLocalizedString(@"None", @"None");
				photoCell.photoButton.hidden = YES;
			}

            cell = photoCell;
        }
        else if ([field.type isEqualToString:WalletFieldTypeDate]) {
            
            A3WalletItemFieldCell *dateCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID2 forIndexPath:indexPath];
            
            dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:dateCell.valueTextField];
            
            dateCell.valueTextField.placeholder = field.name;
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
            
            textCell.valueTextField.placeholder = field.name;
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

- (void)setImageToCell:(A3WalletItemPhotoFieldCell *)photoCell image:(UIImage *)photo {
	photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
	[photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
	[photoCell.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)photoButtonAction:(UIButton *)photoButtonAction {
	// TODO:
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.photoItem) {
		return IS_IPAD ? 510 : 304;
	} else
	if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.metadataItem) {
		return [self.metadataView calculatedHeight];
	}
    if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.noteItem) {
		if (!_item.note) return 74.0;
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                         };
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
        UITextView *txtView = [[UITextView alloc] init];
        [txtView setAttributedText:attributedString];
		CGFloat margin = IS_IPAD ? 28 + 15 : 15 + 15;
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

@end
