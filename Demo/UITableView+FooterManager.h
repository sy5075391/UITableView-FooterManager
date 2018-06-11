//
//  UITableView+FooterManager.h
//  workHelper
//
//  Created by Jamesholy on 2017/9/1.
//  Copyright © 2017年 Jamesholy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (FooterManager)
/**是否开启<数据不满一页的话就自动隐藏下面的mj_footer>功能*/
@property(nonatomic, assign) BOOL autoHideMjFooter;
@end

