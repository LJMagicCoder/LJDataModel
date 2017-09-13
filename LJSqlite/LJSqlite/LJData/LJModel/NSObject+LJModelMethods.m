//
//  NSObject+LJModelMethods.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "NSObject+LJModelMethods.h"
#import "LJObjectInformation.h"
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>

@implementation NSObject (LJModelMethods)

typedef struct {
    void *classInfo;
    void *model;
} ModelContext;

#pragma mark - modelFromObject

+ (NSArray *)lj_ModelArrayFromDictOrJsonArray:(NSArray*)array
{
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        [modelArray addObject:[self lj_ModelFromDictionaryOrJson:dict]];
    }
    return modelArray;
}

+ (id)lj_ModelFromDictionaryOrJson:(id)dicOrJson
{
    if (!dicOrJson) return nil;
    if ([dicOrJson isKindOfClass:[NSDictionary class]]) {
        return [self lj_ModelFromDictionary:(NSDictionary*)dicOrJson];
    }
    NSData* jsonData;
    if ([dicOrJson isKindOfClass:[NSString class]]) {
        jsonData = [(NSString*)dicOrJson dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([dicOrJson isKindOfClass:[NSData class]])
        jsonData = dicOrJson;
    if (jsonData) {
        return [self lj_ModelFromDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil]];
    }
    return nil;
}

+ (id)lj_ModelFromDictionary:(NSDictionary*)dic
{
    if (!dic ||![dic isKindOfClass:[NSDictionary class]]) return nil;
    NSObject *object = [[self alloc]init];
    ModelContext modelContext = {0};
    LJClassInformation *class = [[LJClassInformation alloc]initWithClass:self];
    modelContext.model = (__bridge void *)(object);
    modelContext.classInfo = (__bridge void *)(class);
    CFDictionaryApplyFunction((__bridge CFDictionaryRef)dic, ModelSetValueToProperty, &modelContext);
    return object;
}

static void ModelSetValueToProperty(const void *key, const void *value, void *context)
{
    ModelContext *modelContext = context;
    NSString* dicKey = (__bridge NSString *)(key);
    id dicValue = (__bridge id)(value);
    LJObjectInformation *objectInfo = [((__bridge LJClassInformation*)modelContext->classInfo) objectInfoWithName:dicKey];
    NSObject *object = (__bridge NSObject *)modelContext->model;
    if (objectInfo.cls) {
        setNSTypePropertyValue(object, dicValue, objectInfo.nsTypeEcoding, objectInfo.set);
    }else if (objectInfo.type.length){
        NSNumber* number = numberWithValue(dicValue);
        setBaseTypePropertyValue(object, number, objectInfo.baseTypeEcoding,objectInfo.set);
    }
}

#pragma mark - objectFromModel

-(NSArray *)lj_DictOrJsonArrayFromModelArray
{
    NSMutableArray *dictArray = [NSMutableArray array];
    for (id model in (NSArray *)self) {
        [dictArray addObject:[model lj_DictionaryFromModel]];
    }
    return dictArray;
}

- (NSData *)lj_JsonFromModel{
    return [NSJSONSerialization dataWithJSONObject:[self lj_DictionaryFromModel] options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSDictionary *)lj_DictionaryFromModel
{
    if ([self isKindOfClass:[NSArray class]]) {
        return nil;
    }else if ([self isKindOfClass:[NSDictionary class]]){
        return (NSDictionary*)self;
    }else if ([self isKindOfClass:[NSString class]]||[self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:dataFromObject(self) options:NSJSONReadingMutableContainers error:nil];
    }else {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        ModelContext context = {0};
        context.classInfo = (__bridge void *)(dic);
        context.model = (__bridge void *)(self);
        LJClassInformation* classInfo = [[LJClassInformation alloc] initWithClass:object_getClass(self)];
        CFDictionaryApplyFunction((__bridge CFMutableDictionaryRef)classInfo.objectInfoDic, ModelGetValueToDic, &context);
        return dic;
    }
    return nil;
}

static void ModelGetValueToDic(const void* key,const void* value,void* context)
{
    ModelContext* modelContext = context;
    NSMutableDictionary* dic = (__bridge NSMutableDictionary *)(modelContext->classInfo);
    id object = (__bridge id)(modelContext->model);
    NSString* dicKey = (__bridge NSString *)(key);
    LJObjectInformation* objectInfo = (__bridge LJObjectInformation*)(value);
    if (objectInfo) {
        if (objectInfo.cls) {
            [dic setValue:((id(*)(id,SEL))(void*) objc_msgSend)(object,objectInfo.get) forKey:dicKey];
        }else if (objectInfo.type.length>0) {
            NSNumber* number = getBaseTypePropertyValue(object, objectInfo.baseTypeEcoding, objectInfo.get);
            [dic setValue:number forKey:dicKey];
        }
    }
}

static NSNumber* getBaseTypePropertyValue(__unsafe_unretained NSObject* object, NSUInteger type,SEL get)
{
    switch (type) {
        case LJBaseTypeEcodingINT:
            
            return @(((int (*)(id, SEL))(void *) objc_msgSend)(object, get));
            
        case LJBaseTypeEcodingLONG:
            
            return @(((long (*)(id, SEL))(void *) objc_msgSend)(object,get));
            
        case LJBaseTypeEcodingULONG:
            
            return @(((NSUInteger(*)(id,SEL))(void*) objc_msgSend)(object,get));
            
        case LJBaseTypeEcodingFLOAT:
            
            return @(((float(*)(id,SEL))(void*) objc_msgSend)(object,get));
            
        case LJBaseTypeEcodingDOUBLE:
            
            return @(((double(*)(id,SEL))(void*) objc_msgSend)(object,get));
            
        case LJBaseTypeEcodingBOOL:
            
            return @(((BOOL(*)(id,SEL))(void*) objc_msgSend)(object,get));
            
        case LJBaseTypeEcodingCHAR:
            
            return @(((char(*)(id,SEL))(void*) objc_msgSend)(object,get));
            
        default:
            return nil;
            break;
    }
}

static void setNSTypePropertyValue(__unsafe_unretained id object,__unsafe_unretained id value,LJNSTypeEcoding typeEcoding,SEL set)
{
    switch (typeEcoding) {
        case LJNSTypeUNknow:
            ((void(*)(id,SEL,id))(void*) objc_msgSend)(object,set,value);
            break;
            
        case LJNSTypeNSString:
            ((void(*)(id,SEL,id))(void*) objc_msgSend)(object,set,stringFromObject(value));
            break;
            
        case LJNSTypeNSNumber:
            ((void(*)(id,SEL,NSNumber*))(void*) objc_msgSend)(object,set,numberWithValue(value));
            break;
            
        case LJNSTypeNSDate:
            ((void(*)(id,SEL,NSDate*))(void*) objc_msgSend)(object,set,dateFromObject(value));
            break;
            
        case LJNSTypeNSData:
            ((void(*)(id,SEL,NSData*))(void*) objc_msgSend)(object,set,dataFromObject(value));
            break;
            
        case LJNSTypeNSURL:
            ((void(*)(id,SEL,NSURL*))(void*) objc_msgSend)(object,set,urlFromObject(value));
            break;
            
        case LJNSTypeNSArray:
            ((void(*)(id,SEL,NSArray*))(void*) objc_msgSend)(object,set,arrayFromObject(value));
            break;
            
        case LJNSTypeNSDictionary:
            ((void(*)(id,SEL,NSDictionary*))(void*) objc_msgSend)(object,set,dicFromObject(value));
            break;
            
        case LJNSTypeUIImage:
            ((void(*)(id,SEL,UIImage*))(void*) objc_msgSend)(object,set,imageFromObject(value));
            break;
            
        default:
            break;
    }
}

static void setBaseTypePropertyValue(__unsafe_unretained NSObject* object,__unsafe_unretained NSNumber* value, NSUInteger type,SEL set)
{
    switch (type) {
        case LJBaseTypeEcodingINT:
            ((void (*)(id, SEL, int))(void *) objc_msgSend)(object, set, value.intValue);
            break;
            
        case LJBaseTypeEcodingLONG:
            ((void(*)(id,SEL,long))(void*) objc_msgSend)(object,set,value.integerValue);
            break;
            
        case LJBaseTypeEcodingULONG:
            ((void(*)(id,SEL,long))(void*) objc_msgSend)(object,set,value.unsignedIntegerValue);
            break;
            
        case LJBaseTypeEcodingFLOAT:
            ((void(*)(id,SEL,float))(void*) objc_msgSend)(object,set,value.floatValue);
            break;
            
        case LJBaseTypeEcodingDOUBLE:
            ((void(*)(id,SEL,double))(void*) objc_msgSend)(object,set,value.doubleValue);
            break;
            
        case LJBaseTypeEcodingBOOL:
            ((void(*)(id,SEL,BOOL))(void*) objc_msgSend)(object,set,value.boolValue);
            break;
            
        case LJBaseTypeEcodingCHAR:
            ((void(*)(id,SEL,char))(void*) objc_msgSend)(object,set,value.charValue);
            break;
            
        default:
            ((void(*)(id,SEL,id))(void*) objc_msgSend)(object,set,nil);
            break;
    }
}

static NSNumber* numberWithValue(__unsafe_unretained id value)
{
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        if ([value containsString:@"."]) {
            const char *cstring = ((NSString *)value).UTF8String;
            if (!cstring) return nil;
            double num = atof(cstring);
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }else {
            const char *cstring = ((NSString*)value).UTF8String;
            if (!cstring) return nil;
            return @(atoll(cstring));
        }
    }
    return nil;
}

static NSDate* dateFromObject(id object)
{
    if ([object isKindOfClass:[NSDate class]]) {
        return object;
    }else if ([object isKindOfClass:[NSString class]]) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [formatter dateFromString:object];
    }else if ([object isKindOfClass:[NSData class]]) {
        NSString* dateStr = [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [formatter dateFromString:dateStr];
    }else
        return object;
}

static NSString* stringFromObject(id object)
{
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    }else if ([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    }else if ([object isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding];
    }else if ([object isKindOfClass:[NSDate class]]) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [formatter stringFromDate:object];
    }else
        return object;
}

static NSData* dataFromObject(id object)
{
    if ([object isKindOfClass:[NSData class]]) {
        return object;
    }else if ([object isKindOfClass:[NSString class]]) {
        return [object dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([object isKindOfClass:[NSDate class]]) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        return [[formatter stringFromDate:object] dataUsingEncoding:NSUTF8StringEncoding];
    }else if ([object isKindOfClass:[NSArray class]]||[object isKindOfClass:[NSDictionary class]]) {
        return [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    }else if ([object isKindOfClass:NSClassFromString(@"UIImage")]) {
        return UIImageJPEGRepresentation(object, 1);
    }else
        return [object dataUsingEncoding:NSUTF8StringEncoding];
}

static NSURL* urlFromObject(id object)
{
    if ([object isKindOfClass:[NSURL class]]) {
        return object;
    }else if ([object isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:[object stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else  {
        return [NSURL URLWithString:[[[NSString alloc] initWithData:dataFromObject(object) encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
}

static NSArray* arrayFromObject(id object)
{
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    }else if ([object isKindOfClass:[NSDictionary class]]){
        return nil;
    }else {
        id value = [NSJSONSerialization JSONObjectWithData:dataFromObject(object) options:NSJSONReadingMutableContainers error:nil];
        if ([value isKindOfClass:[NSArray class]]) {
            return value;
        }
        return nil;
    }
}

static NSDictionary* dicFromObject(id object)
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return object;
    }else {
        NSData* data = dataFromObject(object);
        id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([value isKindOfClass:[NSDictionary class]]) {
            return value;
        }
        return nil;
    }
}

static UIImage* imageFromObject(id object)
{
    if ([object isKindOfClass:[UIImage class]]) {
        return object;
    }else {
        return [UIImage imageWithData:dataFromObject(object)];
    }
}

- (NSDictionary*)lj_ModelToDictionary
{
    if ([self isKindOfClass:[NSArray class]]) {
        return nil;
    }else if ([self isKindOfClass:[NSDictionary class]]){
        return (NSDictionary*)self;
    }else if ([self isKindOfClass:[NSString class]]||[self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:dataFromObject(self) options:NSJSONReadingMutableContainers error:nil];
    }else {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        ModelContext context = {0};
        context.classInfo = (__bridge void *)(dic);
        context.model = (__bridge void *)(self);
        //判断缓存中是否有这个类的信息
        LJClassInformation* classInfo = [[LJClassInformation alloc] initWithClass:object_getClass(self)];
        CFDictionaryApplyFunction((__bridge CFMutableDictionaryRef)classInfo.objectInfoDic, ModelGetValueToDic, &context);
        return dic;
    }
    return nil;
}

+ (NSDictionary*)getAllPropertyNameAndType
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t* property_t = class_copyPropertyList(self, &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        NSString* propertyName = [NSString stringWithUTF8String:property_getName(propert)];
        NSString* propertyType = [NSString stringWithUTF8String:property_getAttributes(propert)];
        [dic setValue:objectType(propertyType) forKey:propertyName];
    }
    free(property_t);
    return dic;
}

+ (NSDictionary*)determineProperties
{
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    objc_property_t* property_t = class_copyPropertyList(self, &count);
    for (int i=0; i<count; i++) {
        objc_property_t propert = property_t[i];
        NSString* propertyName = [NSString stringWithUTF8String:property_getName(propert)];
        
        unsigned int counts;
        objc_property_attribute_t *t = property_copyAttributeList(propert, &counts);
        objc_property_attribute_t p = t[0];
        size_t len = strlen(p.value);
        if (len > 3) {
            [attributeDict setValue:@"nsType" forKey:propertyName];
        }else
            [attributeDict setValue:@"baseType" forKey:propertyName];
    }
    return attributeDict;
}

static id objectType(NSString* typeString)
{
    if ([typeString containsString:@"@"]) {
        NSArray* strArray = [typeString componentsSeparatedByString:@"\""];
        if (strArray.count >= 1) {
            return strArray[1];
        }else
            return nil;
    }else
        return [typeString substringWithRange:NSMakeRange(1, 1)];
}

+ (NSString*)getTypeNameWith:(NSString*)propertyName
{
    NSString* typeStr = [[self getAllPropertyNameAndType]valueForKey:propertyName];
    if ([typeStr isEqualToString:@"i"]) {
        return @"INT";
    }else if ([typeStr isEqualToString:@"f"]) {
        return @"FLOAT";
    }else if ([typeStr isEqualToString:@"B"]) {
        return @"BOOL";
    }else if ([typeStr isEqualToString:@"d"]) {
        return @"DOUBLE";
    }else if ([typeStr isEqualToString:@"q"]) {
        return @"LONG";
    }else if ([typeStr isEqualToString:@"NSData"]||[typeStr isEqualToString:@"UIImage"]) {
        return @"BLOB";
    }else if ([typeStr isEqualToString:@"NSNumber"]){
        return @"INT";
    } else
        return @"TEXT";
}

@end

