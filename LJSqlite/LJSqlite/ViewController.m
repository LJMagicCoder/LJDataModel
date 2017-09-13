//
//  ViewController.m
//  LJSqlite
//
//  Created by 宋立军 on 16/3/24.
//  Copyright © 2016年 sancaigongsi. All rights reserved.
//
#define kPOST_TEST [NSString stringWithFormat:@"http://www.dljgb.cn/phone/index.php"]
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width       //屏幕宽度
#define SCREEN_HEIGHTH [[UIScreen mainScreen]bounds].size.height    //屏幕高度

#import "ViewController.h"
#import "LJHttpRequestManager.h"
#import "LJSqliteHeader.h"
#import "LJModel.h"

@interface ViewController ()<UITextViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    [self loadData];
}

- (void)loadUI
{
    UIButton *addBtn = [self loadBtn:1 name:@"增"];
    [addBtn addTarget:self action:@selector(addBtnMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = [self loadBtn:2 name:@"删"];
    [deleteBtn addTarget:self action:@selector(deleteBtnMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *selectedBtn = [self loadBtn:3 name:@"查"];
    [selectedBtn addTarget:self action:@selector(selectedBtnMethod) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *upDataBtn = [self loadBtn:4 name:@"改"];
    [upDataBtn addTarget:self action:@selector(upDataBtnMethod) forControlEvents:UIControlEventTouchUpInside];
    
}

- (UIButton *)loadBtn:(int)num name:(NSString *)name
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *0.8, 40)];
    btn.center = CGPointMake(SCREEN_WIDTH *0.5, SCREEN_HEIGHTH *0.2 *num);
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:name forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    [self.view addSubview:btn];
    return btn;
}
- (void)loadData
{
//    [LJModel lj_dbName:@"LJDBName"];
    [LJModel lj_createTable];
}

- (void)addBtnMethod
{
    NSArray *array = [self falseData];
    [LJModel lj_syncSqliteMethod:[LJSqliteMethod addDataToDBFromArray:array] fail:nil];
}

- (void)deleteBtnMethod
{
    [LJModel lj_syncSqliteMethod:[LJSqliteMethod deleteDataToDBFromDict:nil] fail:nil];
}

- (void)selectedBtnMethod
{
    //    LJSqliteMethod *ljMethod = [LJSqliteMethod selectDataToDBFromDict:nil];//@{@"id":@"5",@"fid":@"1007"}
    LJSqliteMethod *ljMethod = [LJSqliteMethod selectDataToFreedomString:nil];//@"id = '5' or fid = '1019'"
    ljMethod.isOr = YES;
    NSArray *dataArray = [LJModel lj_syncSqliteMethod:ljMethod fail:^(NSError *error) {
        NSLog(@"queryError...%@",error);
    }];
    NSLog(@"queryDataModle%@",dataArray);

//    //异步加载
//    [LJModel lj_asyncSqliteMethod:ljMethod success:^(NSArray *result) {
//        NSLog(@"queryData%@",result);
//        NSArray *dataArray = [LJModel lj_ModelArrayFromDictOrJsonArray:result];
//        NSLog(@"queryDataModle%@",dataArray);
//    } fail:^(NSError *error) {
//        NSLog(@"queryError...%@",error);
//    }];
}

- (void)upDataBtnMethod
{
    [LJModel lj_syncSqliteMethod:[LJSqliteMethod upDataToDBFromArray:@{@"id":@"666",@"fid":@"123a"} statementDict:@{@"id":@"15"}] fail:nil];
    //    [LJModel lj_syncSqliteMethod:[LJSqliteMethod upDataToChangeStr:@"id = 'a' , fid = 'b'" condString:@"id = '9'"] fail:nil];
}

#pragma mark 数据测试
- (NSArray *)falseData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<100; i++) {
        [dict removeAllObjects];
        [dict setObject:[NSString stringWithFormat:@"%d",i] forKey:[NSString stringWithFormat:@"id"]];
        [dict setObject:[NSString stringWithFormat:@"%d",i + 1000] forKey:[NSString stringWithFormat:@"fid"]];
        [dict setObject:[NSString stringWithFormat:@"%d",i + 2000] forKey:[NSString stringWithFormat:@"name"]];
        [dict setObject:[NSString stringWithFormat:@"%d",i + 3000] forKey:[NSString stringWithFormat:@"price"]];
        [array addObject:[dict copy]];
    }
    return array;
}

-(void)downloadData:(void(^)(NSArray *array))Success
{
    LJHttpRequestManager *manager = [[LJHttpRequestManager alloc] initPostWithUrlString:kPOST_TEST parameters:nil andBlock:^(LJHttpRequestManager *manager) {
        @try {
            
            //判断网络请求是否成功
            if (![manager.error isEqualToString:@""])NSLog(@"返回错误！");
            
            Success(manager.data[@"classify"]);
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }];
    NSLog(@"%@",manager);
}


@end
