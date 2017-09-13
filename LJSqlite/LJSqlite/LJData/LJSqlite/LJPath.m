//
//  LJPath.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "LJPath.h"

@implementation LJPath

+ (instancetype)sharedManagerWithPath:(NSString *)dbPath
{
    static LJPath *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LJPath alloc] init];
    });
    if (dbPath) {
        sharedInstance.dbPath = dbPath;
    }
    return sharedInstance;
}

@end

