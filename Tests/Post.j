/*
    Test class
*/

@implementation Post : MCResource
{
    CPString    title       @accessors;
    CPString    content     @accessors;
    BOOL        isDraft     @accessors;
}

+ (void)initialize
{
  [self hasMany:@"comments"];
}

@end
