//
//  LJObjectInformation.h
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger,LJBaseTypeEcoding) {
    LJBaseTypeEcodingUnknow,
    LJBaseTypeEcodingINT,
    LJBaseTypeEcodingLONG,
    LJBaseTypeEcodingULONG,
    LJBaseTypeEcodingCHAR,
    LJBaseTypeEcodingFLOAT,
    LJBaseTypeEcodingBOOL,
    LJBaseTypeEcodingDOUBLE
};

typedef NS_ENUM(NSUInteger,LJNSTypeEcoding) {
    LJNSTypeUNknow,
    LJNSTypeNSString,
    LJNSTypeNSNumber,
    LJNSTypeNSDate,
    LJNSTypeNSData,
    LJNSTypeNSURL,
    LJNSTypeNSArray,
    LJNSTypeNSDictionary,
    LJNSTypeUIImage
};

//model内的元素的信息
@interface LJObjectInformation : NSObject

@property (nonatomic) Class cls;

@property (nonatomic) objc_property_t property_t;

@property (nonatomic,copy) NSString* name;

@property (nonatomic,assign) LJBaseTypeEcoding baseTypeEcoding;

@property (nonatomic,assign) LJNSTypeEcoding nsTypeEcoding;

@property (nonatomic) SEL set;

@property (nonatomic) SEL get;

@property (nonatomic,copy) NSString* type;

- (instancetype)initWithProperty:(objc_property_t)property;

@end

//model类信息
@interface LJClassInformation : NSObject

@property (nonatomic)Class cls;

@property (nonatomic)Class superClass;

@property (nonatomic)Class metaClass;

@property (nonatomic,assign) BOOL isMetaClass;

@property (nonatomic,strong) NSMutableDictionary* objectInfoDic;

- (instancetype)initWithClass:(Class)cls;

- (LJObjectInformation*)objectInfoWithName:(NSString*)name;

@end



