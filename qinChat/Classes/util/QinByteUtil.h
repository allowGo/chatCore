/*!
 @header QinByteUtil.h
 @abstract 
 @author kinstalk.com
 @version 1.00 15/8/9
 Created by DengHua on 15/8/9.
*/

#import <Foundation/Foundation.h>


@interface QinByteUtil : NSObject

+ (NSInteger)bytes2Length:(Byte *)indata;

+ (NSInteger)length2Bytes:(Byte*)outdata length:(NSInteger)length;

@end