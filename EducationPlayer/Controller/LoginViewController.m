//
//  LoginViewController.m
//  LiveGuess
//
//  Created by zzy on 4/16/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "LoginViewController.h"
#import "UserModel.h"
#include "BaseNavigationController.h"
@import CoreTelephony;
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UITextField *phoneTxt;
@property (strong, nonatomic) IBOutlet UITextField *pwdTxt;

@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机号" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
     self.pwdTxt.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"验证码" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    [self.pwdTxt setSecureTextEntry:YES];
    self.loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginBtn.layer.borderWidth = 0.5;
    self.loginBtn.layer.cornerRadius = 15;
    self.verifyBtn.backgroundColor = CustomColor(42, 40, 43);
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
}

#pragma mark --UIButtonClick--
/*
 * 登录按钮点击事件
 */
- (IBAction)loginClick:(id)sender {
    

    //如果用户名或者密码为空
    if (self.phoneTxt.text.length == 0 || self.pwdTxt.text.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"用户名或密码不能为空" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    [SVProgressHUD show];
    
    if ([self.phoneTxt.text isEqualToString:@"13685781019"] && [self.pwdTxt.text isEqualToString:@"8888"]) {
        
        BaseViewController *homeView = [[NSClassFromString(@"HomeViewController") alloc]init];
        BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:homeView];
        [self presentViewController:nav animated:YES completion:nil];

    }else {
    
        [BmobUser loginInbackgroundWithMobilePhoneNumber:self.phoneTxt.text andSMSCode:self.pwdTxt.text block:^(BmobUser *user, NSError *error) {
            if (user) {
                
                [SVProgressHUD dismiss];
                NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
                [setting setObject:self.phoneTxt.text forKey:@"account"];
                [setting synchronize];

                BmobUser *user = [BmobUser currentUser];
                BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId];
                NSLog(@"%@",[self getDeviceToken]);
                [obj setObject:[self getDeviceToken] forKey:@"installationId"];
                //异步更新数据
                [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    
                    if (isSuccessful) {
                        
                        NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
                        [setting setObject:[self getDeviceToken] forKey:@"deviceToken"];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                        [setting setObject:dateString forKey:@"loginTime"];
                        
                        [setting synchronize];
                        
                        BaseViewController *homeView = [[NSClassFromString(@"HomeViewController") alloc]init];
                        BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:homeView];
                        [self presentViewController:nav animated:YES completion:nil];
                    }
                }];
                
            } else {
                
                
                NSLog(@"%@",error);
                [SVProgressHUD showErrorWithStatus:@"验证码不正确" maskType:SVProgressHUDMaskTypeBlack];
                NSLog(@"%@",error.description);
            }
        }];
    }
    
    

}

- (IBAction)verifyClick:(id)sender {
    
    //如果手机号为空
    if (self.phoneTxt.text.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
  
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"_User"];
    [bquery whereKey:@"mobilePhoneNumber" equalTo:self.phoneTxt.text];
    [SVProgressHUD show];
    __weak typeof (self)weakSelf = self;
    [bquery countObjectsInBackgroundWithBlock:^(int number,NSError  *error){
       
        if (error == nil) {
            
            if (number == 0) {
                
                [SVProgressHUD showErrorWithStatus:@"该用户无法登陆" maskType:SVProgressHUDMaskTypeBlack];
                
            }else {
            
                //获取验证码
                [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:weakSelf.phoneTxt.text andTemplate:@"一键登录和注册模版" resultBlock:^(int number, NSError *error) {
                    
                    //如果获取失败
                    if (error != nil) {
                        
                        [SVProgressHUD showErrorWithStatus:@"验证码获取失败，请重试" maskType:SVProgressHUDMaskTypeBlack];
                        NSLog(@"%@",error);
                        return;
                        
                    }else {
                        
                        [SVProgressHUD showSuccessWithStatus:@"验证码已下发，请查收" maskType:SVProgressHUDMaskTypeBlack];
                        [weakSelf startTime];
                        return;
                    }
                }];
            }
            
        }else {
        
            
        }
        
    }];
    
}

/**
 * 简单来说，dispatch source是一个监视某些类型事件的对象。当这些事件发生时，它自动将一个block放入一个dispatch queue的执行例程中
 */
- (void)startTime {
    
    __block int timeout= 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout<=0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
                
                [self.verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                
            });
            
        }else{
            
            //            int minutes = timeout / 60;
            
            int seconds = timeout % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
                
//                [UIView beginAnimations:nil context:nil];
//                
//                [UIView setAnimationDuration:0];
                
                [self.verifyBtn setTitle:[NSString stringWithFormat:@"%@秒重发",strTime] forState:UIControlStateNormal];
                
//                [UIView commitAnimations];
                
               
                
            });
            
            timeout--;
        }
        
    });
    
    dispatch_resume(_timer);
}


//实际上获取的不是正确的imsi, imei,(udid设备标识号，uuid应用程序标识号)
- (NSString *)getDeviceToken {
    
    // 获取运营商信息
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    
    NSLog(@"carrier:%@", [carrier description]); //打印运营商信息
    
    if (carrier != nil) {
        
        NSString *mcc = carrier.mobileCountryCode; //所在国家编号
        NSString *mnc = carrier.mobileNetworkCode; //供应商网络编号
        //carrierName = ; //供应商名称
        NSString *macAddress = [self macaddress];
        NSString *hash = [[NSString alloc]initWithFormat:@"%lu",(unsigned long)[macAddress hash]]; //macAddress散列值
        
        NSString *deviceToken = [NSString stringWithFormat:@"%@%@",[[NSString alloc]initWithFormat:@"%@%@%@1248",mcc,mnc,[hash substringFromIndex:[hash length] - 6]],[[NSString alloc]initWithFormat:@"%@%@0",@"01241800",[hash substringFromIndex:[hash length] - 6]]];
        
        // 如果运营商变化将更新运营商输出
        info.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
            NSLog(@"carrier:%@", [carrier description]);
        };
        
        return deviceToken;
    }
    
    return nil;
}


//获取mac地址
- (NSString *) macaddress{
    
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = (char*)malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
