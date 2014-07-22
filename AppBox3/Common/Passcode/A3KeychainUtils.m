//
//  A3KeychainUtils.m
//  AppBox3
//
//  Created by A3 on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3KeychainUtils.h"
#import "A3AppDelegate+passcode.h"
#import "NSData-AES.h"
#import <Security/Security.h>

static NSString *kA3KeychainServiceName = @"A3PasscodeService";
static NSString *kA3KeychainAccountName = @"A3AppBox3Passcode";

@implementation A3KeychainUtils

+ (NSDictionary *)query {
	return @{
			 (__bridge_transfer NSString *)kSecClass		:	(__bridge_transfer id)kSecClassGenericPassword,
			 (__bridge_transfer NSString *)kSecAttrService	:	kA3KeychainServiceName,
			 (__bridge_transfer NSString *)kSecAttrAccount	:	kA3KeychainAccountName
			 };
}

+ (BOOL)storePassword:(NSString *)password hint:(NSString *)hint {
	NSString *hintString = hint;
	if (!hintString) {
		hintString = @"";
	}

	NSMutableDictionary *query = [[self query] mutableCopy];
	[query setObject:@YES forKey:(__bridge_transfer NSString *)kSecReturnData];
	
	CFTypeRef resData = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&resData);

	if (status != errSecItemNotFound) {
		NSDictionary *updateQuery = [self query];
		NSDictionary *changesDictionary = @{
				(__bridge_transfer NSString *) kSecValueData 	: [password dataUsingEncoding:NSUTF8StringEncoding],
				(__bridge_transfer NSString *) kSecAttrComment	: hintString
		};
		status = SecItemUpdate((__bridge CFDictionaryRef) updateQuery, (__bridge CFDictionaryRef) changesDictionary);
	} else {
		NSMutableDictionary *addQuery = [[self query] mutableCopy];
		[addQuery setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge_transfer NSString *)kSecValueData];
		[addQuery setObject:hintString forKey:(__bridge_transfer NSString *)kSecAttrComment];
		status = SecItemAdd((__bridge CFDictionaryRef) addQuery, NULL);
	}
	return status == noErr;
}

+ (NSString *)getPassword {
	NSMutableDictionary *query = [[self query] mutableCopy];
	[query setObject:@YES forKey:(__bridge_transfer NSString *)kSecReturnData];
	
	CFTypeRef resData = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&resData);
	if (status != noErr) {
		return nil;
	}
	NSData *resultData = (__bridge_transfer NSData *)resData;
	NSString *password = nil;
	if (resultData) {
		password = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	}
	return password;
}

+ (NSString *)getHint {
	NSMutableDictionary *query = [[self query] mutableCopy];
	[query setObject:@YES forKey:(__bridge_transfer NSString *)kSecReturnAttributes];

	CFDictionaryRef resData = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *) &resData);
	if (status != noErr) {
		return nil;
	}
	NSDictionary *resultDictionary = (__bridge_transfer NSDictionary *)resData;
	NSString *hint = [resultDictionary objectForKey:(__bridge_transfer NSString *)kSecAttrComment];
	return hint;
}

+ (void)removePassword {
	NSDictionary *query = [self query];
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	if (status != noErr) {
		FNLOG(@"Error deleting password.");
	}
}

+ (double)passcodeTime {
	return [[NSUserDefaults standardUserDefaults] doubleForKey:kUserDefaultsKeyForPasscodeTimerDuration];
}

+ (NSString *)passcodeTimeString {
	double passcodeTime = [A3KeychainUtils passcodeTime];
	NSString *string;
	if (passcodeTime == 0.0) {
		string = NSLocalizedString(@"Immediately", @"Immediately");
	} else if (passcodeTime / 60 >= 60) {
		string = [NSString localizedStringWithFormat:NSLocalizedStringFromTable(@"After %ld hours", @"StringsDict", @"Require Passcode after n hours"), (long)passcodeTime / 60 / 60 ];
	} else {
		string = [NSString localizedStringWithFormat:NSLocalizedStringFromTable(@"After %ld minutes", @"StringsDict", @"Require Passcode after n minutes"), (long)passcodeTime / 60];
	}
	return string;
}

#pragma mark - Migration from V1

NSString *const kUserEnabledPasscode					= @"kUserEnabledPasscode";
NSString *const kUserSavedPasscode					= @"kUserSavedPasscode";
NSString *const kUserSavedPasscodeHint				= @"kUserSavedPasscodHint";
NSString *const USERPASSCODEDECRYPTKEY				= @"d54?qjS8QD[.,UasG2R7FhS8?uk-D9+L";
NSString *const kUserUseSimplePasscode				= @"kUserUseSimplePasscode";

+ (void)migrateV1Passcode {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserEnabledPasscode]) {
		NSData *encryptedPasswordData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSavedPasscode];
		NSString *decryptedPasscode = [[NSString alloc] initWithData:[encryptedPasswordData AESDecryptWithPassphrase:USERPASSCODEDECRYPTKEY] encoding:NSUTF8StringEncoding];
		if ([decryptedPasscode length]) {
			NSData *encryptedHintData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSavedPasscodeHint];
			NSString *decryptedHint = [[NSString alloc] initWithData:[encryptedHintData AESDecryptWithPassphrase:USERPASSCODEDECRYPTKEY] encoding:NSUTF8StringEncoding];

			if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsKeyForUseSimplePasscode]) {
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
			} else {
				// Verify is it simple passcode.
				NSCharacterSet *digitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
				NSString *verification = [decryptedPasscode stringByTrimmingCharactersInSet:digitCharacterSet];
				if ([decryptedPasscode length] != 4 || [verification length] != 0) {
					[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsKeyForUseSimplePasscode];
				} else {
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsKeyForUseSimplePasscode];
				}
			}
			[A3KeychainUtils storePassword:decryptedPasscode hint:decryptedHint];
		}
	}
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserEnabledPasscode];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSavedPasscode];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSavedPasscodeHint];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
