//
// Created by 祥龙 on 15/10/28.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>


@protocol LogglyFieldsDelegate
- (NSDictionary *)logglyFieldsToIncludeInEveryLogStatement;
@end

@interface QinLogFormatter : NSObject <DDLogFormatter>
@property (nonatomic, assign) BOOL alwaysIncludeRawMessage;
- (id)initWithLogglyFieldsDelegate:(id<LogglyFieldsDelegate>)delegate;
@end
