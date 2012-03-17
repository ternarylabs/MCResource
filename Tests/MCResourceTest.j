@import "TestHelper.j"

var fs = require("file");
var postJSON = fs.open("Tests/Fixtures/post.json").read();

@implementation MCResourceTest : OJTestCase

- (void)setUp
{
  	// Response. Can't mock it because code expects this exact class.
    response = [CPHTTPURLResponse new];
    [response _setStatusCode:200];

    // Mock network connections
	connection = mock([MCURLConnection alloc]);

	MCURLConnection = mock(CPObject);
	[MCURLConnection selector:@selector(alloc) returns:connection];

    [[MCQueue sharedQueue] start];
}

- (void)tearDown
{
    [MCURLConnection verifyThatAllExpectationsHaveBeenMet];
}

- (void)testCFHTTPRequestMock
{
	[self assertNotNull:MCURLConnection];
}

- (void)testIdentifierKey
{
    [self assert:@"id" equals:[Post identifierKey]];
    [self assert:@"id" equals:[Comment identifierKey]];
}

- (void)testRailsName
{
    [self assert:@"post" equals:[Post railsName]];
    [self assert:@"comment" equals:[Comment railsName]];
    [self assert:@"m_c_resource" equals:[MCResource railsName]];
}

- (void)testFindByIdentifier
{
    var delegate = moq();
    [delegate selector:@selector(findByIdentifierCallback:) times:1];
    [delegate selector:@selector(findByIdentifierCallback:) callback:function(args){
        var post = args[0];
        [self assert:1 equals:[post identifier]];
        [self assert:@"Post 1 Title" equals:[post title]];
        [self assert:[[CPDate alloc] initWithString:@"2012-02-27 10:14:18 -0800"] equals:[post createdAt]];
    }];

    [connection selector:@selector(initWithRequest:delegate:startImmediately:) callback:function(args){
        var request = args[0];
        var delegate = args[1];
        [delegate connection:connection didReceiveData:postJSON];
        [delegate connection:connection didReceiveResponse:response];
        [delegate connectionDidFinishLoading:connection];
    }];

    [Post find:[CPDictionary dictionaryWithJSObject:{"id":"1"}] withDelegate:delegate andSelector:@selector(findByIdentifierCallback:)];

    [connection verifyThatAllExpectationsHaveBeenMet];
	[delegate verifyThatAllExpectationsHaveBeenMet];
}

- (void)testFindByIdentifierNotFound
{
    var delegate = moq();
    [delegate selector:@selector(findByIdentifierCallback:) times:1];
    [delegate selector:@selector(findByIdentifierCallback:) callback:function(args){
        var post = args[0];
        [self assertNull:post];
    }];

    [response _setStatusCode:404];

    [connection selector:@selector(initWithRequest:delegate:startImmediately:) callback:function(args){
        var request = args[0];
        var delegate = args[1];
        [delegate connection:connection didReceiveResponse:response];
        [delegate connectionDidFinishLoading:connection];
    }];

    [Post find:[CPDictionary dictionaryWithJSObject:{"id":"1"}] withDelegate:delegate andSelector:@selector(findByIdentifierCallback:)];

    [connection verifyThatAllExpectationsHaveBeenMet];
    [delegate verifyThatAllExpectationsHaveBeenMet];
}

- (void)testFindByIdentifierServerError
{
    var delegate = moq();
    [delegate selector:@selector(findByIdentifierCallback:) times:0];

    [response _setStatusCode:500];

    [connection selector:@selector(initWithRequest:delegate:startImmediately:) callback:function(args){
        var request = args[0];
        var delegate = args[1];
        [delegate connection:connection didReceiveResponse:response];
        [delegate connectionDidFinishLoading:connection];
    }];

    [Post find:[CPDictionary dictionaryWithJSObject:{"id":"1"}] withDelegate:delegate andSelector:@selector(findByIdentifierCallback:)];

    [connection verifyThatAllExpectationsHaveBeenMet];
    [delegate verifyThatAllExpectationsHaveBeenMet];
}

@end
