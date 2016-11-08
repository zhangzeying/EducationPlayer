//
//  VideoViewController.m
//  EducationPlayer
//
//  Created by zzy on 7/29/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "VideoViewController.h"
#import "PlayVideoViewController.h"
#import "CourseModel.h"
#import "ZFDownloadManager.h"
#import "DownLoadViewController.h"
@interface VideoViewController ()<UITableViewDelegate, UITableViewDataSource>
/** <##> */
@property (nonatomic, weak)UITableView *table;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload) name:@"reload" object:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 114) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    [self.view addSubview:table];
    self.table = table;
}

-(void)viewDidLayoutSubviews
{
    if ([self.table respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.table setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.table respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.table setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
    }
    
    CourseModel *model = self.dataArr[indexPath.row];
    cell.textLabel.text = model.courseName;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImage *image = nil;
    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
    NSString *name = [[model.uri componentsSeparatedByString:@"/"] lastObject];
    
    if (model.uri.length == 0) {
        
        image = [UIImage imageNamed:@"ic_down"];
        
    }else {
    
        if ([ZFCommonHelper isExistFile:FILE_PATH(name)]) {
            
            image = [UIImage imageNamed:@"ic_play"];
            
        }else {
            
            image = [UIImage imageNamed:@"ic_down"];
        }

    }
    
    
    button.width = image.size.width + 30;
    button.height = image.size.height + 30;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside ];
    button.tag = indexPath.row;
    
    NSString *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"state"];
    if ([state isEqualToString:@"1"]) {
        
        cell.accessoryView = button;
    }
    
    
    return cell;
}

- (void)btnClicked:(UIButton *)sender {

    CourseModel *model = self.dataArr[sender.tag];
    NSString *name = [[model.uri componentsSeparatedByString:@"/"] lastObject];
    NSLog(@"%@",FILE_PATH(name));
    NSString *tempfilePath = [TEMP_PATH(name) stringByAppendingString:@".plist"];
    
    if (model.uri.length == 0) {
        
         [SVProgressHUD showErrorWithStatus:@"没有对应视频,请联系管理员" maskType:SVProgressHUDMaskTypeBlack];
    }else {
    
        if ([ZFCommonHelper isExistFile:FILE_PATH(name)]) {
            
            PlayVideoViewController *DownLoadVC = [[PlayVideoViewController alloc]initWithUrl:FILE_PATH(name) playType:0];
            [self.navigationController pushViewController:DownLoadVC animated:YES];
            
        }else {
            
            if (![ZFCommonHelper isExistFile:tempfilePath]) {
                
                
                // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
                NSString *name = [[model.uri componentsSeparatedByString:@"/"] lastObject];
                
                [[ZFDownloadManager sharedDownloadManager] downFileUrl:model.uri filename:name fileimage:nil realName:model.courseName];
                // 设置最多同时下载个数（默认是3）
                [ZFDownloadManager sharedDownloadManager].maxCount = 3;
            }
            
            DownLoadViewController *DownLoadVC = [[DownLoadViewController alloc]init];
            [self.navigationController pushViewController:DownLoadVC animated:YES];
            
        }
    }
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"state"];
    if (![state isEqualToString:@"1"]) {
        
        CourseModel *model = self.dataArr[indexPath.row];
        
        NSString *str = [model.round substringWithRange:NSMakeRange(1, 1)];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@课程将于星期%@晚上开课，开课前会短信通知具体上课时间和地点",model.courseName,str] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }

    
//    NSString *name = [[model.uri componentsSeparatedByString:@"/"] lastObject];
//    if (![ZFCommonHelper isExistFile:FILE_PATH(name)]) {
//
//        PlayVideoViewController *DownLoadVC = [[PlayVideoViewController alloc]initWithUrl:model.uri playType:1];
//        [self.navigationController pushViewController:DownLoadVC animated:YES];
//    }else {
//    
//        PlayVideoViewController *DownLoadVC = [[PlayVideoViewController alloc]initWithUrl:FILE_PATH(name) playType:0];
//        [self.navigationController pushViewController:DownLoadVC animated:YES];
//    }
    
}

- (void)reload {

    [self.table reloadData];
}

- (void)setDataArr:(NSMutableArray *)dataArr {

    _dataArr = dataArr;
    [self.table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
