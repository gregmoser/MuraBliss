component output="false" accessors="true" {
	
	public any function init() {
		return this;
	}
	
	public any function get( required string entityName, required any idOrFilter, boolean isReturnNewOnNotFound = false ) {
		// Adds the Slatwall Prefix to the entityName when needed.
		if(left(arguments.entityName,8) != "Slatwall") {
			arguments.entityName = "Slatwall#arguments.entityName#";
		}
		
		if ( isSimpleValue( idOrFilter ) && len( idOrFilter ) && idOrFilter != 0 ) {
			var entity = entityLoadByPK( entityName, idOrFilter );
		} else if ( isStruct( idOrFilter ) ){
			var entity = entityLoad( entityName, idOrFilter, true );
		}
		
		if ( !isNull( entity ) ) {
			return entity;
		}

		if ( isReturnNewOnNotFound ) {
			return new( entityName );
		}
	}

	function list( string entityName, struct filterCriteria = {}, string sortOrder = '', struct options = {} ) {
		// Adds the Slatwall Prefix to the entityName when needed.
		if(left(arguments.entityName,8) != "Slatwall") {
			arguments.entityName = "Slatwall#arguments.entityName#";
		}
		
		return entityLoad( entityName, filterCriteria, sortOrder, options );
	}


	function new( required string entityName ) {
		// Adds the Slatwall Prefix to the entityName when needed.
		if(left(arguments.entityName,8) != "Slatwall") {
			arguments.entityName = "Slatwall#arguments.entityName#";
		}
		
		return entityNew( entityName );
	}


	function save( required target ) {
		if ( isArray( target ) ) {
			for ( var object in target ) {
				save( object );
			}
		}

		entitySave( target );
		
		return target;
	}
	
	public void function delete(required target) {
		if(isArray(target)) {
			for(var object in target) {
				delete(object);
			}
		}
		entityDelete(target);
	}
	
	
	public void function reloadEntity(required any entity) {
    	entityReload(arguments.entity);
    }
	

	public any function getSmartList(required string entityName, struct data={}){
		// Adds the Slatwall Prefix to the entityName when needed.
		if(left(arguments.entityName,8) != "Slatwall") {
			arguments.entityName = "Slatwall#arguments.entityName#";
		}
		
		var smartList = new Slatwall.com.utility.SmartList(argumentCollection=arguments);
	
		return smartList;
	}
	
	// @hint checks whether another entity has the same value for the given property
	public boolean function isDuplicateProperty( required string propertyName, required any entity ) {
		var entityName = arguments.entity.getClassName();
		var idValue = evaluate("arguments.entity.get#replaceNoCase(entityName,'Slatwall','','one')#ID()");
		var propertyValue = evaluate("arguments.entity.get#arguments.propertyName#()");
		return arrayLen(ormExecuteQuery("from #entityName# e where e.#arguments.propertyName# = :propValue and e.id != :entityID", {propValue=propertyValue, entityID=idValue}));
	}
	
	
}
