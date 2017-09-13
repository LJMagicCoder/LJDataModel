//
//  LJSqliteMethod.m
//  LJSqlite
//
//  Created by 宋立军 on 16/4/1.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "LJSqliteMethod.h"
#import "LJSqliteStatement.h"

@implementation LJSqliteMethod

- (NSString *)joiningTogetherStatement:(id)idClass
{
    switch (self.statement) {
        case LJAddStatement:
            return insertString(idClass);
        case LJDeleteStatement:
            return deleteString(idClass, self.statementDict, self.isOr);
        case LJQueryStatement:
            return selectString(idClass, self.statementDict,self.sortStr, self.isOr);
        case LJChangeStatement:
            return changeString(idClass, self.changeDict, self.statementDict, self.isOr);
        case LJFreedomStatement:
            return freedomString(idClass, self.freedomStr,  self.changeStr, self.freedomStatement);
        default:
            return nil;
    }
}

-(instancetype)initWithDataArray:(id)data
{
    self = [super init];
    if (self) {
        if ([data isKindOfClass:[NSArray class]]) {
            self.dataArray = data;
        }else{
            self.dataArray = [NSArray arrayWithObject:data];
        }
    }
    return self;
}

+ (LJSqliteMethod *)addDataToDBFromArray:(id)dataArrayOrModel
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]initWithDataArray:dataArrayOrModel];
    method.type = LJSqliteTypeWrite;
    method.statement = LJAddStatement;
    return method;
}

+ (LJSqliteMethod *)deleteDataToDBFromDict:(NSDictionary *)deleteDict
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.statementDict = deleteDict;
    method.type = LJSqliteTypeWrite;
    method.statement = LJDeleteStatement;
    return method;
}

+ (LJSqliteMethod *)selectDataToDBFromDict:(NSDictionary *)queryDict
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.statementDict = queryDict;
    method.type = LJSqliteTypeRead;
    method.statement = LJQueryStatement;
    return method;
}

- (void)sortisNormalConditions:(NSString *)condStr Sort:(BOOL)normalSort
{
    if (condStr) {
        if (normalSort) {
            self.sortStr = [NSString stringWithFormat:@" ORDER BY %@ ASC",condStr];
        }else
            self.sortStr = [NSString stringWithFormat:@" ORDER BY %@ DESC",condStr];
    }
}

+ (LJSqliteMethod *)upDataToDBFromArray:(NSDictionary *)changeDict statementDict:(NSDictionary *)statementDict
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.changeDict = changeDict;
    method.statementDict = statementDict;
    method.type = LJSqliteTypeWrite;
    method.statement = LJChangeStatement;
    return method;
}

+ (LJSqliteMethod *)deleteDataToFreedomString:(NSString *)freedomString
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.type = LJSqliteTypeWrite;
    method.statement = LJFreedomStatement;
    method.freedomStatement = LJDeleteStatement;
    method.freedomStr = freedomString;
    return method;
}

+ (LJSqliteMethod *)selectDataToFreedomString:(NSString *)freedomString
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.type = LJSqliteTypeRead;
    method.statement = LJFreedomStatement;
    method.freedomStatement = LJQueryStatement;
    method.freedomStr = freedomString;
    return method;
}

+ (LJSqliteMethod *)upDataToChangeStr:(NSString *)changeStr condString:(NSString *)condString
{
    LJSqliteMethod *method = [[LJSqliteMethod alloc]init];
    method.type = LJSqliteTypeWrite;
    method.statement = LJFreedomStatement;
    method.freedomStatement = LJChangeStatement;
    method.changeStr = changeStr;
    method.freedomStr = condString;
    return method;
}


@end

