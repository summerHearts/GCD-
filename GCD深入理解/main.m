//
//  main.m
//  GCD深入理解
//
//  Created by Kenvin on 16/12/6.
//  Copyright © 2016年 上海方创金融信息服务股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

void testSync(){
    NSObject* obj = [NSObject new];
    @synchronized (obj) {

    }
}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        testSync();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}


