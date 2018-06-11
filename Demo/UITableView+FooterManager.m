//
//  UITableView+FooterManager.m
//  workHelper
//
//  Created by Jamesholy on 2017/9/1.
//  Copyright © 2017年 Jamesholy. All rights reserved.
//

#import "UITableView+FooterManager.h"
#import "MJRefresh.h"
#import <objc/runtime.h>


@implementation UITableView (FooterManager)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class targetClass = [self class];
		SEL originalSelector = @selector(reloadData);
		SEL swizzledSelector = @selector(sy_reloadData);
		swizzleMethod(targetClass, originalSelector, swizzledSelector);
	});
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
	Method originalMethod = class_getInstanceMethod(class, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
	
	IMP swizzledImp = method_getImplementation(swizzledMethod);
	char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
	
	IMP originalImp = method_getImplementation(originalMethod);
	char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
	
	BOOL success = class_addMethod(class, originalSelector, swizzledImp, swizzledTypes);
	if (success) {
		class_replaceMethod(class, swizzledSelector, originalImp, originalTypes);
	}else {
		// 添加失败，表明已经有这个方法，直接交换
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
}


- (void)sy_reloadData {
	[self sy_reloadData];
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.autoHideMjFooter) {
			[self setFooterShow];
		}
	});
}

#pragma mark - 添加属性
static const char *autoHideMjFooterKey = "autoHideMjFooter";
- (void)setAutoHideMjFooter:(BOOL)autoHideMjFooter {
	objc_setAssociatedObject(self, autoHideMjFooterKey, @(autoHideMjFooter), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)autoHideMjFooter{
	return [objc_getAssociatedObject(self, autoHideMjFooterKey) boolValue];
}

/**
 数据不满一页的话就自动隐藏下面的“上拉加载更多”或是"没有更多数据" 。
 */
- (void)setFooterShow {
	dispatch_async(dispatch_get_main_queue(), ^{
		CGFloat heightOfContentSize = self.contentSize.height; // 内容高度
		// 计算tableView实际显示范围
		// 先拿到tableView实际的contentInset (因为下拉刷新时mj会重设contentInset)
		UIEdgeInsets originContentInset = self.mj_header.scrollViewOriginalInset;
		CGFloat actualHeight = self.frame.size.height - originContentInset.top - originContentInset.bottom;
		// 修正footer对contenInset的影响
		if (!self.mj_footer.hidden) { // 没有隐藏
			actualHeight = actualHeight + self.mj_footer.frame.size.height + 10; // 默认的mj_footer高度为44  默认实际偏移了54
		}
		if (actualHeight >= heightOfContentSize) { // 实际显示高度大于内容高度 代表第一页都没有占满
			self.mj_footer.hidden = YES;
		} else {
			self.mj_footer.hidden = NO;
		}
	});
	
}

@end

