//
//  SchoodUtil.m
//  BTLE Transfer
//
//  Created by Honorato Rocha on 30/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "SchoodUtil.h"

@implementation SchoodUtil: NSObject

+ (NSString *)toBinary:(unsigned int)input {
    if (input == 1 || input == 0)
        return [NSString stringWithFormat:@"%u", input];
    return [NSString stringWithFormat:@"%@%u", [SchoodUtil toBinary:input / 2], input % 2];
}

+ (NSString *)onlyHexa:(NSData *)input {
    NSString *stringWithoutSpaces = [[NSString alloc] initWithFormat:@"%@", input.description];
    stringWithoutSpaces = [ stringWithoutSpaces stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringWithoutSpaces = [ stringWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
    stringWithoutSpaces = [ stringWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
    return stringWithoutSpaces;
}

+ (NSString *)hexToBin:(NSString *)hex {
    unsigned int hexAsInt = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&hexAsInt];
    return [NSString stringWithFormat:@"%0.8d", [SchoodUtil toBinary:hexAsInt].intValue];
}

+ (NSInteger)bin2Dec:(NSString *)bin {
    return strtol([bin UTF8String], NULL, 2);
}

+ (NSString *)extractSchoolId:(NSData *)input {
    return [[SchoodUtil onlyHexa:input] substringToIndex:4];
}

+ (NSString *)extractAlias:(NSData *)input {
    NSString *stringWithoutSpaces = [SchoodUtil onlyHexa:input];
    
    NSString *alias = [stringWithoutSpaces substringWithRange:NSMakeRange(4, 4)];
    NSString *firstByte = [alias substringToIndex:2];
    NSString *secondByte = [alias substringFromIndex:2];

    NSString *binary = [SchoodUtil hexToBin:firstByte];

    NSString *firstBit = [binary substringToIndex:4];
    firstBit = [firstBit substringFromIndex:3];
    NSString *secondBit = [alias substringWithRange:NSMakeRange(1, 1)];
    
    return [NSString stringWithFormat:@"%@%@%@", firstBit, secondBit, secondByte];
}

+ (NSString *)extractCommandSeq:(NSData *)input {
    NSString *stringWithoutSpaces = [SchoodUtil onlyHexa:input];
    return [stringWithoutSpaces substringWithRange:NSMakeRange(8, 2)];
}

+ (NSString *)extractCommand:(NSData *)input {
    NSString *stringWithoutSpaces = [SchoodUtil onlyHexa:input];
    return [stringWithoutSpaces substringWithRange:NSMakeRange(10, 2)];
}

+ (NSInteger)extractAdvType:(NSData *)input {
    NSString *cmd = [SchoodUtil extractCommand:input];
    NSString *binary = [SchoodUtil hexToBin:cmd];
    return [SchoodUtil bin2Dec:[binary substringToIndex:2]];
}

+ (NSInteger)extractAdvMode:(NSData *)input {
    NSString *cmd = [SchoodUtil extractCommand:input];
    NSString *binary = [SchoodUtil hexToBin:cmd];
    return [SchoodUtil bin2Dec:[binary substringWithRange:NSMakeRange(2, 2)]];
}

+ (NSInteger)extractAnswer:(NSData *)input {
    NSString *cmd = [SchoodUtil extractCommand:input];
    NSString *binary = [SchoodUtil hexToBin:cmd];
    return [SchoodUtil bin2Dec:[binary substringWithRange:NSMakeRange(5, 3)]];
}

+ (NSInteger)extractReserved:(NSData *)input {
    NSString *cmd = [SchoodUtil extractCommand:input];
    return [[[SchoodUtil hexToBin:cmd] substringFromIndex:8] integerValue];
}

@end
