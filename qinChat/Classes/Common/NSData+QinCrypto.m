//
// Created by 祥龙 on 15/8/26.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "NSData+QinCrypto.h"


@implementation NSData (QinCrypto)


- (NSData *) AES256ParmEncryptWithKey:(NSString *)key {

    char keyPtr[kCCKeySizeAES128+1];

    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;


    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
            kCCOptionPKCS7Padding,
            keyPtr, kCCKeySizeAES128,
            keyPtr,
            [self bytes], dataLength,
            buffer, bufferSize,
            &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {

        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
//        free(buffer);
        return data;
    }

    free(buffer);

    return nil;
}

- (NSData *) AES256ParmDecryptWithKey:(NSString *)key {

    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
            kCCOptionPKCS7Padding,
            keyPtr, kCCKeySizeAES128,
            keyPtr,
            [self bytes], dataLength,
            buffer, bufferSize,
            &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {

        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
//        free(buffer);

        return data;
    }

    free(buffer);

    return nil;
}
@end