//
//  HomeViewController.m
//  EducationPlayer
//
//  Created by zzy on 7/27/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCollectionCell.h"
#import "PeriodViewController.h"
#import "LoginViewController.h"
#import "GradeModel.h"
#import "DownLoadViewController.h"
@import CoreTelephony;
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
static NSString *ID = @"cell";

@interface HomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,BmobEventDelegate,UIAlertViewDelegate>
{
    BmobEvent *_bmobEvent;
}
@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation HomeViewController

- (NSMutableArray *)dataArr {
    
    if (_dataArr == nil) {
        
        _dataArr = [NSMutableArray array];
    }
    
    return _dataArr;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"教育视频";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"退出" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(quitClick) forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.width = 80;
    btn.height = 60;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    //cell间距
    layout.minimumInteritemSpacing = 0;
    //cell行距
    layout.minimumLineSpacing = 10;
    
    layout.itemSize = CGSizeMake(ScreenW / 2 - 30, ScreenW / 2 - 30);
    
    
    UICollectionView *collect = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:layout];
    [collect registerClass:[HomeCollectionCell class] forCellWithReuseIdentifier:ID];
    collect.backgroundColor = [UIColor clearColor];
    collect.showsVerticalScrollIndicator = NO;
    collect.delegate = self;
    collect.dataSource = self;
    collect.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.view addSubview:collect];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"GradeBean"];
    [bquery orderByAscending:@"index"];
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"加载中..."];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [SVProgressHUD dismiss];
        for (BmobObject *obj in array) {
            
            GradeModel *model = [[GradeModel alloc] init];
            model.gradeName = [obj objectForKey:@"gradeName"];
            model.level = [[obj objectForKey:@"level"] integerValue];
            model.objectId = [obj objectForKey:@"objectId"];
            model.index = [[obj objectForKey:@"index"] integerValue];
            [self.dataArr addObject:model];
        }
        
        [collect reloadData];
        
    }];
    
    
    NSString *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"state"];
    if ([state isEqualToString:@"1"]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(downLoadClick)];
        [self listen];
    }
}

#pragma mark --- UICollectionViewDataSource ---
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    GradeModel *model = self.dataArr[indexPath.row];
    cell.title = model.gradeName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    BmobUser *user = [BmobUser currentUser];
    NSArray *levelArr = [user objectForKey:@"level"];
    GradeModel *model = self.dataArr[indexPath.row];
    if (user == nil) {
        
        PeriodViewController *periodVC = [[PeriodViewController alloc]initWithGradeId:model.objectId];
        [self.navigationController pushViewController:periodVC animated:YES];
    }else {
    
       
        if ([levelArr containsObject:@(model.level)]) {
            
            PeriodViewController *periodVC = [[PeriodViewController alloc]initWithGradeId:model.objectId];
            [self.navigationController pushViewController:periodVC animated:YES];
            
        }else {
            
            [SVProgressHUD showErrorWithStatus:@"该用户无权限访问"];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        }

    }
    
}

- (void)quitClick {

    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [[self.navigationController.childViewControllers lastObject] presentViewController:loginVC animated:YES completion:nil];
    
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    [setting removeObjectForKey:@"account"];
    [setting removeObjectForKey:@"deviceToken"];
    [setting synchronize];
}

- (void)downLoadClick {

    DownLoadViewController *DownLoadVC = [[DownLoadViewController alloc]init];
    [self.navigationController pushViewController:DownLoadVC animated:YES];
}

- (void)listen{
    //创建BmobEvent对象
    _bmobEvent = [BmobEvent defaultBmobEvent];
    //设置代理
    _bmobEvent.delegate = self;
    //启动连接
    [_bmobEvent start];
}

/**
 *  连接上服务器
 *
 *  @param event BmobEvent对象
 */
-(void)bmobEventDidConnect:(BmobEvent *)event {

    NSLog(@"11");
}

#pragma mark -- BmobEventDelegate --
//可以进行监听或者取消监听事件
- (void)bmobEventCanStartListen:(BmobEvent *)event{
    
    BmobUser *user = [BmobUser currentUser];
    //监听GameBean表更新
    [_bmobEvent listenRowChange:BmobActionTypeUpdateRow tableName:@"_User" objectId:user.objectId];
    BmobQuery  *bquery = [BmobQuery queryWithClassName:@"_User"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //查找GameScore表里面id为0c6db13c的数据
        [bquery getObjectInBackgroundWithId:user.objectId block:^(BmobObject *object,NSError *error){
            if (error){
                //进行错误处理
            }else{
                //表里有id为0c6db13c的数据
                if (object) {
                    //得到playerName和cheatMode
                    NSString *deviceToken = [object objectForKey:@"installationId"];
                    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]);
                    if (![deviceToken isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]]) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"你的账号已在其他地方登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alertView show];
                    }
                }
            }
        }];
    });
    
}

//-
- (void)bmobEvent:(BmobEvent *)event didReceiveMessage:(NSString *)message {
    //打印数据
    
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                        error:&err];
    NSLog(@"%@",[dict objectForKey:@"data"]);
    NSDictionary *dataDict = [dict objectForKey:@"data"];
    
    if (!([dataDict[@"installationId"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]])) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"你的账号已在其他地方登录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        
    }
   

}

/**
 *  BmobEvent发生错误时
 *
 *  @param event BmobEvent对象
 *  @param error 错误信息
 */
-(void)bmobEvent:(BmobEvent*)event error:(NSError *)error {

    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [[self.navigationController.childViewControllers lastObject] presentViewController:loginVC animated:YES completion:nil];
    
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    [setting removeObjectForKey:@"account"];
    [setting removeObjectForKey:@"deviceToken"];
    [setting synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    [self quitClick];
}

- (void)dealloc {
    
    [_bmobEvent cancelListenTableChange:BmobActionTypeUpdateTable tableName:@"_User"];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
