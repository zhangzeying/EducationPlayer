//
//  DownLoadViewController.m
//  EducationPlayer
//
//  Created by zzy on 8/24/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "DownLoadViewController.h"
#import "CourseModel.h"
#import "ZFDownloadManager.h"
#import "ZFDownloadingCell.h"
#import "ZFDownloadedCell.h"
#import "PlayVideoViewController.h"
@interface DownLoadViewController ()<UITableViewDelegate, UITableViewDataSource, ZFDownloadDelegate>
/** <##> */
@property(nonatomic,strong)NSMutableArray *dataArr;
/** <##> */
//@property(nonatomic,strong)CourseModel *model;
/** <##> */
@property (nonatomic, weak)UITableView *table;
@property (atomic, strong) NSMutableArray *downloadObjectArr;
@property (nonatomic, strong) ZFDownloadManager *downloadManage;
@end

@implementation DownLoadViewController
//
//- (instancetype)initWithDataArr:(CourseModel *)model
//{
//    self = [super init];
//    if (self) {
//        
//        self.model = model;
//    }
//    return self;
//}

- (ZFDownloadManager *)downloadManage
{
    if (!_downloadManage) {
        _downloadManage = [ZFDownloadManager sharedDownloadManager];
    }
    return _downloadManage;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"我的下载";
    // 更新数据源
    [self initData];
//    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
//    NSString *name = [[self.model.uri componentsSeparatedByString:@"/"] lastObject];
//    [[ZFDownloadManager sharedDownloadManager] downFileUrl:self.model.uri filename:name fileimage:nil];
//    // 设置最多同时下载个数（默认是3）
//    [ZFDownloadManager sharedDownloadManager].maxCount = 3;
    self.downloadManage.downloadDelegate = self;
    UITableView *table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    self.table = table;
    
    NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
}

- (void)initData
{
    [self.downloadManage startLoad];
    NSMutableArray *downladed = self.downloadManage.finishedlist;
    NSMutableArray *downloading = self.downloadManage.downinglist;
    self.downloadObjectArr = @[].mutableCopy;
    [self.downloadObjectArr addObject:downladed];
    [self.downloadObjectArr addObject:downloading];
    [self.table reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.downloadObjectArr[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ZFDownloadedCell *cell = [ZFDownloadedCell cellWithTableView:tableView];
        ZFFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        cell.fileInfo = fileInfo;
        return cell;
    } else if (indexPath.section == 1) {
        ZFDownloadingCell *cell = [ZFDownloadingCell cellWithTableView:tableView];
        ZFHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        if (request == nil) { return nil; }
        ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
        
        __weak typeof(self) weakSelf = self;
        // 下载按钮点击时候的要刷新列表
        cell.btnClickBlock = ^{
            [weakSelf initData];
        };
        // 下载模型赋值
        cell.fileInfo = fileInfo;
        // 下载的request
        cell.request = request;
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
    
        return 50;
        
    }else {
    
        return 110;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        ZFFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        PlayVideoViewController *DownLoadVC = [[PlayVideoViewController alloc]initWithUrl:FILE_PATH(fileInfo.fileName) playType:0];
        [self.navigationController pushViewController:DownLoadVC animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ZFFileModel *fileInfo = self.downloadObjectArr[indexPath.section][indexPath.row];
        [self.downloadManage deleteFinishFile:fileInfo];
    }else if (indexPath.section == 1) {
        ZFHttpRequest *request = self.downloadObjectArr[indexPath.section][indexPath.row];
        [self.downloadManage deleteRequest:request];
    }
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"下载完成",@"下载中"][section];
}

#pragma mark - ZFDownloadDelegate

// 开始下载
- (void)startDownload:(ZFHttpRequest *)request
{
    NSLog(@"开始下载!");
}

// 下载中
- (void)updateCellProgress:(ZFHttpRequest *)request
{
    ZFFileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

// 下载完成
- (void)finishedDownload:(ZFHttpRequest *)request
{
    [self initData];
}

// 更新下载进度
- (void)updateCellOnMainThread:(ZFFileModel *)fileInfo
{
    NSArray *cellArr = [self.table visibleCells];
    for (id obj in cellArr) {
        if([obj isKindOfClass:[ZFDownloadingCell class]]) {
            ZFDownloadingCell *cell = (ZFDownloadingCell *)obj;
            if([cell.fileInfo.fileURL isEqualToString:fileInfo.fileURL]) {
                cell.fileInfo = fileInfo;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reload" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
