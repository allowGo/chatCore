//
// Created by DengHua on 15/8/25.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinDDLogFormatter.h"
#import "CocoaLumberjack/DDLegacyMacros.h"


@implementation QinDDLogFormatter {

}
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {

//    NSString *logLevel = nil;
//    switch (logMessage.flag)
//    {
//        case LOG_FLAG_ERROR:
//            logLevel = @"[ERROR]> ";
//            break;
//        case LOG_FLAG_WARN:
//            logLevel = @"[WARN]> ";
//            break;
//        case LOG_FLAG_INFO:
//            logLevel = @"[INFO]> ";
//            break;
//        case LOG_FLAG_DEBUG:
//            logLevel = @"[DEBUG]> ";
//            break;
//        default:
//            logLevel = @"[VBOSE]> ";
//            break;
//    }

    NSString *formatStr = [NSString stringWithFormat:@"[%@](%lu) %@",
                                                     //logMessage.fileName,
                                                     logMessage.function,
                                                     (unsigned long)logMessage.line,
                    logMessage.message];
    return formatStr;
}

@end