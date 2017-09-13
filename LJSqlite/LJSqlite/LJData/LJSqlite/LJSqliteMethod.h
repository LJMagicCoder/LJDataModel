//
//  LJSqliteMethod.h
//  LJSqlite
//
//  Created by 宋立军 on 16/4/1.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJSqlite.h"

typedef NS_ENUM(NSInteger,LJStatement){
    LJAddStatement,
    LJDeleteStatement,
    LJQueryStatement,
    LJChangeStatement,
    LJFreedomStatement
};

@class LJSqliteMethodElement;

@interface LJSqliteMethod : NSObject

/********************************-调用以下方法操作数据库-********************************/

@property(nonatomic ,assign)BOOL isOr;      //以下方条件默认为and衔接 isOr设为YES后条件为or衔接

/*!
 @brief     增
 @result    LJSqliteMethod实例
 @param     dataArrayOrModel(字典数组/model数组/字典/model) 要增加的数据
 */
+ (LJSqliteMethod *)addDataToDBFromArray:(id)dataArrayOrModel;

/*!
 @brief     删
 @result    LJSqliteMethod实例
 @param     deleteDict(key为字段，value为条件)(传nil为全删)
 */
+ (LJSqliteMethod *)deleteDataToDBFromDict:(NSDictionary *)deleteDict;

/*!
 @brief     查
 @result    LJSqliteMethod实例
 @param     queryDict(key为字段，value为条件)(传nil为全查)
 */
+ (LJSqliteMethod *)selectDataToDBFromDict:(NSDictionary *)queryDict;
//排序(查)(不调用此方法为默认排序)
- (void)sortisNormalConditions:(NSString *)condStr Sort:(BOOL)normalSort;

/*!
 @brief     改
 @result    LJSqliteMethod实例
 @param     changeDict(要改变的字段)(key为字段，value为条件)(为空无效)   
            statementDict(条件)(key为字段，value为条件)(传nil为所有区域)
 */
+ (LJSqliteMethod *)upDataToDBFromArray:(NSDictionary *)changeDict statementDict:(NSDictionary *)statementDict;



/********************************-自定义谓词操作数据库-********************************/

/*!
 @brief     删(谓语补全) (例子:id = 5 and name = 'abc' or age = 20)
*/
+ (LJSqliteMethod *)deleteDataToFreedomString:(NSString *)freedomString;

/*!
 @brief     查(谓语补全) (例子:id = 5 and name = 'abc' or age = 20)
 */
+ (LJSqliteMethod *)selectDataToFreedomString:(NSString *)freedomString;

/*!
 @brief     改(谓语补全) (例子:changeStr:id = 5 set name = 'abc'   condString:id = 6 and name = 'cba' or age = 21)
 */
+ (LJSqliteMethod *)upDataToChangeStr:(NSString *)changeStr condString:(NSString *)condString;



/********************************--********************************/

@property(nonatomic ,strong)NSArray *dataArray;

@property(nonatomic ,strong)NSString *sqlString;

@property(nonatomic ,assign)LJSqliteType type;

@property(nonatomic ,assign)LJStatement statement;

@property(nonatomic ,strong)NSDictionary *statementDict;

@property(nonatomic ,strong)NSDictionary *changeDict;

@property(nonatomic ,strong)NSString *sortStr;

@property(nonatomic ,assign)LJStatement freedomStatement;

@property(nonatomic ,strong)NSString *freedomStr;

@property(nonatomic ,strong)NSString *changeStr;

- (NSString *)joiningTogetherStatement:(id)idClass;

@end


