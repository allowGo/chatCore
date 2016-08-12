//
// Created by 祥龙 on 15/10/20.
//

#import <Foundation/Foundation.h>


@interface QinBeanUtil : NSObject
+ (void)setPropertyFromDictionary:(NSDictionary *)dict andKey:(NSString *)key model:(id)model propertyName:(NSString *)propertyName;
@end