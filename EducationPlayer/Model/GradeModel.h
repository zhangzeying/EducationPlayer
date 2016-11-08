//
//  GradeModel.h
//  EducationPlayer
//
//  Created by zzy on 8/20/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradeModel : BmobObject

/** <##> */
@property(assign,nonatomic)NSInteger level;
/** <##> */
@property(assign,nonatomic)NSInteger index;
/** <##> */
@property(nonatomic,copy)NSString *gradeName;
@end
