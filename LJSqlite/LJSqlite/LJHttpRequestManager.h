//
//  LJHttpRequestManager.h
//  wordNewClasses
//
//  Created by 宋立军 on 16/1/28.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJHttpRequestManager;

typedef void (^httpRequsetBlock)(LJHttpRequestManager *manager);

@interface LJHttpRequestManager : NSObject

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,strong) NSString *error;
@property (nonatomic,strong) NSData *getData;

//post请求
-(id)initPostWithUrlString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)block;

//Get请求
-(id)initGetWithUrlString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)block;

@end

