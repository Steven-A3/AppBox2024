//
//  A3QRCodeViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/7/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeViewController.h"
#import "A3AppDelegate.h"
#import "QRCodeHistory.h"
#import "A3QRCodeHistoryViewController.h"
#import "A3NavigationController.h"
#import "UIViewController+A3Addition.h"
#import "AFHTTPRequestOperation.h"
#import "A3QRCodeDetailViewController.h"
#import "RSCornersView.h"
#import "A3QRCodeDataHandler.h"
#import "A3QRCodeScanLineView.h"
#import "A3CornersView.h"
#import "A3UserDefaults.h"
#import "A3InstructionViewController.h"
#import "A3BasicWebViewController.h"
#import "A3UIDevice.h"
#import "Reachability.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "NSManagedObjectContext+MagicalRecord.h"
#import "A3QRCodeTextViewController.h"
#import "UIImage+imageWithColor.h"

NSString *const A3QRCodeSettingsPlayAlertSound = @"A3QRCodeSettingsPlayAlertSound";
NSString *const A3QRCodeSettingsPlayVibrate = @"A3QRCodeSettingsPlayVibrate";
NSString *const A3QRCodeImageSoundOn = @"sound_on";
NSString *const A3QRCodeImageSoundOff = @"sound_off";
NSString *const A3QRCodeImageVibrateOn = @"vibrate_on";
NSString *const A3QRCodeImageVibrateOff = @"vibrate_off";
NSString *const A3QRCodeImageTorchOn = @"m_flash_on";
NSString *const A3QRCodeImageTorchOff = @"m_flash_off";

@interface A3QRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, A3InstructionViewControllerDelegate,
		A3QRCodeDataHandlerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *statusToolbar;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbarWithoutVibrate;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbarSoundOnly;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *vibrateOnOffButton;
@property (nonatomic, weak) IBOutlet A3CornersView *cornersView;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) A3QRCodeDataHandler *dataHandler;
@property (nonatomic, strong) AVAudioPlayer *beepPlayer;
@property (nonatomic, strong) A3QRCodeScanLineView *scanLineView;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomToolbarBottomSpaceConstraint;
@property (nonatomic, copy) NSString *barcodeToSearch;
@property (nonatomic, assign) BOOL scanHandlerInProgress;
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray *soundOnOffButtons;
@property (nonatomic, strong) IBOutletCollection(UIBarButtonItem) NSArray *torchOnOffButtons;

@end

@implementation A3QRCodeViewController {
	BOOL _googleSearchInProgress;
	BOOL _viewWillAppearFirstRunAfterLoad;
	BOOL _scanIsRunning;
	BOOL _scanAnimationInProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	_viewWillAppearFirstRunAfterLoad = YES;
	[self.navigationController setNavigationBarHidden:YES];
	self.isCornersVisible = NO;
	self.stopOnFirst = YES;

	[self makeBackButtonEmptyArrow];
	[self setupBarcodeHandler];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:@{A3QRCodeSettingsPlayVibrate : @YES,
									 A3QRCodeSettingsPlayAlertSound : @YES}];

	[_soundOnOffButtons enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[obj setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayAlertSound] ? A3QRCodeImageSoundOn : A3QRCodeImageSoundOff]];
	}];
		[_vibrateOnOffButton setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayVibrate] ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
													initWithTarget:self
													action:@selector(handleTapGesture:)];
	[_cornersView addGestureRecognizer:tapGestureRecognizer];

	if (IS_IPAD) {
		[_topToolbar setHidden:YES];
		[_topToolbarSoundOnly setHidden:NO];
	} else if (![A3UIDevice canVibrate]) {
		[_topToolbar setHidden:YES];
		[_topToolbarWithoutVibrate setHidden:NO];
	}
	
	[self setupScanLineView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

	UIImage *image = [UIImage toolbarBackgroundImage];
	[_topToolbar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_topToolbar setShadowImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny];
	[_topToolbarWithoutVibrate setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_topToolbarSoundOnly setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_bottomToolbar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[_statusToolbar setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)applicationDidBecomeActive {
	[self animateScanLine];
}

- (void)applicationDidEnterBackground {
	[self stopRunning];
	_scanAnimationInProgress = NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES];
	[self.navigationController setToolbarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	if (_viewWillAppearFirstRunAfterLoad) {
		_viewWillAppearFirstRunAfterLoad = NO;
		[self setupInstructionView];
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDQRCode keywords:@[@"Low Price", @"Shopping", @"Marketing"] gender:kGADGenderUnknown adSize:IS_IPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard];
	} else {
		if (IS_IOS7) {
			double delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self stopRunning];
				
				double delayInSeconds = 0.2;
				dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self startRunning];
				});
			});
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self startRunning];
	[self animateScanLine];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self stopRunning];
	_scanAnimationInProgress = NO;
	if (self.torchState) {
		[self torchOnOff:nil];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (IBAction)appsButtonAction:(id)sender {
	if (IS_IPHONE) {
		if ([[A3AppDelegate instance] isMainMenuStyleList]) {
			[[A3AppDelegate instance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
		} else {
			UINavigationController *navigationController = [A3AppDelegate instance].currentMainNavigationController;
			[navigationController popViewControllerAnimated:YES];
			[navigationController setToolbarHidden:YES];
		}
	} else {
		[[[A3AppDelegate instance] rootViewController_iPad] toggleLeftMenuViewOnOff];
	}
}

- (IBAction)torchOnOff:(id)sender {
	[self toggleTorch];
	[_torchOnOffButtons enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
		[button setImage:[UIImage imageNamed:self.torchState ? A3QRCodeImageTorchOn : A3QRCodeImageTorchOff]];
	}];
}

- (IBAction)vibrateOnOff:(id)sender {
	BOOL vibrateOn = [[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayVibrate];
	vibrateOn = !vibrateOn;
	[[NSUserDefaults standardUserDefaults] setBool:vibrateOn forKey:A3QRCodeSettingsPlayVibrate];
	[self.vibrateOnOffButton setImage:[UIImage imageNamed:vibrateOn ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
}

- (IBAction)scanFromImage:(id)sender {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
														message:NSLocalizedString(@"It will detect 2D Barcodes(QR Code, Aztec Code, Data Matrix) from the image. It will not detect 1D barcodes.", @"It will detect 2D Barcodes(QR Code, Aztec Code, Data Matrix) from the image. It will not detect 1D barcodes.")
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
											  otherButtonTitles:nil];

	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)historyButtonAction:(id)sender {
	A3QRCodeHistoryViewController *historyViewController = [A3QRCodeHistoryViewController new];
	A3NavigationController *navigationController = [[A3NavigationController alloc] initWithRootViewController:historyViewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)soundOnOff:(id)sender {
	BOOL soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayAlertSound];
	soundOn = !soundOn;
	[[NSUserDefaults standardUserDefaults] setBool:soundOn forKey:A3QRCodeSettingsPlayAlertSound];
	
	[_soundOnOffButtons enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
		[button setImage:[UIImage imageNamed:soundOn ? A3QRCodeImageSoundOn: A3QRCodeImageSoundOff]];
	}];
}

- (void)setupBarcodeHandler {
	__typeof(self) __weak weakSelf = self;
	self.barcodesHandler = ^(NSArray *barcodeObjects) {
		if (weakSelf.scanHandlerInProgress || ([barcodeObjects count] == 0)) {
			return;
		}
		weakSelf.scanHandlerInProgress = YES;
		dispatch_async(dispatch_get_main_queue(), ^{
			AVMetadataMachineReadableCodeObject *barcode = barcodeObjects[0];
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayAlertSound]) {
				[weakSelf.beepPlayer play];
			}
			if ([[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayVibrate]) {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			}
			NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];
			
			QRCodeHistory *history = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:barcode.stringValue inContext:moc];
			if (history) {
				history.created = [NSDate date];
			} else {
				history = [QRCodeHistory MR_createEntityInContext:moc];
				history.uniqueID = [[NSUUID UUID] UUIDString];
				history.created = [NSDate date];
				history.type = barcode.type;
				history.scanData = barcode.stringValue;
				
				NSArray *qrcodeTypes;
				if (IS_IOS7) {
					qrcodeTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
				} else {
					qrcodeTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
				}
				if ([qrcodeTypes indexOfObject:barcode.type] != NSNotFound) {
					history.dimension = @"2";
				} else {
					history.dimension = @"1";
				}
			}
			
			[moc MR_saveToPersistentStoreAndWait];
			
			if ([history.dimension isEqualToString:@"1"]) {
				if ([[[A3AppDelegate instance] reachability] isReachableViaWiFi]) {
					[weakSelf presentWebViewControllerWithBarCode:history.scanData];
				} else {
					_barcodeToSearch = [history.scanData copy];
					UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																			 delegate:weakSelf
																	cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
															   destructiveButtonTitle:nil
																	otherButtonTitles:NSLocalizedString(@"Search on Google", @"Search on Google"),
												  NSLocalizedString(@"Preview", @"Preview"), nil];
					[actionSheet showInView:weakSelf.view];
				}
			} else {
				[weakSelf.dataHandler performActionWithData:history inViewController:weakSelf];
			}
			
			double delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				weakSelf.scanHandlerInProgress = NO;
			});
		});
	};
}

- (void)presentWebViewControllerWithBarCode:(NSString *)barcode {
	if (![[[A3AppDelegate instance] reachability] isReachable]) {
		[self alertInternetConnectionIsNotAvailable];
		[self startRunning];
		[self animateScanLine];
		return;
	}
	A3BasicWebViewController *viewController = [A3BasicWebViewController new];
	viewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@", barcode]];
	[self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		[self startRunning];
		[self animateScanLine];
		return;
	}
	if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Search on Google", @"Search on Google")]) {
		[self presentWebViewControllerWithBarCode:_barcodeToSearch];
	} else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Preview", @"Preview")]) {
		A3QRCodeTextViewController *viewController = [[A3QRCodeTextViewController alloc] init];
		viewController.text = _barcodeToSearch;
		[self.navigationController setNavigationBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
	CIImage *image = [[CIImage alloc] initWithImage:originalImage];
	NSArray *features = [detector featuresInImage:image];
	CIQRCodeFeature *feature = [features firstObject];
	void(^alertBlock)() = nil;
	if (feature) {
		NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];

		QRCodeHistory *newItem = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:feature.messageString inContext:moc];
		if (newItem) {
			newItem.created = [NSDate date];
		} else {
			newItem = [QRCodeHistory MR_createEntityInContext:moc];
			newItem.uniqueID = [[NSUUID UUID] UUIDString];
			newItem.created = [NSDate date];
			newItem.type = feature.type;
			newItem.scanData = feature.messageString;
			newItem.dimension = @"2";
		}

		[moc MR_saveToPersistentStoreAndWait];

		[self.dataHandler performActionWithData:newItem inViewController:self];

	} else {
		alertBlock = ^() {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
																message:NSLocalizedString(@"QR Code not found.", @"QR Code not found.")
															   delegate:nil
													  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													  otherButtonTitles:nil];
			[alertView show];
		};
	}
	[picker dismissViewControllerAnimated:YES completion:alertBlock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)searchBarcode:(NSString *)barcode {
	FNLOG();
	if (_googleSearchInProgress) {
		return;
	}
	_googleSearchInProgress = YES;
	
	NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=%@", barcode] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

	NSURLRequest *request = [NSURLRequest requestWithURL:url];

	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		if ([JSON[@"responseStatus"] integerValue] == 200) {
			NSManagedObjectContext *moc = [NSManagedObjectContext MR_rootSavingContext];
			QRCodeHistory *history = [QRCodeHistory MR_findFirstByAttribute:@"scanData" withValue:barcode inContext:moc];
			history.searchData = [NSKeyedArchiver archivedDataWithRootObject:JSON];
			[moc MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
				[self presentDetailViewControllerWithData:history];
			}];
		}
		_googleSearchInProgress = NO;
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		_googleSearchInProgress = NO;
	}];

	[operation start];
}

- (void)presentDetailViewControllerWithData:(QRCodeHistory *)data {
	A3QRCodeDetailViewController *viewController = [A3QRCodeDetailViewController new];
	viewController.historyData = data;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (A3QRCodeDataHandler *)dataHandler {
	if (!_dataHandler) {
		_dataHandler = [A3QRCodeDataHandler new];
		_dataHandler.delegate = self;
	}
	return _dataHandler;
}

- (AVAudioPlayer *)beepPlayer {
	if (!_beepPlayer) {
		NSString * wavPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
		NSData* data = [[NSData alloc] initWithContentsOfFile:wavPath];
		_beepPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
	}
	return _beepPlayer;
}

- (void)setupScanLineView {
	FNLOGRECT(_cornersView.bounds);
	_scanLineView = [[A3QRCodeScanLineView alloc] initWithFrame:CGRectMake(0, _cornersView.bounds.size.height - 60, _cornersView.bounds.size.width, 60)];
}

- (void)animateScanLine {
	if (!_scanIsRunning || _scanAnimationInProgress) return;
	
	_scanLineView.frame = CGRectMake(0, _cornersView.bounds.size.height, _cornersView.bounds.size.width, 60);
	[_cornersView addSubview:_scanLineView];
	
	[UIView animateWithDuration:5.0 animations:^{
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];
		CGFloat width = MAX(screenBounds.size.width, screenBounds.size.height);
		_scanLineView.frame = CGRectMake(0, -60, width, 60);
		_scanAnimationInProgress = YES;
	} completion:^(BOOL finished) {
		_scanAnimationInProgress = NO;
		if (finished) {
			[self animateScanLine];
		}
	}];
}

#pragma mark Instruction Related

static NSString *const A3V3InstructionDidShowForQRCode = @"A3V3InstructionDidShowForQRCode";

- (void)setupInstructionView
{
	if (![[A3UserDefaults standardUserDefaults] boolForKey:A3V3InstructionDidShowForQRCode]) {
		[self showInstructionView:nil];
	}
}

- (IBAction)showInstructionView:(id)sender
{
	[self stopRunning];
	
	[[A3UserDefaults standardUserDefaults] setBool:YES forKey:A3V3InstructionDidShowForQRCode];
	[[A3UserDefaults standardUserDefaults] synchronize];
	
	UIStoryboard *instructionStoryBoard = [UIStoryboard storyboardWithName:IS_IPHONE ? A3StoryboardInstruction_iPhone : A3StoryboardInstruction_iPad bundle:nil];
	_instructionViewController = [instructionStoryBoard instantiateViewControllerWithIdentifier:@"QRCode"];
	self.instructionViewController.delegate = self;
	[self.navigationController.view addSubview:self.instructionViewController.view];
	self.instructionViewController.view.frame = self.navigationController.view.frame;
	self.instructionViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)dismissInstructionViewController:(UIView *)view
{
	[self.instructionViewController.view removeFromSuperview];
	self.instructionViewController = nil;
	
	[self startRunning];
	[self animateScanLine];
}

#pragma mark - AdMob

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	[self.view addSubview:bannerView];
	
	UIView *superview = self.view;
	[bannerView remakeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(superview.left);
		make.right.equalTo(superview.right);
		make.bottom.equalTo(superview.bottom);
		make.height.equalTo(@(bannerView.bounds.size.height));
	}];

	_bottomToolbarBottomSpaceConstraint.constant = bannerView.bounds.size.height;
	
	[self.view layoutIfNeeded];
	[self.cornersView setNeedsDisplay];
}

#pragma mark - Override RSScannerViewController

- (void)startRunning {
	[super startRunning];

	_scanIsRunning = YES;
}

- (void)stopRunning {
	[super stopRunning];

	_scanIsRunning = NO;
}

- (void)dataHandlerDidFailToPresentViewController {
	[self startRunning];
	[self animateScanLine];
}

@end
