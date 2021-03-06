#############################################################################
##
##                                               CAP package
##
##  Copyright 2014, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#! @Chapter Universal Objects
##
#############################################################################

#FIXME: Add CanComputePreCompose to assumptions in implied methods

##
InstallMethod( AddToGenesis,
               [ IsCapCategoryCell, IsString, IsObject ], 

  function( cell, genesis_entry_name, genesis_entry )
    
    if HasGenesis( cell ) then
      
      AUTODOC_APPEND_RECORD_WRITEONCE( Genesis( cell ), rec( (genesis_entry_name) := genesis_entry ) );
      
   else
      
      SetGenesis( cell, rec( (genesis_entry_name) := genesis_entry ) );
      
   fi;
   
end );

####################################
##
## Kernel
##
####################################

####################################
## Add Operations
####################################

##
InstallMethod( AddKernelObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelFunction( category, func );
    
    SetCanComputeKernelObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( KernelObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local kernel;
        
        kernel := func( mor );
        
        Add( CapCategory( mor ), kernel );
        
        SetFilterObj( kernel, WasCreatedAsKernelObject );
        
        AddToGenesis( kernel, "KernelObjectDiagram", mor );
        
        return kernel;
        
    end );
    
end );

## convenience method
##
InstallMethod( KernelLift,
               [ IsCapCategoryObject, IsCapCategoryMorphism ],
               
  function( kernel, test_morphism )
  
    return KernelLift( Genesis( kernel )!.KernelObjectDiagram, test_morphism );
  
end );

##
InstallMethod( AddKernelLift,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelLiftFunction( category, func );
    
    SetCanComputeKernelLift( category, true );
    
    InstallMethodWithToDoForIsWellDefined( KernelLift,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor, test_morphism )
        local kernel_lift, kernel;
        
        if HasKernelObject( mor ) then
        
          return KernelLiftWithGivenKernelObject( mor, test_morphism, KernelObject( mor ) );
        
        fi;
        
        kernel_lift := func( mor, test_morphism );
        
        Add( CapCategory( mor ), kernel_lift );

        kernel := Range( kernel_lift );
        
        SetKernelObject( mor, kernel );
        
        SetFilterObj( kernel, WasCreatedAsKernelObject );
        
        AddToGenesis( kernel, "KernelObjectDiagram", mor );
        
        return kernel_lift;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "KernelLift", 2 ) );
    
end );

##
InstallMethod( AddKernelLiftWithGivenKernelObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelLiftWithGivenKernelObjectFunction( category, func );
    
    SetCanComputeKernelLiftWithGivenKernelObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( KernelLiftWithGivenKernelObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( mor, test_morphism, kernel )
        local kernel_lift;
        
        kernel_lift := func( mor, test_morphism, kernel );
        
        Add( CapCategory( mor ), kernel_lift );
        
        return kernel_lift;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "KernelLiftWithGivenKernelObject", 3 ) );
    
end );

##
InstallMethod( AddKernelEmb,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelEmbFunction( category, func );
    
    SetCanComputeKernelEmb( category, true );
    
    InstallMethodWithToDoForIsWellDefined( KernelEmb,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local kernel_emb, kernel;
        
        if HasKernelObject( mor ) then
          
          return KernelEmbWithGivenKernelObject( mor, KernelObject( mor ) );
          
        fi;
        
        kernel_emb := func( mor );
        
        Add( CapCategory( mor ), kernel_emb );
        
        SetIsMonomorphism( kernel_emb, true );
        
        kernel := Source( kernel_emb );
        
        SetKernelObject( mor, kernel );
        
        SetFilterObj( kernel, WasCreatedAsKernelObject );
        
        AddToGenesis( kernel, "KernelObjectDiagram", mor );
        
        SetKernelEmb( kernel, kernel_emb );
        
        #Is this necessary (and in all other analogous situations?): SetKernelEmbWithGivenKernelObject( mor, kernel, kernel_emb );
        
        return kernel_emb;
        
    end );
    
end );

##
InstallMethod( AddKernelEmbWithGivenKernelObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelEmbWithGivenKernelObjectFunction( category, func );
    
    SetCanComputeKernelEmbWithGivenKernelObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( KernelEmbWithGivenKernelObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( mor, kernel )
        local kernel_emb;
        
        kernel_emb := func( mor, kernel );
        
        Add( CapCategory( mor ), kernel_emb );
        
        SetIsMonomorphism( kernel_emb, true );
        
        SetKernelEmb( kernel, kernel_emb );
        
        return kernel_emb;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "KernelEmbWithGivenKernelObject", 2 ) );

end );


####################################
## Attributes
####################################

## convenience
##
InstallMethod( KernelEmb,
               [ IsCapCategoryObject and WasCreatedAsKernelObject ],
               
  function( kernel )
  
    return KernelEmb( Genesis( kernel )!.KernelObjectDiagram );
    
end );

####################################
## Implied Operations
####################################



####################################
## Functorial operations
####################################

##
InstallMethod( KernelObjectFunctorial,
               [ IsList ],
                                  
  function( morphism_of_morphisms )
    
    return KernelObjectFunctorial( morphism_of_morphisms[1], morphism_of_morphisms[2][1], morphism_of_morphisms[3] );
    
end );

####################################
##
## Cokernel
##
####################################

####################################
## Add Operations
####################################

##
InstallMethod( AddCokernel,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelFunction( category, func );
    
    SetCanComputeCokernel( category, true );
    
    InstallMethodWithToDoForIsWellDefined( Cokernel,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local cokernel;
        
        cokernel := func( mor );
        
        Add( CapCategory( mor ), cokernel );
        
        SetFilterObj( cokernel, WasCreatedAsCokernel );
        
        AddToGenesis( cokernel,"CokernelDiagram", mor );
        
        return cokernel;
        
    end );
    
end );

## convenience
##
InstallMethod( CokernelColift,
               [ IsCapCategoryObject, IsCapCategoryMorphism ],
               
  function( cokernel, test_morphism )
  
    return CokernelColift( Genesis( cokernel )!.CokernelDiagram, test_morphism );
  
end );

##
InstallMethod( AddCokernelColift,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelColiftFunction( category, func );
    
    SetCanComputeCokernelColift( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CokernelColift,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor, test_morphism )
        local cokernel_colift, cokernel;
        
        if HasCokernel( mor ) then
          
          return CokernelColiftWithGivenCokernel( mor, test_morphism, Cokernel( mor ) );
          
        fi;
        
        cokernel_colift := func( mor, test_morphism );
        
        Add( CapCategory( mor ), cokernel_colift );
        
        cokernel := Source( cokernel_colift );
        
        SetFilterObj( cokernel, WasCreatedAsCokernel );
        
        AddToGenesis( cokernel, "CokernelDiagram", mor );
        
        return cokernel_colift;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "CokernelColift", 2 ) );
    
end );

##
InstallMethod( AddCokernelColiftWithGivenCokernel,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelColiftWithGivenCokernelFunction( category, func );
    
    SetCanComputeCokernelColiftWithGivenCokernel( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CokernelColiftWithGivenCokernel,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( mor, test_morphism, cokernel )
        local cokernel_colift;
        
        cokernel_colift := func( mor, test_morphism, cokernel );
        
        Add( CapCategory( mor ), cokernel_colift );
        
        return cokernel_colift;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "CokernelColiftWithGivenCokernel", 3 ) );
    
end );

##
InstallMethod( AddCokernelProj,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelProjFunction( category, func );
    
    SetCanComputeCokernelProj( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CokernelProj,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local cokernel_proj, cokernel;
        
        if HasCokernel( mor ) then
          
          return CokernelProjWithGivenCokernel( mor, Cokernel( mor ) );
          
        fi;
        
        cokernel_proj := func( mor );
        
        Add( CapCategory( mor ), cokernel_proj );
        
        SetIsEpimorphism( cokernel_proj, true );

        cokernel := Range( cokernel_proj );
        
        SetCokernel( mor, cokernel );
        
        SetFilterObj( cokernel, WasCreatedAsCokernel );
        
        AddToGenesis( cokernel, "CokernelDiagram", mor );

        SetCokernelProj( cokernel, cokernel_proj );
        
        return cokernel_proj;
        
    end );
    
end );

##
InstallMethod( AddCokernelProjWithGivenCokernel,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelProjWithGivenCokernelFunction( category, func );
    
    SetCanComputeCokernelProjWithGivenCokernel( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CokernelProjWithGivenCokernel,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( mor, cokernel )
        local cokernel_proj;
        
        cokernel_proj := func( mor, cokernel );
        
        Add( CapCategory( mor ), cokernel_proj );
        
        SetIsEpimorphism( cokernel_proj, true );

        SetCokernelProj( cokernel, cokernel_proj );
        
        return cokernel_proj;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "CokernelProjWithGivenCokernel", 2 ) );
    
end );

####################################
## Attributes 
####################################

##
InstallMethod( CokernelProj,
               [ IsCapCategoryObject and WasCreatedAsCokernel ],
               
  function( cokernel )
    
    return CokernelProj( Genesis( cokernel )!.CokernelDiagram );
    
end );



####################################
## Functorial operations
####################################

##
InstallMethod( CokernelFunctorial,
               [ IsList ],
                                  
  function( morphism_of_morphisms )
    
    return CokernelFunctorial( morphism_of_morphisms[1], morphism_of_morphisms[2][2], morphism_of_morphisms[3] );
    
end );

####################################
##
## Coproduct and Pushout
##
####################################

##
InstallGlobalFunction( InjectionOfCofactor,
               
  function( object_product_list, injection_number )
    local number_of_objects;
    
    if WasCreatedAsCoproduct( object_product_list ) and WasCreatedAsPushout( object_product_list ) then
        
      ## this might only happen when
      ## the function which was added to construct the coproduct/pushout does not return
      ## a new object but some part of its input
      
      return Error( "this object is a coproduct and a pushout concurrently, thus the injection is ambiguous" );
        
    fi;
    
    ## convenience: first argument was created as a coproduct
    if WasCreatedAsCoproduct( object_product_list ) then
    
      number_of_objects := Length( Genesis( object_product_list )!.CoproductDiagram );
      
      if injection_number < 1 or injection_number > number_of_objects then
      
        Error( Concatenation( "there does not exist a ", String( injection_number ), "-th injection" ) );
      
      fi;
    
      return InjectionOfCofactorOfCoproductWithGivenCoproduct( Genesis( object_product_list )!.CoproductDiagram, injection_number, object_product_list );
    
    fi;
    
    ## convenience: first argument was created as a pushout
    if WasCreatedAsPushout( object_product_list ) then
    
      number_of_objects := Length( Genesis( object_product_list )!.PushoutDiagram );
      
      if injection_number < 1 or injection_number > number_of_objects then
      
        Error( Concatenation( "there does not exist a ", String( injection_number ), "-th injection" ) );
      
      fi;
    
      return InjectionOfCofactorOfPushoutWithGivenPushout( Genesis( object_product_list )!.PushoutDiagram, injection_number, object_product_list );
    
    fi;
    
    ## first argument is a product object
    number_of_objects := Length( object_product_list );
  
    if injection_number < 0 or injection_number > number_of_objects then
    
      Error( Concatenation( "there does not exist a ", String( injection_number ), "-th injection" ) );
    
    fi;
    
    if IsCapCategoryObject( object_product_list[1] ) then
      
      return InjectionOfCofactorOfCoproductOp( object_product_list, injection_number, object_product_list[1] );
    
    else ## IsCapCategoryMorphism( object_product_list[1] ) = true
      
      return InjectionOfCofactorOfPushoutOp( object_product_list, injection_number, object_product_list[1] );
      
    fi;
    
end );

####################################
##
## Coproduct
##
####################################

InstallGlobalFunction( Coproduct,
  
  function( arg )
    
    if Length( arg ) = 1
       and IsList( arg[1] )
       and ForAll( arg[1], IsCapCategoryObject ) then
       
       return CoproductOp( arg[1], arg[1][1] );
       
    fi;
    
    return CoproductOp( arg, arg[ 1 ] );
    
end );

##
InstallMethod( AddCoproduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCoproductFunction( category, func );
    
    SetCanComputeCoproduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CoproductOp,
                                           [ IsList, IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( object_product_list, method_selection_object )
        local coproduct;
        
        coproduct := func( object_product_list );
        
        Add( CapCategory( method_selection_object ), coproduct );
        
        AddToGenesis( coproduct, "CoproductDiagram", object_product_list );
        
        SetFilterObj( coproduct, WasCreatedAsCoproduct );
        
        return coproduct;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "CoproductOp", 2 ) );
    
end );

## convenience method
##
InstallMethod( InjectionOfCofactorOfCoproduct,
               [ IsList, IsInt ],
               
  function( object_product_list, injection_number )
    
    return InjectionOfCofactorOfCoproductOp( object_product_list, injection_number, object_product_list[1] );
    
end );

##
InstallMethod( AddInjectionOfCofactorOfCoproduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetInjectionOfCofactorOfCoproductFunction( category, func );
    
    SetCanComputeInjectionOfCofactorOfCoproduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( InjectionOfCofactorOfCoproductOp,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( object_product_list, injection_number, method_selection_object )
        local injection_of_cofactor, coproduct;
        
        if HasCoproductOp( object_product_list, method_selection_object ) then
          
          return InjectionOfCofactorOfCoproductWithGivenCoproduct( object_product_list, injection_number, CoproductOp( object_product_list, method_selection_object ) );
          
        fi;
        
        injection_of_cofactor := func( object_product_list, injection_number );
        
        Add( CapCategory( method_selection_object ), injection_of_cofactor );
        
        ## FIXME: it suffices that the category knows that it has a zero object
        if HasCanComputeZeroObject( category ) and CanComputeZeroObject( category ) then
          
          SetIsSplitMonomorphism( injection_of_cofactor, true );
          
        fi;
        
        coproduct := Range( injection_of_cofactor );
        
        AddToGenesis( coproduct, "CoproductDiagram", object_product_list );
        
        SetCoproductOp( object_product_list, method_selection_object, coproduct );
        
        SetFilterObj( coproduct, WasCreatedAsCoproduct );
        
        return injection_of_cofactor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "InjectionOfCofactorOfCoproductOp", 3 ) );

end );

##
InstallMethod( AddInjectionOfCofactorOfCoproductWithGivenCoproduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetInjectionOfCofactorOfCoproductWithGivenCoproductFunction( category, func );
    
    SetCanComputeInjectionOfCofactorOfCoproductWithGivenCoproduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( InjectionOfCofactorOfCoproductWithGivenCoproduct,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( object_product_list, injection_number, coproduct )
        local injection_of_cofactor;
        
        injection_of_cofactor := func( object_product_list, injection_number, coproduct );
        
        Add( category, injection_of_cofactor );
        
        ## FIXME: it suffices that the category knows that it has a zero object
        if HasCanComputeZeroObject( category ) and CanComputeZeroObject( category ) then
          
          SetIsSplitMonomorphism( injection_of_cofactor, true );
          
        fi;
        
        return injection_of_cofactor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "InjectionOfCofactorOfCoproductWithGivenCoproduct", 3 ) );

end );

##
InstallGlobalFunction( UniversalMorphismFromCoproduct,

  function( arg )
    local diagram;
    
    if Length( arg ) = 2
       and IsList( arg[1] )
       and IsList( arg[2] ) then
       
       return UniversalMorphismFromCoproductOp( arg[1], arg[2], arg[1][1] );
       
    fi;
    
    diagram := List( arg, Source );
    
    return UniversalMorphismFromCoproductOp( diagram, arg, diagram[1] );
  
end );

##
InstallMethod( AddUniversalMorphismFromCoproduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromCoproductFunction( category, func );
    
    SetCanComputeUniversalMorphismFromCoproduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromCoproductOp,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( diagram, sink, method_selection_object )
        local test_object, components, coproduct_objects, universal_morphism, coproduct;
        
        ##TODO: superfluous
        components := sink;
        
        coproduct_objects := diagram;
        
        if HasCoproductOp( coproduct_objects, coproduct_objects[1] ) then
          
          return UniversalMorphismFromCoproductWithGivenCoproduct(
                   diagram,
                   sink,
                   CoproductOp( coproduct_objects, coproduct_objects[1] )
                 );
          
        fi;
        
        test_object := Range( sink[1] );
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Range( c ), test_object ) ) then
            
            Error( "ranges of morphisms must be equal in given sink-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, sink );
        
        Add( category, universal_morphism );
        
        coproduct := Source( universal_morphism );
        
        AddToGenesis( coproduct, "CoproductDiagram", coproduct_objects );
        
        SetCoproductOp( coproduct_objects, coproduct_objects[1], coproduct );
        
        SetFilterObj( coproduct, WasCreatedAsCoproduct );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromCoproductOp", 3 ) );
    
end );

##
InstallMethod( AddUniversalMorphismFromCoproductWithGivenCoproduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromCoproductWithGivenCoproductFunction( category, func );
    
    SetCanComputeUniversalMorphismFromCoproductWithGivenCoproduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromCoproductWithGivenCoproduct,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( diagram, sink, coproduct )
        local test_object, components, coproduct_objects, universal_morphism;
        
        test_object := Range( sink[1] );
        
        components := sink; #components superfluous
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Range( c ), test_object ) ) then
            
            Error( "ranges of morphisms must be equal in given sink-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, sink, coproduct );
        
        Add( category, universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromCoproductWithGivenCoproduct", 3 ) );
    
end );



####################################
## Functorial operations
####################################

##
InstallMethod( CoproductFunctorial,
               [ IsList ],
                                  
  function( morphism_list )
    
    return CoproductFunctorialOp( morphism_list, morphism_list[1] );
    
end );


####################################
##
## Direct Product and FiberProduct
##
####################################

## convenience method:
##
InstallGlobalFunction( ProjectionInFactor,
               
  function( object_product_list, projection_number )
    local number_of_objects;
    
    if WasCreatedAsDirectProduct( object_product_list ) and WasCreatedAsFiberProduct( object_product_list ) then
        
        ## this might only happen when
        ## the function which was added to construct the product/ pullback does not return
        ## a new object but some part of its input
        
        return Error( "this object is a product and a pullback concurrently, thus the projection is ambiguous" );
        
    fi;
    
    ## convenience: first argument was created as direct product
    if WasCreatedAsDirectProduct( object_product_list ) then
    
      number_of_objects := Length( Genesis( object_product_list )!.DirectProductDiagram );
      
      if projection_number < 1 or projection_number > number_of_objects then
      
        Error( Concatenation( "there does not exist a ", String( projection_number ), "-th projection" ) );
      
      fi;
    
      return ProjectionInFactorOfDirectProductWithGivenDirectProduct( Genesis( object_product_list )!.DirectProductDiagram, projection_number, object_product_list );
    
    fi;
    
    ## convenience: first argument was created as a pullback
    if WasCreatedAsFiberProduct( object_product_list ) then
    
      number_of_objects := Length( Genesis( object_product_list )!.FiberProductDiagram );
      
      if projection_number < 1 or projection_number > number_of_objects then
      
        Error( Concatenation( "there does not exist a ", String( projection_number ), "-th projection" ) );
      
      fi;
    
      return ProjectionInFactorOfFiberProductWithGivenFiberProduct( Genesis( object_product_list )!.FiberProductDiagram, projection_number, object_product_list );
    
    fi;
    
    ## assumption: first argument is a product object
    number_of_objects := Length( object_product_list );
  
    if projection_number < 0 or projection_number > number_of_objects then
    
      Error( Concatenation( "there does not exist a ", String( projection_number ), "-th projection" ) );
    
    fi;
    
    if IsCapCategoryObject( object_product_list[1] )  then 
      
      return ProjectionInFactorOfDirectProductOp( object_product_list, projection_number, object_product_list[1] );
      
    else # IsCapCategoryMorphism( object_product_list[1] ) = true
      
      return ProjectionInFactorOfFiberProductOp( object_product_list, projection_number, object_product_list[1] );
      
    fi;
  
end );


####################################
##
## Direct Product
##
####################################

## GAP-Hack in order to avoid the pre-installed GAP-method DirectProduct
BindGlobal( "CAP_INTERNAL_DIRECT_PRODUCT_SAVE", DirectProduct );

MakeReadWriteGlobal( "DirectProduct" );

DirectProduct := function( arg )
  
  if Length( arg ) = 1
     and IsList( arg[1] ) 
     and ForAll( arg[1], IsCapCategoryObject ) then
     
     return DirectProductOp( arg[1], arg[1][1] );
     
  fi;
  
  if ( ForAll( arg, IsCapCategory ) or ForAll( arg, IsCapCategoryObject ) or ForAll( arg, IsCapCategoryMorphism ) ) and Length( arg ) > 0 then
      
      return DirectProductOp( arg, arg[ 1 ] );
      
  fi;
  
  return CallFuncList( CAP_INTERNAL_DIRECT_PRODUCT_SAVE, arg );
  
end;

MakeReadOnlyGlobal( "DirectProduct" );

##
InstallMethod( AddDirectProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetDirectProductFunction( category, func );
    
    SetCanComputeDirectProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( DirectProductOp,
                                           [ IsList, IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( object_product_list, method_selection_object )
        local direct_product;
        
        direct_product := func( object_product_list );
        
        SetFilterObj( direct_product, WasCreatedAsDirectProduct );
        
        AddToGenesis( direct_product, "DirectProductDiagram", object_product_list );
        
        Add( CapCategory( method_selection_object ), direct_product );
        
        return direct_product;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "DirectProductOp", 2 ) );
    
end );

##
InstallMethod( ProjectionInFactorOfDirectProduct,
               [ IsList, IsInt ],
               
  function( object_product_list, projection_number )
    
    return ProjectionInFactorOfDirectProductOp( object_product_list, projection_number, object_product_list[1] );
    
end );

##
InstallMethod( AddProjectionInFactorOfDirectProduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetProjectionInFactorOfDirectProductFunction( category, func );
    
    SetCanComputeProjectionInFactorOfDirectProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ProjectionInFactorOfDirectProductOp,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( object_product_list, projection_number, method_selection_object )
        local projection_in_factor, direct_product;
        
        if HasDirectProductOp( object_product_list, method_selection_object ) then
          
          return ProjectionInFactorOfDirectProductWithGivenDirectProduct( object_product_list, projection_number, DirectProductOp( object_product_list, method_selection_object ) );
          
        fi;
        
        projection_in_factor := func( object_product_list, projection_number );
        
        Add( CapCategory( method_selection_object ), projection_in_factor );
        
        ## FIXME: it suffices that the category knows that it has a zero object
        if HasCanComputeZeroObject( category ) and CanComputeZeroObject( category ) then
          
          SetIsSplitEpimorphism( projection_in_factor, true );
          
        fi;
        
        direct_product := Source( projection_in_factor );
        
        AddToGenesis( direct_product, "DirectProductDiagram", object_product_list );
        
        SetDirectProductOp( object_product_list, method_selection_object, direct_product );
        
        SetFilterObj( direct_product, WasCreatedAsDirectProduct );
        
        return projection_in_factor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "ProjectionInFactorOfDirectProductOp", 3 ) );

end );

##
InstallMethod( AddProjectionInFactorOfDirectProductWithGivenDirectProduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetProjectionInFactorOfDirectProductWithGivenDirectProductFunction( category, func );
    
    SetCanComputeProjectionInFactorOfDirectProductWithGivenDirectProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ProjectionInFactorOfDirectProductWithGivenDirectProduct,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( object_product_list, projection_number, direct_product )
        local projection_in_factor;
        
        projection_in_factor := func( object_product_list, projection_number, direct_product );
        
        Add( category, projection_in_factor );
        
        ## FIXME: it suffices that the category knows that it has a zero object
        if HasCanComputeZeroObject( category ) and CanComputeZeroObject( category ) then
          
          SetIsSplitEpimorphism( projection_in_factor, true );
          
        fi;
        
        return projection_in_factor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "ProjectionInFactorOfDirectProductWithGivenDirectProduct", 3 ) );

end );

##
InstallGlobalFunction( UniversalMorphismIntoDirectProduct,

  function( arg )
    local diagram;
    
    if Length( arg ) = 2
       and IsList( arg[1] )
       and IsList( arg[2] ) then
       
       return UniversalMorphismIntoDirectProductOp( arg[1], arg[2], arg[1][1] );
       
    fi;
    
    ##convenience: UniversalMorphismIntoDirectProduct( test_projection_1, ..., test_projection_k )
    diagram := List( arg, Range );
    
    return UniversalMorphismIntoDirectProductOp( diagram, arg, diagram[1] );
  
end );

##
InstallMethod( AddUniversalMorphismIntoDirectProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoDirectProductFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoDirectProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoDirectProductOp,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( diagram, source, method_selection_object )
        local test_object, components, direct_product_objects, universal_morphism, direct_product;
        
        #TODO: superfluous
        components := source;
        
        direct_product_objects := diagram;
        
        if HasDirectProductOp( direct_product_objects, direct_product_objects[1] ) then
        
          return UniversalMorphismIntoDirectProductWithGivenDirectProduct(
                   diagram,
                   source,
                   DirectProductOp( direct_product_objects, direct_product_objects[1] )
                 );
          
        fi;
        
        test_object := Source( source[1] );
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Source( c ), test_object ) ) then
            
            Error( "sources of morphisms must be equal in given source-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, source );
        
        Add( category, universal_morphism );
        
        direct_product := Range( universal_morphism );
        
        AddToGenesis( direct_product, "DirectProductDiagram", direct_product_objects );
        
        SetDirectProductOp( direct_product_objects, direct_product_objects[1], direct_product );
        
        Add( CapCategory( direct_product_objects[1] ), direct_product );
        
        SetFilterObj( direct_product, WasCreatedAsDirectProduct );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismIntoDirectProductOp", 3 ) );
    
end );

##
InstallMethod( AddUniversalMorphismIntoDirectProductWithGivenDirectProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoDirectProductWithGivenDirectProductFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoDirectProductWithGivenDirectProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoDirectProductWithGivenDirectProduct,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( diagram, source, direct_product )
        local test_object, components, direct_product_objects, universal_morphism;
        
        test_object := Source( source[1] );
        
        components := source;#FIXME: components superfluous
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Source( c ), test_object ) ) then
            
            Error( "sources of morphisms must be equal in given source-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, source, direct_product );
        
        Add( category, universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismIntoDirectProductWithGivenDirectProduct", 3 ) );
    
end );



####################################
## Functorial operations
####################################

##
InstallMethod( DirectProductFunctorial,
               [ IsList ],
                                  
  function( morphism_list )
    
    return DirectProductFunctorialOp( morphism_list, morphism_list[1] );
    
end );


####################################
##
## Direct sum
##
####################################

## Immediate methods which link DirectProduct and Coproduct to
## DirectSum in the additive case
InstallImmediateMethod( IS_IMPLIED_DIRECT_SUM,
                        IsCapCategoryObject and WasCreatedAsDirectProduct and IsAdditiveCategory,
                        0,
                        
  function( direct_product )
    local summands;
    
    summands := Genesis( direct_product )!.DirectProductDiagram;
    
    SetDirectSumOp( summands, summands[1], direct_product );
    
    AddToGenesis( direct_product, "DirectProductDiagram", summands );
    
    AddToGenesis( direct_product, "CoproductDiagram", summands ); 
    
    SetFilterObj( direct_product, WasCreatedAsDirectSum );
    
    SetFilterObj( direct_product, WasCreatedAsCoproduct );
    
    SetCoproductOp( summands, summands[1], direct_product );
    
    return true;
    
end );

InstallImmediateMethod( IS_IMPLIED_DIRECT_SUM,
                        IsCapCategoryObject and WasCreatedAsCoproduct and IsAdditiveCategory,
                        0,
                        
  function( coproduct )
    local summands;
  
    summands := Genesis( coproduct )!.CoproductDiagram;
  
    SetDirectSumOp( summands, summands[1], coproduct );
    
    AddToGenesis( coproduct, "DirectProductDiagram", summands );
    
    AddToGenesis( coproduct, "CoproductDiagram", summands ); 
    
    SetFilterObj( coproduct, WasCreatedAsDirectSum );
    
    SetFilterObj( coproduct, WasCreatedAsDirectProduct );
    
    SetDirectProductOp( summands, summands[1], coproduct );
    
    return true;
    
end );


## GAP-Hack in order to avoid the pre-installed GAP-method DirectSum
BindGlobal( "CAP_INTERNAL_DIRECT_SUM_SAVE", DirectSum );

MakeReadWriteGlobal( "DirectSum" );

DirectSum := function( arg )
  
  if Length( arg ) = 1
     and IsList( arg[1] )
     and ForAll( arg[1], IsCapCategoryObject ) then
     
     return DirectSumOp( arg[1], arg[1][1] );
     
   fi;
  
  if ( ForAll( arg, IsCapCategory ) or ForAll( arg, IsCapCategoryObject ) or ForAll( arg, IsCapCategoryMorphism ) ) and Length( arg ) > 0 then
      
      return DirectSumOp( arg, arg[ 1 ] );
      
  fi;
  
  return CallFuncList( CAP_INTERNAL_DIRECT_SUM_SAVE, arg );
  
end;

MakeReadOnlyGlobal( "DirectSum" );

##
InstallMethod( AddDirectSum,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetDirectSumFunction( category, func );
    
    SetCanComputeDirectSum( category, true );
    
    InstallMethodWithToDoForIsWellDefined( DirectSumOp,
                                           [ IsList, IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( object_product_list, method_selection_object )
        local direct_sum;
        
        direct_sum := func( object_product_list );
        
        Add( CapCategory( method_selection_object ), direct_sum );
        
        AddToGenesis( direct_sum, "DirectProductDiagram", object_product_list );
        
        AddToGenesis( direct_sum, "CoproductDiagram", object_product_list );
        
        SetFilterObj( direct_sum, WasCreatedAsDirectSum );
        
        ## this will treat direct_sum as if it was a direct product (see immediate method above)
        SetFilterObj( direct_sum, WasCreatedAsDirectProduct );
        
        ## this will treat direct_sum as if it was a coproduct (see immediate method above)
        SetFilterObj( direct_sum, WasCreatedAsCoproduct );
        
        return direct_sum;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "DirectSumOp", 2 ) );
    
end );


####################################
## Functorial operations
####################################

## FIXME: There has to be a DirectSumFunctorialOp in order to
## add these methods properly to the derivation graph
##
InstallMethod( DirectSumFunctorial,
               [ IsList ],
                                  
  function( morphism_list )
    
    return DirectSumFunctorialOp( morphism_list, morphism_list[1] );
    
end );

####################################
## Convenience operations
####################################

##
InstallMethod( MorphismBetweenDirectSums,
               [ IsList ],
               
  function( morphism_matrix )
    local morphism_matrix_listlist, row, rows, cols;
    
    morphism_matrix_listlist := [ ];
    
    for row in morphism_matrix do
      
      Append( morphism_matrix_listlist, row );
      
    od;
    
    rows := Length( morphism_matrix );
    
    cols := Length( morphism_matrix[1] );
    
    return MorphismBetweenDirectSumsOp( morphism_matrix_listlist, rows, cols, morphism_matrix[1][1] );
    
end );

InstallMethodWithCacheFromObject( MorphismBetweenDirectSumsOp,
                                  [ IsList, IsInt, IsInt, IsCapCategoryMorphism ],
                                  
  function( morphism_matrix_listlist, rows, cols, caching_object )
    local morphism_matrix, i, diagram_direct_sum_source, diagram_direct_sum_range, test_diagram_product, test_diagram_coproduct, morphism_into_product;
    
    Error( "test" );
    
    morphism_matrix := [ ];
    
    for i in [ 1 .. rows ] do
      
      Add( morphism_matrix, morphism_matrix_listlist{[(i-1)*cols + 1 .. i*cols]} );
      
    od;
    
    diagram_direct_sum_source := List( morphism_matrix, row -> Source( row[1] ) );
    
    diagram_direct_sum_range := List( morphism_matrix[1], entry -> Range( entry ) );
    
    test_diagram_coproduct := [ ];
    
    for test_diagram_product in morphism_matrix do
      
      Add( test_diagram_coproduct, UniversalMorphismIntoDirectProduct( diagram_direct_sum_range, test_diagram_product ) );
      
    od;
    
    return UniversalMorphismFromCoproduct( diagram_direct_sum_source, test_diagram_coproduct );
    
end: ArgumentNumber := 4 );

####################################
##
## Zero Object
##
####################################

##
InstallTrueMethod( WasCreatedAsZeroObject, IsZero );

## Immediate methods which link InitialObject and TerminalObject to
## ZeroObject in the additive case
InstallImmediateMethod( IS_IMPLIED_ZERO_OBJECT,
                        IsCapCategoryObject and WasCreatedAsTerminalObject and IsAdditiveCategory,
                        0,
                        
  function( terminal_object )
    local category;
    
    category := CapCategory( terminal_object );
    
    SetFilterObj( terminal_object, WasCreatedAsZeroObject );
    
    SetZeroObject( category, terminal_object );
    
    SetFilterObj( terminal_object, WasCreatedAsInitialObject );
    
    SetInitialObject( category, terminal_object );
    
    return true;
    
end );

##
InstallImmediateMethod( IS_IMPLIED_ZERO_OBJECT,
                        IsCapCategoryObject and WasCreatedAsInitialObject and IsAdditiveCategory,
                        0,
                        
  function( initial_object )
    local category;
    
    category := CapCategory( initial_object );
    
    SetFilterObj( initial_object, WasCreatedAsZeroObject );
    
    SetZeroObject( category, initial_object );
    
    SetFilterObj( initial_object, WasCreatedAsTerminalObject );
    
    SetTerminalObject( category, initial_object );
    
    return true;
    
end );

####################################
## Add Operations
####################################

##
InstallMethod( AddZeroObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetZeroObjectFunction( category, func );
    
    SetCanComputeZeroObject( category, true );
    
end );

####################################
## Attributes
####################################

##
InstallMethod( ZeroObject,
               [ IsCapCategoryCell ],
               
  function( cell )
    
    return ZeroObject( CapCategory( cell ) );
    
end );

##
InstallMethodWithToDoForIsWellDefined( ZeroObject,
                                       [ IsCapCategory ],
                                       
  function( category )
    local zero_object;
    
    if not CanComputeZeroObject( category ) then
        
        Error( "no possibility to construct zero object" );
        
    fi;
    
    zero_object := ZeroObjectFunction( category )();
    
    Add( category, zero_object );
    
    SetIsWellDefined( zero_object, true );
    
    SetIsZero( zero_object, true );
    
    SetFilterObj( zero_object, WasCreatedAsZeroObject );
    
    ## this will treat zero_object as if it was a terminal object (see immediate method above)
    SetFilterObj( zero_object, WasCreatedAsTerminalObject );
    
    ## this will treat zero_object as if it was an initial object (see immediate method above)
    SetFilterObj( zero_object, WasCreatedAsInitialObject );
    
    return zero_object;
    
end );

####################################
## Renamed Operations
####################################

##
InstallMethodWithToDoForIsWellDefined( MorphismFromZeroObject,
                                       [ IsCapCategoryObject ],
                                       
   function( obj )
   
     return UniversalMorphismFromInitialObject( obj );
   
end );

##
InstallMethodWithToDoForIsWellDefined( MorphismIntoZeroObject,
                                       [ IsCapCategoryObject ],
                                       
   function( obj )
   
     return UniversalMorphismIntoTerminalObject( obj );
   
end );

####################################
##
## Terminal Object
##
####################################

####################################
## Add Operations
####################################

##
InstallMethod( AddTerminalObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetTerminalObjectFunction( category, func );
    
    SetCanComputeTerminalObject( category, true );
    
end );

##
InstallMethod( AddUniversalMorphismIntoTerminalObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoTerminalObjectFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoTerminalObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoTerminalObject,
                                           [ IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( test_source )
        local category, universal_morphism, terminal_object;
        
        category := CapCategory( test_source );
        
        if HasTerminalObject( category ) then
        
          return UniversalMorphismIntoTerminalObjectWithGivenTerminalObject( test_source, TerminalObject( category ) );
          
        fi;
        
        universal_morphism := func( test_source );
        
        Add( CapCategory( test_source ), universal_morphism );
        
        terminal_object := Range( universal_morphism );
        
        SetTerminalObject( category, terminal_object );
        
        SetFilterObj( terminal_object, WasCreatedAsTerminalObject );
        
        return universal_morphism;
        
    end );
    
end );

##
InstallMethod( AddUniversalMorphismIntoTerminalObjectWithGivenTerminalObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoTerminalObjectWithGivenTerminalObjectFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoTerminalObjectWithGivenTerminalObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoTerminalObjectWithGivenTerminalObject,
                                           [ IsCapCategoryObject and ObjectFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( test_source, terminal_object )
        local universal_morphism;
        
        universal_morphism := func( test_source, terminal_object );
        
        Add( CapCategory( test_source ), universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismIntoTerminalObjectWithGivenTerminalObject", 2 ) );
    
end );

####################################
## Attributes
####################################

##
InstallMethod( TerminalObject,
               [ IsCapCategoryCell ],
               
  function( cell )
    
    return TerminalObject( CapCategory( cell ) );
    
end );

##
# Because the diagram of the terminal object is empty, the user
# must not install UniversalMorphismIntoTerminalObject without installing TerminalObject.
# Thus the following implication is unnecessary:
# InstallTrueMethod( CanComputeTerminalObject, CanComputeUniversalMorphismIntoTerminalObject );

## Maybe set IsWellDefined by default.
InstallMethod( TerminalObject,
               [ IsCapCategory and HasTerminalObjectFunction ],
               
  function( category )
    local terminal_object;
    
    terminal_object := TerminalObjectFunction( category )();
    
    Add( category, terminal_object );
    
    SetIsWellDefined( terminal_object, true );
    
    SetFilterObj( terminal_object, WasCreatedAsTerminalObject );
    
    return terminal_object;
    
end );

####################################
##
## Initial Object
##
####################################

####################################
## Add Operations
####################################

##
InstallMethod( AddInitialObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetInitialObjectFunction( category, func );
    
#     SetFilterObj( category, CanComputeInitialObject );
    
    SetCanComputeInitialObject( category, true );
    
end );

##
InstallMethod( AddUniversalMorphismFromInitialObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromInitialObjectFunction( category, func );
    
#     SetFilterObj( category, CanComputeUniversalMorphismFromInitialObject );
    
    SetCanComputeUniversalMorphismFromInitialObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromInitialObject,
                                           [ IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( test_sink )
        local category, universal_morphism, initial_object;
        
        category := CapCategory( test_sink );
        
        if HasInitialObject( category ) then
        
          return UniversalMorphismFromInitialObjectWithGivenInitialObject( test_sink, InitialObject( category ) );
          
        fi;
        
        universal_morphism := func( test_sink );
        
        Add( CapCategory( test_sink ), universal_morphism );
        
        initial_object := Source( universal_morphism );
        
        SetInitialObject( category, initial_object );
        
        SetFilterObj( initial_object, WasCreatedAsInitialObject );
        
        return universal_morphism;
        
    end );
    
end );

##
InstallMethod( AddUniversalMorphismFromInitialObjectWithGivenInitialObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromInitialObjectWithGivenInitialObjectFunction( category, func );
    
#     SetFilterObj( category, CanComputeUniversalMorphismFromInitialObjectWithGivenInitialObject );
    
    SetCanComputeUniversalMorphismFromInitialObjectWithGivenInitialObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromInitialObjectWithGivenInitialObject,
                                           [ IsCapCategoryObject and ObjectFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( test_sink, initial_object )
        local universal_morphism;
        
        universal_morphism := func( test_sink, initial_object );
        
        Add( CapCategory( test_sink ), universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromDirectProductWithGivenInitialObject", 2 ) );
    
end );

####################################
## Attributes
####################################

##
InstallMethod( InitialObject,
               [ IsCapCategoryCell ],
               
  function( cell )
    
    return InitialObject( CapCategory( cell ) );
    
end );

##
# Because the diagram of the initial object is empty, the user
# must not install UniversalMorphismFromInitialObject without installing InitialObject.
# Thus the following implication is unnecessary:
# InstallTrueMethod( CanComputeInitialObject, CanComputeUniversalMorphismFromInitialObject );

## Maybe set IsWellDefined by default?
InstallMethod( InitialObject,
               [ IsCapCategory and HasInitialObjectFunction ],
               
  function( category )
    local initial_object;
    
    initial_object := InitialObjectFunction( category )();
    
    Add( category, initial_object );
    
    SetIsWellDefined( initial_object, true );
    
    SetFilterObj( initial_object, WasCreatedAsInitialObject );
    
    return initial_object;
    
end );

####################################
##
## FiberProduct
##
####################################

InstallGlobalFunction( FiberProduct,
  
  function( arg )
    
    if Length( arg ) = 1
       and IsList( arg[1] )
       and ForAll( arg[1], IsCapCategoryMorphism ) then
       
       return FiberProductOp( arg[1], arg[1][1] );
       
     fi;
    
    return FiberProductOp( arg, arg[ 1 ] );
    
end );

####################################
## Add Operations
####################################

##
InstallMethod( AddFiberProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetFiberProductFunction( category, func );
    
    SetCanComputeFiberProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( FiberProductOp,
                                           [ IsList, IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( diagram, method_selection_morphism )
        local base, pullback;
        
        base := Range( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects(  Range( c ), base ) ) then
        
          Error( "the given morphisms of the pullback diagram must have equal ranges\n" );
        
        fi;
        
        pullback := func( diagram );
        
        SetFilterObj( pullback, WasCreatedAsFiberProduct );
        
        AddToGenesis( pullback, "FiberProductDiagram", diagram );
        
        Add( CapCategory( method_selection_morphism ), pullback );
        
        return pullback;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "FiberProductOp", 2 ) );
    
end );

## convenience method:
##
InstallMethod( ProjectionInFactorOfFiberProduct,
               [ IsList, IsInt ],
               
  function( diagram, projection_number )
    
    return ProjectionInFactorOfFiberProductOp( diagram, projection_number, diagram[1] );
    
end );

##
InstallMethod( AddProjectionInFactorOfFiberProduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetProjectionInFactorOfFiberProductFunction( category, func );
    
    SetCanComputeProjectionInFactorOfFiberProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ProjectionInFactorOfFiberProductOp,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryMorphism and MorphismFilter( category ) ],
                                             
      function( diagram, projection_number, method_selection_morphism )
        local base, projection_in_factor, pullback;
        
        if HasFiberProductOp( diagram, method_selection_morphism ) then
          
          return ProjectionInFactorOfFiberProductWithGivenFiberProduct( diagram, projection_number, FiberProductOp( diagram, method_selection_morphism ) );
          
        fi;
        
        base := Range( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects(  Range( c ), base ) ) then
        
          Error( "the given morphisms of the pullback diagram must have equal ranges\n" );
        
        fi;
        
        projection_in_factor := func( diagram, projection_number );
        
        Add( CapCategory( method_selection_morphism ), projection_in_factor );
        
        pullback := Source( projection_in_factor );
        
        AddToGenesis( pullback, "FiberProductDiagram", diagram );
        
        SetFiberProductOp( diagram, method_selection_morphism, pullback );
        
        SetFilterObj( pullback, WasCreatedAsFiberProduct );
        
        return projection_in_factor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "ProjectionInFactorOfFiberProductOp", 3 ) );

end );

##
InstallMethod( AddProjectionInFactorOfFiberProductWithGivenFiberProduct,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetProjectionInFactorOfFiberProductWithGivenFiberProductFunction( category, func );
    
    SetCanComputeProjectionInFactorOfFiberProductWithGivenFiberProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ProjectionInFactorOfFiberProductWithGivenFiberProduct,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( diagram, projection_number, pullback )
        local base, projection_in_factor;
        
        base := Range( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects(  Range( c ), base ) ) then
        
          Error( "the given morphisms of the pullback diagram must have equal ranges\n" );
        
        fi;
        
        projection_in_factor := func( diagram, projection_number, pullback );
        
        Add( category, projection_in_factor );
        
        return projection_in_factor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "ProjectionInFactorOfFiberProductWithGivenFiberProduct", 3 ) );

end );

##
InstallGlobalFunction( UniversalMorphismIntoFiberProduct,

  function( arg )
    local diagram, pullback_or_diagram, source;
    
    if Length( arg ) = 2
       and IsList( arg[1] )
       and IsList( arg[2] ) then
       
       return UniversalMorphismIntoFiberProductOp( arg[1], arg[2], arg[1][1] );
       
    fi;
    
    pullback_or_diagram := arg[ 1 ];
    
    source := arg{[ 2 .. Length( arg ) ]};
    
    if WasCreatedAsFiberProduct( pullback_or_diagram ) then
    
      diagram := Genesis( pullback_or_diagram )!.FiberProductDiagram;
    
      return UniversalMorphismIntoFiberProductOp( diagram, source, diagram[1] );
    
    fi;
    
    return UniversalMorphismIntoFiberProductOp( pullback_or_diagram, source, pullback_or_diagram[1] );
    
end );

##
InstallMethod( AddUniversalMorphismIntoFiberProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoFiberProductFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoFiberProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoFiberProductOp,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( diagram, source, method_selection_morphism )
        local base, test_object, components, universal_morphism, pullback;
        
        if HasFiberProductOp( diagram, diagram[1] ) then
        
          return UniversalMorphismIntoFiberProductWithGivenFiberProduct( 
                   diagram, 
                   source,
                   FiberProductOp( diagram, diagram[1] )
                 );
          
        fi;
        
        base := Range( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects(  Range( c ), base ) ) then
          
          Error( "the given morphisms of the pullback diagram must have equal ranges\n" );
          
        fi;
        
        test_object := Source( source[1] );
        
        components := source; #FIXME components superfluous
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Source( c ), test_object ) ) then
            
            Error( "sources of morphisms must be equal in given source-diagram" );
            
        fi;
        
        ## here the user also needs the diagram
        universal_morphism := func( diagram, source );
        
        Add( category, universal_morphism );
        
        pullback := Range( universal_morphism );
        
        AddToGenesis( pullback, "FiberProductDiagram", diagram );
        
        SetFiberProductOp( diagram, diagram[1], pullback );
        
#         Add( CapCategory( diagram[1] ), pullback );
        
        SetFilterObj( pullback, WasCreatedAsFiberProduct );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismIntoFiberProductOp", 3 ) );
    
end );

##
InstallMethod( AddUniversalMorphismIntoFiberProductWithGivenFiberProduct,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismIntoFiberProductWithGivenFiberProductFunction( category, func );
    
    SetCanComputeUniversalMorphismIntoFiberProductWithGivenFiberProduct( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismIntoFiberProductWithGivenFiberProduct,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) 
                                           ],
                                           
      function( diagram, source, pullback )
        local base, test_object, components, universal_morphism;
        
        base := Range( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Range( c ), base ) ) then
          
          Error( "the given morphisms of the pullback diagram must have equal ranges\n" );
          
        fi;
        
        test_object := Source( source[1] );
        
        components := source;
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Source( c ), test_object ) ) then
            
            Error( "sources of morphisms must be equal in given source-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, source, pullback );
        
        Add( category, universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismIntoFiberProductWithGivenFiberProduct", 3 ) );
    
end );



####################################
## Functorial operations
####################################

##
InstallMethod( FiberProductFunctorial,
               [ IsList ],
               
  function( morphism_of_morphisms )
      
      return FiberProductFunctorialOp( morphism_of_morphisms, morphism_of_morphisms[1][1] );
      
end );




####################################
##
## Pushout
##
####################################

InstallGlobalFunction( Pushout,
  
  function( arg )
    
    if Length( arg ) = 1
       and IsList( arg[1] )
       and ForAll( arg[1], IsCapCategoryMorphism ) then
       
       return PushoutOp( arg[1], arg[1][1] );
       
     fi;
    
    return PushoutOp( arg, arg[ 1 ] );
    
end );

####################################
## Add Operations
####################################

##
InstallMethod( AddPushout,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetPushoutFunction( category, func );
    
    SetCanComputePushout( category, true );
    
    InstallMethodWithToDoForIsWellDefined( PushoutOp,
                                           [ IsList, IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( diagram, method_selection_morphism )
        local cobase, pushout;
        
        cobase := Source( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Source( c ), cobase ) ) then
           
           Error( "the given morphisms of the pushout diagram must have equal sources\n" );
           
        fi;
        
        pushout := func( diagram );
        
        SetFilterObj( pushout, WasCreatedAsPushout );
        
        AddToGenesis( pushout, "PushoutDiagram", diagram );
        
        Add( category, pushout );
        
        return pushout;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "PushoutOp", 2 ) );
    
end );

## convenience method
##
InstallMethod( InjectionOfCofactorOfPushout,
               [ IsList, IsInt ],
               
  function( diagram, injection_number )
    
    return InjectionOfCofactorOfPushoutOp( diagram, injection_number, diagram[1] );
    
end );

##
InstallMethod( AddInjectionOfCofactorOfPushout,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetInjectionOfCofactorOfPushoutFunction( category, func );
    
    SetCanComputeInjectionOfCofactorOfPushout( category, true );
    
    InstallMethodWithToDoForIsWellDefined( InjectionOfCofactorOfPushoutOp,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryMorphism and MorphismFilter( category ), ],
                                             
      function( diagram, injection_number, method_selection_morphism )
        local cobase, injection_of_cofactor, pushout;
        
        if HasPushoutOp( diagram, method_selection_morphism ) then
          
          return InjectionOfCofactorOfPushoutWithGivenPushout( diagram, injection_number, PushoutOp( diagram, method_selection_morphism ) );
          
        fi;
        
        cobase := Source( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Source( c ), cobase ) ) then
           
           Error( "the given morphisms of the pushout diagram must have equal sources\n" );
           
        fi;
        
        injection_of_cofactor := func( diagram, injection_number );
        
        Add( CapCategory( method_selection_morphism ), injection_of_cofactor );
        
        pushout := Range( injection_of_cofactor );
        
        AddToGenesis( pushout, "PushoutDiagram", diagram );

        SetPushoutOp( diagram, method_selection_morphism, pushout );
        
        SetFilterObj( pushout, WasCreatedAsPushout );
        
        return injection_of_cofactor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "InjectionOfCofactorOfPushoutOp", 3 ) );

end );

##
InstallMethod( AddInjectionOfCofactorOfPushoutWithGivenPushout,
               [ IsCapCategory, IsFunction ],

  function( category, func )
    
    SetInjectionOfCofactorOfPushoutWithGivenPushoutFunction( category, func );
    
    SetCanComputeInjectionOfCofactorOfPushoutWithGivenPushout( category, true );
    
    InstallMethodWithToDoForIsWellDefined( InjectionOfCofactorOfPushoutWithGivenPushout,
                                           [ IsList,
                                             IsInt,
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                             
      function( diagram, injection_number, pushout )
        local cobase, injection_of_cofactor;
        
        cobase := Source( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Source( c ), cobase ) ) then
           
           Error( "the given morphisms of the pushout diagram must have equal sources\n" );
           
        fi;
        
        injection_of_cofactor := func( diagram, injection_number, pushout );
        
        Add( category, injection_of_cofactor );
        
        return injection_of_cofactor;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "InjectionOfCofactorOfPushoutWithGivenPushout", 3 ) );

end );

##
InstallGlobalFunction( UniversalMorphismFromPushout,

  function( arg )
    local diagram, pushout_or_diagram, sink;
    
    if Length( arg ) = 2
       and IsList( arg[1] )
       and IsList( arg[2] ) then
       
       return UniversalMorphismFromPushoutOp( arg[1], arg[2], arg[1][1] );
       
    fi;
    
    pushout_or_diagram := arg[ 1 ];
    
    sink := arg{[ 2 .. Length( arg ) ]};
    
    if WasCreatedAsPushout( pushout_or_diagram ) then
    
      diagram := Genesis( pushout_or_diagram )!.PushoutDiagram;
    
      return UniversalMorphismFromPushoutOp( diagram, sink, diagram[1] );
    
    fi;
    
    return UniversalMorphismFromPushoutOp( pushout_or_diagram, sink, pushout_or_diagram[1] );
    
end );

##
InstallMethod( AddUniversalMorphismFromPushout,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromPushoutFunction( category, func );
    
    SetCanComputeUniversalMorphismFromPushout( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromPushoutOp,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( diagram, sink, method_selection_morphism )
        local cobase, test_object, components, universal_morphism, pushout;
        
        if HasPushoutOp( diagram, diagram[1] ) then
        
          return UniversalMorphismFromPushoutWithGivenPushout( 
                   diagram, 
                   sink,
                   PushoutOp( diagram, diagram[1] )
                 );
          
        fi;
        
        cobase := Source( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Source( c ), cobase ) ) then
           
           Error( "the given morphisms of the pushout diagram must have equal sources\n" );
           
        fi;
        
        test_object := Range( sink[1] );
        
        components := sink;
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Range( c ), test_object ) ) then
            
            Error( "ranges of morphisms must be equal in given sink-diagram" );
            
        fi;
        
        ## here the user also needs the diagram
        universal_morphism := func( diagram, sink );
        
        Add( category, universal_morphism );
        
        pushout := Source( universal_morphism );
        
        AddToGenesis( pushout, "PushoutDiagram",diagram );
        
        SetPushoutOp( diagram, diagram[1], pushout );
        
        Add( CapCategory( diagram[1] ), pushout );
        
        SetFilterObj( pushout, WasCreatedAsPushout );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromPushoutOp", 3 ) );
    
end );

##
InstallMethod( AddUniversalMorphismFromPushoutWithGivenPushout,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromPushoutWithGivenPushoutFunction( category, func );
    
    SetCanComputeUniversalMorphismFromPushoutWithGivenPushout( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromPushoutWithGivenPushout,
                                           [ IsList,
                                             IsList,
                                             IsCapCategoryObject and ObjectFilter( category ) 
                                           ],
                                           
      function( diagram, sink, pushout )
        local cobase, test_object, components, universal_morphism;
        
        cobase := Source( diagram[1] );
        
        if not ForAll( diagram, c -> IsEqualForObjects( Source( c ), cobase ) ) then
           
           Error( "the given morphisms of the pushout diagram must have equal sources\n" );
           
        fi;
        
        test_object := Range( sink[1] );
        
        components := sink; #FIXME: components superfluous
        
        if false in List( components{[2 .. Length( components ) ]}, c -> IsEqualForObjects( Range( c ), test_object ) ) then
            
            Error( "ranges of morphisms must be equal in given sink-diagram" );
            
        fi;
        
        universal_morphism := func( diagram, sink, pushout );
        
        Add( category, universal_morphism );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromPushoutWithGivenPushout", 3 ) );
    
end );



####################################
## Functorial operations
####################################

##
InstallMethod( PushoutFunctorial,
               [ IsList ],
               
  function( morphism_of_morphisms )
      
      return PushoutFunctorialOp( morphism_of_morphisms, morphism_of_morphisms[1][1] );
      
end );


####################################
##
## Image
##
####################################

##
InstallMethod( AddImageObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetImageFunction( category, func );
    
    SetCanComputeImageObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ImageObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local image;
        
        image := func( mor );
        
        Add( category, image );
        
        SetFilterObj( image, WasCreatedAsImageObject );
        
        AddToGenesis( image, "ImageDiagram", mor );
        
        return image;
        
    end );
    
end );

##
InstallMethod( AddImageEmbedding,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetImageEmbeddingFunction( category, func );
    
    SetCanComputeImageEmbedding( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ImageEmbedding,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( mor )
        local image_embedding, image;
        
        if HasImageObject( mor ) then
        
          return ImageEmbeddingWithGivenImageObject( mor, ImageObject( mor ) );
        
        fi;
        
        image_embedding := func( mor );
        
        Add( CapCategory( mor ), image_embedding );
        
        ##Implication (by definition of an image)
        SetIsMonomorphism( image_embedding, true );
        
        image := Source( image_embedding );
        
        AddToGenesis( image, "ImageDiagram", mor );
        
        SetFilterObj( image, WasCreatedAsImageObject );
        
        SetImageObject( mor, image );
        
        return image_embedding;
        
    end );
    
end );

##
InstallMethod( AddImageEmbeddingWithGivenImageObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetImageEmbeddingWithGivenImageObjectFunction( category, func );
    
    SetCanComputeImageEmbeddingWithGivenImageObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( ImageEmbeddingWithGivenImageObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( mor, image )
        local image_embedding;
        
        image_embedding := func( mor, image );
        
        Add( category, image_embedding );
        
        return image_embedding;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "ImageEmbeddingWithGivenImageObject", 2 ) );
    
end );

##
InstallMethod( AddCoastrictionToImage,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCoastrictionToImageFunction( category, func );
    
    SetCanComputeCoastrictionToImage( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CoastrictionToImage,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ) ],
                                           
      function( morphism )
        local coastriction_to_image, image;
        
        if HasImageObject( morphism ) then
        
          return CoastrictionToImageWithGivenImageObject( morphism, ImageObject( morphism ) );
        
        fi;
        
        coastriction_to_image := func( morphism );
        
        Add( CapCategory( morphism ), coastriction_to_image );
        
        image := Range( coastriction_to_image );
        
        AddToGenesis( image, "ImageDiagram", morphism );
        
        SetFilterObj( image, WasCreatedAsImageObject );
        
        SetImageObject( morphism, image );
        
        return coastriction_to_image;
        
    end );
    
end );

##
InstallMethod( AddCoastrictionToImageWithGivenImageObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetCoastrictionToImageWithGivenImageObjectFunction( category, func );
    
    SetCanComputeCoastrictionToImageWithGivenImageObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( CoastrictionToImageWithGivenImageObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsCapCategoryObject and ObjectFilter( category ) ],
                                           
      function( morphism, image )
        local coastriction_to_image;
        
        coastriction_to_image := func( morphism, image );
        
        Add( category, coastriction_to_image );
        
        return coastriction_to_image;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "CoastrictionToImageWithGivenImageObject", 2 ) );
    
end );

##
InstallMethod( AddUniversalMorphismFromImage,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromImageFunction( category, func );
    
    SetCanComputeUniversalMorphismFromImage( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromImage,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsList ],
                                           
      function( morphism, test_factorization )
        local universal_morphism, image;
        
        if HasImageObject( morphism ) then
          
          return UniversalMorphismFromImageWithGivenImageObject(
                   morphism,
                   test_factorization,
                   ImageObject( morphism )
                 );
          
        fi;
        
        if ( Source( morphism ) <> Source( test_factorization[1] ) )
           or ( Range( morphism ) <> Range( test_factorization[2] ) )
           or ( Range( test_factorization[1] ) <> Range( test_factorization[2] ) ) then
            
            Error( "the input is not a proper factorization\n" );
            
        fi;
        
        universal_morphism := func( morphism, test_factorization );
        
        Add( category, universal_morphism );
        
        image := Source( universal_morphism );
        
        AddToGenesis( image, "ImageDiagram", morphism );
        
        SetImageObject( morphism, image );
        
        SetFilterObj( image, WasCreatedAsImageObject );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromImage", 2 ) );
    
end );

##
InstallMethod( AddUniversalMorphismFromImageWithGivenImageObject,
               [ IsCapCategory, IsFunction ],
               
  function( category, func )
    
    SetUniversalMorphismFromImageWithGivenImageObjectFunction( category, func );
    
    SetCanComputeUniversalMorphismFromImageWithGivenImageObject( category, true );
    
    InstallMethodWithToDoForIsWellDefined( UniversalMorphismFromImageWithGivenImageObject,
                                           [ IsCapCategoryMorphism and MorphismFilter( category ),
                                             IsList,
                                             IsCapCategoryObject ],
                                           
      function( morphism, test_factorization, image )
        local universal_morphism;
        
        if ( Source( morphism ) <> Source( test_factorization[1] ) )
           or ( Range( morphism ) <> Range( test_factorization[2] ) )
           or ( Range( test_factorization[1] ) <> Range( test_factorization[2] ) ) then
            
            Error( "the input is not a proper factorization\n" );
            
        fi;
        
        ##FIXME: this is a monomorphism if test_factorization[2] was a monomorphism (i.e. a proper input)
        universal_morphism := func( morphism, test_factorization, image );
        
        return universal_morphism;
        
    end : InstallMethod := InstallMethodWithCache, Cache := GET_METHOD_CACHE( category, "UniversalMorphismFromImageWithGivenImageObject", 3 ) );
    
end );

####################################
##
## Attributes
##
####################################

InstallMethod( ImageEmbedding,
               [ IsCapCategoryObject and WasCreatedAsImageObject ],
               
  function( image )
    
    return ImageEmbedding( Genesis( image )!.ImageDiagram );
    
end );

InstallMethod( CoastrictionToImage,
               [ IsCapCategoryObject and WasCreatedAsImageObject ],
               
  function( image )
    
    return CoastrictionToImage( Genesis( image )!.ImageDiagram );
    
end );


####################################
##
## Scheme for Universal Object
##
####################################

####################################
## Add Operations
####################################

####################################
## Attributes
####################################

####################################
## Implied Operations
####################################

