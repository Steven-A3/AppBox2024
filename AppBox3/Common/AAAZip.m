//
//  AAAZip.m
//  AppBox Pro
//
//  Created by Sun Kim on 2/27/11.
//  Copyright 2011 ALLABOUTAPPS. All rights reserved.
//

#import "AAAZip.h"
#import "A3AppDelegate.h"

@interface AAAZip ()

@end

@implementation AAAZip {
	zipFile		_zipFile;
	unzFile		_unzFile;

	NSString*   _password;
	id			_delegate;
	NSThread*   _thread;

	float _currentByte;
	float _totalByte;

	BOOL		unzipWithPassword;
	NSString*	zipFilename;
	NSString*	zipFilepath;
	NSFileManager *_fileManager;
}

- (id)init
{
	if((self=[super init]))
	{
		_zipFile = NULL ;
		_fileManager = [NSFileManager new];
        _encryptZip = YES;
	}
	return self;
}

- (BOOL)closeZipFile2
{
	_password = nil;
	if( _zipFile==NULL )
		return NO;
	BOOL ret =  zipClose( _zipFile,NULL )==Z_OK?YES:NO;
	_zipFile = NULL;
	return ret;
}

- (void)dealloc
{
	[self closeZipFile2];
}

- (BOOL)createZipFile2:(NSString*) zipFile
{
	_zipFile = zipOpen( (const char*)[zipFile UTF8String], 0 );
	if( !_zipFile ) 
		return NO;
	return YES;
}

- (BOOL)createZipFile2:(NSString *)zipFile Password:(NSString*) password
{
	_password = password;
	return [self createZipFile2:zipFile];
}

#define bufferSizeForReading	65536

- (BOOL)addFileToZip:(NSString*) file newname:(NSString*) newname;
{
	if( !_zipFile )
		return NO;

    //	tm_zip filetime;
	time_t current;
	time( &current );
	
	zip_fileinfo zipInfo = {0};
    //	zipInfo.dosDate = (unsigned long) current;
    
	NSError *error = nil;
	NSDictionary* attr = [_fileManager attributesOfItemAtPath:file error:&error];
	if (error) {
		FNLOG(@"%@", error.localizedDescription);
	}
	if( attr )
	{
		NSDate* fileDate = (NSDate*)[attr objectForKey:NSFileModificationDate];
		if( fileDate )
		{
			// some application does use dosDate, but tmz_date instead
			NSCalendar* currCalendar = [[A3AppDelegate instance] calendar];
			NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay |
           NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond ;
			NSDateComponents* dc = [currCalendar components:flags fromDate:fileDate];
			zipInfo.tmz_date.tm_sec = (uInt) [dc second];
			zipInfo.tmz_date.tm_min = (uInt) [dc minute];
			zipInfo.tmz_date.tm_hour = (uInt) [dc hour];
			zipInfo.tmz_date.tm_mday = (uInt) [dc day];
			zipInfo.tmz_date.tm_mon = (uInt) ([dc month] - 1);
			zipInfo.tmz_date.tm_year = (uInt) [dc year];
		}
	}
	
	int ret ;
	if( [_password length] == 0 )
	{
		ret = zipOpenNewFileInZip( _zipFile,
								  (const char*) [newname UTF8String],
								  &zipInfo,
								  NULL,0,
								  NULL,0,
								  NULL,//comment
								  Z_DEFLATED,
								  Z_DEFAULT_COMPRESSION );
	}
	else
	{
		uLong crcValue = [self crcForPath:file];
		ret = zipOpenNewFileInZip3( _zipFile,
                                   (const char*) [newname UTF8String],
                                   &zipInfo,
                                   NULL,0,
                                   NULL,0,
                                   NULL,//comment
                                   Z_DEFLATED,
                                   Z_DEFAULT_COMPRESSION,
                                   0,
                                   15,
                                   8,
                                   Z_DEFAULT_STRATEGY,
                                   [_password cStringUsingEncoding:NSASCIIStringEncoding],
                                   crcValue );
	}
	if( ret!=Z_OK )
	{
		return NO;
	}

	CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)file, kCFURLPOSIXPathStyle, false);
	if (!fileURL) return NO;
	CFReadStreamRef readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
	if (!readStream) goto release_and_return;
	if (!CFReadStreamOpen(readStream)) goto release_and_return;
	CFIndex readBytesCount;
	do {
		uint8_t buffer[bufferSizeForReading];
		readBytesCount = CFReadStreamRead(readStream, buffer, sizeof(buffer));
		if (readBytesCount > 0) {
			ret = zipWriteInFileInZip(_zipFile, buffer, (unsigned int) readBytesCount);
			_currentByte += readBytesCount;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self compressProgress];
			});
		}
	} while (readBytesCount > 0 && ret == Z_OK);

	if (ret == Z_OK) {
		ret = zipCloseFileInZip( _zipFile );
	}

release_and_return:
	if (readStream) {
		CFReadStreamClose(readStream);
		CFRelease(readStream);
	}
	if (fileURL) {
		CFRelease(fileURL);
	}

	return ret == Z_OK;
}

- (uLong)crcForPath:(NSString *)path {
	uLong crcValue = crc32(0L, NULL, 0);
	CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
			(__bridge CFStringRef)path, kCFURLPOSIXPathStyle, false);
	if (!fileURL) return 0;
	CFReadStreamRef readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
	if (!readStream) goto done;
	if (!CFReadStreamOpen(readStream)) goto done;
	CFIndex readBytesCount;
	do {
		uint8_t buffer[bufferSizeForReading];
		readBytesCount = CFReadStreamRead(readStream, buffer, sizeof(buffer));
		if (readBytesCount > 0) {
			crcValue = crc32(crcValue, buffer, (uInt)readBytesCount);
		}
	} while (readBytesCount > 0);

done:
	if (readStream) {
		CFReadStreamClose(readStream);
		CFRelease(readStream);
	}
	if (fileURL) {
		CFRelease(fileURL);
	}
	return crcValue;
}

- (BOOL)unzipOpenFile:(NSString*) zipFile
{
	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile )
	{
		unz_global_info  globalInfo = {0};
		unzGetGlobalInfo(_unzFile, &globalInfo );
	}
	return _unzFile != NULL;
}

- (BOOL)unzipOpenFile:(NSString *)zipFile Password:(NSString*) password
{
	_password = password;
	return [self unzipOpenFile:zipFile];
}

- (BOOL)unzipCloseFile
{
	_password = nil;
	if( _unzFile )
		return unzClose( _unzFile )==UNZ_OK;
	return YES;
}

#pragma mark wrapper for delegate

- (void)outputErrorMessage:(NSString*) msg
{
	if( _delegate && [_delegate respondsToSelector:@selector(errorMessage:)] )
		[_delegate errorMessage:msg];
}

- (BOOL)overWrite:(NSString*) file
{
	if( _delegate && [_delegate respondsToSelector:@selector(overWriteOperation:)] )
		return [_delegate overWriteOperation:file];
	return YES;
}

#pragma mark - Notify progress

- (void)compressProgress
{
    if([_delegate respondsToSelector:@selector(compressProgress:total:)]) {
		[_delegate compressProgress:_currentByte total:_totalByte];
	}
}

- (void)decompressProgress
{
    if([_delegate respondsToSelector:@selector(decompressProgress:total:)]) {
		[_delegate decompressProgress:_currentByte total:_totalByte];
	}
}

- (void)completedZipProcessWithSuccess
{
    if( _delegate && [_delegate respondsToSelector:@selector(completedZipProcess:)])
    {
		[_delegate completedZipProcess:YES];
    }
}

- (void)completedUnzipProcessWithSuccess
{
    if( _delegate && [_delegate respondsToSelector:@selector(completedUnzipProcess:)])
    {
		[_delegate completedUnzipProcess:YES];
    }
}

- (void)completedZipProcessWithFail
{
    if( _delegate && [_delegate respondsToSelector:@selector(completedZipProcess:)])
    {
		[_delegate completedZipProcess:FALSE];
    }
}

- (void)completedUnzipProcessWithFail {
	if (unzipWithPassword) {
		// Try to uncompress without password.
		unzipWithPassword = NO;
		_password = nil;
		NSDictionary *argumentList = [[NSDictionary alloc] initWithObjectsAndKeys:zipFilename,@"kZipFile", zipFilepath, @"kTargetDir", nil];

		_thread = [[NSThread alloc] initWithTarget:self selector:@selector(decompressFile:) object:argumentList];
		if(_thread != nil)
		{
			[_thread start];
		}

		return;
	}
	if( _delegate && [_delegate respondsToSelector:@selector(completedUnzipProcess:)])
	{
		[_delegate completedUnzipProcess:FALSE];
	}
}

- (float)getTotalBytes:(NSArray *)filelist
{
    float           total = 0;
    NSNumber        *fsize = nil;
    NSError         *error = nil;
    NSDictionary    *aFileInfo;
    NSString        *aFilePath;
    NSDictionary    *fileattrib = nil;
    
    for(aFileInfo in filelist)
    {
        aFilePath = [aFileInfo objectForKey:@"name"];
		if ([_fileManager fileExistsAtPath:aFilePath]) {
			fileattrib = [_fileManager attributesOfItemAtPath:aFilePath error:&error];
			if(error)
			{
				FNLOG(@"getTotalBytes error %@, %@, %@, %@, %@", aFilePath, error.localizedDescription, error.localizedFailureReason, error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
			}
			else
			{
				fsize = [fileattrib objectForKey:NSFileSize];
				total += [fsize floatValue];
				FNLOG(@"%@, %@, %f", aFilePath, fsize, total);
			}
		}
    }
    
    return total;
}

#define DEFAULT_SECURITY_KEY		@"d54?qjS8QD[.,UasG2R7FhS8?uk-D9+L"

- (void)compressWithList:(id)object {
    BOOL              bResult = TRUE;
    
    NSDictionary    *argumentList = object;
    
    NSString        *target = [argumentList objectForKey:@"kZipFile"];
    NSArray         *fileList = [argumentList   objectForKey:@"kFileList"];
    
    _totalByte = [self getTotalBytes:fileList];
    _currentByte = 0;
    
    if(_totalByte > 0) {
        if ([self createZipFile2:target Password:self.encryptZip ? DEFAULT_SECURITY_KEY : nil])
        {
            NSDictionary   *aFileInfo = nil;
            NSString       *filePath = nil;
            NSString       *newPath = nil;
            
            for(aFileInfo in fileList) {
                filePath = [aFileInfo objectForKey:@"name"];
                newPath = [aFileInfo  objectForKey:@"newname"];
                // check if thread is cancelled.
                if([[NSThread currentThread] isCancelled])
                {
					FNLOG(@"Thread is cancelled");
					[self closeZipFile2];
					[self performSelectorOnMainThread:@selector(completedZipProcessWithFail) withObject:nil waitUntilDone:NO];
                    return;
                }
                
                // compress file
                if(![self addFileToZip:filePath newname:newPath]) {
                    bResult = FALSE;
                    break;
                }
                
            }
        }
        else
        {
            bResult = FALSE;
        }
    } else {
        bResult = TRUE;
    }
    
    sleep(1);
	[self closeZipFile2];
    if(bResult) {
		[self performSelectorOnMainThread:@selector(completedZipProcessWithSuccess) withObject:nil waitUntilDone:NO];
    } else {
		[self performSelectorOnMainThread:@selector(completedZipProcessWithFail) withObject:nil waitUntilDone:NO];
    }
    return;
}

- (BOOL)createZipFile:(NSString *)zipFile withArray:(NSMutableArray *)fileList {
    BOOL            bResult = FALSE;
    NSDictionary    *argumentList = @{@"kZipFile" : zipFile, @"kFileList" : fileList};

    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(compressWithList:) object:argumentList];
    if(_thread != nil)
    {
        [_thread start];
        bResult = TRUE;
    }
    
    return bResult;
}

- (BOOL)decompressFile:(id)object {
	_currentByte = 0;

    NSDictionary        *argumentList = object;
    BOOL                success = YES;
    
    NSString        *zipFile = [argumentList objectForKey:@"kZipFile"];
    NSString        *path   = [argumentList   objectForKey:@"kTargetDir"];

	if ([argumentList objectForKey:@"kPassword"]) {
		_password = [argumentList objectForKey:@"kPassword"];
	}
	NSDictionary *zipFileAttribute = [[NSFileManager defaultManager] attributesOfItemAtPath:zipFile error:nil];
	if (zipFileAttribute) {
		_totalByte = [[zipFileAttribute objectForKey:NSFileSize] floatValue];
	}

	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile ){
        int ret = unzGoToFirstFile( _unzFile );
        unsigned char		buffer[bufferSizeForReading] = {0};

        if( ret!=UNZ_OK )
        {
			[self outputErrorMessage:@"Failed"];
        }
        
        do{
            if([[NSThread currentThread] isCancelled])
            {
                FNLOG(@"Thread is cancelled");
				[self unzipCloseFile];
				[self performSelectorOnMainThread:@selector(completedUnzipProcessWithFail) withObject:nil waitUntilDone:NO];
                return FALSE;
            }
            
            if( [_password length]==0 )
                ret = unzOpenCurrentFile( _unzFile );
            else {
                ret = unzOpenCurrentFilePassword( _unzFile, [_password cStringUsingEncoding:NSASCIIStringEncoding] );
				if (ret != UNZ_OK) {
					ret = unzOpenCurrentFile( _unzFile );
				}
			}
            if( ret!=UNZ_OK )
            {
				[self outputErrorMessage:@"Error occurs"];
                success = NO;
                break;
            }
            // reading data and write to file
            int read ;
            unz_file_info	fileInfo ={0};
            ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
            if( ret!=UNZ_OK )
            {
				[self outputErrorMessage:@"Error occurs while getting file info"];
                success = NO;
                unzCloseCurrentFile( _unzFile );
                break;
            }
            char* filename = (char*) malloc( fileInfo.size_filename +1 );
            unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
            filename[fileInfo.size_filename] = '\0';
            
            // check if it contains directory
            NSString * strPath = [NSString stringWithCString:filename encoding:NSUTF8StringEncoding];
            BOOL isDirectory = NO;
            if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
                isDirectory = YES;
            free( filename );
            if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
            {// contains a path
                strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            }
            NSString* fullPath = [path stringByAppendingPathComponent:strPath];
            
            if( isDirectory )
                [_fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
            else
                [_fileManager createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            
            FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
            while( fp )
            {
                read=unzReadCurrentFile(_unzFile, buffer, bufferSizeForReading);
                if( read > 0 )
                {
                    fwrite(buffer, read, 1, fp );

					_currentByte += read;
					#pragma mark -
					dispatch_async(dispatch_get_main_queue(), ^{
						[self decompressProgress];
					});
				}
                else if( read<0 )
                {
					[self outputErrorMessage:@"Failed to reading zip file"];
					
					if (fp) {
						fclose(fp);
					}
					success = NO;
					goto finalize;
                }
                else 
                    break;
            }
            if( fp )
            {
                fclose( fp );
                // set the original datetime property
                NSDate* orgDate = nil;
                
                //{{ thanks to brad.eaton for the solution
                NSDateComponents *dc = [[NSDateComponents alloc] init];
                
                dc.second = fileInfo.tmu_date.tm_sec;
                dc.minute = fileInfo.tmu_date.tm_min;
                dc.hour = fileInfo.tmu_date.tm_hour;
                dc.day = fileInfo.tmu_date.tm_mday;
                dc.month = fileInfo.tmu_date.tm_mon+1;
                dc.year = fileInfo.tmu_date.tm_year;
                
                NSCalendar *gregorian = [[NSCalendar alloc] 
                                         initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                orgDate = [gregorian dateFromComponents:dc] ;

                NSDictionary* attr = [NSDictionary dictionaryWithObject:orgDate forKey:NSFileModificationDate]; //[[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:YES];
                if( attr )
                {
                    //		[attr  setValue:orgDate forKey:NSFileCreationDate];
                    if( ![_fileManager setAttributes:attr ofItemAtPath:fullPath error:nil] )
                    {
                        // cann't set attributes 
                        FNLOG(@"Failed to set attributes");
                    }
                }
            }
            unzCloseCurrentFile( _unzFile );
            ret = unzGoToNextFile( _unzFile );
        }while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
		[self unzipCloseFile];
    } else {
        success = NO;
    }

finalize:
    if(success) {
		[self performSelectorOnMainThread:@selector(completedUnzipProcessWithSuccess) withObject:nil waitUntilDone:NO];
    } else {
		[self performSelectorOnMainThread:@selector(completedUnzipProcessWithFail) withObject:nil waitUntilDone:NO];
    }
    
	return success;
}

- (BOOL)unzipFile:(NSString *)zipFile unzipFileto:(NSString *)path {
    BOOL    bResult = FALSE;
	unzipWithPassword = YES;
	zipFilename = [zipFile copy];
	zipFilepath = [path copy];
    NSDictionary *argumentList = [[NSDictionary alloc] initWithObjectsAndKeys:zipFile,@"kZipFile", path, @"kTargetDir", DEFAULT_SECURITY_KEY, @"kPassword", nil];
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(decompressFile:) object:argumentList];
    if(_thread != nil)
    {
        [_thread start];
        bResult = TRUE;
    }
    
    return bResult;
}

- (void)cancelOperation {
    if(_thread != nil) {
        [_thread cancel];
    }
}

@end

