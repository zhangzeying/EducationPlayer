//
//  UserModel.h
//  EducationPlayer
//
//  Created by zzy on 8/20/16.
//  Copyright © 2016 zzy. All rights reserved.
//

@interface UserModel : BmobUser
/**  */
@property(assign,nonatomic)NSInteger level;
/** <##> */
@property(nonatomic,copy)NSString *installationId;
/** <##> */
@property(nonatomic,copy)NSString *uselessString;
@end
