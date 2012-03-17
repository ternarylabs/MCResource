@implementation MCBelongsToAssociation : MCAssociation
{
    MCResource _associatedObject;
}

- (id)initWithName:(CPString)aName class:(Class)aClass parent:(MCResource)aParent
{
    if(self = [super initWithName:aName class:aClass parent:aParent])
    {
        _associatedObject = nil;
    }

    return self;
}

- (MCResource)associatedObject
{
    CPLog.trace("MCBelongsToAssociation.associatedObject");

    if(_associatedObject)
        return _associatedObject;

    var parentalAssociationId = [_parent valueForKey:_associationName + "Id"];

    if(!parentalAssociationId)
        return nil;

    _associatedObject = [MCResource getResourceWithId:parentalAssociationId ofClass:_associatedObjectClass];

    return _associatedObject;
}

- (void)setAssociatedObject:(MCResource)associatedObject
{
    _associatedObject = associatedObject;
}

@end
