////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonDefinition+ExperimentalAPI.h"
#import "Typhoon.h"

#import "TyphoonPropertyInjectedByType.h"
#import "TyphoonPropertyInjectedWithStringRepresentation.h"
#import "TyphoonPropertyInjectedAsCollection.h"
#import "TyphoonPropertyInjectedAsObjectInstance.h"
#import "TyphoonPropertyInjectedByFactoryReference.h"
#import "TyphoonPropertyInjectedByComponentFactory.h"
#import "TyphoonPropertyInjectedWithRuntimeArg.h"
#import "TyphoonShorthand.h"

@protocol TyphoonObjectWithCustomInjection <NSObject>

- (id) customObjectInjection;

@end

@interface TyphoonDefinition (ExperimentalAPI) <TyphoonObjectWithCustomInjection>

@end


@implementation TyphoonDefinition (ExperimentalAPI)

- (void)_injectProperty:(SEL)selector with:(id)injection
{
    if ([injection isKindOfClass:[TyphoonAbstractInjectedProperty class]]) {
        [(TyphoonAbstractInjectedProperty *)injection setName:NSStringFromSelector(selector)];
        [_injectedProperties addObject:injection];
    }
    else if ([injection conformsToProtocol:@protocol(TyphoonObjectWithCustomInjection)]) {
        [self _injectProperty:selector with:[injection customObjectInjection]];
    }
    else {
        [self _injectProperty:selector with:TyphoonInjectionWithObject(injection)];
    }
}

- (void)_injectProperty:(SEL)selector
{    
    [self _injectProperty:selector with:TyphoonInjectionByType()];
}

#pragma mark - Injections

- (id)_injectionFromSelector:(SEL)factorySelector
{
    return [self _injectionFromKeyPath:NSStringFromSelector(factorySelector)];
}

- (id)_injectionFromKeyPath:(NSString *)keyPath
{
    return [[TyphoonPropertyInjectedByFactoryReference alloc] initWithName:nil reference:self.key keyPath:keyPath];
}

#pragma mark - TyphoonObjectWithCustomInjection

- (id)customObjectInjection
{
    TyphoonPropertyInjectedByReference *injection = [[TyphoonPropertyInjectedByReference alloc] initWithName:nil reference:self.key];
    injection.assemblyBuildArgs = self->_currentRuntimeArgs;
    return injection;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface TyphoonAssembly (ExperimentalAPI) <TyphoonObjectWithCustomInjection>
@end

@implementation TyphoonAssembly (ExperimentalAPI)

- (id)customObjectInjection
{
    return TyphoonInjectionWithComponentFactory();
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface TyphoonCollaboratingAssemblyProxy (ExperimentalAPI) <TyphoonObjectWithCustomInjection>
@end

@implementation TyphoonCollaboratingAssemblyProxy (ExperimentalAPI)

- (id)customObjectInjection
{
    return TyphoonInjectionWithComponentFactory();
}

@end

/////////////////////////////////// Injection making functions /////////////////////////////////////////////////////////////////////////

id TyphoonInjectionWithObject(id object)
{
    return [[TyphoonPropertyInjectedAsObjectInstance alloc] initWithName:nil objectInstance:object];
}

id TyphoonInjectionByType(void)
{
    return [[TyphoonPropertyInjectedByType alloc] init];
}

id TyphoonInjectionWithObjectFromString(NSString *string)
{
    return [[TyphoonPropertyInjectedWithStringRepresentation alloc] initWithName:nil value:string];
}

id TyphoonInjectionWithCollection(void (^collection)(TyphoonPropertyInjectedAsCollection *collectionBuilder))
{
    TyphoonPropertyInjectedAsCollection *propertyInjectedAsCollection = [[TyphoonPropertyInjectedAsCollection alloc] initWithName:nil];
    
    if (collection) {
        __unsafe_unretained TyphoonPropertyInjectedAsCollection *weakPropertyInjectedAsCollection = propertyInjectedAsCollection;
        collection(weakPropertyInjectedAsCollection);
    }
    return propertyInjectedAsCollection;
}

id TyphoonInjectionWithComponentFactory(void)
{
    return [[TyphoonPropertyInjectedByComponentFactory alloc] init];
}

id TyphoonInjectionWithRuntimeArgumentAtIndex(NSInteger argumentIndex)
{
    return [[TyphoonPropertyInjectedWithRuntimeArg alloc] initWithArgumentIndex:argumentIndex];
}


