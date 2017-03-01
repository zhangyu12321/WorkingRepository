//
//  ViewController.m
//  BreakpointResumeDome
//
//  Created by MAC15 on 2017/3/1.
//  Copyright © 2017年 MAC15. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()
{
    NSURLSessionDownloadTask * _downloadtask;
}
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //网络监控句柄
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //status:
        //AFNetworkReachabilityStatusUnknown          = -1,  未知
        //AFNetworkReachabilityStatusNotReachable     = 0,   未连接
        //AFNetworkReachabilityStatusReachableViaWWAN = 1,   3G
        //AFNetworkReachabilityStatusReachableViaWiFi = 2,   无线连接
        NSLog(@"%ld", (long)status);
    }];
    
    //准备从远程下载文件. -> 请点击下面开始按钮启动下载任务
    [self downFileFromServer];
    
}

- (void)downFileFromServer{
    
    //  远程地址
    NSString * pdf_url = [NSString stringWithFormat:@"https://yqms.istarshine.com/Public/wangcan/%@.pdf",@"201702"];
    
    NSURL *URL = [NSURL URLWithString:pdf_url];
    
    // 默认配置
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // AFN3.0 + 基于URLsession的句柄
    AFURLSessionManager * manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    // 请求
    NSURLRequest * request = [NSURLRequest requestWithURL:URL];
    
    // 下载你task操作
    _downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // @property int64_t totalUnitCount;     需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
        
        float progress = 1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        NSLog(@"progress == %f",progress);

        dispatch_async(dispatch_get_main_queue(), ^{
            // 回到主线程 刷新
            self.downloadProgressView.progress = progress;
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        // block的返回值 要求返回一个URL 即文件路径
        
        NSString * cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString * path = [cachesPath stringByAppendingString:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        // 设置下载完成操作
        // filePath就是下载文件的位置
        NSString * managerPath = [filePath path];
        NSLog(@"下载文件的位置 %@",managerPath);
        
    }];
}

// 暂停
- (IBAction)stopDownLoad:(id)sender {
    
    [_downloadtask suspend];
}
// 开始
- (IBAction)startDownLoad:(id)sender {
    [_downloadtask resume];

}


@end
















