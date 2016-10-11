//
// Created by LEI on 15/8/26.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (QinCrypto)

- (NSData *) AES256ParmEncryptWithKey:(NSString *)key; //加密
- (NSData *) AES256ParmDecryptWithKey:(NSString *)key; //解密
@end
