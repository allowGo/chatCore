//
// Created by 祥龙 on 16/2/29.
//

#import <Foundation/Foundation.h>


@interface QinDynamicConfig : NSObject
@property (nonatomic, assign) bool httpTraceEnabled;
@property (nonatomic, assign) bool liveEnabled;
@property (nonatomic, strong) NSString *h5Version;
@end