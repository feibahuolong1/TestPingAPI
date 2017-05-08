//
//  NetworkTool.m
//  TestNetwork
//
//  Created by Broc on 2017/5/8.
//  Copyright © 2017年 Broc. All rights reserved.
//

// 状态码
#define kNetWorkCode         @"code"
// 数据实体
#define kNetWorkDataBody     @"data"
// 列表实体
#define kNetWorkList         @"list"
// 错误信息
#define kNetWorErrorMsg      @"message"
// 错误域
#define kErrorCMMDomain      @"kNetWorkErrorDomain"
#import "NetworkTool.h"
static NSMutableArray *zx_requestTasks;
@implementation NetworkTool
+(NetworkTool *)sharedInstance
{
    static dispatch_once_t  onceToken;
    static NetworkTool * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[NetworkTool alloc] init];
    });
    return sSharedInstance;
}


#pragma mark 检测网路状态
+ (void)netWorkStatus{
    
    /**
     *  AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     *  AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     *  AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G
     *  AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络Wifi
     */
    // 如果要检测网络状态的变化, 必须要用检测管理器的单例startMoitoring
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if(status == AFNetworkReachabilityStatusNotReachable){
//            [CMMUtility showMyNewNote:@"网络连接已断开，请检查您的网络！"];
//            userModel.hasNet = NO;
            return ;
            
        }else{
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:QM_HASNET_NOTIFICATION_KEY object:nil];
//            userModel.hasNet = YES;
        }
    }];
    
}


- (id)init {
    if (self = [super init]) {
        _httpRequest = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""] ];
        _httpRequest.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _httpRequest.requestSerializer.timeoutInterval = 2;
        [_httpRequest.requestSerializer setValue:@"ganqianwangnewApp/1.8" forHTTPHeaderField:@"User-Agent"];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    
    return self;
}

//测试信息
- (void)getAboutMessageWithdelegate:(id)delegate
                              index:(int)index
                            testUrl:(NSString *)testUrl
                             params:(NSMutableDictionary *)params
                            success:(successBlock)success
                            failure:(failedBlock)failure{
    // 在这里修改请求接口
    [[NetworkTool sharedInstance] xsPostPath:testUrl delegate:delegate params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self catchNetResWithResInfo:responseObject index:index success:success error:failure delegate:delegate path:testUrl];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
    
}
-(NSMutableDictionary *)buildParametersDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    return dic;
}
//字典转Json字符串
- (NSString *)JsonStringWhthDict:(NSDictionary *)dict
{
    if (dict == nil) {
        return @"";
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}



/**
	网络访问的get方法
	@param path 访问的路径
	@param delegate 回调方法的代理
	@param params 网络请求的参数
 */
- (void)xsGetPath:(NSString *)path
         delegate:(id)delegate
           params:(NSDictionary *)params
          success:(void (^)(NSURLSessionDataTask *task,id responseObject))success
          failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure
{
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    PPURLSessionTask *session=nil;
    session = [_httpRequest GET:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        //        DLog(@"-----网络响应数据----%@",responseObject);
        NSLog(@"-----json字符串----%@",[self JsonStringWhthDict:responseObject]);
        success(task,responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        //        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"---------%@",error);
    }];
    if (session) {
        [[self allTasks] addObject:session];
    }
}


/**
	网络访问的post方法
	@param path 访问的路径
	@param delegate 回调方法的代理
	@param params 网络访问的参数
 */
- (void)xsPostPath:(NSString *)path
          delegate:(id)delegate
            params:(NSDictionary *)params
           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    PPURLSessionTask *session=nil;
    session = [_httpRequest POST:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        //        DLog(@"-----网络响应数据----%@",responseObject);
        NSLog(@"-----json字符串----%@",[self JsonStringWhthDict:responseObject]);
        success(task,responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        //        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"---------%@",error);
    }];
    if (session) {
        [[self allTasks] addObject:session];
    }
}





- (NSMutableArray *)allTasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(zx_requestTasks == nil){
            zx_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    return zx_requestTasks;
}


- (void)cancelRequestWithURL:(NSString *)url {
    
    if (url == nil) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(PPURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[PPURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

/**
 *
 *  取消所有请求
 */
- (void)cancelAllRequest
{
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(PPURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if([task isKindOfClass:[PPURLSessionTask class]]){
                [task cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    };
}

/**
 统一的数据处理
 @param info 网络返回的data
 */
-(void)catchNetResWithResInfo:(id )info
                        index:(int)index
                      success:(void(^)(id resBody,int index)) success
                        error:(void(^)(NSError* error)) failure
                     delegate:(UIViewController *) delegate
                         path:(NSString *)path
{
    
    if (delegate == nil) {
        return;
    }
    //if ([delegate isKindOfClass:[UIViewController class]]) {
   // [YXSpritesLoadingView dismiss];
    //}
    //网络请求成功
    NSDictionary *dic = (NSDictionary *)info ;
    
    NSNumber *resCode = [dic objectForKey:kNetWorkCode];
    
    switch (resCode.integerValue) {
        case GQWNetSuccess:
            //成功
        {
            NSDictionary *data = [dic objectForKey:kNetWorkDataBody];
            if (success) {
                success(data,index);
            }
        }
            break;
        case GQWNetParamInvalied:
            //失败，参数异常
//            [CMMUtility showNote:@"提交的参数异常,请检查后重新提交!"];
            break;
        case GQWNetNeedLogin:
            //失败，用户未登录
        {
            
//            userModel.isLogin = NO;
            
            //自动登录
//            userInfoModel *userinfo = [[QMAccountUtil sharedInstance] currentAccount];
//            if (!QM_IS_STR_NIL(userinfo.phoneNumber) && !QM_IS_STR_NIL(userinfo.password) && !userModel.isLogin) {
//                [[GQWNetMethod sharedInstance]userLoginWithPhoneNumber:userinfo.phoneNumber pwd:userinfo.password delegate:self success:^(id responseObject) {
//                    
//                    //userModel.isLogin = YES;
//                    
//                } failure:^(NSError *error) {
//                    
//                    //清除手机号，密码
//                    //[[QMAccountUtil sharedInstance] clearPasswordFromKeyChain];
//                    
//                }];
//            }
            
            
            
            //            [CMMUtility showTMPLogin];
            //登陆异常
            NSError *error = [NSError errorWithDomain:kErrorCMMDomain code:resCode.integerValue userInfo:nil];
            if (failure) {
                failure(error);
            }
        }
            break;
        case GQWNetSysInnerException:
            //失败，系统异常
        {
            NSDictionary *data = [dic objectForKey:kNetWorkDataBody];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                NSString *msg = [data objectForKey:kNetWorErrorMsg];
                // NSLog(@"errorMSG:%@",msg);
                if (msg) {
                    NSError *error = [NSError errorWithDomain:kErrorCMMDomain code:GQWNetSysInnerException userInfo:[NSDictionary dictionaryWithObject:msg forKey:kNetWorErrorMsg]];
                    failure(error);
                }else {
                   // [CMMUtility showNote:@"抱歉,系统异常,请稍候重试!"];
                }
            }
            failure([NSError errorWithDomain:kErrorCMMDomain code:resCode.intValue userInfo:nil]);
        }
            
            break;
        default:
        {
            NSString *errorMSG = [dic objectForKey:kNetWorErrorMsg];
            if (errorMSG && [errorMSG isKindOfClass:[NSString class]]) {
                NSMutableDictionary *errorData = [NSMutableDictionary dictionaryWithCapacity:1];
                [errorData setObject:errorMSG forKey:kNetWorErrorMsg];
                // NSLog(@"msg:%@",errorMSG);
                failure([NSError errorWithDomain:kErrorCMMDomain code:resCode.intValue userInfo:errorData]);
            }else {
                failure([NSError errorWithDomain:kErrorCMMDomain code:resCode.intValue userInfo:nil]);
            }
        }
            break;
    }
}

@end
