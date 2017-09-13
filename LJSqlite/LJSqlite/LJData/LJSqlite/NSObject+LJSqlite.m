//
//  NSObject+LJSqlite.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/31.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#define run_in_queue(...) dispatch_async([self executeQueue], ^{\
__VA_ARGS__; \
})

#define DatabasePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"data.sqlite"];

#import "NSObject+LJSqlite.h"
#import "NSObject+LJModelMethods.h"
#import "LJPath.h"
#import "LJSqlite.h"
#import "LJSqliteStatement.h"
#import "LJSqliteMethod.h"
#import <objc/runtime.h>

@implementation NSObject (LJSqlite)

- (dispatch_queue_t)executeQueue
{
    static dispatch_queue_t executeQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executeQueue = dispatch_queue_create("com.sancai.ljdb", DISPATCH_QUEUE_SERIAL);
    });
    return executeQueue;
}

+ (dispatch_queue_t)executeQueue
{
    return [[self new] executeQueue];
}

+ (void)lj_dbName:(NSString *)dbName
{
    if (dbName.length) {
        NSString *dbNewPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",dbName]];
        [LJPath sharedManagerWithPath:dbNewPath];
    }
}

+ (void)addColum:(NSString*)name
{
    LJSqlite* sqlite = [LJSqlite sqliteWithPath:[self dbPath]];
    [sqlite executeSQLWithSqlstringFromModel:addColum(self, name) object:nil executeType:LJSqliteTypeWrite success:nil fail:nil];
}


+ (NSString*)dbPath
{
    if ([LJPath sharedManagerWithPath:nil].dbPath.length == 0) {
        return DatabasePath;
    }else
        return [LJPath sharedManagerWithPath:nil].dbPath;
}

+ (void)lj_createTable
{
    LJSqlite* sqlite = [LJSqlite sqliteWithPath:[self dbPath]];
    [sqlite executeSQLWithSqlstringFromModel:createTableString(self) object:nil executeType:LJSqliteTypeWrite success:nil fail:nil];
}

+ (NSArray *)lj_syncSqliteMethod:(LJSqliteMethod *)method fail:(fail)errorBlock
{
    __block NSMutableArray* array = [NSMutableArray array];
    [self lj_sqliteMethod:method success:^(NSArray *result) {
        for (NSDictionary* dic in result) {
            [array addObject:[self lj_ModelFromDictionaryOrJson:dic]];
        }
    } fail:errorBlock isSync:YES];
    return array;
}

+ (void)lj_asyncSqliteMethod:(LJSqliteMethod *)method success:(success)successBlock fail:(fail)errorBlock
{
    run_in_queue([self lj_sqliteMethod:method success:successBlock fail:errorBlock isSync:NO]);
}

+ (void)lj_sqliteMethod:(LJSqliteMethod *)method success:(success)successBlock fail:(fail)errorBlock isSync:(BOOL)isSync
{
    LJSqlite* sqlite = [LJSqlite sqliteWithPath:[self dbPath]];
    sqlite.isSync = isSync;
        if (method.dataArray.count) {
            for (id data in method.dataArray) {
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [sqlite executeSQLWithSqlstringFromModel:insertStringWithDic(self, data) object:data executeType:method.type success:nil fail:errorBlock];
                }else
                    [sqlite executeSQLWithSqlstringFromModel:[method joiningTogetherStatement:self] object:data executeType:method.type success:nil fail:errorBlock];
            }
        }else
            [sqlite executeSQLWithSqlstringFromModel:[method joiningTogetherStatement:self] object:nil executeType:method.type success:successBlock fail:errorBlock];
}

@end
