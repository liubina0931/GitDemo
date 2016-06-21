//
//  Database.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-7-16.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@class FMDatabase;
@class FMResultSet;
@class GatewayInfoModel;

@interface Database : NSObject
{
    FMDatabase *sqliteDB;
    NSMutableArray *storeArray;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Database);

@property (nonatomic, retain) FMDatabase *sqliteDB;
@property (nonatomic, retain) NSMutableArray *storeArray;


- (void) dbClose;
- (void) createTable;
- (void)clearTable:(NSString *)tableName;
- (void)clearTableContents:(NSString *)tableName;
- (void)clearTable:(NSString *)tableName withItem:(NSString *)itemName;
//- (void)clearDownloadTable;
- (void)initRemoteGatewayData;
- (void) insertToTable:(NSString *)tableName withValues:(NSDictionary *)values;
- (void)savePhoneSymbol:(NSString *)phoneSymbol;
- (void)updataItemToTable:(NSString *)tablename withValues:(NSDictionary *)values withWhere:(NSString *)whereClause withArgs:(NSString *)whereArgs;
- (FMResultSet *)queryFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selectionArgs;
- (void)deleteFromTable:(NSString *)tableName withSelection:(NSString *)selection withSelectionArgs:(NSString *)selectionArgs;
- (NSString *)readStringDataFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selecttionArgs;
- (int)readIntDataFromTable:(NSString *)tableName withColumn:(NSString *)column withSelection:(NSString *)selection withSelectionArgs:(NSString *)selecttionArgs;
//- (NSMutableArray *)getAllDeviceList;
//- (NSMutableArray *)getSceneList;
//- (NSMutableArray *)getMonitorAreaList;
//- (NSMutableArray *)getElectronicList;
//- (NSMutableArray *)getSecurityAreaList;
//- (NSMutableArray *)getFloorList;
//- (NSMutableArray *)getRoomList;
//- (NSMutableArray *)getAlarmInfoList;
//- (NSMutableArray *)getHistorySetInfoList;
//- (NSMutableArray *)getTimerList;
//- (NSMutableArray *)getUserList;
- (void)updataLoginType:(int)loginType;
- (void)saveLocalGatewayInfo:(GatewayInfoModel *)gatewayInfo;
//- (NSMutableString *)getRoomNameFromRoomID:(int)roomID;


@end