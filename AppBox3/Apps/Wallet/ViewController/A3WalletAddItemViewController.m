//
//  A3WalletAddItemViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletAddItemViewController.h"
#import "A3WalletCategorySelectViewController.h"
#import "A3WalletItemTitleView.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletItemFieldCateCell.h"
#import "A3WalletItemRightIconCell.h"
#import "A3WalletNoteCell.h"
#import "A3WalletDateInputCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletField.h"
#import "WalletFieldItem.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "NSManagedObject+Identify.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface NSObject (NullCheck)
- (BOOL)isNull;
@end

@implementation NSObject (NullCheck)

- (BOOL)isNull
{
    return [self isKindOfClass:[NSNull class]];
}

@end

@interface A3WalletAddItemViewController () <WalletCatogerySelectDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) WalletItem *addItem;
@property (nonatomic, strong) A3WalletItemTitleView *headerView;
@property (nonatomic, strong) NSMutableDictionary *categoryItem;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;
@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) NSMutableDictionary *itemData;
@property (nonatomic, strong) UIPopoverController *popOver;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

NSString *const A3WalletItemFieldCellID3 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID3 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemFieldTwoValueCellID3 = @"A3WalletItemFieldTwoValueCell";
NSString *const A3WalletItemFieldCateCellID3 = @"A3WalletItemFieldCateCell";
NSString *const A3WalletItemRightIconCellID3 = @"A3WalletItemRightIconCell";
NSString *const A3WalletItemNoteCellID3 = @"A3WalletNoteCell";
NSString *const A3WalletItemDateInputCellID3 = @"A3WalletDateInputCell";
NSString *const A3WalletItemDateCellID3 = @"A3WalletItemFieldCell";

@implementation A3WalletAddItemViewController
{
    NSIndexPath *currentIndexPath;
    UITextField *firstResponder;
    
    WalletField *currentField;
    CGRect cellRectInView;
    
    float textViewHeight;
    
    NSIndexPath *dateInputIndexPath;
    NSDate *preDate;
    
    BOOL titleBecomeActive;
    
    BOOL getLocation;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // location manager 시작
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    self.navigationItem.title = @"Add Item";
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
    [self itemData];
    
	self.tableView.tableHeaderView = self.headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    // 입력 초기상태
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (titleBecomeActive == NO) {
        [self.headerView.titleTextField becomeFirstResponder];
        titleBecomeActive = YES;
    }
}

- (NSMutableArray *)fields
{
    if (!_fields) {
        
        NSArray *items = [self.selectedCategory fieldsArray];
        
        _fields = [NSMutableArray arrayWithArray:items];
        
        [_fields insertObject:self.categoryItem atIndex:0];
        [_fields addObject:self.noteItem];
    }
    
    return _fields;
}

- (NSMutableDictionary *)itemData
{
    if (!_itemData) {
        
        // 초기화
        _itemData = [NSMutableDictionary dictionaryWithDictionary:
                     @{
                       @"Title": @"",
                       @"Note" : @"",
                       }
                     ];
        
        NSArray *items = [self.selectedCategory fieldsArray];
        
        for (WalletField *field in items) {
            // date타입은 nsdate 값을 갖는다.
            if ([field.type isEqualToString:WalletFieldTypeDate]) {
                // 초기화는 현재시간으로 한다.
                [_itemData setObject:[NSDate date] forKey:field.uriKey];
            }
            else {
                [_itemData setObject:@"" forKey:field.uriKey];
            }
        }
    }
    
    return _itemData;
}

- (NSMutableDictionary *)categoryItem
{
    if (!_categoryItem) {
		_categoryItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"category", @"order":@""}];
	}
	return _categoryItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
		_noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"note", @"order":@""}];
	}
	return _noteItem;
}

- (NSMutableDictionary *)dateInputItem
{
    if (!_dateInputItem) {
        _dateInputItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"dateInput", @"order":@""}];
    }
    
    return _dateInputItem;
}

- (A3WalletItemTitleView *)headerView
{
    if (!_headerView) {
        NSString *nibName = IS_IPAD ? @"A3WalletItemTitleView_iPad":@"A3WalletItemTitleView";
        _headerView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:Nil options:nil] lastObject];
        
        _headerView.isEditMode = YES;
        _headerView.titleTextField.delegate = self;
        _headerView.titleTextField.placeholder = @"Title";
        _headerView.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_headerView.favorButton addTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _headerView;
}

- (void)favorButtonAction:(UIButton *)favorButton
{
    _headerView.favorButton.selected = !_headerView.favorButton.selected;
}

- (void)updateTopInfo
{
    NSString *titleTxt = _itemData[@"Title"];
    _headerView.titleTextField.text = titleTxt;
    
    /*
    CGSize textSize = [titleTxt sizeWithAttributes:@{NSFontAttributeName:_headerView.titleTextField.font}];
    CGRect frame = _headerView.titleTextField.frame;
    frame.size.width = MIN(self.view.bounds.size.width- 30, textSize.width + 50);
    _headerView.titleTextField.frame = frame;
    */
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterFullStyle;
    NSDate *current = [NSDate date];
    _headerView.timeLabel.text = [NSString stringWithFormat:@"Current %@",  [df stringFromDate:current]];
}

- (void)dateChanged:(UIDatePicker *)sender {
    
    WalletField *field = _fields[dateInputIndexPath.row];
    [_itemData setObject:sender.date forKey:field.uriKey];
    
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonAction:(id)sender
{
    [self.locationManager stopUpdatingLocation];
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletITemAddCanceled)]) {
        [_delegate walletITemAddCanceled];
    }
    
    if (IS_IPAD) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self.locationManager stopUpdatingLocation];
    
    // 입력중인거 완료
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
    
    // 입력값 체크
    NSString *title = _itemData[@"Title"];
    if ([self isItemDataEmpty] && title.length==0) {
        // 입력 데이타 없음
        return;
    }
    
    // walletitem만들기
    WalletItem *item = [WalletItem MR_createEntity];
    item.name = title;
    item.note = _itemData[@"Note"];
    item.category = _selectedCategory;
	item.modificationDate = [NSDate date];
    
    NSArray *cateFields = [self.selectedCategory fieldsArray];
    
    NSMutableSet *targets = [[NSMutableSet alloc] init];
    for (int i=0; i < cateFields.count; i++) {
        WalletField *cateField = cateFields[i];
        WalletFieldItem *fieldItem = [WalletFieldItem MR_createEntity];
        fieldItem.field = cateField;
        fieldItem.walletItem = item;
        if ([cateField.type isEqualToString:WalletFieldTypeDate]) {
            id date = _itemData[cateField.uriKey];
            if ([date isKindOfClass:[NSDate class]]) {
                fieldItem.date = date;
            }
        }
        else if ([cateField.type isEqualToString:WalletFieldTypeVideo] || [cateField.type isEqualToString:WalletFieldTypeImage]) {
            NSString *filePath = _itemData[cateField.uriKey];
            if (filePath.length > 0) {
                fieldItem.filePath = filePath;
            }
        }
        else {
            NSString *value = _itemData[cateField.objectID.URIRepresentation.absoluteString];
            if (value.length > 0) {
                fieldItem.value = value;
            }
        }
        [targets addObject:fieldItem];
    }
    item.fieldItems = targets;

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    if (_delegate && [_delegate respondsToSelector:@selector(walletItemAddCompleted:)]) {
        [_delegate walletItemAddCompleted:self.addItem];
    }
    
    if (IS_IPAD) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)askImagePickupWithDelete:(BOOL)deleteEnable
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Photo", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Photo", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        
	} else {
        
        if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose and Resize", @"common", nil), nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
        }
	}
}

- (void)askVideoPickupWithDelete:(BOOL)deleteEnable
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
		if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Video", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedStringFromTable(@"Take Video", @"common", nil),
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
	} else {
		if (deleteEnable) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                        nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
        else {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"common", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:
                                          NSLocalizedStringFromTable(@"Choose Existing", @"common", nil),
                                          nil];
            actionSheet.tag = 2;
            [actionSheet showInView:self.view];
        }
	}
}

- (void)mediaButtonAction:(UIButton *)sender
{
    // 다시 사진을 선택하도록 한다. (해당 테이블 셀을 눌렀을때와 동일한 프로세스로 동작하면 됨)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:ip];
}

- (void)deleteMediaItem
{
    NSUInteger index = currentIndexPath.row;
    if ([_fields[index] isKindOfClass:[WalletField class]]) {
        WalletField *field = _fields[index];
        if ([field.type isEqualToString:WalletFieldTypeImage]) {
            NSString *imagePath = self.itemData[field.uriKey];
            if (imagePath.length > 0) {
                [WalletData deleteFileAtPath:imagePath];
                NSString *thumb = [WalletData thumbImgPathOfImgPath:imagePath];
                [WalletData deleteFileAtPath:thumb];
            }
            
            [_itemData setObject:@"" forKey:field.uriKey];
            
            [self.tableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
            NSString *videoPath = self.itemData[field.uriKey];
            if (videoPath.length > 0) {
                [WalletData deleteFileAtPath:videoPath];
                NSString *thumb = [WalletData thumbImgPathOfVideoPath:videoPath];
                [WalletData deleteFileAtPath:thumb];
            }
            
            [_itemData setObject:@"" forKey:field.uriKey];
            
            [self.tableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)configureFloatingTextField:(JVFloatLabeledTextField *)txtFd
{
    txtFd.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
    txtFd.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    txtFd.font = [UIFont systemFontOfSize:17.0];
    txtFd.floatingLabelFont = [UIFont systemFontOfSize:14];
    txtFd.floatingLabelYPadding = @(-6);
    txtFd.delegate = self;
}

- (BOOL)isItemDataEmpty
{
    NSArray *allKeys = _itemData.allKeys;
    for (int i=0; i<allKeys.count; i++) {
        NSString *key = allKeys[i];
        id object = _itemData[key];
        if ([object isKindOfClass:[NSDate class]]) {
            
        }
        else if ([object isKindOfClass:[NSString class]] && [(NSString *)object isEqualToString:@""]) {
            
        }
        else {
            return NO;
        }
    }
    
    return YES;
}

- (void)exchangeDatePickerFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to
{
    [self.tableView beginUpdates];
    NSUInteger idx = [_fields indexOfObject:self.dateInputItem];
    [_fields removeObject:self.dateInputItem];
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    dateInputIndexPath = nil;
    [self.tableView endUpdates];
    
    [self.tableView beginUpdates];
    if (from.row < to.row) {
        to = [NSIndexPath indexPathForRow:to.row-1 inSection:0];
    }
    dateInputIndexPath = to;
    [_fields insertObject:self.dateInputItem atIndex:dateInputIndexPath.row+1];
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateInputIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)datePickerActiveFromIndexPath:(NSIndexPath *)dateIndexPath
{
    if (![_fields containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        dateInputIndexPath = dateIndexPath;
        
        [_fields insertObject:self.dateInputItem atIndex:dateIndexPath.row+1];
        [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)dismissDatePicker
{
    if ([_fields containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        NSUInteger idx = [_fields indexOfObject:self.dateInputItem];
        [_fields removeObject:self.dateInputItem];
        
        [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        dateInputIndexPath = nil;
        [self.tableView endUpdates];
    }
}

-(NSString *)getUTCFormattedDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

- (void)setLocation:(NSMutableDictionary *)metadata location:(CLLocation *)location
{
    
    if (location) {
        
        CLLocationDegrees exifLatitude  = location.coordinate.latitude;
        CLLocationDegrees exifLongitude = location.coordinate.longitude;
        
        NSString *latRef;
        NSString *lngRef;
        if (exifLatitude < 0.0) {
            exifLatitude = exifLatitude * -1.0f;
            latRef = @"S";
        } else {
            latRef = @"N";
        }
        
        if (exifLongitude < 0.0) {
            exifLongitude = exifLongitude * -1.0f;
            lngRef = @"W";
        } else {
            lngRef = @"E";
        }
        
        NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
        if ([metadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary]) {
            [locDict addEntriesFromDictionary:[metadata objectForKey:(NSString*)kCGImagePropertyGPSDictionary]];
        }
        [locDict setObject:[self getUTCFormattedDate:location.timestamp] forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
        [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [locDict setObject:lngRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
        [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
        
        [metadata setObject:locDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
}

#pragma mark - LocationDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations.count > 0) {
        if ([[locations lastObject] isKindOfClass:[CLLocation class]]) {
            self.currentLocation = [locations lastObject];
            getLocation = YES;
        }
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        // 삭제하기
        [self deleteMediaItem];
        return;
    }
    
	NSInteger myButtonIndex = buttonIndex;
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		myButtonIndex++;
	switch (myButtonIndex) {
		case 0:
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.allowsEditing = NO;
			break;
		case 1:
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.allowsEditing = NO;
			break;
		case 2:
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.allowsEditing = YES;
			break;
	}
    
    // photo
    if (actionSheet.tag == 1) {
        picker.mediaTypes = @[(NSString *) kUTTypeImage];
    }
    // video
    else if (actionSheet.tag == 2){
        picker.mediaTypes = @[(NSString *) kUTTypeMovie];
    }

    picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
	picker.navigationBar.barStyle = UIBarStyleDefault;
	picker.delegate = self;
    
    if (IS_IPAD) {
        BOOL isFullScreen = NO;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            isFullScreen = YES;
        }
        
        if (isFullScreen) {
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else {
            self.popOver = [[UIPopoverController alloc] initWithContentViewController:picker];
            CGRect rect = cellRectInView;
            [_popOver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else {
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == 1) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Photo", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
    else if (actionSheet.tag == 2) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Video", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
}

#pragma mark- UIImagePickerControllerDelegate

- (NSString *)uniqueMediaFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSCalendar *gregorian = [ [NSCalendar alloc ] initWithCalendarIdentifier:NSGregorianCalendar ];
    NSDateComponents *dc = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate: [NSDate date] ];
    
    NSString *newImagefilepath, *newImagefilename;
    srand((unsigned int) time(NULL));
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    do {
        NSString *uniquieIdentifier = [NSString stringWithFormat:@"%04ld-%02ld-%02ld%02ld%02ld%02ld-%ld", (long)[dc year], (long)[dc month], (long)[dc day], (long)[dc hour], (long)[dc minute], (long)[dc second], (long)rand() ];
        NSString *filename = kWalletImageFilePrefix;
        newImagefilename = [filename stringByAppendingString:uniquieIdentifier];
        newImagefilepath = [libraryDirectory stringByAppendingPathComponent:newImagefilename];
    } while ([fileManager fileExistsAtPath:newImagefilepath]);
    
    return newImagefilepath;
}

- (void) saveImage:(UIImage *)image withFilePath:(NSString *)imagePath withMeta:(NSDictionary *)metadata
{
    NSData *jpeg = UIImageJPEGRepresentation(image, 1.0);
    
    CGImageSourceRef  source ;
    source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *dest_data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    if(!destination) {
        NSLog(@"***Could not create image destination ***");
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadata);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    [dest_data writeToFile:imagePath atomically:YES];
    
    //cleanup
    
    CFRelease(destination);
    CFRelease(source);
}

-(void) saveImage:(UIImage *)image withFilePath:(NSString *)imagePath
{
    NSError *error;
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath options:NSAtomicWrite error:&error];
    if (error) {
        FNLOG(@"%@", [error description]);
    }
}

- (void)copyVideoFrom:(NSString *)sourcePath to:(NSString *)targetPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm copyItemAtPath:sourcePath toPath:targetPath error:NULL];
}

- (void)saveVideo:(NSDictionary *)movieInfo {
    NSString *originalVideoPath = [movieInfo objectForKey:@"kOriginalFilePath"];
    NSString *filePath = [movieInfo objectForKey:@"kFilePath"];
    UIImage *thumbImage = [movieInfo objectForKey:@"kThumbImage"];
    NSString *thumbFilePath = [WalletData thumbImgPathOfVideoPath:filePath];
    
    [self copyVideoFrom:originalVideoPath to:filePath];
    [self saveImage:thumbImage withFilePath:thumbFilePath];
    
    WalletField *field = currentField;
    
    NSString *preVideoFilePath = self.itemData[field.uriKey];
    if (preVideoFilePath.length > 0) {
        [WalletData deleteFileAtPath:preVideoFilePath];
        NSString *thumb = [WalletData thumbImgPathOfVideoPath:preVideoFilePath];
        [WalletData deleteFileAtPath:thumb];
    }
    
    [self.itemData setObject:filePath forKey:field.uriKey];
    
    NSInteger idx = [_fields indexOfObject:field];
    NSIndexPath *cip = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[cip] withRowAnimation:UITableViewRowAnimationFade];
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (void)saveImage:(NSDictionary *)imageInfo {
    
    UIImage *originalImage = [imageInfo objectForKey:@"kOriginalImage"];
    UIImage *thumbImage = [imageInfo objectForKey:@"kThumbImage"];
    NSString *imageFilePath = [[imageInfo objectForKey:@"kFileName"] stringByAppendingPathExtension:@"jpg"];
    NSString *thumbFilePath = [WalletData thumbImgPathOfImgPath:imageFilePath];
    NSDictionary *metadata = [imageInfo objectForKey:@"kMetadata"];
    
//    [self saveImage:originalImage withFilePath:imageFilePath];
    [self saveImage:originalImage withFilePath:imageFilePath withMeta:metadata];
    [self saveImage:thumbImage withFilePath:thumbFilePath];
    
    WalletField *field = currentField;
    
    NSString *preImageFilePath = self.itemData[field.uriKey];
    if (preImageFilePath.length > 0) {
        [WalletData deleteFileAtPath:preImageFilePath];
        NSString *thumb = [WalletData thumbImgPathOfImgPath:preImageFilePath];
        [WalletData deleteFileAtPath:thumb];
    }
    
    [self.itemData setObject:imageFilePath forKey:field.uriKey];
    
    NSInteger idx = [_fields indexOfObject:field];
    NSIndexPath *cip = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[cip] withRowAnimation:UITableViewRowAnimationFade];
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)imageEditInfo {
    @autoreleasepool {
        
        NSString *mediaType = imageEditInfo[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            
            if (IS_IPAD && self.popOver) {
                [[self popOver] dismissPopoverAnimated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            
            //get the videoURL
            NSURL *movieURL = imageEditInfo[UIImagePickerControllerMediaURL];
            NSString *movieFilePath = movieURL.path;
            NSString *extension = [movieFilePath pathExtension];
            
            FNLOG(@"%@", movieFilePath);
            
            NSString *newMoviefilepath = [[self uniqueMediaFilePath] stringByAppendingPathExtension:extension];
            UIImage *originalImage = [WalletData videoPreviewImageOfURL:movieURL];
            
            CGSize boundsSize = CGSizeMake(160, 160);
            UIImage *thumbImage = [originalImage imageByScalingProportionallyToMinimumSize:boundsSize];
            
            NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      newMoviefilepath, @"kFilePath",
                                      movieFilePath, @"kOriginalFilePath",
                                      thumbImage, @"kThumbImage",
                                      nil];
            [self performSelector:@selector(saveVideo:) withObject:paramDic afterDelay:0.1];
        }
        else {
            UIImage *originalImage = [imageEditInfo objectForKey:UIImagePickerControllerEditedImage];;
            if (!originalImage)
                originalImage = [imageEditInfo objectForKey:UIImagePickerControllerOriginalImage];
            
            if (!originalImage)
                return;
            
            NSString *newImagefilepath = [self uniqueMediaFilePath];
            
            CGSize boundsSize = CGSizeMake(160, 160);
            UIImage *thumbImage = [originalImage imageByScalingProportionallyToMinimumSize:boundsSize];
            
            // Remove the picker interface and release the picker object.
            if (IS_IPAD && self.popOver) {
                [[self popOver] dismissPopoverAnimated:YES];
            }
            else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            
            // 메타데이타 저장하기
            NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:[imageEditInfo objectForKey:UIImagePickerControllerMediaMetadata]];
            if (getLocation) {
                NSLog(@"write gps : %f- %f", self.currentLocation.coordinate.longitude, self.currentLocation.coordinate.latitude);
                [self setLocation:metadata location:self.currentLocation];
            }
            
            NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      newImagefilepath, @"kFileName",
                                      originalImage, @"kOriginalImage",
                                      thumbImage, @"kThumbImage",
                                      metadata, @"kMetadata",
                                      nil];
            [self performSelector:@selector(saveImage:) withObject:paramDic afterDelay:0.1];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    firstResponder = textField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    firstResponder = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissDatePicker];

	currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"current text field indexpath : %@", [currentIndexPath description]);

	if ([self.fields objectAtIndex:currentIndexPath.row] == self.noteItem) {
		// note
		textField.keyboardType = UIKeyboardTypeDefault;
	}
	else if ([[self.fields objectAtIndex:currentIndexPath.row] isKindOfClass:[WalletField class]]) {

		WalletField *field = [_fields objectAtIndex:currentIndexPath.row];
		if ([field.type isEqualToString:WalletFieldTypeText]) {
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeNumber]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypePhone]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeURL]) {
			textField.keyboardType = UIKeyboardTypeURL;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([field.type isEqualToString:WalletFieldTypeEmail]) {
			textField.keyboardType = UIKeyboardTypeEmailAddress;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
	}
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    // update
    if (firstResponder == _headerView.titleTextField) {
        //  title
        [self.itemData setObject:firstResponder.text forKey:@"Title"];
    }
    else {
        
        if ([self.fields[currentIndexPath.row] isKindOfClass:[WalletField class]]) {
            WalletField *field = self.fields[currentIndexPath.row];
            NSString *key = field.objectID.URIRepresentation.absoluteString;
            [self.itemData setObject:firstResponder.text forKey:key];
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 다음 텍스트 필드로 이동.
    [textField resignFirstResponder];
    
    NSUInteger startIdx;
    if (textField == self.headerView.titleTextField) {
        startIdx = 0;
    }
    else {
        startIdx = currentIndexPath.row+1;
    }
    
    if ([_fields objectAtIndex:startIdx] == self.noteItem) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:startIdx inSection:0];
        A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[self.tableView cellForRowAtIndexPath:ip];
        [noteCell.textView becomeFirstResponder];
    }
    else {
        for (NSUInteger idx = startIdx; idx < _fields.count; idx++) {
            if ([[_fields objectAtIndex:idx] isKindOfClass:[WalletField class]]) {
                WalletField *field = [_fields objectAtIndex:idx];
                
                if ([field.type isEqualToString:WalletFieldTypeDate]) {
                }
                else if ([field.type isEqualToString:WalletFieldTypeImage]) {
                }
                else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
                }
                else {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:idx inSection:0];
                    A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell* )[self.tableView cellForRowAtIndexPath:ip];
                    [inputCell.valueTextField becomeFirstResponder];
                    break;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissDatePicker];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self.itemData setObject:textView.text forKey:@"Note"];
    
    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height+25;
    textView.frame = frame;
    
    textViewHeight = frame.size.height;
    
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.itemData setObject:textView.text forKey:@"Note"];
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

#pragma mark - WalletCategorySelectDelegate
- (void)walletCategorySelected:(WalletCategory *)category
{
    if (_selectedCategory != category) {
        self.selectedCategory = category;
        
        _itemData = nil;
        _fields = nil;
        
        [self.tableView reloadData];
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
    return self.fields.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.fields objectAtIndex:indexPath.row] == self.noteItem) {
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                         };
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self.itemData objectForKey:@"Note"] attributes:textAttributes];
        UITextView *txtView = [[UITextView alloc] init];
        [txtView setAttributedText:attributedString];
        float margin = IS_IPAD ? 49:31;
        CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
        float cellHeight = txtViewSize.height + 20;
        
        // memo카테고리에서는 화면의 가장 아래까지 노트필드가 채워진다.
        float defaultCellHeight = 180.0;
        if ([_selectedCategory.name isEqualToString:@"Memo"]) {
            NSUInteger itemCount = _fields.count;
            if (itemCount>1) {
                NSUInteger normalCellCount = itemCount-1;
                float normalHeight = 74*normalCellCount;
                float topNavHeight = 64;
                float bottomMargin = 20;
                float tmp = self.tableView.frame.size.height - normalHeight - self.headerView.frame.size.height - topNavHeight - bottomMargin;
                
                if (tmp > defaultCellHeight) {
                    defaultCellHeight = tmp;
                }
            }
        }
        if (cellHeight < defaultCellHeight) {
            return defaultCellHeight;
        }
        
        else {
            return cellHeight;
        }
    }
    else if ([self.fields objectAtIndex:indexPath.row] == self.dateInputItem) {
        
        return 218;
    }
    else if (indexPath.row == 0) {
        
        return IS_RETINA ? 74.5 : 75.0;
    }
    
    return 74.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if ([self.fields objectAtIndex:indexPath.row] == self.categoryItem) {
            // category
            A3WalletItemFieldCateCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCateCellID3 forIndexPath:indexPath];
            
            inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:inputCell.valueTextField];
            
            inputCell.valueTextField.enabled = NO;
            inputCell.valueTextField.floatingLabelFont = [UIFont systemFontOfSize:14];
            inputCell.valueTextField.font = [UIFont systemFontOfSize:17];
            inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            inputCell.valueTextField.placeholder = @"Category";
            inputCell.valueTextField.text = self.selectedCategory.name;
            
            cell = inputCell;
        }
        else if ([self.fields objectAtIndex:indexPath.row] == self.noteItem) {
            // note
            A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemNoteCellID3 forIndexPath:indexPath];
            
            noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
            noteCell.textView.delegate = self;
            noteCell.textView.bounces = NO;
            noteCell.textView.placeholder = @"Notes";
            noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
            noteCell.textView.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
            noteCell.textView.font = [UIFont systemFontOfSize:17];
            
            cell = noteCell;
        }
        else if ([self.fields objectAtIndex:indexPath.row] == self.dateInputItem) {
            // date input cell
            A3WalletDateInputCell *dateInputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateInputCellID3 forIndexPath:indexPath];
            dateInputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dateInputCell.datePicker.date = preDate;
            dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
            [dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
            
            cell = dateInputCell;
        }
        else if ([[self.fields objectAtIndex:indexPath.row] isKindOfClass:[WalletField class]]) {
            
            WalletField *field = [_fields objectAtIndex:indexPath.row];
            
            if ([field.type isEqualToString:WalletFieldTypeDate]) {
                
                A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateCellID3 forIndexPath:indexPath];
                
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self configureFloatingTextField:inputCell.valueTextField];
                
                inputCell.valueTextField.enabled = NO;
                inputCell.valueTextField.placeholder = field.name;
                
                if ([_itemData[field.uriKey] isKindOfClass:[NSDate class]]) {
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    //[df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                    [df setDateFormat:@"MMM dd, YYYY"];
                    inputCell.valueTextField.text = [df stringFromDate:_itemData[field.uriKey]];
                }
                else {
                    inputCell.valueTextField.text = @"";
                }
                
                if ([indexPath compare:dateInputIndexPath] == NSOrderedSame) {
                    inputCell.valueTextField.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
                } else {
                    inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                }
                
                cell = inputCell;
            }
            else if ([field.type isEqualToString:WalletFieldTypeImage]) {
                
                NSString *filePath = _itemData[field.uriKey];
                if (filePath.length  > 0) {
                    
                    A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID3 forIndexPath:indexPath];
                    
                    photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [self configureFloatingTextField:photoCell.valueTxtFd];
                    
                    photoCell.valueTxtFd.enabled = NO;
                    photoCell.valueTxtFd.placeholder = field.name;
                    
                    photoCell.valueTxtFd.text = @" ";
                    photoCell.photoButton.hidden = NO;
                    
                    NSString *thumbFilePath = [WalletData thumbImgPathOfImgPath:filePath];
                    NSData *img = [NSData dataWithContentsOfFile:thumbFilePath];
                    UIImage *photo = [UIImage imageWithData:img];
                    photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
                    [photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
                    [photoCell.photoButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    photoCell.photoButton.tag = indexPath.row;
                    
                    cell = photoCell;
                }
                else {
                    A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID3 forIndexPath:indexPath];

                    iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    iconCell.titleLabel.text = field.name;
                    iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                    iconCell.iconImgView.image = [UIImage imageNamed:@"camera"];
                    
                    cell = iconCell;
                }
            }
            else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
                
                NSString *filePath = _itemData[field.uriKey];
                if (filePath.length  > 0) {
                    
                    A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID3 forIndexPath:indexPath];
                    
                    photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [self configureFloatingTextField:photoCell.valueTxtFd];
                    
                    photoCell.valueTxtFd.enabled = NO;
                    photoCell.valueTxtFd.placeholder = field.name;
                    
                    photoCell.valueTxtFd.text = @" ";
                    photoCell.photoButton.hidden = NO;
                    
                    NSString *thumbFilePath = [WalletData thumbImgPathOfVideoPath:filePath];
                    NSData *img = [NSData dataWithContentsOfFile:thumbFilePath];
                    UIImage *photo = [UIImage imageWithData:img];
                    photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
                    [photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
                    [photoCell.photoButton addTarget:self action:@selector(mediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                    photoCell.photoButton.tag = indexPath.row;
                    
                    cell = photoCell;
                }
                else {
                    A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID3 forIndexPath:indexPath];
                    
                    iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    iconCell.titleLabel.text = field.name;
                    iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                    iconCell.iconImgView.image = [UIImage imageNamed:@"video"];
                    
                    cell = iconCell;
                }
            }
            else {
                
                A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID3 forIndexPath:indexPath];
                
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self configureFloatingTextField:inputCell.valueTextField];
                
                inputCell.valueTextField.placeholder = field.name;
                inputCell.valueTextField.text = _itemData[field.uriKey];
                
                cell = inputCell;
            }
            
        }
	}
    
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
    
    if ([self.fields objectAtIndex:indexPath.row] == self.categoryItem) {
        // category
        A3WalletCategorySelectViewController *viewController = [[A3WalletCategorySelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.selectedCategory = _selectedCategory;
        viewController.delegate = self;

        [self dismissDatePicker];
        
        if (IS_IPHONE) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
            [rootViewController presentRightSideViewController:viewController];
        }
    }
    if ([[self.fields objectAtIndex:indexPath.row] isKindOfClass:[WalletField class]]) {
        
        WalletField *field = [_fields objectAtIndex:indexPath.row];
        
        if ([field.type isEqualToString:WalletFieldTypeDate]) {
            preDate = _itemData[field.uriKey];
            
            if ([_fields containsObject:self.dateInputItem]) {
                if ([indexPath compare:dateInputIndexPath] == NSOrderedSame) {
                    // 현재 셀에 연결된 입력 picker
                    [self dismissDatePicker];
                }
                else {
                    // 다른 셀에 연결된 입력 picker
                    [self exchangeDatePickerFromIndexPath:dateInputIndexPath toIndexPath:indexPath];
                }
            }
            else {
                [self datePickerActiveFromIndexPath:indexPath];
            }
            
            //[inputCell.valueTextField becomeFirstResponder];
        }
        else if ([field.type isEqualToString:WalletFieldTypeImage]) {
            
            NSString *filePath = _itemData[field.uriKey];
            filePath.length>0 ? [self askImagePickupWithDelete:YES] : [self askImagePickupWithDelete:NO];
            
            if ([_fields containsObject:self.dateInputItem]) {
                [self dismissDatePicker];
                
                if (indexPath.row > 0) {
                    NSIndexPath *ip1 = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                    [self.tableView reloadRowsAtIndexPaths:@[ip1] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
//            currentIndexPath = indexPath;
            currentField = field;
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
                A3WalletItemRightIconCell *iconCell = (A3WalletItemRightIconCell *)cell;
                cellRectInView = [self.view convertRect:iconCell.iconImgView.bounds fromView:iconCell.iconImgView];
            }
            else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
                A3WalletItemPhotoFieldCell *photoCell = (A3WalletItemPhotoFieldCell *)cell;
                cellRectInView = [self.view convertRect:photoCell.photoButton.bounds fromView:photoCell.photoButton];
            }

        }
        else if ([field.type isEqualToString:WalletFieldTypeVideo]) {
            
            NSString *filePath = _itemData[field.uriKey];
            filePath.length>0 ? [self askVideoPickupWithDelete:YES] : [self askVideoPickupWithDelete:NO];
            
            if ([_fields containsObject:self.dateInputItem]) {
                [self dismissDatePicker];
                
                if (indexPath.row > 0) {
                    NSIndexPath *ip1 = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                    [self.tableView reloadRowsAtIndexPaths:@[ip1] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
//            currentIndexPath = indexPath;
            currentField = field;
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[A3WalletItemRightIconCell class]]) {
                A3WalletItemRightIconCell *iconCell = (A3WalletItemRightIconCell *)cell;
                cellRectInView = [self.view convertRect:iconCell.iconImgView.bounds fromView:iconCell.iconImgView];
            }
            else if ([cell isKindOfClass:[A3WalletItemPhotoFieldCell class]]) {
                A3WalletItemPhotoFieldCell *photoCell = (A3WalletItemPhotoFieldCell *)cell;
                cellRectInView = [self.view convertRect:photoCell.photoButton.bounds fromView:photoCell.photoButton];
            }
        }
        else {
            A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
            [inputCell.valueTextField becomeFirstResponder];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
