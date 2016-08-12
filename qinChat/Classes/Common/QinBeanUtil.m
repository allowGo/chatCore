//
// Created by 祥龙 on 15/10/20.
//

#import "QinBeanUtil.h"


@implementation QinBeanUtil {

}
+ (void)setPropertyFromDictionary:(NSDictionary *)dict andKey:(NSString *)key model:(id)model propertyName:(NSString *)propertyName {
    id value = dict[key];
    if (value) {
        SEL sel = NSSelectorFromString(propertyName);
        if ([model respondsToSelector:sel]) {
            [model setValue:value forKey:propertyName];
        } else {
            NSLog(@"can't find model property:%@", propertyName);
        }

    }
}
@end