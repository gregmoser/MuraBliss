/*

    MuraBliss - A plugin framework for Mura CMS
    Copyright (C) 2011 Greg Moser
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/

component displayname="Base Service" persistent="false" accessors="true" output="false" hint="This is a base service that all services will extend" {

	property name="entityName" type="string";
	property name="DAO" type="any";
	property name="validationService" type="any";
	property name="fileService" type="any";
	
	public any function init() {
		return super.init();
	}
	
	public any function get(required string entityName, required any idOrFilter, boolean isReturnNewOnNotFound = false ) {
		return getDAO().get(argumentcollection=arguments);
	}

	public any function list(required string entityName, struct filterCriteria = {}, string sortOrder = '', struct options = {} ) {
		return getDAO().list(argumentcollection=arguments);
	}

	public any function new(required string entityName ) {
		return getDAO().new(argumentcollection=arguments);
	}

	public any function getSmartList(string entityName, struct data={}){
		return getDAO().getSmartList(argumentcollection=arguments);
	}
	
	public any function delete(required any entity){
		var response = new com.utility.ResponseBean();
		var entityName = replaceNoCase(arguments.entity.getClassName(),getPluginConfig().getApplication().getApplicationKey(),"","one");
		if(!arguments.entity.hasErrors()) {
			getDAO().delete(target=arguments.entity);
			response.addMessage(messageCode="01", message=rbKey("entity.#entityName#.delete_success"));
		} else {
			// set entity into the response
			response.setData(arguments.entity);
			// set errors in the response error bean (from the entity error bean)
			response.getErrorBean().setErrors(arguments.entity.getErrorBean().getErrors());
			getService("requestCacheService").setValue("ormHasErrors", true);
		}
		return response;
	}
	
	public any function populate(required any entity, required struct data, boolean cleanseInput=false) {
		return arguments.entity.populate(data=arguments.data, cleanseInput=arguments.cleanseInput);
	}

    public any function save(required any entity, struct data, boolean cleanseInput=false) {
        if(structKeyExists(arguments,"data")){
            populate(argumentCollection=arguments);
        }
        validate(entity=arguments.entity);
        
        if(!arguments.entity.hasErrors()) {
            arguments.entity = getDAO().save(target=arguments.entity);
        } else {
            getService("requestCacheService").setValue("ormHasErrors", true);
        }
        return arguments.entity;
    }
    
    public any function validate(required any entity) {
    	return getValidationService().validateObject(entity=arguments.entity);
    }
    
    public void function reloadEntity(required any entity) {
    	getDAO().reloadEntity(entity=arguments.entity);
    }
    
 /**
	 * Provides dynamic methods, by convention, on missing method:
	 *
	 *   newXXX()
	 *
	 *   saveXXX( required any xxxEntity )
	 *
	 *   deleteXXX( required any xxxEntity )
	 *
	 *   getXXX( required any ID, boolean isReturnNewOnNotFound = false )
	 *
	 *   getXXXByYYY( required any yyyFilterValue, boolean isReturnNewOnNotFound = false )
	 *
	 *   listXXX( struct filterCriteria, string sortOrder, struct options )
	 *
	 *   listXXXFilterByYYY( required any yyyFilterValue, string sortOrder, struct options )
	 *
	 *   listXXXOrderByZZZ( struct filterCriteria, struct options )
	 *
	 *   listXXXFilterByYYYOrderByZZZ( required any yyyFilterValue, struct options )
	 *
	 * ...in which XXX is an ORM entity name, and YYY and ZZZ are entity property names.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	public any function onMissingMethod( required string missingMethodName, required struct missingMethodArguments ) {
		var lCaseMissingMethodName = lCase( missingMethodName );

		if ( lCaseMissingMethodName.startsWith( 'get' ) ) {
			if(right(lCaseMissingMethodName,9) == "smartlist") {
				return onMissingGetSmartListMethod( missingMethodName, missingMethodArguments );
			} else {
				return onMissingGetMethod( missingMethodName, missingMethodArguments );
			}
		} else if ( lCaseMissingMethodName.startsWith( 'new' ) ) {
			return onMissingNewMethod( missingMethodName, missingMethodArguments );
		} else if ( lCaseMissingMethodName.startsWith( 'list' ) ) {
			return onMissingListMethod( missingMethodName, missingMethodArguments );
		} else if ( lCaseMissingMethodName.startsWith( 'save' ) ) {
			return onMissingSaveMethod( missingMethodName, missingMethodArguments );
		} else if ( lCaseMissingMethodName.startsWith( 'delete' ) )	{
			return onMissingDeleteMethod( missingMethodName, missingMethodArguments );
		} else if ( lCaseMissingMethodName.startsWith( 'validate' ) )	{
			return onMissingValidateMethod( missingMethodName, missingMethodArguments );
		}

		throw( 'No matching method for #missingMethodName#().' );
	}
	


	/********** PRIVATE ************************************************************/
	private function onMissingValidateMethod( required string missingMethodName, required struct missingMethodArguments ) {
		return validate( missingMethodArguments[ 1 ] );
	}

	private function onMissingDeleteMethod( required string missingMethodName, required struct missingMethodArguments ) {
		return delete( missingMethodArguments[ 1 ] );
	}


	/**
	 * Provides dynamic get methods, by convention, on missing method:
	 *
	 *   getXXX( required any ID, boolean isReturnNewOnNotFound = false )
	 *
	 *   getXXXByYYY( required any yyyFilterValue, boolean isReturnNewOnNotFound = false )
	 *
	 * ...in which XXX is an ORM entity name, and YYY is an entity property name.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingGetMethod( required string missingMethodName, required struct missingMethodArguments ){
		var isReturnNewOnNotFound = structKeyExists( missingMethodArguments, '2' ) ? missingMethodArguments[ 2 ] : false;

		var entityName = missingMethodName.substring( 3 );

		if ( entityName.matches( '(?i).+by.+' ) ) {
			var tokens = entityName.split( '(?i)by', 2 );
			entityName = tokens[ 1 ];
			var filter = { '#tokens[ 2 ]#' = missingMethodArguments[ 1 ] };
			return get( entityName, filter, isReturnNewOnNotFound );
		} else {
			var id = missingMethodArguments[ 1 ];
			return get( entityName, id, isReturnNewOnNotFound );
		}
	}

	/**
	 * Provides dynamic getSmarList method, by convention, on missing method:
	 *
	 *   getXXXSmartList( struct data )
	 *
	 * ...in which XXX is an ORM entity name
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	 
	private function onMissingGetSmartListMethod( required string missingMethodName, required struct missingMethodArguments ){
		var smartListArgs = {};
		var entityNameLength = len(arguments.missingMethodName) - 12;
		
		var entityName = missingMethodName.substring( 3,entityNameLength + 3 );
		var data = {};
		if( !isNull(missingMethodArguments[ 1 ]) && isStruct(missingMethodArguments[ 1 ]) ) {
			data = missingMethodArguments[ 1 ];
		}
		
		return getSmartList(entityName=entityName, data=data);
	} 
	 

	/**
	 * Provides dynamic list methods, by convention, on missing method:
	 *
	 *   listXXX( struct filterCriteria, string sortOrder, struct options )
	 *
	 *   listXXXFilterByYYY( required any yyyFilterValue, string sortOrder, struct options )
	 *
	 *   listXXXOrderByZZZ( struct filterCriteria, struct options )
	 *
	 *   listXXXFilterByYYYOrderByZZZ( required any yyyFilterValue, struct options )
	 *
	 * ...in which XXX is an ORM entity name, and YYY and ZZZ are entity property names.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingListMethod( required string missingMethodName, required struct missingMethodArguments ){
		var listMethodForm = 'listXXX';

		if ( findNoCase( 'FilterBy', missingMethodName ) ) {
			listMethodForm &= 'FilterByYYY';
		}

		if ( findNoCase( 'OrderBy', missingMethodName ) ) {
			listMethodForm &= 'OrderByZZZ';
		}

		switch( listMethodForm ) {
			case 'listXXX':
				return onMissingListXXXMethod( missingMethodName, missingMethodArguments );

			case 'listXXXFilterByYYY':
				return onMissingListXXXFilterByYYYMethod( missingMethodName, missingMethodArguments );

			case 'listXXXOrderByZZZ':
				return onMissingListXXXOrderByZZZMethod( missingMethodName, missingMethodArguments );

			case 'listXXXFilterByYYYOrderByZZZ':
				return onMissingListXXXFilterByYYYOrderByZZZMethod( missingMethodName, missingMethodArguments );
		}
	}


	/**
	 * Provides dynamic list method, by convention, on missing method:
	 *
	 *   listXXX( struct filterCriteria, string sortOrder, struct options )
	 *
	 * ...in which XXX is an ORM entity name.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingListXXXMethod( required string missingMethodName, required struct missingMethodArguments ) {
		var listArgs = {};

		listArgs.entityName = missingMethodName.substring( 4 );
		
		if ( structKeyExists( missingMethodArguments, '1' ) ) {
			listArgs.filterCriteria = missingMethodArguments[ '1' ];

			if ( structKeyExists( missingMethodArguments, '2' ) ) {
				listArgs.sortOrder = missingMethodArguments[ '2' ];

				if ( structKeyExists( missingMethodArguments, '3' ) ) {
					listArgs.options = missingMethodArguments[ '3' ];
				}
			}
		}

		return list( argumentCollection = listArgs );
	}


	/**
	 * Provides dynamic list method, by convention, on missing method:
	 *
	 *   listXXXFilterByYYY( required any yyyFilterValue, string sortOrder, struct options )
	 *
	 * ...in which XXX is an ORM entity name, and YYY is an entity property name.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingListXXXFilterByYYYMethod( required string missingMethodName, required struct missingMethodArguments )
	{
		var listArgs = {};

		var temp = missingMethodName.substring( 4 );

		var tokens = temp.split( '(?i)FilterBy', 2 );

		listArgs.entityName = tokens[ 1 ];

		listArgs.filterCriteria = { '#tokens[ 2 ]#' = missingMethodArguments[ 1 ] };

		if ( structKeyExists( missingMethodArguments, '2' ) )
		{
			listArgs.sortOrder = missingMethodArguments[ '2' ];

			if ( structKeyExists( missingMethodArguments, '3' ) )
			{
				listArgs.options = missingMethodArguments[ '3' ];
			}
		}

		return list( argumentCollection = listArgs );
	}


	/**
	 * Provides dynamic list method, by convention, on missing method:
	 *
	 *   listXXXFilterByYYYOrderByZZZ( required any yyyFilterValue, struct options )
	 *
	 * ...in which XXX is an ORM entity name, and YYY and ZZZ are entity property names.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingListXXXFilterByYYYOrderByZZZMethod( required string missingMethodName, required struct missingMethodArguments )
	{
		var listArgs = {};

		var temp = missingMethodName.substring( 4 );

		var tokens = temp.split( '(?i)FilterBy', 2 );

		listArgs.entityName = tokens[ 1 ];

		tokens = tokens[ 2 ].split( '(?i)OrderBy', 2 );

		listArgs.filterCriteria = { '#tokens[ 1 ]#' = missingMethodArguments[ 1 ] };

		listArgs.sortOrder = tokens[ 2 ];

		if ( structKeyExists( missingMethodArguments, '2' ) )
		{
			listArgs.options = missingMethodArguments[ '2' ];
		}

		return list( argumentCollection = listArgs );
	}


	/**
	 * Provides dynamic list method, by convention, on missing method:
	 *
	 *   listXXXOrderByZZZ( struct filterCriteria, struct options )
	 *
	 * ...in which XXX is an ORM entity name, and ZZZ is an entity property name.
	 *
	 * NOTE: Ordered arguments only--named arguments not supported.
	 */
	private function onMissingListXXXOrderByZZZMethod( required string missingMethodName, required struct missingMethodArguments )
	{
		var listArgs = {};

		var temp = missingMethodName.substring( 4 );

		var tokens = temp.split( '(?i)OrderBy', 2 );

		listArgs.entityName = tokens[ 1 ];

		listArgs.sortOrder = tokens[ 2 ];

		if ( structKeyExists( missingMethodArguments, '1' ) )
		{
			listArgs.filterCriteria = missingMethodArguments[ '1' ];

			if ( structKeyExists( missingMethodArguments, '2' ) )
			{
				listArgs.options = missingMethodArguments[ '2' ];
			}
		}

		return list( argumentCollection = listArgs );
	}


	private function onMissingNewMethod( required string missingMethodName, required struct missingMethodArguments )
	{
		var entityName = missingMethodName.substring( 3 );

		return new( entityName );
	}


	private function onMissingSaveMethod( required string missingMethodName, required struct missingMethodArguments ) {
		if ( structKeyExists( missingMethodArguments, '2' ) ) {
			return save( entity=missingMethodArguments[1], data=missingMethodArguments[2]);
		} else {
			return save( entity=missingMethodArguments[1] );
		}
	}
}
