//
//  NetworkTool.h
//  TestNetwork
//
//  Created by Broc on 2017/5/8.
//  Copyright © 2017年 Broc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface NetworkTool : NSObject
@property (nonatomic, strong) AFHTTPSessionManager *httpRequest;

typedef void(^successBlock)(id responseObject,int index);
typedef void(^failedBlock)(NSError *error);
//服务请求ResCode
typedef NS_ENUM(NSInteger, ServiceResCode){
    GQWNetSuccess   = 1,            //请求成功
    GQWNetParamInvalied = 2,        //参数异常
    GQWNetNeedLogin = 3,            //需要登录
    GQWNetSysInnerException = 9,    //系统内部异常
};
/** 请求成功的Block */
typedef void(^requestSuccessBlock)(id dic);

/** 请求失败的Block */
typedef void(^requestFailureBlock)(NSError *error);



/** 请求任务 */
typedef NSURLSessionTask PPURLSessionTask;


+(NetworkTool *)sharedInstance;



/**
 检测网路状态
 */
+ (void)netWorkStatus;




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
          failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;


/**
	网络访问的post方法
	@param path 访问的路径
	@param delegate 回调方法的代理
	@param params 网络访问的参数
 */
- (void)xsPostPath:(NSString *)path
          delegate:(id)delegate
            params:(NSDictionary *)params
           success:(void (^)(NSURLSessionDataTask *task,id responseObject))success
           failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

/**
 *
 *	取消所有请求
 */
- (void)cancelAllRequest;
/**
 *
 *	取消某个请求。如果是要取消某个请求，最好是引用接口所返回来的HYBURLSessionTask对象，
 *  然后调用对象的cancel方法。如果不想引用对象，这里额外提供了一种方法来实现取消某个请求
 *
 *	@param url				URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */

- (void)cancelRequestWithURL:(NSString *)url;




/**
 测试请求链接

 @param delegate 代理
 @param index 待测index
 @param testUrl 测试接口
 @param success 成功
 @param failure 失败
 */
- (void)getAboutMessageWithdelegate:(id)delegate
                              index:(int)index
                            testUrl:(NSString *)testUrl
                             params:(NSMutableDictionary *)params
                            success:(successBlock)success
                            failure:(failedBlock)failure;

@end
