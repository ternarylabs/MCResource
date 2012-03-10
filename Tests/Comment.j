/*
    Test class
*/

@implementation Comment : MCResource
{
    CPString    content @accessors;
}

+ (void)initialize
{
	[self belongsTo:@"post"];
}
@end
