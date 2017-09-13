//
//  LJSqliteStatement.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/31.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJSqliteMethod.h"

@interface LJSqliteStatement : NSObject

NSString* createTableString(Class modelClass);

NSString* addColum(id model,NSString *name);

NSString* insertString(id model);

NSString* insertStringWithDic(id model ,NSDictionary* dic);

NSString* deleteString(Class modelClass,NSDictionary* preDict,BOOL isOr);

NSString* selectString(Class modelClass,NSDictionary* preDict,NSString *sortStr,BOOL isOr);

NSString* changeString(Class modelClass,NSDictionary* changeDict,NSDictionary* preDict,BOOL isOr);

NSString* freedomString(Class modelClass,NSString* predicateString,NSString* changeString,LJStatement freedomStatement);

@end
