//
//  SQLiteWrapper.h
//  WeddingMatch
//
//  Created by coanyaa on 10. 12. 3..
//  Copyright 2010 Joy2x. All rights reserved.
//

#import <sqlite3.h>


@interface SQLiteWrapper : NSObject {
	NSString *dbPath;
	sqlite3 *dbCon;
}

- (id)initWithPath:(NSString*)filePath;
- (void)open;
- (void)close;
- (void)raiseSqliteException:(NSString*)errorMessage;
- (NSMutableArray*) executeSql:(NSString*)sql;
- (NSArray*)columnNamesForStatement:(sqlite3_stmt *)statement;
- (NSArray*)columnTypesForStatement:(sqlite3_stmt*)statement;
- (int)typeForStatement:(sqlite3_stmt*)statement column:(int)column;
- (int)columnTypeToInt:(NSString*)columnType;
- (void)copyValuesFromStatement:(sqlite3_stmt*)statement 
						  toRow:(NSMutableDictionary*)row 
					  queryInfo:(NSDictionary*)queryInfo 
					columnTypes:(NSArray*)columnTypes 
					columnNames:(NSArray*)columnNames;
- (id)valueFromStatement:(sqlite3_stmt*)statement column:(int)column queryInfo:(NSDictionary*)queryInfo columnTypes:(NSArray*)columnTypes;
- (NSUInteger)lastInsertedID;
- (BOOL)isExistsColumn:(NSString*)columnName inTable:(NSString*)tableName;

@property (nonatomic,strong) NSString *dbPath;
@end
