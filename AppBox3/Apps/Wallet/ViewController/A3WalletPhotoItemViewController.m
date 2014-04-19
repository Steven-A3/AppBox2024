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
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "MWPhotoBrowser.h"
#import "UIImage+Extension2.h"
#import "WalletFieldItem+initialize.h"

@interface A3WalletPhotoItemViewController () <WalletItemEditDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray *photoFieldItems;
@property (nonatomic, strong) NSMutableArray *normalFieldItems;
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) A3WalletPhotoItemTitleView *headerView;
@property (nonatomic, strong) NSMutableArray *photoThumbs;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIView *thumbListContainView;
@property (nonatomic, strong) NSMutableArray *alBumPhotos;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) MWPhotoBrowser *innerPhotoBrowser;
@property (nonatomic, strong) NSMutableDictionary *mapItem;
@property (nonatomic, strong) NSDictionary *gpsMetaInfo;

@end

@implementation A3WalletPhotoItemViewController

NSString *const A3WalletItemFieldCellID1 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID1 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemMapCellID1 = @"A3WalletMapCell";
NSString *const A3WalletItemFieldNoteCellID1 = @"A3WalletNoteCell";


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

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTopInfo];
    [self updatePhotoMetaInfo];
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
        
        NSArray *fieldItems = [_item fieldItemsArray];
        for (int i=0; i<fieldItems.count; i++) {
            WalletFieldItem *fieldItem = fieldItems[i];
            if (![fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                [_normalFieldItems addObject:fieldItem];
            }
        }
        
        // 데이타 없는 item은 표시하지 않는다.
        NSMutableArray *deleteTmp = [NSMutableArray new];
        for (WalletFieldItem *fieldItem in _normalFieldItems) {
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                if (fieldItem.date == nil) {
                    [deleteTmp addObject:fieldItem];
                }
            }
            else if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage] || [fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                if (!fieldItem.image && ![fieldItem.hasVideo boolValue]) {
                    [deleteTmp addObject:fieldItem];
                }
            }
            else {
                if ([fieldItem.value length] == 0) {
                    [deleteTmp addObject:fieldItem];
                }
            }
        }
        [_normalFieldItems removeObjectsInArray:deleteTmp];
        
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

- (NSMutableDictionary *)mapItem
{
    if (!_mapItem) {
        _mapItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Map", @"order":@""}];
    }
    
    return _mapItem;
}

- (NSMutableArray *)alBumPhotos
{
    if (!_alBumPhotos) {
        _alBumPhotos = [[NSMutableArray alloc] init];
        
        for (int i=0; i<self.photoFieldItems.count; i++) {
            WalletFieldItem *fieldItem = _photoFieldItems[i];
            MWPhoto *photo = [MWPhoto photoWithImage:fieldItem.image];
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

- (A3WalletPhotoItemTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletPhotoItemTitleView_iPad":@"A3WalletPhotoItemTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        
        [_headerView.favorButton addTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _headerView.titleTextField.delegate = self;
    }
    
    return _headerView;
}

- (void)refreshViews
{
    _photoFieldItems = nil;
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
    [self updatePhotoMetaInfo];
}

- (void)updateTopInfo
{
    _headerView.titleTextField.text = _item.name;
    CGSize textSize = [_item.name sizeWithAttributes:@{NSFontAttributeName:_headerView.titleTextField.font}];
    CGRect frame = _headerView.titleTextField.frame;
    frame.size.width = MIN(self.view.bounds.size.width- 30, textSize.width + 50);
    _headerView.titleTextField.frame = frame;
    
    _headerView.favorButton.selected = self.item.favorite != nil;
    _headerView.timeLabel.text = [NSString stringWithFormat:@"Updated %@",  [_item.modificationDate timeAgo]];
}

- (void)updatePhotoMetaInfo
{
    NSUInteger index = _photoScrollView.contentOffset.x/_photoScrollView.bounds.size.width;
    
    if (self.photoFieldItems.count <= index) {
        return;
    }
    
    WalletFieldItem *fieldItem = _photoFieldItems[index];
    
    if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
		NSData *imageData = UIImageJPEGRepresentation(fieldItem.image, 1.0);
        CGImageSourceRef source = CGImageSourceCreateWithData( (__bridge CFDataRef) imageData, NULL);
        NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
        
        /*
        {
            ColorModel = RGB;
            DPIHeight = 72;
            DPIWidth = 72;
            Depth = 8;
            Orientation = 6;
            PixelHeight = 2448;
            PixelWidth = 3264;
            "{Exif}" =     {
                ApertureValue = "2.52606882168926";
                BrightnessValue = "3.2496";
                ColorSpace = 1;
                DateTimeDigitized = "2014:01:28 01:04:56";
                DateTimeOriginal = "2014:01:28 01:04:56";
                ExposureMode = 0;
                ExposureProgram = 2;
                ExposureTime = "0.04166666666666666";
                FNumber = "2.4";
                Flash = 24;
                FocalLenIn35mmFilm = 33;
                FocalLength = "4.12";
                ISOSpeedRatings =         (
                                           50
                                           );
                LensMake = Apple;
                LensModel = "iPhone 5 back camera 4.12mm f/2.4";
                LensSpecification =         (
                                             "4.12",
                                             "4.12",
                                             "2.4",
                                             "2.4"
                                             );
                MeteringMode = 5;
                PixelXDimension = 3264;
                PixelYDimension = 2448;
                SceneType = 1;
                SensingMethod = 2;
                ShutterSpeedValue = "4.584985835694051";
                SubjectArea =         (
                                       1631,
                                       1223,
                                       1795,
                                       1077
                                       );
                SubsecTimeDigitized = 829;
                SubsecTimeOriginal = 829;
                WhiteBalance = 0;
            };
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
            "{JFIF}" =     {
                DensityUnit = 1;
                JFIFVersion =         (
                                       1,
                                       1
                                       );
                XDensity = 72;
                YDensity = 72;
            };
            "{MakerApple}" =     {
                1 = 0;
                3 =         {
                    epoch = 0;
                    flags = 1;
                    timescale = 1000000000;
                    value = 57163867774666;
                };
                4 = 1;
                5 = 132;
                6 = 132;
                7 = 1;
            };
            "{TIFF}" =     {
                DateTime = "2014:01:28 01:04:56";
                Make = Apple;
                Model = "iPhone 5";
                Orientation = 6;
                ResolutionUnit = 2;
                Software = "7.0.4";
                XResolution = 72;
                YResolution = 72;
            };
        }
         */
        
        if (metadata) {
            NSUInteger fileSize = [imageData length];
            NSString *fileSizeText;
            if (fileSize > 1000000) {
                fileSizeText = [NSString stringWithFormat:@"%.1fMB", fileSize/1024.0/1024.0];
            } else {
                fileSizeText = [NSString stringWithFormat:@"%.1fKB", fileSize/1024.0];
            }
            
            NSNumber *width, *height;
            NSNumber *orientation = metadata[@"Orientation"];
            if (orientation.intValue<5) {
                // width -> widht
                width = metadata[@"PixelWidth"];
                height = metadata[@"PixelHeight"];
            } else {
                // width -> height
                width = metadata[@"PixelHeight"];
                height = metadata[@"PixelWidth"];
            }
            NSString *widthTxt = [self.decimalFormatter stringFromNumber:width];
            NSString *heightTxt = [self.decimalFormatter stringFromNumber:height];
            NSUInteger photoResol = width.intValue * height.intValue;
            NSString *photoResolTxt = [NSString stringWithFormat:@"%.1f", (((float)photoResol)/1000000)];
            
            NSDictionary *exifMetadata = [metadata objectForKey:(id)kCGImagePropertyExifDictionary];
            NSString *orgDateText = exifMetadata[@"DateTimeOriginal"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yy:MM:dd hh:mm:ss"];
            NSDate *orgDate = [df dateFromString:orgDateText];
            
            // location 정보가 있는지 확인
            NSDictionary *gpsMetadata = [metadata objectForKey:(id)kCGImagePropertyGPSDictionary];
            if (gpsMetadata) {
                self.gpsMetaInfo = gpsMetadata;
                if ([self.normalFieldItems containsObject:self.mapItem]) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else {
                    [self.normalFieldItems insertObject:self.mapItem atIndex:0];
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            else {
                if ([self.normalFieldItems containsObject:self.mapItem]) {
                    [self.normalFieldItems removeObject:self.mapItem];
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
            _headerView.fileNameLB.hidden = NO;
            _headerView.imgSizeLB.hidden = NO;
            _headerView.fileSizeLB.hidden = NO;
            _headerView.takenDateLB.hidden = NO;
            
            _headerView.imgSizeLB.text = [NSString stringWithFormat:@"%@ x %@ (%@MP)", widthTxt, heightTxt, photoResolTxt];
            _headerView.fileSizeLB.text = fileSizeText;
            _headerView.takenDateLB.text = [orgDate timeAgo];
            
            CGRect rect = _headerView.frame;
            rect.size.height = 148.0;
            _headerView.frame = rect;
            
            self.tableView.tableHeaderView = self.headerView;
        }
        else {
            _headerView.fileNameLB.hidden = YES;
            _headerView.imgSizeLB.hidden = YES;
            _headerView.fileSizeLB.hidden = YES;
            _headerView.takenDateLB.hidden = YES;
            
            CGRect rect = _headerView.frame;
            rect.size.height = 84.0;
            _headerView.frame = rect;
            
            self.tableView.tableHeaderView = self.headerView;
        }
    }
}

- (UIScrollView *)photoScrollView
{
    // ipad : 576, 506
    // iphone : 320, 300
    
    float rectWidth = (IS_IPAD) ? 576:320;
    float rectHeight = (IS_IPAD) ? 506:300;
    
    
    if (!_photoScrollView) {
        
        CGRect photoFrame = CGRectMake((self.view.bounds.size.width-rectWidth)/2, 64+4, rectWidth, rectHeight);
        _photoScrollView = [[UIScrollView alloc] initWithFrame:photoFrame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.pagingEnabled = YES;
        _photoScrollView.bounces = NO;
        _photoScrollView.delegate = self;
        
        for (int i = 0; i < self.photoFieldItems.count; i++) {
            WalletFieldItem *photoFieldItem = _photoFieldItems[i];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(rectWidth*i, 0, rectWidth, rectHeight)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;

			UIImage *photoImg = photoFieldItem.image;
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

- (NSMutableArray *)photoThumbs
{
    if (!_photoThumbs) {
        _photoThumbs = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.photoFieldItems.count; i++) {
            WalletFieldItem *photoFieldItem = _photoFieldItems[i];
            UIImageView *photoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 ,24, 16)];
            photoImgView.contentMode = UIViewContentModeScaleAspectFill;
            UIImage *photoImg = photoFieldItem.thumbnailImage;
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
        
        [self makeThumbSelected:page];
        [self updatePhotoMetaInfo];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.photoScrollView) {
        if (!decelerate) {
            NSUInteger page = floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
            [self makeThumbSelected:page];
            [self updatePhotoMetaInfo];
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
        A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID1 forIndexPath:indexPath];
        
        noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
        noteCell.textView.editable = NO;
        noteCell.textView.bounces = NO;
        noteCell.textView.placeholder = @"Notes";
        noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        noteCell.textView.font = [UIFont systemFontOfSize:17];
        
        noteCell.textView.text = _item.note;
        
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
                               NSLog(@"Geocode failed with error: %@", error);
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
            [self configureFloatingTextField:photoCell.valueTxtFd];
            
            photoCell.valueTxtFd.placeholder = fieldItem.field.name;
            
            if (fieldItem.image) {
                photoCell.valueTxtFd.text = @" ";
                photoCell.photoButton.hidden = NO;
                
                UIImage *photo = fieldItem.thumbnailImage;
                photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
                [photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
                [photoCell.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                photoCell.photoButton.tag = indexPath.row;
                
            }
            else {
                photoCell.valueTxtFd.text = @"None";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.noteItem) {
		if (!_item.note) return 74.0;

        NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};

		UITextView *txtView = [[UITextView alloc] init];
		if (_item.note) {
			NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
			[txtView setAttributedText:attributedString];
		}
        CGFloat margin = IS_IPAD ? 49:31;
        CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
        CGFloat cellHeight = txtViewSize.height + 20;

		CGFloat defaultCellHeight = 74.0;
        
        if (cellHeight < defaultCellHeight) {
            return defaultCellHeight;
        }
        else {
            return cellHeight;
        }
    }
    else if ([self.normalFieldItems objectAtIndex:indexPath.row] == self.mapItem) {
        return 140.0;
    }
    else {
        return 74.0;
    }
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
