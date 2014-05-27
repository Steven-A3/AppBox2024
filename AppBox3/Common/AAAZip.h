//
//  AAAZip.h
//  AppBox Pro
//
//  Created by Sun Kim on 2/27/11.
//  Copyright 2011 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "zip.h"
#include "unzip.h"

@protocol AAAZipDelegate <NSObject>

@optional
-(void) ErrorMessage:(NSString*) msg;
-(BOOL) OverWriteOperation:(NSString*) file;
-(void) CompressProgress:(float)currentByte Total:(float)totalByte;
-(void) DecompressProgress:(float)currentBtye Total:(float)totalByte;
-(void) CompletedProcess:(BOOL)bResult;
@end

@interface AAAZip : NSObject {
    NSString    *targetFile;
@private
	zipFile		_zipFile;
	unzFile		_unzFile;
	
	NSString*   _password;
	id			_delegate;
    NSThread*   _thread;
    
    float       currentByte;
    float       totalByte;
	
	BOOL		unzipWithPassword;
	NSString*	zipFilename;
	NSString*	zipFilepath;
}

@property (nonatomic, retain) id<AAAZipDelegate> delegate;
@property (retain, nonatomic) NSString *targetFile;

-(BOOL) CreateZipFileWithList:(NSString *) zipFile SoureList:(NSMutableArray *)fileList;
-(BOOL) UnzipFile:(NSString *)zipFile unzipFileto:(NSString *)path;
-(void) cancelOperation;

@end
