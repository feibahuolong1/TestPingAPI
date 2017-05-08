//
//  ViewController.m
//  TestNetwork
//
//  Created by Broc on 2017/5/8.
//  Copyright © 2017年 Broc. All rights reserved.
//

#import "ViewController.h"
#import "NetworkTool.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource> {
    // 待测数组
    NSArray *_baseArray;
    // 待测接口
    NSString *_testStr;
    UITableView *_tabView;
    // 是否ping通数组
    NSMutableArray *_isCanPingArray;
    // 开始请求的时间数组
    NSMutableArray *_timeArray;
    // 连接时间的数组
    NSMutableArray *_pingTimeArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 待测试列表
    
    _baseArray = @[@"https://api.weibo.com/oauth2"];
    // 待测接口
    _testStr = @"access_token";
    
    
    //是否能链接
    _isCanPingArray = [[NSMutableArray alloc]init];
    //连接时间
    _pingTimeArray = [[NSMutableArray alloc]init];
    for (NSString *baser in _baseArray) {
        NSLog(@"-- base %@",baser);
        [_isCanPingArray addObject:@"false"];
        [_pingTimeArray addObject:@"0 ms"];
    }
    // 表
    _tabView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tabView.frame = CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 170);
    _tabView.delegate = self;
    _tabView.dataSource = self;
    [self.view addSubview:_tabView];
    
    //刷新
    UIButton *testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame = CGRectMake(100, [UIScreen mainScreen].bounds.size.height - 80, [UIScreen mainScreen].bounds.size.width - 200, 50);
    testBtn.backgroundColor = [UIColor redColor];
    [testBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(checkPing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    // 检查链接
    [self checkPing];
}
- (void)checkPing {
    _timeArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < _baseArray.count; i++) {
        // baseURL重新初始化
        [NetworkTool sharedInstance].httpRequest = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[_baseArray objectAtIndex:i]] ];
        [NetworkTool sharedInstance].httpRequest.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [NetworkTool sharedInstance].httpRequest.requestSerializer.timeoutInterval = 2;
        [[NetworkTool sharedInstance].httpRequest.requestSerializer setValue:@"ganqianwangnewApp/1.8" forHTTPHeaderField:@"User-Agent"];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        // 开始请求的时间
         [_timeArray addObject:[NSDate date]];
        
        //开始请求 testUrl:要测试的接口   params:接口需要参数以字典形式传过去
        [[NetworkTool sharedInstance] getAboutMessageWithdelegate:self index:i testUrl:_testStr params:nil success:^(id responseObject,int index) {
            [_isCanPingArray setObject:@"true" atIndexedSubscript:i];
            UInt64 oldTime = [_timeArray[i] timeIntervalSince1970]*1000;
            UInt64 nowTime = [[NSDate date] timeIntervalSince1970]*1000;
            [_pingTimeArray setObject:[NSString stringWithFormat:@"%llu ms",nowTime - oldTime] atIndexedSubscript:i];
            [_tabView reloadData];
        } failure:^(NSError *error) {
            [_isCanPingArray setObject:@"false" atIndexedSubscript:i];
            UInt64 oldTime = [_timeArray[i] timeIntervalSince1970]*1000;
            UInt64 nowTime = [[NSDate date] timeIntervalSince1970]*1000;
            [_pingTimeArray setObject:[NSString stringWithFormat:@"Error-%llu ms",nowTime - oldTime] atIndexedSubscript:i];
            [_tabView reloadData];
        }];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _baseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idStr = @"cell_";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idStr];
    if (!cell ) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:idStr];
    }
    // 只保留服务器地址
    NSString *baseUrl = _baseArray[indexPath.row];
    if([baseUrl rangeOfString:@"/"].location != NSNotFound && ![baseUrl isEqualToString:@""]) {
        cell.textLabel.text = [baseUrl componentsSeparatedByString:@"/"][2];
    }
    cell.detailTextLabel.text = _pingTimeArray[indexPath.row];
    if ([(NSString *)_isCanPingArray[indexPath.row ] isEqualToString:@"false"]) {
        cell.textLabel.textColor = [UIColor redColor];
        
    } else {
        cell.textLabel.textColor = [UIColor greenColor];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
