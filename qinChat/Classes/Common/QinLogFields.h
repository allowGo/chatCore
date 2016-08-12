//
// Created by 祥龙 on 15/10/28.
//
#import <Foundation/Foundation.h>
#import "QinLogFormatter.h"

@interface QinLogFields : NSObject <LogglyFieldsDelegate>
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *sessionid;
@end
