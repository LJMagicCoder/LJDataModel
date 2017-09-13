//
//  LJSqliteStatement.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/31.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "LJSqliteStatement.h"
#import <objc/runtime.h>
#import "NSObject+LJModelMethods.h"

#define CREATE_TABLENAME_HEADER @"CREATE TABLE IF NOT EXISTS "
#define INSERT_HEADER @"INSERT INTO "
#define UPDATE_HEADER @"UPDATE "
#define DELETE_HEADER @"DELETE FROM "
#define SELECT_HEADER @"SELECT * FROM "

@implementation LJSqliteStatement

NSString* createTableString(Class modelClass)
{
    NSMutableString* sqlString = [NSMutableString stringWithString:CREATE_TABLENAME_HEADER];
    NSDictionary* stateMentDic = [modelClass getAllPropertyNameAndType];
    [sqlString appendString:NSStringFromClass(modelClass)];
    NSMutableString* valueStr = [NSMutableString string];
    [stateMentDic enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL* stop) {
        [valueStr appendString:tableNameValueString(obj, key)];
    }];
    if (valueStr.length>0) {
        [valueStr deleteCharactersInRange:NSMakeRange(valueStr.length-1, 1)];
    }
    [sqlString appendFormat:@"(%@)",valueStr];
    return sqlString;
}

NSString* addColum(id model,NSString *name)
{
    NSString* sqlString = [NSString stringWithFormat:@"alter table %@ add %@ %@",NSStringFromClass(model),name,[model getTypeNameWith:name]];
    return sqlString;
}

NSString* insertString(id model)
{
    NSMutableString* sqlString = [NSMutableString stringWithString:INSERT_HEADER];
    [sqlString appendString:NSStringFromClass([model class])];
    NSDictionary* valueDic = [model getAllPropertyNameAndType];
    NSMutableString* keyStr = [NSMutableString string];
    NSMutableString* valueStr = [NSMutableString string];
    for (NSString *key in valueDic.allKeys) {
        [keyStr appendFormat:@"%@,",key];
        [valueStr appendFormat:@"?,"];
    }
    [sqlString appendFormat:@"(%@) VALUES (%@)",[keyStr substringToIndex:keyStr.length-1],[valueStr substringToIndex:valueStr.length-1]];
    return sqlString;
}

NSString* insertStringWithDic(id model ,NSDictionary* dic)
{
    NSMutableString* sqlString = [NSMutableString stringWithString:INSERT_HEADER];
    [sqlString appendString:NSStringFromClass([model class])];
    NSMutableString* keyStr = [NSMutableString string];
    NSMutableString* valueStr = [NSMutableString string];
    for (NSString *key in dic.allKeys) {
        [keyStr appendFormat:@"%@,",key];
        [valueStr appendFormat:@"?,"];
    }
    [sqlString appendFormat:@"(%@) VALUES (%@)",[keyStr substringToIndex:keyStr.length-1],[valueStr substringToIndex:valueStr.length-1]];
    return sqlString;
}

NSString* deleteString(Class modelClass,NSDictionary* preDict,BOOL isOr)
{
    NSMutableString* deleteStr = [NSMutableString stringWithString:DELETE_HEADER];
    [deleteStr appendString:NSStringFromClass(modelClass)];
    NSString *preStr;
    if (isOr) {
        preStr  = predicate(modelClass, preDict, @"or");
    }else
        preStr  = predicate(modelClass, preDict, @"and");
    if (preStr.length) {
        [deleteStr appendFormat:@" WHERE %@",preStr];
    }
    return deleteStr;
}

NSString* selectString(Class modelClass,NSDictionary* preDict,NSString *sortStr,BOOL isOr)
{
    NSMutableString* selectStr = [NSMutableString stringWithString:SELECT_HEADER];
    [selectStr appendString:NSStringFromClass(modelClass)];
    
    NSString *preStr;
    if (isOr) {
        preStr  = predicate(modelClass, preDict, @"or");
    }else
        preStr  = predicate(modelClass, preDict, @"and");
    
    if (preStr.length) {
        [selectStr appendFormat:@" WHERE %@",preStr];
    }
    if (sortStr.length) {
        [selectStr appendString:sortStr];
    }
    return selectStr;
}

NSString* changeString(Class modelClass,NSDictionary* changeDict,NSDictionary* preDict,BOOL isOr)
{
    NSMutableString* changeStr = [NSMutableString stringWithString:UPDATE_HEADER];
    [changeStr appendString:NSStringFromClass(modelClass)];
    NSString *chaStr = predicate(modelClass, changeDict, @",");
    
    NSString *preStr;
    if (isOr) {
        preStr  = predicate(modelClass, preDict, @"or");
    }else
        preStr  = predicate(modelClass, preDict, @"and");
    
    if (chaStr.length) {
        [changeStr appendFormat:@" SET %@",chaStr];
        if (preStr.length) {
            [changeStr appendFormat:@" WHERE %@",preStr];
        }
        return changeStr;
    }else
        return nil;
}


NSString* freedomString(Class modelClass,NSString* predicateString,NSString* changeString,LJStatement freedomStatement)
{
    NSMutableString* predicateStr;
    switch (freedomStatement) {
        case LJAddStatement:
            predicateStr = [NSMutableString stringWithString:INSERT_HEADER];
            break;
        case LJDeleteStatement:
            predicateStr = [NSMutableString stringWithString:DELETE_HEADER];
            break;
        case LJQueryStatement:
            predicateStr = [NSMutableString stringWithString:SELECT_HEADER];
            break;
        case LJChangeStatement:
            predicateStr = [NSMutableString stringWithString:UPDATE_HEADER];
            break;
        default:
            return nil;
    }
    [predicateStr appendString:NSStringFromClass(modelClass)];
    if (freedomStatement == LJChangeStatement && changeString.length)
        [predicateStr appendFormat:@" SET %@",changeString];
    
    if (predicateString.length)
        [predicateStr appendFormat:@" WHERE %@",predicateString];
    
    return predicateStr;
}

NSString* predicate(Class modelClass,NSDictionary* preDict,NSString *link)
{
    NSDictionary* stateMentDic = [modelClass determineProperties];
    NSMutableString *preStr = [NSMutableString string];
    NSArray *preArray = [preDict allKeys];
    for (NSString *key in preArray) {
        if ([stateMentDic[key] isEqual: @"nsType"]) {
            [preStr appendString:[NSString stringWithFormat:@"%@ = '%@' %@",key ,preDict[key], link]];
        }else if ([stateMentDic[key] isEqual: @"baseType"]){
            [preStr appendString:[NSString stringWithFormat:@"%@ = %@ %@",key ,preDict[key], link]];
        }
    }
    if (preStr.length) {
        return [preStr substringToIndex:preStr.length-link.length - 1];
    }else
        return @"";
}

static NSString* tableNameValueString(NSString* type,NSString* name)
{
    NSString* finalStr = @",";
    NSString* typeStr = (NSString*)type;
    if ([typeStr isEqualToString:@"i"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"INT",finalStr];
    }else if ([typeStr isEqualToString:@"f"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"FLOAT",finalStr];
    }else if ([typeStr isEqualToString:@"B"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"BOOL",finalStr];
    }else if ([typeStr isEqualToString:@"d"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"DOUBLE",finalStr];
    }else if ([typeStr isEqualToString:@"q"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"LONG",finalStr];
    }else if ([typeStr isEqualToString:@"NSData"]||[typeStr isEqualToString:@"UIImage"]) {
        return [NSString stringWithFormat:@"%@ %@%@",name,@"BLOB",finalStr];
    }else if ([typeStr isEqualToString:@"NSNumber"]){
        return [NSString stringWithFormat:@"%@ %@%@",name,@"INT",finalStr];
    } else
        return [NSString stringWithFormat:@"%@ %@%@",name,@"TEXT",finalStr];
}

@end
