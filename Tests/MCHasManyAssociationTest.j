@import "TestHelper.j"

var fs = require("file");
var postJSON = fs.open("Tests/Fixtures/post.json").read();
var commentsJSON = fs.open("Tests/Fixtures/comments.json").read();

@implementation MCHasManyAssociationTest : OJTestCase

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

- (void)testLoadAssociatedObjects
{
    var loadPostDelegate = moq();
    var loadCommentsDelegate = moq();
    var post = null;

    [loadPostDelegate selector:@selector(callback:) times:1];
    [loadPostDelegate selector:@selector(callback:) callback:function(args){
        post = args[0];
        [self assertNotNull:post];

        [connection selector:@selector(initWithRequest:delegate:startImmediately:) callback:function(args){
            var request = args[0];
            var delegate = args[1];
            [delegate connection:connection didReceiveData:commentsJSON];
            [delegate connection:connection didReceiveResponse:response];
            [delegate connectionDidFinishLoading:connection];
        }];

        [[post associationForName:@"comments"] loadAssociatedObjectsWithDelegate:loadCommentsDelegate andSelector:@selector(callback:)];
    }];

    [loadCommentsDelegate selector:@selector(callback:) times:1];
    [loadCommentsDelegate selector:@selector(callback:) callback:function(args){
        comments = args[0];
        [self assertNotNull:comments];
        [self assert:3 equals:[comments count]];
        [self assert:10 equals:[comments[0] identifier]];
        [self assert:[[CPDate alloc] initWithString:@"2012-02-27 10:14:18 -0800"] equals:[comments[0] createdAt]];

        [self assertNotNull:[[comments[0] post] associatedObject]];
        [self assert:1 equals:[[[comments[0] post] associatedObject] identifier]];
    }];

    [connection selector:@selector(initWithRequest:delegate:startImmediately:) callback:function(args){
        var request = args[0];
        var delegate = args[1];
        [delegate connection:connection didReceiveData:postJSON];
        [delegate connection:connection didReceiveResponse:response];
        [delegate connectionDidFinishLoading:connection];
    }];

    [Post find:[CPDictionary dictionaryWithJSObject:{"id":"1"}] withDelegate:loadPostDelegate andSelector:@selector(callback:)];

    [connection verifyThatAllExpectationsHaveBeenMet];
	[loadPostDelegate verifyThatAllExpectationsHaveBeenMet];
}


@end
