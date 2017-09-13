//
//  LJPath.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJPath : NSObject

@property (nonatomic,strong) NSString* dbPath;

+ (instancetype)sharedManagerWithPath:(NSString *)dbPath;

@end
