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

NSString *const A3QRCodeSettingsPlayAlertSound = @"A3QRCodeSettingsPlayAlertSound";
NSString *const A3QRCodeSettingsPlayVibrate = @"A3QRCodeSettingsPlayVibrate";
NSString *const A3QRCodeImageSoundOn = @"sound_on";
NSString *const A3QRCodeImageSoundOff = @"sound_off";
NSString *const A3QRCodeImageVibrateOn = @"vibrate_on";
NSString *const A3QRCodeImageVibrateOff = @"vibrate_off";
NSString *const A3QRCodeImageTorchOn = @"m_flash_on";
NSString *const A3QRCodeImageTorchOff = @"m_flash_off";

@interface A3QRCodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, A3InstructionViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *torchOnOffButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *vibrateOnOffButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *soundOnOffButton;
@property (nonatomic, weak) IBOutlet A3CornersView *cornersView;
@property (nonatomic, strong) A3QRCodeDataHandler *dataHandler;
@property (nonatomic, strong) AVAudioPlayer *beepPlayer;
@property (nonatomic, strong) A3QRCodeScanLineView *scanLineView;
@property (nonatomic, strong) A3InstructionViewController *instructionViewController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomToolbarBottomSpaceConstraint;

@end

@implementation A3QRCodeViewController {
	BOOL _googleSearchInProgress;
	BOOL _viewWillAppearFirstRunAfterLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	_viewWillAppearFirstRunAfterLoad = YES;
	[self.navigationController setNavigationBarHidden:YES];
	self.isCornersVisible = NO;
	self.stopOnFirst = YES;

	[self setupBarcodeHandler];
	[self setupTapGestureHandler];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:@{A3QRCodeSettingsPlayVibrate : @YES,
									 A3QRCodeSettingsPlayAlertSound : @YES}];
	
	[self.soundOnOffButton setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayAlertSound] ? A3QRCodeImageSoundOn : A3QRCodeImageSoundOff]];
	[self.vibrateOnOffButton setImage:[UIImage imageNamed:[userDefaults boolForKey:A3QRCodeSettingsPlayVibrate] ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	if (_viewWillAppearFirstRunAfterLoad) {
		_viewWillAppearFirstRunAfterLoad = NO;
		[self setupInstructionView];
		[self setupBannerViewForAdUnitID:AdMobAdUnitIDQRCode keywords:@[@"Low Price", @"Shopping", @"Marketing"] gender:kGADGenderUnknown adSize:IS_IPHONE ? kGADAdSizeBanner : kGADAdSizeLeaderboard];
	} else {
		[self startRunning];
		[self.cornersView setNeedsDisplay];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self setupScanLineView];
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
	[self.torchOnOffButton setImage:[UIImage imageNamed:self.torchState ? A3QRCodeImageTorchOn : A3QRCodeImageTorchOff]];
}

- (IBAction)vibrateOnOff:(id)sender {
	BOOL vibrateOn = [[NSUserDefaults standardUserDefaults] boolForKey:A3QRCodeSettingsPlayVibrate];
	vibrateOn = !vibrateOn;
	[[NSUserDefaults standardUserDefaults] setBool:vibrateOn forKey:A3QRCodeSettingsPlayVibrate];
	[self.vibrateOnOffButton setImage:[UIImage imageNamed:vibrateOn ? A3QRCodeImageVibrateOn : A3QRCodeImageVibrateOff]];
}

- (IBAction)scanFromImage:(id)sender {
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
	[self.soundOnOffButton setImage:[UIImage imageNamed:soundOn ? A3QRCodeImageSoundOn: A3QRCodeImageSoundOff]];
}

- (void)setupBarcodeHandler {
	__typeof(self) __weak weakSelf = self;
	self.barcodesHandler = ^(NSArray *barcodeObjects) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[barcodeObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject * _Nonnull barcode, NSUInteger idx, BOOL * _Nonnull stop) {
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
					
					NSArray *qrcodeTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode];
					if ([qrcodeTypes indexOfObject:barcode.type] != NSNotFound) {
						history.dimension = @"2";
					} else {
						history.dimension = @"1";
					}
				}
				
				[moc MR_saveToPersistentStoreAndWait];

				if ([history.dimension isEqualToString:@"1"]) {
					A3BasicWebViewController *viewController = [A3BasicWebViewController new];
					viewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@", history.scanData]];
					[weakSelf.navigationController setNavigationBarHidden:NO];
					[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
					[weakSelf.navigationController pushViewController:viewController animated:YES];
//					if (!history.searchData) {
//						[weakSelf searchBarcode:barcode.stringValue];
//					} else {
//						[weakSelf presentDetailViewControllerWithData:history];
//					}
				} else {
					[weakSelf.dataHandler performActionWithData:history inViewController:weakSelf];
				}
			}];
		});
	};
}

- (void)setupTapGestureHandler {
	self.tapGestureHandler = ^(CGPoint tapPoint) {

	};
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
	_scanLineView = [[A3QRCodeScanLineView alloc] initWithFrame:CGRectMake(0, _cornersView.bounds.size.height - 60, _cornersView.bounds.size.width, 60)];
	[_cornersView addSubview:_scanLineView];

	[self animateScanLine];
}

- (void)animateScanLine {
	_scanLineView.frame = CGRectMake(0, _cornersView.bounds.size.height, _cornersView.bounds.size.width, 60);
	[UIView animateWithDuration:5.0 animations:^{
		_scanLineView.frame = CGRectMake(0, -60, _cornersView.bounds.size.width, 60);

	} completion:^(BOOL finished) {
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

@end