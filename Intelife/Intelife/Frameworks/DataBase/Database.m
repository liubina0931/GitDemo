//
//  Database.m
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-7-16.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import "Database.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DeviceInfoModel.h"
#import "SceneInfoModel.h"
#import "MonitorAreaModel.h"
#import "AppliancesInfoModel.h"
#import "SceneInfoModel.h"
#import "SecurityAreaModel.h"
#import "FloorInfoModel.h"
#import "RoomInfoModel.h"
#import "AlarmInfoModel.h"
#import "TimerInfoModel.h"
#import "UserInfoModel.h"
#import "GatewayInfoModel.h"
#import "GlobalDefines.h"

#define DB_NAME @"Intelife_IOS.db"
#define DB_VESION   1

@implementation Database
@synthesize sqliteDB;
@synthesize storeArray;

SYNTHESIZE_SINGLETON_FOR_CLASS(Database);

- (id) init
{
    if(self = [super init])
    {
		NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent: DB_NAME];
		
        sqliteDB = [[FMDatabase databaseWithPath:writableDBPath] retain];
			
        [self checkDatabaseVersion];
        [self initOtherConfigData];
        [self initP2PConfigData];
        [self initLocalGatewayData];
        [self initRemoteGatewayData];
        [self initDatabaseVersion];
        [self editDatabase];
	}
	return self;
}

- (void)closeDatabase
{
    if ([sqliteDB close])
    {
//        NSLog(@"sqlite database closed!");
    }
    else
    {
        NSLog(@"Failed to close database.");
        NSLog(@"%s %d", __FUNCTION__, __LINE__);
    }
}

- (void)createTable
{
    if ([sqliteDB open])
    {
        NSLog(@"sqlite database opened!");
        [sqliteDB setShouldCacheStatements:YES];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS PhoneSymbolInfo (_id INTEGER PRIMARY KEY AUTOINCREMENT,uuid TEXT(50))"];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS OtherConfig (_id INTEGER PRIMARY KEY AUTOINCREMENT,jPushTag TEXT(30),connectAllow TEXT(2))"];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS P2PConfig (_id INTEGER PRIMARY KEY AUTOINCREMENT,gatewayID TEXT(30),host TEXT(30),port INTEGER,communicationMode INTEGER,p2pLoginStatus INTEGER)"];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS RemoteGatewayInfo (_id INTEGER PRIMARY KEY AUTOINCREMENT,gatewayType TEXT(4),gatewayName TEXT(30),gatewayMac TEXT(30),gatewaySymbol TEXT(30),host TEXT(30),port INTEGER)"];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS LocalGatewayInfo (_id INTEGER PRIMARY KEY AUTOINCREMENT,gatewayType TEXT(4),gatewayName TEXT(30),gatewayMac TEXT(30),gatewaySymbol TEXT(30),host TEXT(30),port INTEGER,monitorName TEXT(30),monitorMac TEXT(30))"];
        [self.sqliteDB executeUpdate:@"CREATE TABLE IF NOT EXISTS DatabaseVersion (_id INTEGER PRIMARY KEY AUTOINCREMENT,version INTEGER)"];
    }
    else
    {
        NSLog(@"Failed to open database.");
        NSLog(@"%s %d", __FUNCTION__, __LINE__);
    }
}

- (void) insertToTable:(NSString *)tableName withValues:(NSDictionary *)values
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"INSERT INTO "];
    [sql appendString:tableName];
    [sql appendString:@"("];
    int size = (values != nil && [values count] > 0) ? (int)[values count] : 0;
    int i = 0;
    NSArray *allColumns = [values allKeys];
    NSString *colName = [[NSString alloc] init];
    if (size > 0)
    {
        for (i = 0; i < size; i++)
        {
            colName = [allColumns objectAtIndex:i];
            [sql appendString:((i > 0) ? @"," : @"")];
            [sql appendString:colName];
        }
        [sql appendString:@") VALUES ("];
        for (i = 0; i < size; i++)
        {
            colName = [allColumns objectAtIndex:i];
            [sql appendString:((i > 0) ? @", :" : @":")];
            [sql appendString:colName];
        }
        
        [sql appendString:@")"];
    }
    else
    {
        [sql appendString:@") VALUES(NULL)"];
    }

    BOOL result = [sqliteDB executeUpdate:sql withParameterDictionary:values];
    if (!result) {
        NSLog([NSString stringWithFormat:@"%d", [sqliteDB lastErrorCode]], nil);
        NSLog([sqliteDB lastErrorMessage], nil);
    }
    [sql release];
    [colName release];
}

- (void)clearTable:(NSString *)tableName
{
    NSString *formatForTable = @"DELETE FROM %@";
    NSString *sql;
    sql = [NSString stringWithFormat:formatForTable,tableName];
    [sqliteDB executeUpdate:sql];
}

- (void)clearTableContents:(NSString *)tableName
{
    NSMutableString *itemString = [[NSMutableString alloc] init];
    [itemString appendString:@"'"];
    [itemString appendString:tableName];
    [itemString appendString:@"'"];
    [self clearTable:tableName];
    [self clearTable:@"sqlite_sequence" withItem:itemString];
    [itemString release];
}

- (void)clearTable:(NSString *)tableName withItem:(NSString *)itemName
{
    NSString *formatForTable = @"DELETE FROM %@ WHERE name = %@";
    //NSString *formatForPrimaryKey = @"DELETE FROM sqlite_sequence WHERE name = '%@'";
    NSString *sql;
    sql = [NSString stringWithFormat:formatForTable,tableName,itemName];
    [sqliteDB executeUpdate:sql];
    //sql = [NSString stringWithFormat:formatForPrimaryKey,tableName];
    //[sqliteDB executeUpdate:sql];
}

- (void)dropTable:(NSString *)tableName
{
    NSString *formatForTable = @"DROP TABLE IF EXISTS %@";
    NSString *sql;
    sql = [NSString stringWithFormat:formatForTable,tableName];
    [sqliteDB executeUpdate:sql];
}

- (void)initOtherConfigData
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"OtherConfig" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if (![fmCursor next])
    {
        //初始化其他配置信息
        NSLog(@"初始化其他配置数据");
        NSMutableDictionary *otherConfigDic = [[NSMutableDictionary alloc] init];
        [otherConfigDic setObject:@"201411111415" forKey:@"jPushTag"];
        [otherConfigDic setObject:@"0" forKey:@"connectAllow"];
        [self insertToTable:@"OtherConfig" withValues:otherConfigDic];
        [otherConfigDic release];
    }
}

- (void)initP2PConfigData
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"P2PConfig" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if (![fmCursor next])
    {
        //初始化其他配置信息
        NSMutableDictionary *p2pConfigDic = [[NSMutableDictionary alloc] init];
        [p2pConfigDic setObject:@"0" forKey:@"gatewayID"];
        [p2pConfigDic setObject:@"192.168.1.168" forKey:@"host"];
        [p2pConfigDic setObject:[NSNumber numberWithInt:16899] forKey:@"port"];
        [p2pConfigDic setObject:[NSNumber numberWithInt:MODE_UNKNOW_CONNECT] forKey:@"communicationMode"];
        [p2pConfigDic setObject:[NSNumber numberWithInt:LOGIN_FAILED] forKey:@"p2pLoginStatus"];
        [self insertToTable:@"P2PConfig" withValues:p2pConfigDic];
        [p2pConfigDic release];
    }
}

- (void)initRemoteGatewayData
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"RemoteGatewayInfo" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if (![fmCursor next])
    {
        //初始化其他配置信息
        NSMutableDictionary *gatewayDic = [[NSMutableDictionary alloc] init];
        [gatewayDic setObject:[NSNumber numberWithInt:TYPE_MINI_GATEWAY] forKey:@"gatewayType"];
        [gatewayDic setObject:LocalizedString(@"SmartGateway") forKey:@"gatewayName"];
        [gatewayDic setObject:@"0" forKey:@"gatewayMac"];
        [gatewayDic setObject:@"0" forKey:@"gatewaySymbol"];
        [gatewayDic setObject:@"192.168.1.168" forKey:@"host"];
        [gatewayDic setObject:[NSNumber numberWithInt:16899] forKey:@"port"];
        [self insertToTable:@"RemoteGatewayInfo" withValues:gatewayDic];
        [gatewayDic release];
    }
}

- (void)initLocalGatewayData
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"LocalGatewayInfo" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if (![fmCursor next])
    {
        //初始化其他配置信息
        NSMutableDictionary *gatewayDic = [[NSMutableDictionary alloc] init];
        [gatewayDic setObject:[NSNumber numberWithInt:TYPE_MINI_GATEWAY] forKey:@"gatewayType"];
        [gatewayDic setObject:LocalizedString(@"SmartGateway") forKey:@"gatewayName"];
        [gatewayDic setObject:@"0" forKey:@"gatewayMac"];
        [gatewayDic setObject:@"0" forKey:@"gatewaySymbol"];
        [gatewayDic setObject:@"192.168.1.168" forKey:@"host"];
        [gatewayDic setObject:[NSNumber numberWithInt:16899] forKey:@"port"];
        [self insertToTable:@"LocalGatewayInfo" withValues:gatewayDic];
        [gatewayDic release];
    }
}

- (void)initDatabaseVersion
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"DatabaseVersion" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if (![fmCursor next])
    {
        //初始化数据库版本
        NSLog(@"初始化数据库版本");
        NSMutableDictionary *versionDic = [[NSMutableDictionary alloc] init];
        [versionDic setObject:[NSNumber numberWithInt:1] forKey:@"version"];
        [self insertToTable:@"DatabaseVersion" withValues:versionDic];
        [versionDic release];
    }
}

- (void)checkDatabaseVersion
{
    int historyDatabaseVersion = [self getHistoryDatabaseVersion];
    if (historyDatabaseVersion < DB_VESION)
    {
        [self deleteAllTable];
        [self createTable];
        [self setDatabaseVersion:DB_VESION];
        NSLog(@"sqlite database upgraded!");
    }
    else if (historyDatabaseVersion > DB_VESION)
    {
        NSLog(@"当前数据库版本不能低于历史版本!");
        [sqliteDB open];
    }
    else if (historyDatabaseVersion == DB_VESION)
    {
        [self createTable];
    }
}

- (void)savePhoneSymbol:(NSString *)phoneSymbol
{
    if (phoneSymbol != nil)
    {
        NSMutableDictionary *phoneDic = [[NSMutableDictionary alloc] init];
        [phoneDic setObject:phoneSymbol forKey:@"uuid"];
        [self insertToTable:@"PhoneSymbolInfo" withValues:phoneDic];
        [phoneDic release];
    }
}

- (int)getHistoryDatabaseVersion
{
    int returnDatabaseVersion = 0;
    if ([sqliteDB open])
    {
//        NSLog(@"sqlite database opened!");
        FMResultSet *fmCursor = nil;
        fmCursor = [self queryFromTable:@"DatabaseVersion" withColumn:nil withSelection:nil withSelectionArgs:nil];
        
        if([fmCursor next])
        {
            returnDatabaseVersion = [fmCursor intForColumn:@"version"];
        }
        else
        {
            returnDatabaseVersion = DB_VESION;
        }
    }
    else
    {
        NSLog(@"Failed to open database.");
        NSLog(@"%s %d", __FUNCTION__, __LINE__);
    }
    [self closeDatabase];
    return returnDatabaseVersion;
}

- (void)setDatabaseVersion:(int)version
{
    FMResultSet *fmCursor = nil;
    fmCursor = [self queryFromTable:@"DatabaseVersion" withColumn:nil withSelection:nil withSelectionArgs:nil];
    if ([fmCursor next])
    {
        //更新数据库版本
        NSLog(@"更新数据库版本");
        NSMutableDictionary *versionDic = [[NSMutableDictionary alloc] init];
        [versionDic setObject:[NSNumber numberWithInt:version] forKey:@"version"];
        [self updataItemToTable:@"DatabaseVersion" withValues:versionDic withWhere:@"_id=?" withArgs:@"1"];
        [versionDic release];
    }
}

- (void)editDatabase
{
    if (![sqliteDB columnExists:@"connectAllow" inTableWithName:@"OtherConfig"])//增加字段
    {
        NSLog(@"connectAllow为空");
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT(2)",@"OtherConfig",@"connectAllow"];
        [sqliteDB executeUpdate:sql];
        //初始化其他配置信息
        NSMutableDictionary *otherConfigDic = [[NSMutableDictionary alloc] init];
        [otherConfigDic setObject:@"0" forKey:@"connectAllow"];
        [self updataItemToTable:@"OtherConfig" withValues:otherConfigDic withWhere:@"_id=?" withArgs:@"1"];
        [otherConfigDic release];
    }
}

- (void)deleteAllTable
{
//    [sqliteDB setShouldCacheStatements:YES];
    if ([sqliteDB open])
    {
        [self dropTable:@"OtherConfig"];
        [self dropTable:@"RemoteGatewayInfo"];
        [self dropTable:@"LocalGatewayInfo"];
    }
    else
    {
        NSLog(@"Failed to open database.");
        NSLog(@"%s %d", __FUNCTION__, __LINE__);
    }
    [self closeDatabase];
}

- (void)updataItemToTable:(NSString *)tablename withValues:(NSDictionary *)values withWhere:(NSString *)whereClause withArgs:(NSString *)whereArgs
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSMutableArray *bindValues = [[NSMutableArray alloc] init];
    [sql appendString:@"UPDATE "];
    [sql appendString:tablename];
    [sql appendString:@" SET "];
    int setValueSize = (values != nil && [values count] > 0) ? (int)[values count] : 0;
    int i = 0;
    NSArray *allColumns = [values allKeys];
    NSString *colName = [[NSString alloc] init];
    for (i = 0; i < setValueSize; i++)
    {
        [sql appendString:((i > 0) ? @"," : @"")];
        colName = [allColumns objectAtIndex:i];
        [sql appendString:colName];
        [bindValues addObject:[values objectForKey:colName]];
        [sql appendString:@"=?"];
    }
    if (whereArgs != nil)
    {
        [bindValues addObject:whereArgs];
    }
    if (whereClause != nil)
    {
        [sql appendString:@" WHERE "];
        [sql appendString:whereClause];
    }
    [sqliteDB executeUpdate:sql withArgumentsInArray:bindValues];
    [sql release];
    [colName release];
}
- (FMResultSet *)queryFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selectionArgs
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *args = [NSArray arrayWithObjects: selectionArgs, nil];
    [sql appendString:@"SELECT "];
    
    if (column != nil)
    {
        [sql appendString:column];
    }
    else
    {
        [sql appendString:@"* "];
    }
    [sql appendString:@" FROM "];
    [sql appendString:tableName];
    if (selection != nil)
    {
        [sql appendString:@" WHERE "];
        [sql appendString:selection];
    }
    
    FMResultSet *fmCursor = [sqliteDB executeQuery:sql withArgumentsInArray:args];
    
    [sql release];
    
    return fmCursor;
}

- (void)deleteFromTable:(NSString *)tableName withSelection:(NSString *)selection withSelectionArgs:(NSString *)selectionArgs
{
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendString:@"DELETE FROM "];
    [sql appendString:tableName];
    if (selection != nil)
    {
        [sql appendString:@" WHERE "];
        [sql appendString:selection];
    }
    
    [sqliteDB executeUpdate:sql,selectionArgs];
    
    [sql release];
}

- (NSString *)readStringDataFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selecttionArgs
{
    FMResultSet *fmCursor = nil;
    NSString * returnData = [[[NSString alloc] init] autorelease];
    fmCursor = [self queryFromTable:tableName withColumn:column withSelection:selection withSelectionArgs:selecttionArgs];
    while ([fmCursor next])
    {
        returnData = [fmCursor stringForColumn:column];
    }
    return returnData;
}

- (int)readIntDataFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selecttionArgs
{
    FMResultSet *fmCursor = nil;
    int returnData = 0;
    fmCursor = [self queryFromTable:tableName withColumn:column withSelection:selection withSelectionArgs:selecttionArgs];
    while ([fmCursor next])
    {
        returnData = [fmCursor intForColumn:column];
    }
    return returnData;
}

- (void)updataLoginType:(int)loginType
{
    NSMutableDictionary *updataData = [[NSMutableDictionary alloc] init];
    [updataData setObject:[NSNumber numberWithInt:loginType] forKey:@"loginAccountType"];
    [self updataItemToTable:@"AccountInfo" withValues:updataData withWhere:@"_id=?" withArgs:@"1"];
}

- (void)saveLocalGatewayInfo:(GatewayInfoModel *)gatewayInfo
{
    NSMutableDictionary *gatewayDic = [[NSMutableDictionary alloc] init];
    [gatewayDic setObject:[NSNumber numberWithInt:gatewayInfo.gatewayType] forKey:@"gatewayType"];
    [gatewayDic setObject:LocalizedString(@"SmartGateway") forKey:@"gatewayName"];
    [gatewayDic setObject:[NSString stringWithFormat:@"%lld",gatewayInfo.gatewayMacAddress] forKey:@"gatewayMac"];
    [gatewayDic setObject:gatewayInfo.gatewayIpAddress forKey:@"host"];
    [gatewayDic setObject:[NSNumber numberWithInt:gatewayInfo.gatewayPort] forKey:@"port"];
    [self updataItemToTable:@"LocalGatewayInfo" withValues:gatewayDic withWhere:@"_id=?" withArgs:@"1"];
    [gatewayDic release];
}

- (void)dbClose
{
    [sqliteDB close];
    [sqliteDB release];
}

- (void) dealloc
{
    [self dbClose];
    NSLog(@"sqlite closed");
    [super dealloc];
}

@end