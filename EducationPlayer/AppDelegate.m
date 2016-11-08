//
//  AppDelegate.m
//  EducationPlayer
//
//  Created by zzy on 7/26/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import <Bugly/Bugly.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self initSDK];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"AppChange"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (error == nil) {
            
            BmobObject *obj = array[0];
            NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion = [bundleDic objectForKey:@"CFBundleShortVersionString"];
            if ([currentVersion isEqualToString:[obj objectForKey:@"version"]]) {
                
                NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
                [setting setObject:[obj objectForKey:@"status"] forKey:@"state"];
                [setting synchronize];
                
            }else {
                
                NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
                [setting setObject:@"1" forKey:@"state"];
                [setting synchronize];
            }
        }
        
    }];
    
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    
    if ([setting objectForKey:@"account"] != nil) {
    
        NSString *loginTime = [setting objectForKey:@"loginTime"];
        if (loginTime != nil) {
            
            NSDateFormatter *date = [[NSDateFormatter alloc] init];
            [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSCalendar *cal = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
            NSDateComponents *d = [cal components:unitFlags fromDate:[date dateFromString:loginTime] toDate:[NSDate date] options:0];
            // NSLog(@"%d天%d小时%d分钟%d秒",[d day],[d hour],[d minute],[d second]);
            if ([d day] >= 2) {//超过24小时
                
                LoginViewController *homeVC = [[LoginViewController alloc]init];
                self.window.rootViewController = homeVC;
                
            }else {
                
                BaseViewController *homeView = [[NSClassFromString(@"HomeViewController") alloc]init];
                BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:homeView];
                self.window.rootViewController = nav;
            }
        }

    }else {
    
        LoginViewController *homeVC = [[LoginViewController alloc]init];
        self.window.rootViewController = homeVC;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)initSDK {
    
    [Bmob registerWithAppKey:@"73fbf4e5e7fc413c24757c97fdf2c972"];
    [Bugly startWithAppId:@"97fe9d756a"];
}

//func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//    
//    //注册成功后上传Token至服务器
//    let currentIntallation = BmobInstallation.currentInstallation()
//    
//    currentIntallation.setDeviceTokenFromData(deviceToken)
//    print(currentIntallation.deviceToken)
//    currentIntallation.saveInBackground()
//    NSUserDefaults.standardUserDefaults().setObject(currentIntallation.deviceToken, forKey: "deviceToken")
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"44");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"22");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
