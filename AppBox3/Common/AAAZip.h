//
//  AAAZip.h
//  AppBox Pro
//
//  Created by Sun Kim on 2/27/11.
//  Copyright 2011 ALLABOUTAPPS. All rights reserved.
//

#include "zip.h"
#include "unzip.h"

@protocol AAAZipDelegate <NSObject>
@optional
- (void)errorMessage:(NSString*) msg;
- (BOOL)overWriteOperation:(NSString*) file;
- (void)compressProgress:(float)currentByte total:(float)totalByte;
- (void)decompressProgress:(float)currentByte total:(float)totalByte;
- (void)completedZipProcess:(BOOL)bResult;
- (void)completedUnzipProcess:(BOOL)bResult;
@end

@interface AAAZip : NSObject

@property (nonatomic, strong) id<AAAZipDelegate> delegate;
@property (nonatomic, assign) BOOL encryptZip;

- (BOOL)createZipFile:(NSString *)zipFile withArray:(NSMutableArray *)fileList;
- (BOOL)unzipFile:(NSString *)zipFile unzipFileto:(NSString *)path;
- (void)cancelOperation;

@end
