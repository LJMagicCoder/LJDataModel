//
//  LJHttpRequestManager.m
//  wordNewClasses
//
//  Created by 宋立军 on 16/1/28.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//

#import "LJHttpRequestManager.h"
#import "AFNetworking.h"

@interface LJHttpRequestManager()

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
@end

@implementation LJHttpRequestManager


//post请求
-(id)initPostWithUrlString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)block{
    if (self = [super init]) {
        [self requestPostDataWithString:url parameters:dic andBlock:block];
    }
    return self;
}

-(void)requestPostDataWithString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)tempBlock{
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    //申明返回的结果是json类型
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //申明请求的数据是json类型
    //    _manager.requestSerializer=[AFJSONRequestSerializer serializer];
    
    //如果报接受类型不一致请替换一致text/html或别的
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/x-json",@"text/html",nil];
    
    [_manager POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //解析
        self.data = responseObject;
        self.error = @"";
        tempBlock(self);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.error = error.localizedDescription;
        
        tempBlock(self);
    }];
}

//get请求
-(id)initGetWithUrlString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)block{
    if (self = [super init]) {
        [self requestDataWithString:url parameters:dic andBlock:block];
    }
    return self;
}
-(void)requestDataWithString:(NSString *)url parameters:(NSDictionary *)dic andBlock:(httpRequsetBlock)tempBlock{
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSArray *key = [dic allKeys];
    NSArray *value = [dic allValues];
    
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < dic.count; i++) {
        [string appendString:[NSString stringWithFormat:@"/%@/%@",key[i],value[i]]];
    }
    
    NSString *finalUrl;
    if (dic.count > 0) {
        finalUrl = [NSString stringWithFormat:@"%@%@",url,[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        finalUrl = url;
    }
    
    [_manager GET:finalUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //解析
        self.getData = responseObject;
        self.error = @"";
        tempBlock(self);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.error = error.localizedDescription;
        tempBlock(self);
    }];
}
@end

