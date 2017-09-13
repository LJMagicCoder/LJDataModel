//
//  LJObjectInformation.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "LJObjectInformation.h"

@implementation LJObjectInformation

- (instancetype)initWithProperty:(objc_property_t)property
{
    self = [super init];
    if (self) {
        _property_t = property;
        _name = [NSString stringWithUTF8String:property_getName(property)];
        unsigned int count;
        objc_property_attribute_t *t = property_copyAttributeList(property, &count);
        objc_property_attribute_t p = t[0];
        size_t len = strlen(p.value);
        if (len > 3) {
            char name[len - 2];
            name[len - 3] = '\0';
            memcpy(name, p.value + 2, len - 3);
            _cls = objc_getClass(name);
            _type = [NSString stringWithUTF8String:name];
            _nsTypeEcoding = nsTypeEcoding(_type);
        }else {
            _type = [NSString stringWithUTF8String:p.value];
            if (_type.length>1) {
                _type = [_type substringToIndex:1];
            }
            if (_type.length>0) {
                _baseTypeEcoding = baseTypeEcoding([_type characterAtIndex:0]);
            }
        }
        free(t);
        if (_name.length>0) {
            _set = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[_name substringToIndex:1] uppercaseString],[_name substringFromIndex:1]]);
            _get = NSSelectorFromString(_name);
        }
    }
    return self;
}

static LJNSTypeEcoding nsTypeEcoding(NSString *type)
{
    if ([type isEqualToString:@"NSString"]) {
        return LJNSTypeNSString;
    }
    if ([type isEqualToString:@"NSNumber"]) {
        return LJNSTypeNSNumber;
    }
    if ([type isEqualToString:@"NSDate"]) {
        return LJNSTypeNSDate;
    }
    if ([type isEqualToString:@"NSData"]) {
        return LJNSTypeNSData;
    }
    if ([type isEqualToString:@"NSURL"]) {
        return LJNSTypeNSURL;
    }
    if ([type isEqualToString:@"NSArray"]) {
        return LJNSTypeNSArray;
    }
    if ([type isEqualToString:@"NSDictionary"]) {
        return LJNSTypeNSDictionary;
    }
    if ([type isEqualToString:@"UIImage"]) {
        return LJNSTypeUIImage;
    }
    return LJNSTypeUNknow;
}

static LJBaseTypeEcoding baseTypeEcoding(char type)
{
    switch (type) {
        case 'Q':
            return LJBaseTypeEcodingULONG;
        case 'i':
            return LJBaseTypeEcodingINT;
        case 'q':
            return LJBaseTypeEcodingLONG;
        case 'f':
            return LJBaseTypeEcodingFLOAT;
        case 'd':
            return LJBaseTypeEcodingDOUBLE;
        case 'B':
            return LJBaseTypeEcodingBOOL;
        case 'b':
            return LJBaseTypeEcodingBOOL;
        case 'c':
            return LJBaseTypeEcodingCHAR;
        default:
            return LJBaseTypeEcodingUnknow;
    }
}

@end


static NSMutableDictionary* objectInfoCacheDic;

@implementation LJClassInformation

-(NSMutableDictionary *)objectInfoDic
{
    if (!_objectInfoDic) {
        _objectInfoDic = [NSMutableDictionary dictionary];
    }
    return _objectInfoDic;
}

- (instancetype)initWithClass:(Class)cls{
    
    if ([self isCacheWithClass:cls]) {
        return [self classInfoWithClass:cls];
    }
    self = [super init];
    if (self) {
        _cls = cls;
        unsigned int count;
        objc_property_t *t = class_copyPropertyList(cls, &count);
        for (int num = 0; num < count; num++) {
            LJObjectInformation *objectInfo = [[LJObjectInformation alloc]initWithProperty:t[num]];
            [self.objectInfoDic setValue:objectInfo forKey:[NSString stringWithUTF8String:property_getName(t[num])]];
        }
        [self initializeObjectInfoCacheDic];
        [objectInfoCacheDic setValue:self forKey:NSStringFromClass(cls)];
        free(t);
    }
    return self;
}

-(void)initializeObjectInfoCacheDic
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objectInfoCacheDic = [NSMutableDictionary dictionary];
    });
}

- (BOOL)isCacheWithClass:(Class)cls
{
    if ([objectInfoCacheDic objectForKey:NSStringFromClass(cls)]) {
        return YES;
    }
    return NO;
}

- (LJClassInformation*)classInfoWithClass:(Class)cls
{
    return [objectInfoCacheDic objectForKey:NSStringFromClass(cls)];
}

- (LJObjectInformation*)objectInfoWithName:(NSString*)name
{
    return _objectInfoDic[name];
}

@end


