//
//  A3WalletPhotoItemViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import "A3WalletPhotoItemViewController.h"
#import "A3WalletItemEditViewController.h"
#import "A3WalletPhotoItemTitleView.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletMapCell.h"
#import "A3WalletNoteCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletItem+initialize.h"
#import "WalletItem+Favorite.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "NSDate+TimeAgo.h"
#import "UIViewController+NumberKeyboard.h"
#import "MWPhotoBrowser.h"
#import "UIImage+Extension2.h"
#import "WalletFieldItem+initialize.h"
#import "WalletFieldItemImage.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSDateFormatter+A3Addition.h"
#import "NSDate+Formatting.h"

@interface A3WalletPhotoItemViewController () <WalletItemEditDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *photoFieldItems;
@property (nonatomic, strong) NSMutableArray *normalFieldItems;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) A3WalletPhotoItemTitleView *metadataView;
@property (nonatomic, strong) NSMutableArray *photoThumbs;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIView *thumbListContainView;
@property (nonatomic, strong) NSMutableArray *alBumPhotos;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) MWPhotoBrowser *innerPhotoBrowser;
@property (nonatomic, strong) NSMutableDictionary *mapItem;
@property (nonatomic, strong) NSMutableDictionary *photoItem;
@property (nonatomic, strong) NSMutableDictionary *metadataItem;
@property (nonatomic, strong) NSDictionary *gpsMetaInfo;

@end

NSString *const A3TableViewCellDefaultCellID = @"defaultCellID";
NSString *const A3WalletItemFieldCellID1 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID1 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemMapCellID1 = @"A3WalletMapCell";
NSString *const A3WalletItemFieldNoteCellID1 = @"A3WalletNoteCell";

@implementation A3WalletPhotoItemViewController

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

	self.title = NSLocalizedString(@"Detail", @"Detail");
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initializeViews];
    
    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
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

	if (![self isMovingToParentViewController]) {
		[self refreshViews];
	}
	[self updateMetadataViewWithPage:0];
}

- (void)initializeViews
{
	FNLOG();
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
    self.navigationItem.rightBarButtonItem = editItem;
    
	CGFloat tbvHeight = self.view.bounds.size.height - 44;
    if (self.photoThumbs.count < 2) {
        tbvHeight += 44;
    }
    
	_tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, tbvHeight);
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	if (![_item.note length]) {
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38)];
		_tableView.tableFooterView = footerView;
	} else {
		_tableView.tableFooterView = nil;
	}

	if ([self.photoFieldItems count] > 1) {
		[self.view insertSubview:self.toolBar belowSubview:_tableView];
		_toolBar.layer.anchorPoint = CGPointMake(0.5, 1);
		_toolBar.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height);

		CGFloat offsetX = (self.photoThumbs.count*(14 + 1))/2;
		for (NSUInteger idx = 0; idx < self.photoThumbs.count; idx++) {
			UIImageView *thumbImgView = _photoThumbs[idx];
			[self.thumbListContainView addSubview:thumbImgView];
			CGFloat centerX = 7 + (14 + 1)* idx;
			thumbImgView.center = CGPointMake(_thumbListContainView.bounds.size.width/2 + centerX - offsetX, _thumbListContainView.bounds.size.height/2);
		}
		[self makeThumbSelected:0];
	}
}

- (NSMutableArray *)photoFieldItems
{
    if (!_photoFieldItems) {
        _photoFieldItems = [[NSMutableArray alloc] init];
        
        NSArray *fieldItems = [_item fieldItemsArray];
        for (int i=0; i<fieldItems.count; i++) {
            WalletFieldItem *fieldItem = fieldItems[i];
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] && fieldItem.image) {
                [_photoFieldItems addObject:fieldItem];
            }
        }
    }
    
    return _photoFieldItems;
}

- (NSMutableArray *)normalFieldItems
{
    if (!_normalFieldItems) {
        _normalFieldItems = [[NSMutableArray alloc] init];

		[_normalFieldItems addObject:self.photoItem];
		[_normalFieldItems addObject:self.metadataItem];

		[self updateMetadataViewWithPage:self.currentPageAtPhotoScrollView];

		if (self.gpsMetaInfo) {
			[_normalFieldItems addObject:self.mapItem];
		}

        NSArray *fieldItems = [_item fieldItemsArray];
        for (NSUInteger idx = 0; idx < fieldItems.count; idx++) {
            WalletFieldItem *fieldItem = fieldItems[idx];
			if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate] && !fieldItem.date) {
				continue;
			}
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] || ![fieldItem.value length]) {
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
		_photoItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Photo", @"Photo"), @"order":@""}];
	}
	return _photoItem;
}

- (NSMutableDictionary *)metadataItem {
	if (!_metadataItem) {
		_metadataItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"metadata", @"order":@""}];
	}
	return _metadataItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Note", @"Note"), @"order":@""}];
    }
    
    return _noteItem;
}

- (NSMutableDictionary *)mapItem
{
    if (!_mapItem) {
        _mapItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Map", @"Map"), @"order":@""}];
    }
    
    return _mapItem;
}

- (NSMutableArray *)alBumPhotos
{
    if (!_alBumPhotos) {
        _alBumPhotos = [[NSMutableArray alloc] init];
        
        for (NSUInteger idx = 0; idx < self.photoFieldItems.count; idx++) {
            WalletFieldItem *fieldItem = _photoFieldItems[idx];
            MWPhoto *photo = [MWPhoto photoWithImage:[fieldItem photoImageInOriginalDirectory:YES]];
			[_alBumPhotos addObject:photo];
        }
    }
    
    return _alBumPhotos;
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
        NSString *nibName = IS_IPAD ? @"A3WalletPhotoItemTitleView_iPad" : @"A3WalletPhotoItemTitleView";
        _metadataView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
		[_metadataView.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		_metadataView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 148);
        _metadataView.titleTextField.delegate = self;
		_metadataView.backgroundColor = [UIColor clearColor];
    }
    
    return _metadataView;
}

- (void)refreshViews
{
	FNLOG();
    _photoFieldItems = nil;
    _normalFieldItems = nil;
    
    [self.toolBar removeFromSuperview];

    _photoScrollView = nil;
    _toolBar = nil;
    _photoThumbs = nil;
    _thumbListContainView = nil;
    
    [self initializeViews];

	[self updateMetadataViewWithPage:0];
    [self.tableView reloadData];
}

- (void)updateMetadataViewWithPage:(NSUInteger)page {
	FNLOG(@"%ld", (long)page);
	self.metadataView.titleTextField.text = [_item.name length] ?  _item.name : NSLocalizedString(@"New Item", @"New Item");
	_metadataView.favoriteButton.selected = self.item.favorite != nil;
	_metadataView.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [_item.modificationDate timeAgo]];

    if (self.photoFieldItems.count <= page) {
        return;
    }
    
    WalletFieldItem *fieldItem = _photoFieldItems[page];
    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
        NSDictionary *metadata;
		if (fieldItem.image.metadata) {
			NSPropertyListFormat format;
			NSString *errorDescription;
			metadata = [NSPropertyListSerialization propertyListFromData:fieldItem.image.metadata mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
		}
        if (metadata) {
			NSDictionary *exifMetadata = [metadata objectForKey:(id)kCGImagePropertyExifDictionary];

            NSNumber *width, *height;
            NSNumber *orientation = metadata[@"Orientation"];
			if (exifMetadata && exifMetadata[@"PixelXDimension"] && exifMetadata[@"PixelXDimension"]) {
				width = exifMetadata[@"PixelXDimension"];
				height = exifMetadata[@"PixelYDimension"];
			} else if (metadata[@"PixelWidth"] && metadata[@"PixelHeight"]) {
				if (orientation.intValue < 5) {
					width = metadata[@"PixelWidth"];
					height = metadata[@"PixelHeight"];
				} else {
					width = metadata[@"PixelHeight"];
					height = metadata[@"PixelWidth"];
				}
			}

			if (width && height) {
				NSString *widthTxt = [self.decimalFormatter stringFromNumber:width];
				NSString *heightTxt = [self.decimalFormatter stringFromNumber:height];
				NSInteger photoResolution = width.intValue * height.intValue;
				NSString *photoResolutionText;
				photoResolutionText = [NSString stringWithFormat:@"%.1f", (((float) photoResolution)/1000000)];
				_metadataView.mediaSizeLabel.text = [NSString stringWithFormat:@"%@ x %@ (%@MP)", widthTxt, heightTxt, photoResolutionText];
			} else {
				_metadataView.mediaSizeLabel.text = @"";
			}

            NSString *orgDateText = exifMetadata[@"DateTimeOriginal"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
			NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
			[df setLocale:locale];
			[df setDateFormat:@"y:MM:dd HH:mm:ss"];
            NSDate *orgDate = [df dateFromString:orgDateText];
            
            // location 정보가 있는지 확인
            self.gpsMetaInfo = [metadata objectForKey:(id)kCGImagePropertyGPSDictionary];

            _metadataView.mediaSizeLabel.hidden = NO;
            _metadataView.takenDateLabel.hidden = NO;
            
			[df setLocale:[NSLocale currentLocale]];
            if (IS_IPAD || [NSDate isFullStyleLocale]) {
                [df setDateStyle:NSDateFormatterFullStyle];
                [df setTimeStyle:NSDateFormatterShortStyle];
            }
            else {
                df.dateFormat = [df customFullWithTimeStyleFormat];
            }

            _metadataView.takenDateLabel.text = [df stringFromDate:orgDate];
        }
        else {
            _metadataView.mediaSizeLabel.hidden = YES;
            _metadataView.takenDateLabel.hidden = YES;
        }
	}
	[_metadataView layoutIfNeeded];
}

- (UIScrollView *)photoScrollView
{
    CGFloat rectWidth = (IS_IPAD) ? 576 : 320;
    CGFloat rectHeight = (IS_IPAD) ? 506 : 300;

    if (!_photoScrollView) {
        CGRect photoFrame = CGRectMake((self.view.bounds.size.width-rectWidth)/2, 4, rectWidth, rectHeight);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:photoFrame];
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.bounces = NO;
        _photoScrollView.delegate = self;
        
        for (NSUInteger idx = 0; idx < self.photoFieldItems.count; idx++) {
            WalletFieldItem *photoFieldItem = _photoFieldItems[idx];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rectWidth* idx, 0, rectWidth, rectHeight)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;

			UIImage *photoImg = [photoFieldItem photoImageInOriginalDirectory:YES];
			photoImgView.image = [photoImg imageByScalingProportionallyToMinimumSize:CGSizeMake(rectWidth*2, rectWidth*2)];

            // photo cover
            UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectWidth, rectHeight)];
            coverView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.05];
            [photoImgView addSubview:coverView];
            
            [_photoScrollView addSubview:photoImgView];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
        tap.numberOfTapsRequired = 1;
        [_photoScrollView addGestureRecognizer:tap];
        
        _photoScrollView.contentSize = CGSizeMake(rectWidth*_photoFieldItems.count, 0);
    }
    
    return _photoScrollView;
}

- (NSInteger)currentPageAtPhotoScrollView {
	return (NSInteger)floorf(_photoScrollView.contentOffset.x / _photoScrollView.bounds.size.width);
}

- (NSMutableArray *)photoThumbs
{
    if (!_photoThumbs) {
        _photoThumbs = [[NSMutableArray alloc] init];
        for (NSUInteger idx = 0; idx < self.photoFieldItems.count; idx++) {
            WalletFieldItem *photoFieldItem = _photoFieldItems[idx];
            UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 ,34, 25)];
			photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
			photoImageView.layer.borderWidth = 1.0;
			photoImageView.layer.masksToBounds = YES;
            photoImageView.contentMode = UIViewContentModeScaleAspectFill;
			photoImageView.tag = idx;
            UIImage *photoImg = photoFieldItem.thumbnailImage;
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
	[self gotoPage:page];
}

- (void)favoriteButtonAction:(UIButton *)favorButton
{
	[_item changeFavorite:_item.favorite == nil];
    _metadataView.favoriteButton.selected = _item.favorite != nil;
}

- (void)editButtonAction:(id)sender
{
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
    A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
    viewController.delegate = self;
    viewController.item = self.item;
    viewController.hidesBottomBarWhenPushed = YES;
	viewController.alwaysReturnToOriginalCategory = self.alwaysReturnToOriginalCategory;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    nav.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)makeThumbSelected:(NSInteger) selectedIndex
{
    if (_photoThumbs.count <= selectedIndex) {
        return;
    }
    
    for (UIImageView *imgView in _photoThumbs) {
        CGPoint center = imgView.center;
        imgView.bounds = CGRectMake(0, 0, 14, 11);
        imgView.center = center;
    }
    
    UIImageView *selectThumbImgView = _photoThumbs[selectedIndex];
    CGPoint center = selectThumbImgView.center;
    selectThumbImgView.bounds = CGRectMake(0, 0, 36, 25);
    selectThumbImgView.center = center;
    [self.thumbListContainView bringSubviewToFront:selectThumbImgView];
}

- (void)photoTapped:(UITapGestureRecognizer *)tap
{
    NSInteger index = floorf(_photoScrollView.contentOffset.x/_photoScrollView.bounds.size.width);
    WalletFieldItem *fieldItem = _photoFieldItems[index];
    
    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
        
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = NO;
        browser.zoomPhotosToFill = YES;
        [browser setCurrentPhotoIndex:index];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        
        [self.navigationController presentViewController:nc animated:YES completion:NULL];
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

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.alBumPhotos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _alBumPhotos.count)
        return [_alBumPhotos objectAtIndex:index];
    return nil;
}

#pragma mark - walletItemEditDelegate

-(void)walletItemEdited:(WalletItem *)item
{
    _alBumPhotos = nil;
    
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
        [self gotoPage:page];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.photoScrollView) {
        if (!decelerate) {
            NSUInteger page = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
            [self makeThumbSelected:page];
			[self updateMetadataViewWithPage:page];
        }
    }
}

- (void)gotoPage:(NSInteger)page {
	[self makeThumbSelected:page];
	[self updateMetadataViewWithPage:page];

	NSUInteger mapItemIndex = [self.normalFieldItems indexOfObject:self.mapItem];
	if (self.gpsMetaInfo && mapItemIndex == NSNotFound) {
		[self.normalFieldItems insertObject:self.mapItem atIndex:2];
		[_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else if (!self.gpsMetaInfo && mapItemIndex != NSNotFound) {
		[self.normalFieldItems removeObjectAtIndex:mapItemIndex];
		[_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else{
		[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
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
	} else if (_normalFieldItems[indexPath.row] == self.noteItem) {
		A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID1 forIndexPath:indexPath];
        [noteCell setupTextView];
        noteCell.textView.editable = NO;

		[noteCell setNoteText:_item.note];
		[noteCell showTopSeparator:!_gpsMetaInfo];

        cell = noteCell;
    }
    else if (_normalFieldItems[indexPath.row] == self.mapItem) {
        A3WalletMapCell *mapCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemMapCellID1 forIndexPath:indexPath];

        /*
        "{GPS}" =     {
            Altitude = "37.22942206654992";
            DOP = "65.7909090909091";
            DateStamp = "2014:01:28";
            Latitude = "37.50890833333333";
            LatitudeRef = N;
            Longitude = "127.0659333333333";
            LongitudeRef = E;
            TimeStamp = "00:00:00";
        };
         */
        double latitudeValue = [self.gpsMetaInfo[@"Latitude"] doubleValue];
        double longitudeValue = [self.gpsMetaInfo[@"Longitude"] doubleValue];
        
        MKCoordinateRegion region;
        region.center.latitude = latitudeValue;
        region.center.longitude = longitudeValue;
        region.span.latitudeDelta = 0.001;
        region.span.longitudeDelta = 0.001;
        
        [mapCell.mapView setRegion:region animated:NO];
        mapCell.mapView.scrollEnabled = NO;
        mapCell.mapView.pitchEnabled = YES;
        // create a new marker in the middle
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitudeValue, longitudeValue);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:latitudeValue
                                                            longitude:longitudeValue];
        
        [geocoder reverseGeocodeLocation:newLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           
                           if (error) {
                               FNLOG(@"Geocode failed with error: %@", error);
                               return;
                           }
                           
                           if (placemarks && placemarks.count > 0)
                           {
                               CLPlacemark *placemark = placemarks[0];
                               NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                               
                               MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                               annotation.coordinate = coordinate;
                               annotation.title = locatedAt;
                               [mapCell.mapView addAnnotation:annotation];
                               [mapCell.mapView selectAnnotation:annotation animated:YES];
                           }
                       }];
        
        cell = mapCell;
    }
    else if ([_normalFieldItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _normalFieldItems[indexPath.row];
        
        if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] || [fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
            A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID1 forIndexPath:indexPath];
            
            photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
			[self configureFloatingTextField:photoCell.valueTextField];
            
            photoCell.valueTextField.placeholder = fieldItem.field.name;
            
            if (fieldItem.image) {
                photoCell.valueTextField.text = @" ";
                photoCell.photoButton.hidden = NO;
                
                UIImage *photo = fieldItem.thumbnailImage;
                photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
                [photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
                [photoCell.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                photoCell.photoButton.tag = indexPath.row;
                
            }
            else {
                photoCell.valueTextField.text = @"None";
                photoCell.photoButton.hidden = YES;
            }
            
            cell = photoCell;
        }
        else if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
            A3WalletItemFieldCell *dateCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID1 forIndexPath:indexPath];
            
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
            A3WalletItemFieldCell *textCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID1 forIndexPath:indexPath];
            
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

- (void)photoButtonAction:(UIButton *)photoButtonAction {
	// TODO:
	FNLOG(@"FUNCTION NOT IMPLEMENTED");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.photoItem) {
		return IS_IPAD ? 510 : 304;
	} else
	if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.metadataItem) {
		return [self.metadataView calculatedHeight];
	}
	if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.noteItem) {
		if (!_item.note) return 74.0;

		NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};

		UITextView *txtView = [[UITextView alloc] init];
		if (_item.note) {
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
			[txtView setAttributedText:attributedString];
		}
		CGFloat margin = IS_IPAD ? 28 + 15 : 15 + 15;
		CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.bounds.size.width - margin, CGFLOAT_MAX)];
		CGFloat cellHeight = txtViewSize.height + 10;

		return MAX(cellHeight, 74.0);
	}
	else if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.mapItem) {
		return 140.0;
	}
	else {
		return 74.0;
	}
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
