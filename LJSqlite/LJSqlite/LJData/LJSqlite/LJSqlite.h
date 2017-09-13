//
//  LJSqlite.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/30.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^success)(NSArray* result);

typedef void(^fail)(NSError* error);

typedef NS_ENUM(NSInteger,LJSqliteType) {
    LJSqliteTypeWrite,
    LJSqliteTypeRead
};

@interface LJSqlite : NSObject

@property (nonatomic,strong) NSString* sqlPath;

@property (nonatomic,strong) NSDateFormatter* dateFormatter;

@property (nonatomic,assign) BOOL isSync;

- (instancetype)initWithPath:(NSString*)dbPath;

+ (instancetype)sqliteWithPath:(NSString*)dbPath;

- (void)executeSQLWithSqlstringFromModel:(NSString*)sqlString object:(id)modelOrDict executeType:(LJSqliteType)type success:(success)successBlock fail:(fail)failBlock;

@end
