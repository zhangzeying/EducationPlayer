//
//  ZFDownloadedCell.h
//  EducationPlayer
//
//  Created by zzy on 8/26/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFDownloadManager.h"
@interface ZFDownloadedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

/** 下载信息模型 */
@property (nonatomic, strong)ZFFileModel *fileInfo;
+ (instancetype)cellWithTableView:(UITableView *)table;
@end
