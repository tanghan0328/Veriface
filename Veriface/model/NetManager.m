//
//  NetManager.m
//  Veriface
//
//  Created by tang tang on 2017/11/30.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "NetManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"

#define BASEAPPURLSTRING @"http://10.168.78.42:8080"

@interface NetManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation NetManager

- (void)initSessionManager
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 30;
    configuration.timeoutIntervalForResource = 30;//设置30秒超时
    _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    _sessionManager.requestSerializer.timeoutInterval = 30.f;
    _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

+ (id)sharedManager
{
    static NetManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.baseAPPURLString = BASEAPPURLSTRING;
    });
    return sharedMyManager;
}
//上传图片的封装
- (void)filePostWithPath:(NSString *)path
                    data:(NSData *)data
                    name:(NSString *)name
              parameters:(NSDictionary *)parameters
                complete:(void (^)(id object, NSError *error))complete
{
    if([self stringUrl:path] != nil){
        path = [self stringUrl:path];
    }else{
        return;
    }
     SLog(@"start request %@ ===HTTPRequestHeaders==%@====data==%@", path,_sessionManager.requestSerializer.HTTPRequestHeaders,data);
    [_sessionManager POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:name fileName:@"image.jpg" mimeType:@"image/jpeg"];
        SLog(@"===data======%@",formData);
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SLog(@"end==headers=%@=======>response==post==>: %@",task.response, responseObject);
        [self succeedResponseWithResponseObject:responseObject Complete:complete];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"====error==%@",error);
        [self failResponseWithError:error Complete:complete];
    }];
}

//请求正确封装
- (void)succeedResponseWithResponseObject:(id) responseObject Complete:(void (^)(id object, NSError *error))complete
{
    SLog(@"response==post==>:\n %@",[self convertToJsonData: responseObject]);
    if (complete) {
        if ([[responseObject objectForKey:@"ok"] boolValue]) {
            complete([responseObject valueForKeyPath:@"data"], nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"API"
                                                 code:1000
                                             userInfo:responseObject];
            complete(responseObject, error);
        }
    }
}
//请求错误封装
- (void)failResponseWithError:(NSError *) error Complete:(void (^)(id object, NSError *error))complete
{
    SLog(@"error=============>%@", error);
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 429) {
        error = [NSError errorWithDomain:error.domain
                                    code:error.code
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"请求太频繁，请稍后再试",@"error", nil]];
        complete(nil, error);
        return;
    }
    if ([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 500) {
        error = [NSError errorWithDomain:error.domain
                                    code:error.code
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"内部服务器错误，请稍后再试",@"error", nil]];
        complete(nil, error);
        return;
    }
    if (complete) {
        if (!error) {
            error = [NSError errorWithDomain:@"API"
                                        code:1000
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"服务器错误",@"error", nil]];
        }
        complete(nil, error);
    }
}
//请求操作进行封装
- (void)requestWithMethod:(NSString *)method
                      url:(NSString *)url
               parameters:(id)parameters
                 complete:(void (^)(id object, NSError *error))complete
{
    if([self stringUrl:url] != nil){
        url = [self stringUrl:url];
    }else{
        return;
    }
    
    if([method.uppercaseString isEqualToString:@"POST"]){
        [_sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self succeedResponseWithResponseObject:responseObject Complete:complete];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self failResponseWithError:error Complete:complete];
        }];
        
    }else if([method.uppercaseString isEqualToString:@"DELETE"]){
        [_sessionManager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self succeedResponseWithResponseObject:responseObject Complete:complete];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self initSessionManager];
            [self failResponseWithError:error Complete:complete];
        }];
    }else if([method.uppercaseString isEqualToString:@"PUT"]){
        [_sessionManager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            [self succeedResponseWithResponseObject:responseObject Complete:complete];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self initSessionManager];
            [self failResponseWithError:error Complete:complete];
        }];
    }else{
        NSString *str1 = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [_sessionManager GET:str1 parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            [self succeedResponseWithResponseObject:responseObject Complete:complete];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self failResponseWithError:error Complete:complete];
            
        }];
    }
}

-(void)requestAuthFaceWithData:(NSData *)data
                            complete:(void (^)(id object, NSError *error))complete {
    [self filePostWithPath:@"/Test/returnSuccess"
                      data:data
                      name:@"photo"
                parameters:nil
                  complete:complete];
}

-(void)requestLoadFaceWithData:(NSData *)data
                          name:(NSString *)name
                    employeeID:(NSString *)employeeID
                   photoNumber:(int)photoNumber
                      complete:(void (^)(id object, NSError *error))complete {
    [self filePostWithPath:@"/messenger/api/v2/auth.faceDetect"
                      data:data
                      name:@"photo"
                parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                            name,@"employeeName",
                            employeeID,@"employeeID",
                            photoNumber,@"photoNumber",nil]
                  complete:complete];
}

//确认打卡
-(void)requestAuthFaceWithResult:(BOOL) confirm
                      employeeID:(NSString *)employeeID
                        complete:(void (^)(id object, NSError *error))complete
{
    [self requestWithMethod:@"POST"
                        url:@"/Test/returnSuccess"
                 parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:confirm],@"confirm", nil]
                   complete:complete];
}

//拼装URL地址
- (NSString *)stringUrl:(NSString *)url
{
    if(url.length >0){
        if ([url hasPrefix:@"/"]) {
            url = [NSString stringWithFormat:@"%@%@",self.baseAPPURLString ,[url substringFromIndex:1]];
        }
        return url;
    }else{
        return nil;
    }
}

-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
