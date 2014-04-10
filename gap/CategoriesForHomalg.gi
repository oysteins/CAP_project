#############################################################################
##
##                                               CategoriesForHomalg package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##                  Sebastian Posur,   RWTH Aachen
##
#############################################################################

##
InstallValue( CATEGORIES_FOR_HOMALG,
              rec(
                   name_counter := 0
              )
);

##
InstallGlobalFunction( CATEGORIES_FOR_HOMALG_NAME_COUNTER,
                       
  function( )
    local counter;
    
    counter := CATEGORIES_FOR_HOMALG.name_counter + 1;
    
    CATEGORIES_FOR_HOMALG.name_counter := counter;
    
    return counter;
    
end );

##
InstallGlobalFunction( DECIDE_INSTALL_FUNCTION,
                       
  function( category, method, number_parameters )
    local caching_info;
    
    if not IsBound( category!.caching_info.( method ) ) then
        
        category!.caching_info.( method ) := "weak";
        
    fi;
    
    caching_info := category!.caching_info.( method );
    
    if caching_info = "weak" then
        
        PushOptions( rec( Cache := CachingObject( category, method, number_parameters ) ) );
        
        return;
        
    elif caching_info = "crisp" then
        
        PushOptions( rec( Cache := CachingObject( category, method, number_parameters, true ) ) );
        
        return;
        
    elif caching_info = "none" then
        
        PushOptions( rec( Cache := false ) );
        
    else
        
        Error( "wrong type of install function" );
        
    fi;
    
end );

######################################
##
## Reps, types, stuff.
##
######################################

DeclareRepresentation( "IsHomalgCategoryRep",
                       IsAttributeStoringRep and IsHomalgCategory,
                       [ ] );

BindGlobal( "TheFamilyOfHomalgCategories",
        NewFamily( "TheFamilyOfHomalgCategories" ) );

BindGlobal( "TheTypeOfHomalgCategories",
        NewType( TheFamilyOfHomalgCategories,
                 IsHomalgCategoryRep ) );


#####################################
##
## Global functions
##
#####################################

##
InstallGlobalFunction( CREATE_HOMALG_CATEGORY_FILTERS,
                       
  function( category )
    local name, filter_name, filter;
    
    name := Name( category );
    
    filter_name := Concatenation( name, "ObjectFilter" );
    
    SetObjectFilter( category, NewFilter( filter_name ) );
    
    filter_name := Concatenation( name, "MorphismFilter" );
    
    SetMorphismFilter( category, NewFilter( filter_name ) );
    
end );

##
InstallGlobalFunction( "CREATE_HOMALG_CATEGORY_OBJECT",
                       
  function( obj_rec, attr_list )
    local i, flatted_attribute_list;
    
    for i in [ 1 .. Length( attr_list ) ] do
        
        if IsString( attr_list[ i ][ 1 ] ) then
            
            attr_list[ i ][ 1 ] := ValueGlobal( attr_list[ i ][ 1 ] );
            
        fi;
        
    od;
    
    flatted_attribute_list := [ ];
    
    for i in attr_list do
        
        Add( flatted_attribute_list, i[ 1 ] );
        
        Add( flatted_attribute_list, i[ 2 ] );
        
    od;
    
    flatted_attribute_list := Concatenation( [ obj_rec, TheTypeOfHomalgCategories ], flatted_attribute_list );
    
    CallFuncList( ObjectifyWithAttributes, flatted_attribute_list );
    
    obj_rec!.caches := rec( );
    
    return obj_rec;
    
end );

#####################################
##
## Category stored object functions
##
#####################################

##
InstallMethod( ZeroObject,
               [ IsHomalgCategory ],
               
  function( category )
    local zero_obj;
    
    if not IsBound( category!.zero_object_constructor ) then
        
        Error( "no possibility to construct zero object" );
        
    fi;
    
    zero_obj := category!.zero_object_constructor();
    
    Add( category, zero_obj );
    
    SetIsZero( zero_obj, true );
    
    return zero_obj;
    
end );

######################################################
##
## Add functions
##
######################################################

#######################################
##
## IdentityMorphism
##
#######################################

##
InstallMethod( AddIdentityMorphism,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetIdentityMorphismFunction( category, func );
    
    SetCanComputeIdentityMorphism( category, true );
    
      InstallMethod( IdentityMorphism,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) ],
                   
      function( object )
        local ret_val;
        
        ret_val := func( object );
        
        Add( category, ret_val );
        
        SetIsOne( ret_val, true );
        
        SetInverse( ret_val, ret_val );
        
        return ret_val;
        
      end );
    
end );

#######################################
##
## PreCompose
##
#######################################

##
InstallMethod( AddPreCompose,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetPreComposeFunction( category, func );
    
    SetCanComputePreCompose( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "PreCompose", 2 );
    
    InstallMethodWithCache( PreCompose,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ), IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                   
      function( mor_left, mor_right )
        local ret_val;
        
        if not IsIdenticalObj( HomalgCategory( mor_left ), HomalgCategory( mor_right ) ) then
            
            Error( "morphisms must lie in the same category" );
            
        elif not IsIdenticalObj( Range( mor_left ), Source( mor_right ) ) then
            
            Error( "morphisms not composable" );
            
        fi;
        
        ret_val := func( mor_left, mor_right );
        
        Add( category, ret_val );
        
        return ret_val;
        
      end );
    
end );

#######################################
##
## Zero object
##
#######################################

InstallMethod( AddZeroObject,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    category!.zero_object_constructor := func;
    
    SetZeroObjectFunction( category, func );
    
    SetCanComputeZeroObject( category, true );
    
    InstallMethod( ZeroObject,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) ],
                   
      function( object )
        
        return ZeroObject( category );
        
      end );
    
end );

##
InstallMethod( AddMorphismIntoZeroObject,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetMorphismIntoZeroObjectFunction( category, func );
    
    SetCanComputeMorphismIntoZeroObject( category, true );
    
    InstallMethod( MorphismIntoZeroObject,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) ],
                   
      function( object )
        local morphism;
        
        morphism := func( object );
        
        Add( category, morphism );
        
        return morphism;
        
    end );
    
end );

##
InstallMethod( AddMorphismFromZeroObject,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetMorphismFromZeroObjectFunction( category, func );
    
    SetCanComputeMorphismFromZeroObject( category, true );
    
    InstallMethod( MorphismFromZeroObject,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) ],
                   
      function( object )
        local morphism;
        
        morphism := func( object );
        
        Add( category, morphism );
        
        return morphism;
        
    end );
    
end );

#######################################
##
## Direct sum
##
#######################################

##
InstallMethod( AddDirectSum_OnObjects,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    DECIDE_INSTALL_FUNCTION( category, "DirectSum", 2 );
    
    SetDirectSum_OnObjectsFunction( category, func );
    
    SetCanComputeDirectSum( category, true );
    
    InstallMethodWithCache( DirectSumOp,
                            [ IsList, IsHomalgCategoryObject and ObjectFilter( category ) ],
                   
      function( obj_list, obj1 )
        local obj2, sum_obj;
        
        if not Length( obj_list ) = 2 then
            
            Error( "there must be two objects for a direct sum" );
            
        fi;
        
        obj2 := obj_list[ 2 ];
        
        if not IsIdenticalObj( HomalgCategory( obj1 ), HomalgCategory( obj2 ) ) then
            
            Error( "Objects must lie in the same category" );
            
        fi;
        
        sum_obj := func( obj1, obj2 );
        
        SetFirstSummand( sum_obj, obj1 );
        
        SetSecondSummand( sum_obj, obj2 );
        
        Add( HomalgCategory( obj1 ), sum_obj );
        
        return sum_obj;
        
    end );
    
end );

##
InstallMethod( AddInjectionFromFirstSummand,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetInjectionFromFirstSummandFunction( category, func );
    
    SetCanComputeInjectionFromFirstSummand( category, true );
    
    InstallMethod( InjectionFromFirstSummand,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) and WasCreatedAsDirectSum ],
                   
      function( sum_obj )
        local injection1;
        
        injection1 := func( sum_obj );
        
        Add( HomalgCategory( sum_obj ), injection1 );
        
        ## TODO: This morphism is mono
        
        return injection1;
        
    end );
    
end );

##
InstallMethod( AddInjectionFromSecondSummand,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetInjectionFromSecondSummandFunction( category, func );
    
    SetCanComputeInjectionFromSecondSummand( category, true );
    
    InstallMethod( InjectionFromSecondSummand,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) and WasCreatedAsDirectSum ],
                   
      function( sum_obj )
        local injection1;
        
        injection1 := func( sum_obj );
        
        Add( HomalgCategory( sum_obj ), injection1 );
        
        ## TODO: This morphism is mono
        
        return injection1;
        
    end );
    
end );

##
InstallMethod( AddProjectionInFirstFactor,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetProjectionInFirstFactorFunction( category, func );
    
    SetCanComputeProjectionInFirstFactor( category, true );
    
    InstallMethod( ProjectionInFirstFactor,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) and WasCreatedAsDirectSum ],
                   
      function( sum_obj )
        local surjection;
        
        surjection := func( sum_obj );
        
        Add( HomalgCategory( sum_obj ), surjection );
        
        ## TODO: This morphism is epi
        
        return surjection;
        
    end );
    
end );

##
InstallMethod( AddProjectionInSecondFactor,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetProjectionInSecondFactorFunction( category, func );
    
    SetCanComputeProjectionInSecondFactor( category, true );
    
    InstallMethod( ProjectionInSecondFactor,
                   [ IsHomalgCategoryObject and ObjectFilter( category ) and WasCreatedAsDirectSum ],
                   
      function( sum_obj )
        local surjection;
        
        surjection := func( sum_obj );
        
        Add( HomalgCategory( sum_obj ), surjection );
        
        ## TODO: This morphism is epi
        
        return surjection;
        
    end );
    
end );

####################################
##
## Monomorphism as kernel lift
##
####################################

##
InstallMethod( AddMonoAsKernelLift,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetMonoAsKernelLiftFunction( category, func );
    
    SetCanComputeMonoAsKernelLift( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddMonoAsKernelLift", 2 );
    
    InstallMethodWithCache( MonoAsKernelLift,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                            
      function( monomorphism, test_morphism )
        local lift;
        
        lift := func( monomorphism, test_morphism );
        
        Add( HomalgCategory( monomorphism ), lift );
        
        return lift;
        
    end );
    
end );

####################################
##
## Epimorphism as cokernel colift
##
####################################

##
InstallMethod( AddEpiAsCokernelColift,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetEpiAsCokernelColiftFunction( category, func );
    
    SetCanComputeEpiAsCokernelColift( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddEpiAsCokernelColift", 2 );
    
    InstallMethodWithCache( EpiAsCokernelColift,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                       
      function( epimorphism, test_morphism )
        local colift;
        
        colift := func( epimorphism, test_morphism );
        
        Add( HomalgCategory( epimorphism ), colift );
        
        return colift;
        
    end );
    
end );

####################################
##
## Inverse
##
####################################

##
InstallMethod( AddInverse,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetInverseFunction( category, func );
    
    SetCanComputeInverse( category, true );
    
    InstallMethod( Inverse,
                     [ IsHomalgCategoryMorphism and MorphismFilter( category ) and IsIsomorphism ],
                     
      function( isomorphism )
        local inverse;
        
        inverse := func( isomorphism );
        
        Add( HomalgCategory( isomorphism ), inverse );
        
        return inverse;
        
    end );
    
end );

####################################
##
## Kernel
##
####################################

##
InstallMethod( AddKernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelFunction( category, func );
    
    SetCanComputeKernel( category, true );
    
    InstallMethod( KernelObject,
                   [ IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                     
      function( mor )
        local kernel;
        
        kernel := func( mor );
        
        Add( HomalgCategory( mor ), kernel );
        
        SetWasCreatedAsKernel( kernel, true );
        
        return kernel;
        
    end );
    
end );

##
InstallMethod( AddKernelLift,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelLiftFunction( category, func );
    
    SetCanComputeKernelLift( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddKernelLift", 2 );
    
    InstallMethodWithCache( KernelLift,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                       
      function( mor, test_morphism )
        local kernel_lift, kernel;
        
        if HasKernelObject( mor ) then
        
          return KernelLiftWithGivenKernel( mor, test_morphism, KernelObject( mor ) );
        
        fi;
        
        kernel_lift := func( mor, test_morphism );
        
        Add( HomalgCategory( mor ), kernel_lift );

        kernel := Range( kernel_lift );
        
        SetKernelObject( mor, kernel );
        
        SetWasCreatedAsKernel( kernel, true );
        
        return kernel_lift;
        
    end );
    
end );

##
InstallMethod( AddKernelLiftWithGivenKernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelLiftWithGivenKernelFunction( category, func );
    
    SetCanComputeKernelLiftWithGivenKernel( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddKernelLiftWithGivenKernel", 3 );
    
    InstallMethodWithCache( KernelLiftWithGivenKernel,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryObject and ObjectFilter( category ) ],
                            
      function( mor, test_morphism, kernel )
        local kernel_lift;
        
        kernel_lift := func( mor, test_morphism, kernel );
        
        Add( HomalgCategory( mor ), kernel_lift );
        
        return kernel_lift;
        
    end );
    
end );

##
InstallMethod( AddKernelEmb,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelEmbFunction( category, func );
    
    SetCanComputeKernelEmb( category, true );
    
    InstallMethod( KernelEmb,
                   [ IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                   
      function( mor )
        local kernel_emb, kernel;
        
        if HasKernelObject( mor ) then
          
          return KernelEmbWithGivenKernel( mor, KernelObject( mor ) );
          
        fi;
        
        kernel_emb := func( mor );
        
        Add( HomalgCategory( mor ), kernel_emb );
        
        SetIsMonomorphism( kernel_emb, true );
        
        kernel := Source( kernel_emb );
        
        SetKernelObject( mor, kernel );
        
        SetWasCreatedAsKernel( kernel, true );
        
        SetKernelEmb( kernel, kernel_emb );
        
        return kernel_emb;
        
    end );
    
end );

##
InstallMethod( AddKernelEmbWithGivenKernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetKernelEmbWithGivenKernelFunction( category, func );
    
    SetCanComputeKernelEmbWithGivenKernel( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddKernelEmbWithGivenKernel", 2 );
    
    InstallMethodWithCache( KernelEmbWithGivenKernel,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryObject and ObjectFilter( category ) ],
                            
      function( mor, kernel )
        local kernel_emb;
        
        kernel_emb := func( mor, kernel );
        
        Add( HomalgCategory( mor ), kernel_emb );
        
        SetIsMonomorphism( kernel_emb, true );
        
        SetKernelEmb( kernel, kernel_emb );
        
        return kernel_emb;
        
    end );

end );

####################################
##
## Cokernel
##
####################################

##
InstallMethod( AddCokernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelFunction( category, func );
    
    SetCanComputeCokernel( category, true );
    
    InstallMethod( Cokernel,
                   [ IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                     
      function( mor )
        local cokernel;
        
        cokernel := func( mor );
        
        Add( HomalgCategory( mor ), cokernel );
        
        SetWasCreatedAsCokernel( cokernel, true );
        
        return cokernel;
        
    end );
    
end );

##
InstallMethod( AddCokernelColift,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelColiftFunction( category, func );
    
    SetCanComputeCokernelColift( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddCokernelColift", 2 );
    
    InstallMethodWithCache( CokernelColift,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                       
      function( mor, test_morphism )
        local cokernel_colift, cokernel;
        
        if HasCokernel( mor ) then
          
          return CokernelColiftWithGivenCokernel( mor, test_morphism, Cokernel( mor ) );
          
        fi;
        
        cokernel_colift := func( mor, test_morphism );
        
        Add( HomalgCategory( mor ), cokernel_colift );
        
        cokernel := Source( cokernel_colift );
        
        SetWasCreatedAsCokernel( cokernel );
        
        return cokernel_colift;
        
    end );
    
end );

##
InstallMethod( AddCokernelColiftWithGivenCokernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelColiftWithGivenCokernelFunction( category, func );
    
    SetCanComputeCokernelColiftWithGivenCokernel( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddCokernelColiftWithGivenCokernel", 3 );
    
    InstallMethodWithCache( CokernelColiftWithGivenCokernel,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryObject and ObjectFilter( category ) ],
                            
      function( mor, test_morphism, cokernel )
        local cokernel_colift;
        
        cokernel_colift := func( mor, test_morphism, cokernel );
        
        Add( HomalgCategory( mor ), cokernel_colift );
        
        return cokernel_colift;
        
    end );
    
end );

##
InstallMethod( AddCokernelProj,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelProjFunction( category, func );
    
    SetCanComputeCokernelProj( category, true );
    
    InstallMethod( CokernelProj,
                   [ IsHomalgCategoryMorphism and MorphismFilter( category ) ],
                   
      function( mor )
        local cokernel_proj, cokernel;
        
        if HasCokernel( mor ) then
          
          return CokernelProjWithGivenCokernel( mor, Cokernel( mor ) );
          
        fi;
        
        cokernel_proj := func( mor );
        
        Add( HomalgCategory( mor ), cokernel_proj );
        
        SetIsEpimorphism( cokernel_proj, true );

        cokernel := Range( cokernel_proj );
        
        SetCokernel( mor, cokernel );

        SetCokernelProj( cokernel, cokernel_proj );
        
        return cokernel_proj;
        
    end );
    
end );

##
InstallMethod( AddCokernelProjWithGivenCokernel,
               [ IsHomalgCategory, IsFunction ],
               
  function( category, func )
    
    SetCokernelProjWithGivenCokernelFunction( category, func );
    
    SetCanComputeCokernelProjWithGivenCokernel( category, true );
    
    DECIDE_INSTALL_FUNCTION( category, "AddCokernelProjWithGivenCokernel", 2 );
    
    InstallMethodWithCache( CokernelProjWithGivenCokernel,
                            [ IsHomalgCategoryMorphism and MorphismFilter( category ),
                            IsHomalgCategoryObject and ObjectFilter( category ) ],
                            
      function( mor, cokernel )
        local cokernel_proj;
        
        cokernel_proj := func( mor, cokernel );
        
        Add( HomalgCategory( mor ), cokernel_proj );
        
        SetIsEpimorphism( cokernel_proj, true );

        SetCokernelProj( cokernel, cokernel_proj );
        
        return cokernel_proj;
        
    end : Cache := CachingObject( category, "CokernelProjWithGivenCokernel", 2 ) );
    
end );

#######################################
##
## Caching
##
#######################################

##
InstallMethod( SetCaching,
               [ IsHomalgCategory, IsString, IsString ],
               
  function( category, function_name, caching_info )
    
    if not caching_info in [ "weak", "crisp", "none" ] then
        
        Error( "wrong caching type" );
        
    fi;
    
    category!.caching_info.( function_name ) := caching_info;
    
end );

##
InstallMethod( SetCachingToWeak,
               [ IsHomalgCategory, IsString ],
               
  function( category, function_name )
    
    SetCaching( category, function_name, "weak" );
    
end );

##
InstallMethod( SetCachingToCrisp,
               [ IsHomalgCategory, IsString ],
               
  function( category, function_name )
    
    SetCaching( category, function_name, "crisp" );
    
end );

##
InstallMethod( DeactivateCaching,
               [ IsHomalgCategory, IsString ],
               
  function( category, function_name )
    
    SetCaching( category, function_name, "none" );
    
end );

##
InstallMethod( CachingObject,
               [ IsHomalgCategoryCell, IsString, IsInt ],
               
  function( cell, name, number )
    local category, cache;
    
    category := HomalgCategory( cell );
    
    if IsBound( category!.caches.(name) ) then
        
        return category!.caches.(name);
        
    fi;
    
    cache := CachingObject( number );
    
    category!.caches.(name) := cache;
    
    return cache;
    
end );

##
InstallMethod( CachingObject,
               [ IsHomalgCategory, IsString, IsInt ],
               
  function( arg )
    
    return CallFuncList( CachingObject, Concatenation( arg, [ false ] ) );
    
end );

##
InstallMethod( CachingObject,
               [ IsHomalgCategory, IsString, IsInt, IsBool ],
               
  function( category, name, number, is_crisp )
    local cache;
    
    if IsBound( category!.caches.(name) ) then
        
        return category!.caches.(name);
        
    fi;
    
    cache := CachingObject( number, is_crisp );
    
    category!.caches.(name) := cache;
    
    return cache;
    
end );

#######################################
##
## Constructors
##
#######################################

##
InstallMethod( CreateHomalgCategory,
               [ ],
               
  function( )
    local name;
    
    name := Concatenation( "AutomaticHomalgCategory", String( CATEGORIES_FOR_HOMALG_NAME_COUNTER( ) ) );
    
    return CreateHomalgCategory( name );
    
end );

InstallMethod( CreateHomalgCategory,
               [ IsString ],
               
  function( name )
    local category;
    
    category := rec( caching_info := rec( ) );
    
    category := CREATE_HOMALG_CATEGORY_OBJECT( category, [ [ "Name", name ] ] );
    
    CREATE_HOMALG_CATEGORY_FILTERS( category );
    
    InstallImmediateMethod( HomalgCategory,
                            IsHomalgCategoryObject and ObjectFilter( category ),
                            0,
                            
      function( object )
        
        return category;
        
    end );
    
    InstallImmediateMethod( HomalgCategory,
                            IsHomalgCategoryMorphism and MorphismFilter( category ),
                            0,
                            
      function( object )
        
        return category;
        
    end );
    
    return category;
    
end );

#######################################
##
## ViewObj
##
#######################################

InstallMethod( ViewObj,
               [ IsHomalgCategory ],
               
  function( x )
    
    if HasName( x ) then
        
        Print( "<", Name( x ), ">" );
        
    else
        
        Print( "<A homalg category>" );
        
    fi;
    
end );
