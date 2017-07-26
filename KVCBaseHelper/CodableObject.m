//
//  CodableObject.m
//  ski-ref
//
//  Created by xzming on 16/7/11.
//  Copyright © 2016年 HZMC. All rights reserved.
//

#import "CodableObject.h"
#import <objc/runtime.h>

@implementation CodableObject

-(NSArray *)exculdePropertys{
    return @[];
}

- (NSArray *)propertyNames
{
    // Check for a cached value (we use _cmd as the cache key,
    // which represents @selector(propertyNames))
    NSMutableArray *array = objc_getAssociatedObject([self class], _cmd);
    if (array)
    {
        return array;
    }
    
    // Loop through our superclasses until we hit NSObject
    array = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass,
                                                             &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            // Get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = @(propertyName);
            
            if ([[self exculdePropertys] containsObject:key]) {
                continue;
            }
            
            // Check if there is a backing ivar
            char *ivar = property_copyAttributeValue(property, "V");
            if (ivar)
            {
                // Check if ivar has KVC-compliant name
                NSString *ivarName = @(ivar);
                if ([ivarName isEqualToString:key] ||
                    [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                {
                    // setValue:forKey: will work
                    [array addObject:key];
                }
                free(ivar);
            }
        }
        free(properties);
        subclass = [subclass superclass];
    }
    
    // Cache and return array
    objc_setAssociatedObject([self class], _cmd, array, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return array;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [self init]))
    {
        // Loop through the properties
        for (NSString *key in [self propertyNames])
        {
            // Decode the property, and use the KVC setValueForKey: method to set it
            id value = [aDecoder decodeObjectForKey:key];
            if (!value) {
                continue;
            }
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Loop through the properties
    for (NSString *key in [self propertyNames])
    {
        // Use the KVC valueForKey: method to get the property and then encode it
        id value = [self valueForKey:key];
        if (!value) {
            continue;
        }
        [aCoder encodeObject:value forKey:key];
    }
}

@end
