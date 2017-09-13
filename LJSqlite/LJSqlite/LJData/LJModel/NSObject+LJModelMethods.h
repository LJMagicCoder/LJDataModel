//
//  NSObject+LJModelMethods.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LJModelMethods)

/********************************-object转成model-********************************/
/*!
 @brief 将数组中的Dictionary或Json转成Model，以数组形式传回
 */
+ (NSArray *)lj_ModelArrayFromDictOrJsonArray:(NSArray*)array;

/*!
 @brief 将Dictionary或Json转成Model
 */
+ (id)lj_ModelFromDictionaryOrJson:(id)dicOrJson;

/********************************-model转成object-********************************/
/*!
 @brief 将数组中的Model转成Dictionary（如果是string或data类型会转成json），以数组形式传回
 */
- (NSArray *)lj_DictOrJsonArrayFromModelArray;

/*!
 @brief 将Model转成NSDictionary
 */
- (NSDictionary *)lj_DictionaryFromModel;

/*!
 @brief 将Model转成Json
 */
- (NSData *)lj_JsonFromModel;

/********************************--********************************/

- (NSDictionary*)lj_ModelToDictionary;

+ (NSDictionary*)getAllPropertyNameAndType;

+ (NSDictionary*)determineProperties;

+ (NSString*)getTypeNameWith:(NSString*)propertyName;

@end
