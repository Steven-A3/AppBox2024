//
//  SQLiteWrapper.m
//  WeddingMatch
//
//  Created by coanyaa on 10. 12. 3..
//  Copyright 2010 Joy2x. All rights reserved.
//

#import "SQLiteWrapper.h"

@implementation SQLiteWrapper
@synthesize dbPath;

- (id)initWithPath:(NSString*)filePath
{
	if( self = [super init] )
	{
		self.dbPath = filePath;
		[self open];
	}
	
	return self;
}

- (void)close
{
	if( sqlite3_close(dbCon) != SQLITE_OK )
	{
		[self raiseSqliteException:@"failed to close database with message '%S'."];
	}
}

- (void)open
{
	if( sqlite3_open([self.dbPath UTF8String],&dbCon) != SQLITE_OK )
	{
		sqlite3_close(dbCon);
		[self raiseSqliteException:@"failed to open database with message '%S'."];
	}
}

- (void)raiseSqliteException:(NSString *)errorMessage
{
	[NSException raise:@"ISDatabaseSQLiteException" format:errorMessage,sqlite3_errmsg16(dbCon)];
}

- (void)dealloc
{
	[self close];
	
}

- (NSMutableArray*) executeSql:(NSString*)sql
{
	NSMutableDictionary *queryInfo = [NSMutableDictionary dictionary];
	[queryInfo setObject:sql forKey:@"sql"];
	NSMutableArray *rows = [NSMutableArray array];
	
	sqlite3_stmt *statement = NULL;
	if( sqlite3_prepare_v2(dbCon, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK )
	{
		BOOL needsToFetchColumnTypesAndNames = YES;
		NSArray *columnTypes = nil;
		NSArray *columnNames = nil;
		
		while (sqlite3_step(statement) == SQLITE_ROW ) {
			if( needsToFetchColumnTypesAndNames )
			{
				columnTypes = [self columnTypesForStatement:statement];
				columnNames = [self columnNamesForStatement:statement];
				needsToFetchColumnTypesAndNames = NO;
			}
			
			NSMutableDictionary *row = [NSMutableDictionary dictionary];
			[self copyValuesFromStatement:statement toRow:row queryInfo:queryInfo columnTypes:columnTypes columnNames:columnNames];
			[rows addObject:row];
		}
	}else {
		sqlite3_finalize(statement);
		[self raiseSqliteException:[[NSString stringWithFormat:@"failed to execute statement: '%@' with message: ",sql] stringByAppendingString:@"%S"]];
	}

	sqlite3_finalize(statement);
	
	return rows;
}

- (NSArray*)columnNamesForStatement:(sqlite3_stmt *)statement
{
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnNames = [NSMutableArray array];
	for(int i=0; i < columnCount; i++)
	{
		[columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
	}
	
	return columnNames;
}

- (NSArray*)columnTypesForStatement:(sqlite3_stmt*)statement
{
	int columnCount = sqlite3_column_count(statement);
	
	NSMutableArray *columnTypes = [NSMutableArray array];
	for(int i=0; i < columnCount; i++)
	{
		[columnTypes addObject:[NSNumber numberWithInt:[self typeForStatement:statement column:i]]];
	}
	
	return columnTypes;
}

- (int)typeForStatement:(sqlite3_stmt*)statement column:(int)column
{
	const char *columnType = sqlite3_column_decltype(statement, column);
	if(columnType != NULL )
	{
		return [self columnTypeToInt:[[NSString stringWithUTF8String:columnType] uppercaseString]];
	}
	
	return sqlite3_column_type(statement, column);
}

- (int)columnTypeToInt:(NSString*)columnType
{
	if( [columnType isEqualToString:@"INTEGER"] )
	{
		return SQLITE_INTEGER;
	}
	else if( [columnType isEqualToString:@"REAL"] )
	{
		return SQLITE_FLOAT;
	}
	else if( [columnType isEqualToString:@"TEXT"] )
	{
		return SQLITE_TEXT;
	}
	else if( [columnType isEqualToString:@"BLOB"] )
	{
		return SQLITE_BLOB;
	}
	else if( [columnType isEqualToString:@"NULL"] )
	{
		return SQLITE_NULL;
	}
	
	return SQLITE_TEXT;
}

- (void)copyValuesFromStatement:(sqlite3_stmt*)statement 
						  toRow:(NSMutableDictionary*)row 
					  queryInfo:(NSDictionary*)queryInfo 
					columnTypes:(NSArray*)columnTypes 
					columnNames:(NSArray*)columnNames
{
	int columnCount = sqlite3_column_count(statement);
	
	for(int i=0; i < columnCount; i++)
	{
		id value = [self valueFromStatement:statement column:i queryInfo:queryInfo columnTypes:columnTypes];
		if( value != nil )
		{
			[row setValue:value forKey:[columnNames objectAtIndex:i]];
		}
	}
}

- (id)valueFromStatement:(sqlite3_stmt*)statement column:(int)column queryInfo:(NSDictionary*)queryInfo columnTypes:(NSArray*)columnTypes
{
	int columnType = [[columnTypes objectAtIndex:column] intValue];
	
	if( columnType == SQLITE_INTEGER )
	{
		return [NSNumber numberWithInt:sqlite3_column_int(statement,column)];
	}
	else if( columnType == SQLITE_FLOAT )
	{
		return [NSNumber numberWithInt:sqlite3_column_double(statement, column)];
	}
	else if( columnType == SQLITE_TEXT )
	{
		const char *text = (const char*)sqlite3_column_text(statement, column);
		if( text != nil )
			return [NSString stringWithUTF8String:text];
		else
			return nil;
	}
	else if( columnType == SQLITE_BLOB )
	{
		return [NSData dataWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
	}
	else if( columnType == SQLITE_NULL)
	{
		return nil;
	}
	
	return nil;
}

- (NSUInteger)lastInsertedID
{
	return (NSUInteger)sqlite3_last_insert_rowid(dbCon);
}

- (BOOL)isExistsColumn:(NSString*)columnName inTable:(NSString*)tableName
{
    NSArray *retArray = [self executeSql:[NSString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE tbl_name='%@' AND sql like '%%%@%%'",tableName,columnName]];
    if( ([retArray count] > 0) && ([[[retArray objectAtIndex:0] objectForKey:@"sql"] length] > 0))
        return YES;
    return NO;
}

@end
