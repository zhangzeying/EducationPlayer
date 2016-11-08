//
//  CourseModel.h
//  EducationPlayer
//
//  Created by zzy on 8/20/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GradeModel;
@interface CourseModel : BmobObject

/** <##> */
@property(assign,nonatomic)NSInteger type;//0:MP4   1: MP3
/** <##> */
@property(nonatomic,copy)NSString *round;//第几周期
/** <##> */
@property(nonatomic,copy)NSString *uri;
/** <##> */
@property(nonatomic,copy)NSString *courseName;
/** <##> */
@property(nonatomic,strong)GradeModel *gradeModel;
/** <##> */
@property(assign,nonatomic)NSInteger index;
/** 是否下载 */
@property(assign,nonatomic)BOOL isDown;
@end
