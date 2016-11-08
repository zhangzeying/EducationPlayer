//
//  ZFDownloadedCell.m
//  EducationPlayer
//
//  Created by zzy on 8/26/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "ZFDownloadedCell.h"
static NSString *ID = @"ID";
@implementation ZFDownloadedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setFileInfo:(ZFFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    NSString *totalSize = [ZFCommonHelper getFileSizeString:fileInfo.fileSize];
    self.fileNameLabel.text = fileInfo.realName;
    self.sizeLabel.text = totalSize;
}

+ (instancetype)cellWithTableView:(UITableView *)table {
    
    ZFDownloadedCell *cell = [table dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
@end
