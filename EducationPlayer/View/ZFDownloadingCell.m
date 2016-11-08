//
//  ZFDownloadingCell.m
//  EducationPlayer
//
//  Created by zzy on 8/26/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "ZFDownloadingCell.h"
static NSString *ID = @"ID";
@interface ZFDownloadingCell()
/** <##> */
@property(copy,nonatomic)NSString *size;
@end

@implementation ZFDownloadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  暂停、下载
 *
 *  @param sender UIButton
 */
- (IBAction)clickDownload:(UIButton *)sender {
    // 执行操作过程中应该禁止该按键的响应 否则会引起异常
    sender.userInteractionEnabled = NO;
    ZFFileModel *downFile = self.fileInfo;
    ZFDownloadManager *filedownmanage = [ZFDownloadManager sharedDownloadManager];
    if(downFile.downloadState == ZFDownloading) { //文件正在下载，点击之后暂停下载 有可能进入等待状态
        self.downloadBtn.selected = YES;
        [filedownmanage stopRequest:self.request];
    } else {
        self.downloadBtn.selected = NO;
        [filedownmanage resumeRequest:self.request];
    }
    
    // 暂停意味着这个Cell里的ASIHttprequest已被释放，要及时更新table的数据，使最新的ASIHttpreqst控制Cell
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
    sender.userInteractionEnabled = YES;
    
}

/**
 *  model setter
 *
 *  @param sessionModel sessionModel
 */
- (void)setFileInfo:(ZFFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    self.fileNameLabel.text = fileInfo.realName;
    // 服务器可能响应的慢，拿不到视频总长度
    if (!fileInfo.fileSize) {
        self.progressLabel.text = @"正在获取";
        self.speedLabel.text = @"0B/S";
        return;
    }
    

    NSString *currentSize = [ZFCommonHelper getFileSizeString:fileInfo.fileReceivedSize];
    
    
    NSString *totalSize = [ZFCommonHelper getFileSizeString:fileInfo.fileSize];
    // 下载进度
    float progress = (float)[fileInfo.fileReceivedSize longLongValue] / [fileInfo.fileSize longLongValue];
    
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@ (%.2f%%)",currentSize, totalSize, progress*100];
    
    self.progress.progress = progress;
    
    NSString *spped = [NSString stringWithFormat:@"%@/S",[ZFCommonHelper getFileSizeString:[NSString stringWithFormat:@"%lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]]]];
    self.speedLabel.text = spped;
    
    if (fileInfo.downloadState == ZFDownloading) { //文件正在下载
        self.downloadBtn.selected = NO;
        [self.downloadBtn setTitle:@"暂停" forState:UIControlStateNormal];
    } else if (fileInfo.downloadState == ZFStopDownload&&!fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"已暂停";
        [self.downloadBtn setTitle:@"开始" forState:UIControlStateNormal];
    }else if (fileInfo.downloadState == ZFWillDownload&&!fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"等待下载";
    } else if (fileInfo.error) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = @"错误";
    }
}

+ (instancetype)cellWithTableView:(UITableView *)table {
    
    ZFDownloadingCell *cell = [table dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
