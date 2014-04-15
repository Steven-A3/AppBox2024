//
//  A3WalletItemEditViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 2..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3WalletItemEditViewController.h"
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
#import "WalletItem+initialize.h"
#import "WalletItem+Favorite.h"
#import "WalletFieldItem.h"
#import "WalletFieldItem+initialize.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "WalletField.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+A3Addition.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"

#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>

@interface A3WalletItemEditViewController () <WalletCatogerySelectDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *fieldItems;
@property (nonatomic, strong) NSMutableDictionary *noteItem;
@property (nonatomic, strong) NSMutableDictionary *deleteItem;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) A3WalletItemTitleView *headerView;
@property (nonatomic, strong) NSMutableDictionary *categoryItem;
@property (nonatomic, strong) NSMutableDictionary *dateInputItem;

@property (nonatomic, strong) NSMutableDictionary *editTempItems;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, strong) NSString *nameBackupText;
@property (nonatomic, strong) NSString *noteBackupText;

@end

NSString *const A3WalletItemFieldCellID4 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID4 = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemFieldTwoValueCellID4 = @"A3WalletItemFieldTwoValueCell";
NSString *const A3WalletItemFieldCateCellID4 = @"A3WalletItemFieldCateCell";
NSString *const A3WalletItemRightIconCellID4 = @"A3WalletItemRightIconCell";
NSString *const A3WalletItemNoteCellID4 = @"A3WalletNoteCell";
NSString *const A3WalletItemDateInputCellID4 = @"A3WalletDateInputCell";
NSString *const A3WalletItemDateCellID4 = @"A3WalletItemFieldCell";
NSString *const A3WalletItemFieldDeleteCellID4 = @"A3WalletItemFieldDeleteCell";


@implementation A3WalletItemEditViewController
{
    NSIndexPath *currentIndexPath;
    UITextField *firstResponder;
    WalletFieldItem *currentItem;
    CGRect cellRectInView;
    
    BOOL _isEdited;
    BOOL _isCategoryChanged;
    
    float textViewHeight;
    
    NSIndexPath *dateInputIndexPath;
    NSDate *preDate;

    BOOL getLocation;
    
    WalletCategory *orgCategory;
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
    
    self.navigationItem.title = @"Edit Item";
    
    [self makeBackButtonEmptyArrow];
    [self rightBarButtonDoneButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
	self.tableView.tableHeaderView = self.headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    
    orgCategory = self.item.category;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)fieldItems
{
    if (!_fieldItems) {
        
        // Item이 만들어진 이후에 Category가 편집되어 새로운 field가 생겼을수가 있다.
        // 따라서, 편집모드에서는 기존의 fieldItem 이외에 새로 추가된 field의 fieldItem를 초기화해서 추가해야 한다.
        
        NSMutableArray *fieldItems = [[NSMutableArray alloc] initWithArray:_item.fieldItems.allObjects];
        NSMutableArray *editedFieldItems = [[NSMutableArray alloc] initWithArray:self.editTempItems.allValues];
        NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:_item.category.fields.allObjects];
        
        // 카테고리가 변경된 경우를 대비하여, fieldItem을 만드는 기준은 현재 카테고리에서 뽑은 fields를 기준으로한다.
        // 그리고, fieldItemd을 뽑는 기준은 editTempItems를 먼저, 그다음 fieldItems로 한다.
        
        NSMutableArray *container = [NSMutableArray new];
        for (int i=0; i<fields.count; i++) {
            WalletField *field = fields[i];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"field==%@", field];
            NSArray *pickedFromEdited = [editedFieldItems filteredArrayUsingPredicate:predicate];
            if (pickedFromEdited.count>0) {
                [container addObject:pickedFromEdited[0]];
            }
            else {
                NSArray *pickedFromFieldItems = [fieldItems filteredArrayUsingPredicate:predicate];
                if (pickedFromFieldItems.count>0) {
                    [container addObject:pickedFromFieldItems[0]];
                }
                else {
                    WalletFieldItem *toAddFieldItem = [WalletFieldItem MR_createEntity];
                    toAddFieldItem.field = field;
                    toAddFieldItem.walletItem = _item;
                    [container addObject:toAddFieldItem];
                }
            }
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"field.order" ascending:YES];
        _fieldItems = [[NSMutableArray alloc] initWithArray:[container sortedArrayUsingDescriptors:@[sortDescriptor]]];
        
        [_fieldItems insertObject:self.categoryItem atIndex:0];
        [_fieldItems addObject:self.noteItem];
//        [_fieldItems addObject:self.deleteItem];
    }
    
    return _fieldItems;
}

- (NSMutableDictionary *)editTempItems
{
    if (!_editTempItems) {
        _editTempItems = [[NSMutableDictionary alloc] init];
    }
    
    return _editTempItems;
}

- (NSMutableDictionary *)dateInputItem
{
    if (!_dateInputItem) {
        _dateInputItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"dateInput", @"order":@""}];
    }
    
    return _dateInputItem;
}

- (NSMutableDictionary *)noteItem
{
    if (!_noteItem) {
        _noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Note", @"order":@""}];
    }
    
    return _noteItem;
}

- (NSMutableDictionary *)deleteItem
{
    if (!_deleteItem) {
        _deleteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"Delete", @"order":@""}];
    }
    
    return _deleteItem;
}

- (NSMutableDictionary *)categoryItem
{
    if (!_categoryItem) {
		_categoryItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"category", @"order":@""}];
	}
	return _categoryItem;
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
    [_item setFavor:![_item isFavored]];
    _headerView.favorButton.selected = [_item isFavored];
}

- (void)updateTopInfo
{
    NSString *titleTxt;
    if (self.nameBackupText) {
        titleTxt = _nameBackupText;
    } else {
        titleTxt = _item.name;
    }
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
    
    _isEdited = YES;
    
    WalletFieldItem *fieldItem = _fieldItems[dateInputIndexPath.row];
    
    //fieldItem.date = sender.date;
    
    // 이전 임시 fieldItem이 있으면 지운다.
    if (self.editTempItems[fieldItem.field.uniqueID]) {
        WalletFieldItem *preEditedFieldItem = _editTempItems[fieldItem.field.uniqueID];
        [preEditedFieldItem deleteAndClearRelated];
        
        [self.editTempItems removeObjectForKey:fieldItem.field.uniqueID];
    }
    
    // editTempItem에 새로운 값을 만들어서 저장한다.
    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
    editFieldItem.field = fieldItem.field;
    editFieldItem.walletItem = self.item;
    editFieldItem.date = sender.date;
    [self.editTempItems setObject:editFieldItem forKey:fieldItem.field.uniqueID];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (void)cancelButtonAction:(id)sender
{
    [self.locationManager stopUpdatingLocation];
    
    // category 원위치
    if (self.item.category != orgCategory) {
        self.item.category = orgCategory;

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    }
    
    // 입력중인거 완료
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }

    // item 원상태로 되돌리기
    if ([_item hasChanges]) {
        [_item.managedObjectContext refreshObject:_item mergeChanges:NO];
    }
    
    // 임시 fieldItem 지우기
    for (int i=0; i<_editTempItems.allKeys.count; i++) {
        NSString *key = _editTempItems.allKeys[i];
        WalletFieldItem *fieldItem = _editTempItems[key];
        NSLog(@"%@", key);
        [fieldItem deleteAndClearRelated];

    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)doneButtonAction:(UIBarButtonItem *)button
{
    [self.locationManager stopUpdatingLocation];

    // 입력중인거 완료
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
    
    NSString *title = _item.name;
    if ([self isItemDataEmpty] && title.length==0) {
        // 입력 데이타 없음
        return;
    }
    
    if (_isEdited) {

        // name, note 반영하기
        if (self.nameBackupText) {
            _item.name = _nameBackupText;
        }
        if (self.noteBackupText) {
            _item.note = _noteBackupText;
        }

        
        // 변경된 fieldItem 반영하기
        _fieldItems = nil; //  다시 읽어온다. (item.fieldItems, editTempItems, 카테고리에 추가된 item들을 기준으로 새로 만들기)
        
        for (int i=0; i<self.fieldItems.count; i++) {
            if ([_fieldItems[i] isKindOfClass:[WalletFieldItem class]]) {
                WalletFieldItem *fieldItem = _fieldItems[i];
                if ([self.editTempItems.allValues containsObject:fieldItem]) {
                    [_item addFieldItemsObject:fieldItem];
                }
                else if ([_item.fieldItems.allObjects containsObject:fieldItem]) {
                    // do nothing
                }
                else {
                    [_item addFieldItemsObject:fieldItem];
                }
            }
        }
        
        // self.fieldItems에 없는 _item.fieldItems는 제거한다.
        NSArray *itemFieldItems = _item.fieldItems.allObjects;
        for (int i=0; i<itemFieldItems.count; i++) {
            WalletFieldItem *fieldItem = itemFieldItems[i];
            if (![self.fieldItems containsObject:fieldItem]) {
                [_item removeFieldItemsObject:fieldItem];
                [fieldItem deleteAndClearRelated];
            }
        }

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
        if (_delegate && [_delegate respondsToSelector:@selector(walletItemEdited:)]) {
            [_delegate walletItemEdited:_item];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaButtonAction:(UIButton *)sender
{
    // 다시 사진을 선택하도록 한다. (해당 테이블 셀을 눌렀을때와 동일한 프로세스로 동작하면 됨)
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:ip];
}

- (void)mediaClearButtonAction:(UIButton *)sender
{
    if ([_fieldItems[sender.tag] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _fieldItems[sender.tag];
        if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
            NSString *imagePath = fieldItem.filePath;
            if (imagePath.length > 0) {
                [WalletData deleteFileAtPath:imagePath];
                NSString *thumb = [WalletData thumbImgPathOfImgPath:imagePath];
                [WalletData deleteFileAtPath:thumb];
            }
            
            fieldItem.filePath = @"";
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
            
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
        }
        else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
            NSString *videoPath = fieldItem.filePath;
            if (videoPath.length > 0) {
                [WalletData deleteFileAtPath:videoPath];
                NSString *thumb = [WalletData thumbImgPathOfVideoPath:videoPath];
                [WalletData deleteFileAtPath:thumb];
            }
            
            fieldItem.filePath = @"";
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
            
            [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)deleteMediaItem
{
    NSUInteger index = currentIndexPath.row;
    if ([_fieldItems[index] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _fieldItems[index];
        
        // 이전 임시 fieldItem이 있으면 지운다.
        if (self.editTempItems[fieldItem.field.uniqueID]) {
            WalletFieldItem *preEditedFieldItem = _editTempItems[fieldItem.field.uniqueID];
            [preEditedFieldItem deleteAndClearRelated];
            
            [self.editTempItems removeObjectForKey:fieldItem.field.uniqueID];
        }
        
        // editTempItem에 새로운 값을 만들어서 저장한다.
        WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
        editFieldItem.field = fieldItem.field;
        editFieldItem.walletItem = self.item;
        [self.editTempItems setObject:editFieldItem forKey:fieldItem.field.uniqueID];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        
        [self.tableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    if (_item.name.length>0) {
        return NO;
    }
    
    if (_item.note.length>0) {
        return NO;
    }
    
    NSArray *items = _item.fieldItems.allObjects;
    for (int i=0; i<items.count; i++) {
        WalletFieldItem *item = items[i];
        if ([item.field.name isEqualToString:WalletFieldTypeDate]) {
            if (item.date) {
                return NO;
            }
        }
        else if ([item.field.name isEqualToString:WalletFieldTypeImage] || [item.field.name isEqualToString:WalletFieldTypeVideo]) {
            if (item.filePath.length > 0) {
                return NO;
            }
        }
        else {
            if (item.value.length > 0) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)exchangeDatePickerFromIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to
{
    [self.tableView beginUpdates];
    NSUInteger idx = [_fieldItems indexOfObject:self.dateInputItem];
    [_fieldItems removeObject:self.dateInputItem];
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    dateInputIndexPath = nil;
    [self.tableView endUpdates];
    
    [self.tableView beginUpdates];
    if (from.row < to.row) {
        to = [NSIndexPath indexPathForRow:to.row-1 inSection:0];
    }
    dateInputIndexPath = to;
    [_fieldItems insertObject:self.dateInputItem atIndex:dateInputIndexPath.row+1];
    [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateInputIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)datePickerActiveFromIndexPath:(NSIndexPath *)dateIndexPath
{
    if (![_fieldItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        dateInputIndexPath = dateIndexPath;
        
        [_fieldItems insertObject:self.dateInputItem atIndex:dateIndexPath.row+1];
        [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dateIndexPath.row+1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)dismissDatePicker
{
    if ([_fieldItems containsObject:self.dateInputItem]) {
        [self.tableView beginUpdates];
        
        NSUInteger idx = [_fieldItems indexOfObject:self.dateInputItem];
        [_fieldItems removeObject:self.dateInputItem];
        [self.tableView reloadRowsAtIndexPaths:@[dateInputIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        dateInputIndexPath = nil;
        [self.tableView endUpdates];
    }
}

- (void)changeCategory:(WalletCategory *)toCategorry
{
    // 카테고리 변경
    // 같은 이름 필드는 값 입력
    // 나머지는 노트에 추가
    
    // 일반 필드는 item에 입력하고, walletFieldItem은 _editTempItems 에 저장한다.
    
    /*
     @property (nonatomic, retain) NSDate * modificationDate;
     @property (nonatomic, retain) NSString * name;
     @property (nonatomic, retain) NSString * note;
     @property (nonatomic, retain) NSString * order;
     @property (nonatomic, retain) WalletCategory *category;
     @property (nonatomic, retain) NSSet *fieldItems;
     */
    
    
    
    // name, order 변경안됨
    // category를 바꾼걸로
    _item.category = toCategorry;
    
    // 현재 변경중인 field item 정보를, 새로운 카테고리에 해당하는 field item으로 바꾼다.
    
    
    NSArray *cateFields = [toCategorry fieldsArray];
    NSMutableDictionary *cateNewEditTempItems = [NSMutableDictionary new];
    
    NSMutableArray *orgItems = [[NSMutableArray alloc] initWithArray:self.item.fieldItems.allObjects];
    NSMutableArray *addedItems = [NSMutableArray new];
    
    for (int i=0; i < cateFields.count; i++) {
        WalletField *cateField = cateFields[i];
        
        // items에 동일한 이름의 값이 있는지 체크하고, 타입을 비교하여, 데이타를 옮길수 잇는 아이템들을 뽑아낸다.
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"field.name==%@", cateField.name];
        NSArray *tmp = [orgItems filteredArrayUsingPredicate:predicate];
        if (tmp.count>0) {
            WalletFieldItem *tempFieldItem = tmp[0];
            if ([cateField.type isEqualToString:WalletFieldTypeDate]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.date = tempFieldItem.date;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else if ([cateField.type isEqualToString:WalletFieldTypeImage]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.filePath = tempFieldItem.filePath;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else if ([cateField.type isEqualToString:WalletFieldTypeVideo]) {
                if ([tempFieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.filePath = tempFieldItem.filePath;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
            else {
                if (![tempFieldItem.field.type isEqualToString:WalletFieldTypeDate] && ![tempFieldItem.field.type isEqualToString:WalletFieldTypeImage] && ![tempFieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                    
                    // editTempItem에 새로운 값을 만들어서 저장한다.
                    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
                    editFieldItem.field = cateField;
                    editFieldItem.walletItem = self.item;
                    editFieldItem.value = tempFieldItem.value;
                    [cateNewEditTempItems setObject:editFieldItem forKey:cateField.uniqueID];
					[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
                    
                    [addedItems addObject:tempFieldItem];
                }
            }
        }
        else {
            // 기존에 item이 없으면 새로이 fieldItem을 만들고 초기화하여 editTempItems에 저장한다
            WalletFieldItem *madeFieldItem = [WalletFieldItem MR_createEntity];
            madeFieldItem.field = cateField;
            madeFieldItem.walletItem = self.item;
            [cateNewEditTempItems setObject:madeFieldItem forKey:cateField.uniqueID];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    
    // 기존에 editTempItems를 초기화한다.
    for (WalletFieldItem *fieldItem in self.editTempItems) {
        [fieldItem deleteAndClearRelated];
    }
    self.editTempItems = cateNewEditTempItems;
    
    // 데이타가 있는 item들중에 옮겨지지 않은 데이타는 note에 텍스트로 기록한다.
    [orgItems removeObjectsInArray:addedItems];
    
    NSMutableString *mString = [NSMutableString new];
    for (int i = 0; i<orgItems.count; i++) {
        WalletFieldItem *remainItem = orgItems[i];
        if (remainItem.value.length > 0) {
            NSString *tmpText = [NSString stringWithFormat:@"%@ : %@\n", remainItem.field.name, remainItem.value];
            [mString appendString:tmpText];
        }
    }
    if (mString.length > 0) {
        self.item.note = mString;
    }
    
    // 정보 불러오기
    _fieldItems = nil;
    [self.tableView reloadData];
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
    
//    WalletFieldItem *fieldItem = self.fieldItems[currentIndexPath.row];
    WalletFieldItem *fieldItem = currentItem;
    
    // 이전 임시 fieldItem이 있으면 지운다.
    if (self.editTempItems[fieldItem.field.uniqueID]) {
        WalletFieldItem *preEditedFieldItem = _editTempItems[fieldItem.field.uniqueID];
        [preEditedFieldItem deleteAndClearRelated];
        
        [self.editTempItems removeObjectForKey:fieldItem.field.uniqueID];
    }
    
    // editTempItem에 새로운 값을 만들어서 저장한다.
    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
    editFieldItem.field = fieldItem.field;
    editFieldItem.walletItem = self.item;
    editFieldItem.filePath = filePath;
    [self.editTempItems setObject:editFieldItem forKey:fieldItem.field.uniqueID];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    NSInteger idx = [self.fieldItems indexOfObject:fieldItem];
    NSIndexPath *cip = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[cip] withRowAnimation:UITableViewRowAnimationFade];
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
    
    //    WalletFieldItem *fieldItem = self.fieldItems[currentIndexPath.row];
    WalletFieldItem *fieldItem = currentItem;
    
    // 이전 임시 fieldItem이 있으면 지운다.
    if (self.editTempItems[fieldItem.field.uniqueID]) {
        WalletFieldItem *preEditedFieldItem = _editTempItems[fieldItem.field.uniqueID];
        [preEditedFieldItem deleteAndClearRelated];
        
        [self.editTempItems removeObjectForKey:fieldItem.field.uniqueID];
    }
    
    // editTempItem에 새로운 값을 만들어서 저장한다.
    WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
    editFieldItem.field = fieldItem.field;
    editFieldItem.walletItem = self.item;
    editFieldItem.filePath = imageFilePath;
    [self.editTempItems setObject:editFieldItem forKey:fieldItem.field.uniqueID];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
    
    NSInteger idx = [self.fieldItems indexOfObject:fieldItem];
    NSIndexPath *cip = [NSIndexPath indexPathForRow:idx inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[cip] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)imageEditInfo {
    @autoreleasepool {
        
        _isEdited = YES;
        
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
            
            // Remove the picker interface and release the picker object.
            [picker dismissViewControllerAnimated:YES completion:NULL];
            
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
                [picker dismissViewControllerAnimated:YES completion:NULL];
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
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
    
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        if (actionSheet.tag ==1 || actionSheet.tag == 2) {
            // 삭제하기
            [self deleteMediaItem];
            
            _isEdited = YES;
            
            return;
        }
        else if (actionSheet.tag == 3) {
            
            [self.item deleteAndClearRelated];
			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
            [self dismissViewControllerAnimated:NO completion:NULL];
            
            if (_delegate && [_delegate respondsToSelector:@selector(WalletItemDeleted)]) {
                [_delegate WalletItemDeleted];
            }
            
            return;
        }
    }
    
	NSInteger myButtonIndex = buttonIndex;
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		myButtonIndex++;
    if (actionSheet.destructiveButtonIndex>=0)
        myButtonIndex--;
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
    else if (actionSheet.tag == 3) {
        for (UIView *subview in actionSheet.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                if ([[button titleForState:UIControlStateNormal] isEqualToString:NSLocalizedStringFromTable(@"Delete Item", @"common", nil)]) {
                    
                    [button setTitleColor:[UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                    
                }
            }
        }
    }
}

#pragma mark - CategorySelect delegate
- (void)walletCategorySelected:(WalletCategory *) category
{
    FNLOG(@"walletCategorySelected : %@", category.name);
    
    if (_item.category != category) {
        FNLOG(@"Change category");
        
        [self changeCategory:category];
    }
}

#pragma mark - UITextFieldDelegate

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
    
    if ([_fieldItems objectAtIndex:startIdx] == self.noteItem) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:startIdx inSection:0];
        A3WalletNoteCell *noteCell = (A3WalletNoteCell *)[self.tableView cellForRowAtIndexPath:ip];
        [noteCell.textView becomeFirstResponder];
    }
    else {
        for (NSUInteger i = startIdx; i < _fieldItems.count; i++) {
            if ([[_fieldItems objectAtIndex:i] isKindOfClass:[WalletFieldItem class]]) {
                WalletFieldItem *fieldItem = [_fieldItems objectAtIndex:i];
                
                if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                }
                else if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                }
                else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                }
                else {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                    A3WalletItemFieldCell *inputCell = (A3WalletItemFieldCell* )[self.tableView cellForRowAtIndexPath:ip];
                    [inputCell.valueTextField becomeFirstResponder];
                    break;
                }
            }
        }
    }
    
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    
    BOOL isInputData = NO;
    
    if (self.nameBackupText.length > 0) {
        isInputData = YES;
    }
    else {
        
        for (int i=0; i<[self.tableView numberOfSections]; i++) {
            if (isInputData) {
                break;
            }
            for (int j=0; j<[self.tableView numberOfRowsInSection:i]; j++) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                if ([cell isKindOfClass:[A3WalletItemFieldCell class]]) {
                    if (((A3WalletItemFieldCell *)cell).valueTextField.text.length > 0) {
                        isInputData = YES;
                        break;
                    }
                }
            }
        }
        
    }
    
    self.navigationItem.rightBarButtonItem.enabled = isInputData;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    firstResponder = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

    _isEdited = YES;
    
    // update
    if (textField == _headerView.titleTextField) {
        //  title
        self.nameBackupText = textField.text;
    }
    else {
        if ([_fieldItems[currentIndexPath.row] isKindOfClass:[WalletFieldItem class]]) {
            WalletFieldItem *fieldItem = _fieldItems[currentIndexPath.row];
            //fieldItem.value = textField.text;
            
            // 변경사항이 없으면, 무시한다.
            if ([fieldItem.value isEqualToString:textField.text]) {
                return;
            }
            
            // 이전 임시 fieldItem이 있으면 지운다.
            if (self.editTempItems[fieldItem.field.uniqueID]) {
                WalletFieldItem *preEditedFieldItem = _editTempItems[fieldItem.field.uniqueID];
                [preEditedFieldItem deleteAndClearRelated];
                
                [self.editTempItems removeObjectForKey:fieldItem.field.uniqueID];
            }
            
            // editTempItem에 새로운 값을 만들어서 저장한다.
            WalletFieldItem *editFieldItem = [WalletFieldItem MR_createEntity];
            editFieldItem.field = fieldItem.field;
            editFieldItem.walletItem = self.item;
            editFieldItem.value = textField.text;
            [self.editTempItems setObject:editFieldItem forKey:editFieldItem.field.uniqueID];

			[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    firstResponder = textField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self dismissDatePicker];

	currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"current text field indexpath : %@", [currentIndexPath description]);

	if ([self.fieldItems objectAtIndex:currentIndexPath.row] == self.noteItem) {
		// note
		textField.keyboardType = UIKeyboardTypeDefault;
	}
	else if ([[self.fieldItems objectAtIndex:currentIndexPath.row] isKindOfClass:[WalletFieldItem class]]) {

		WalletFieldItem *fieldItem = [_fieldItems objectAtIndex:currentIndexPath.row];
		if ([fieldItem.field.type isEqualToString:WalletFieldTypeText]) {
			textField.keyboardType = UIKeyboardTypeDefault;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([fieldItem.field.type isEqualToString:WalletFieldTypeNumber]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([fieldItem.field.type isEqualToString:WalletFieldTypePhone]) {
			textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([fieldItem.field.type isEqualToString:WalletFieldTypeURL]) {
			textField.keyboardType = UIKeyboardTypeURL;
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		else if ([fieldItem.field.type isEqualToString:WalletFieldTypeEmail]) {
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

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self dismissDatePicker];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _isEdited = YES;
    
    _item.note = textView.text;
    
    [self.tableView beginUpdates];
    
    CGRect frame = textView.frame;
    frame.size.height = textView.contentSize.height+25;
    textView.frame = frame;
    
    textViewHeight = frame.size.height;
    
    [self.tableView endUpdates];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.noteBackupText = textView.text;
    
    self.navigationItem.rightBarButtonItem.enabled = ![self isItemDataEmpty];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (firstResponder) {
        [firstResponder resignFirstResponder];
    }
    
    if (indexPath.section == 0) {
        if ([self.fieldItems objectAtIndex:indexPath.row] == self.categoryItem) {
            // category
            A3WalletCategorySelectViewController *viewController = [[A3WalletCategorySelectViewController alloc] initWithStyle:UITableViewStyleGrouped];
            viewController.selectedCategory = _item.category;
            viewController.delegate = self;
            
            if (IS_IPHONE) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                A3RootViewController_iPad *rootViewController = [[A3AppDelegate instance] rootViewController];
                [rootViewController presentRightSideViewController:viewController];
            }
            
            
        }
        else if ([[self.fieldItems objectAtIndex:indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
            
            WalletFieldItem *fieldItem = [_fieldItems objectAtIndex:indexPath.row];
            
            if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                
                preDate = fieldItem.date;
                
                if ([_fieldItems containsObject:self.dateInputItem]) {
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
            }
            else if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                //            currentIndexPath = indexPath;
                currentItem = fieldItem;
                
                NSString *filePath = fieldItem.filePath;
                filePath.length>0 ? [self askImagePickupWithDelete:YES] : [self askImagePickupWithDelete:NO];
                [self dismissDatePicker];
                
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
            else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                //            currentIndexPath = indexPath;
                currentItem = fieldItem;
                
                NSString *filePath = fieldItem.filePath;
                filePath.length>0 ? [self askVideoPickupWithDelete:YES] : [self askVideoPickupWithDelete:NO];
                [self dismissDatePicker];
                
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
    }
    else {
        // delete category
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Item"
                                                        otherButtonTitles:nil];
        actionSheet.tag = 3;
        [actionSheet showInView:self.view];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return self.fieldItems.count;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.fieldItems objectAtIndex:indexPath.row] == self.noteItem) {
            
            NSDictionary *textAttributes = @{
                                             NSFontAttributeName : [UIFont systemFontOfSize:17]
                                             };
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
            UITextView *txtView = [[UITextView alloc] init];
            [txtView setAttributedText:attributedString];
            float margin = IS_IPAD ? 49:31;
            CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
            float cellHeight = txtViewSize.height + 20;
            
            if (cellHeight < 180) {
                return 180;
            }
            else {
                return cellHeight;
            }
        }
        else if ([self.fieldItems objectAtIndex:indexPath.row] == self.dateInputItem) {
            
            return 218;
        }
        else if (indexPath.row == 0) {
            
            return IS_RETINA ? 74.5 : 75.0;
        }
        
        return 74.0;
    }
    else {
        
        // delete
        return IS_RETINA ? 36.5 : 37;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
	@autoreleasepool {
		cell = nil;
        
        if (indexPath.section == 0) {
            if ([self.fieldItems objectAtIndex:indexPath.row] == self.categoryItem) {
                // category
                A3WalletItemFieldCateCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCateCellID4 forIndexPath:indexPath];
                
                inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self configureFloatingTextField:inputCell.valueTextField];
                
                inputCell.valueTextField.floatingLabelFont = [UIFont systemFontOfSize:14];
                inputCell.valueTextField.font = [UIFont systemFontOfSize:17];
                inputCell.valueTextField.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
                inputCell.valueTextField.enabled = NO;
                inputCell.valueTextField.placeholder = @"Category";
                inputCell.valueTextField.text = _item.category.name;
                
                cell = inputCell;
            }
            else if ([self.fieldItems objectAtIndex:indexPath.row] == self.noteItem) {
                // note
                A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemNoteCellID4 forIndexPath:indexPath];
                
                noteCell.selectionStyle = UITableViewCellSelectionStyleNone;
                noteCell.textView.delegate = self;
                noteCell.textView.bounces = NO;
                noteCell.textView.placeholder = @"Notes";
                noteCell.textView.placeholderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                noteCell.textView.font = [UIFont systemFontOfSize:17];

                if (self.noteBackupText) {
                    noteCell.textView.text = _noteBackupText;
                } else {
                    noteCell.textView.text = _item.note;
                }
                
                cell = noteCell;
            }
            else if ([self.fieldItems objectAtIndex:indexPath.row] == self.dateInputItem) {
                // date input cell
                A3WalletDateInputCell *dateInputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateInputCellID4 forIndexPath:indexPath];
                dateInputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dateInputCell.datePicker.date = preDate;
                dateInputCell.datePicker.datePickerMode = UIDatePickerModeDate;
                [dateInputCell.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
                
                cell = dateInputCell;
            }
            else if ([[self.fieldItems objectAtIndex:indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
                
                // 새로 변경된 fieldItem이 있으면 보여주고, 없으면 원래 fieldItem을 보여준다.
                
                WalletFieldItem *fieldItem;
                
                WalletFieldItem *orgFieldItem = [_fieldItems objectAtIndex:indexPath.row];
                if (self.editTempItems[orgFieldItem.field.uniqueID]) {
                    fieldItem = _editTempItems[orgFieldItem.field.uniqueID];
                }
                else {
                    fieldItem = orgFieldItem;
                }
                
                if ([fieldItem.field.type isEqualToString:WalletFieldTypeDate]) {
                    
                    A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemDateCellID4 forIndexPath:indexPath];
                    
                    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [self configureFloatingTextField:inputCell.valueTextField];
                    
                    inputCell.valueTextField.enabled = NO;
                    inputCell.valueTextField.placeholder = fieldItem.field.name;
                    
                    if ([fieldItem.date isKindOfClass:[NSDate class]]) {
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"MMM dd, YYYY hh:mm a"];
                        inputCell.valueTextField.text = [df stringFromDate:fieldItem.date];
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
                else if ([fieldItem.field.type isEqualToString:WalletFieldTypeImage]) {
                    
                    NSString *filePath = fieldItem.filePath;
                    if (filePath.length  > 0) {
                        
                        A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];
                        
                        photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [self configureFloatingTextField:photoCell.valueTxtFd];
                        
                        photoCell.valueTxtFd.placeholder = fieldItem.field.name;
                        photoCell.valueTxtFd.enabled = NO;
                        
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
                        A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID4 forIndexPath:indexPath];
                        
                        iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        iconCell.titleLabel.text = fieldItem.field.name;
                        iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                        iconCell.iconImgView.image = [UIImage imageNamed:@"camera"];
                        
                        cell = iconCell;
                    }
                }
                else if ([fieldItem.field.type isEqualToString:WalletFieldTypeVideo]) {
                    
                    NSString *filePath = fieldItem.filePath;
                    if (filePath.length  > 0) {
                        
                        A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID4 forIndexPath:indexPath];
                        
                        photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [self configureFloatingTextField:photoCell.valueTxtFd];
                        
                        photoCell.valueTxtFd.placeholder = fieldItem.field.name;
                        photoCell.valueTxtFd.enabled = NO;
                        
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
                        A3WalletItemRightIconCell *iconCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemRightIconCellID4 forIndexPath:indexPath];
                        
                        iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        iconCell.titleLabel.text = fieldItem.field.name;
                        iconCell.titleLabel.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
                        iconCell.iconImgView.image = [UIImage imageNamed:@"video"];
                        
                        cell = iconCell;
                    }
                }
                else {
                    
                    A3WalletItemFieldCell *inputCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID4 forIndexPath:indexPath];
                    
                    inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [self configureFloatingTextField:inputCell.valueTextField];
                    
                    inputCell.valueTextField.tag = 0;
                    inputCell.valueTextField.placeholder = fieldItem.field.name;
                    inputCell.valueTextField.text = fieldItem.value;
                    
                    cell = inputCell;
                }
                
            }
        }
        else {
            UITableViewCell *deleteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldDeleteCellID4 forIndexPath:indexPath];
            deleteCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = deleteCell;
        }
	}
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSUInteger numberSection = [tableView numberOfSections];
    
    float lastFooterHeight = 38.0;
    
    if (section == (numberSection-1)) {
        return lastFooterHeight;
    }
    else {
        return IS_RETINA ? 34.0 : 34.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else {
        return 1.0;
    }
}

@end

