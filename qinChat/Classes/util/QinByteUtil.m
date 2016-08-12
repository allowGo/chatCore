//
// Created by DengHua on 15/8/9.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinByteUtil.h"


@implementation QinByteUtil {

}

+ (NSInteger)bytes2Length:(Byte *)indata
{
    NSInteger multiplier = 1;
    NSInteger length = 0;
    NSInteger digit = 0;
    NSInteger i = 0;
    do {
        digit = indata[i]; //一个字节的有符号或者无符号，转换转换为四个字节有符号 int类型
        length += (digit & 0x7f) * multiplier;
        multiplier *= 128;
        i++;
    } while ((digit & 0x80) != 0);

    return length;
}

+ (NSInteger)length2Bytes:(Byte*)outdata length:(NSInteger)length
{
    NSInteger val = length;
    NSInteger i = 0;
    do {
        NSInteger digit = val % 128;
        val = val / 128;
        if (val > 0)
            digit = digit | 0x80;

        outdata[i] = digit;
        i++;
    } while (val > 0);
    return i;
}

@end