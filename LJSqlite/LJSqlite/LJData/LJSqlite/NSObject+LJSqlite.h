//
//  NSObject+LJSqlite.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/31.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^success)(NSArray* result);

typedef void(^fail)(NSError* error);

@class LJSqliteMethod;

@interface NSObject (LJSqlite)

/********************************-必要操作-********************************/

/*!
 @brief     创建表
 */
+ (void)lj_createTable;

/*!
 @brief     数据库操作(阻塞)
 */
+ (NSArray *)lj_syncSqliteMethod:(LJSqliteMethod *)method fail:(fail)errorBlock;

/*!
 @brief     数据库操作(非阻塞)
 */
+ (void)lj_asyncSqliteMethod:(LJSqliteMethod *)method success:(success)successBlock fail:(fail)errorBlock;


/********************************-非必要操作-********************************/

/*!
 @brief     指定数据库(不调用为默认数据库路径)
 */
+ (void)lj_dbName:(NSString *)dbName;

/*!
 @brief     对数据库增加字段(modle里需先添加上)
 */
+ (void)addColum:(NSString*)name;

@end
