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

component displayname="Base Entity" accessors="true" {
	
	//TODO: How do you we automate the component path to be the Plugin's BaseURL'
	property name="errorBean" type="BASEURL.com.gregmoser.murabliss.utility.ErrorBean";
	property name="updateKeys" type="string";
	 
	public any function init() {
		// Place reference to mura scope in entity
		if(!structKeyExists(request, "muraScope")) {
			request.muraScope = new mura.MuraScope('default');
		}
		variables.$ = request.muraScope;
		
		// Create a new errorBean for all entities
		this.setErrorBean(new BASEURL.com.gregmoser.murabliss.utility.ErrorBean());
		
		// When called from newXXX() within base service a struct or query record can be passed to pre-populate;
		if(!structIsEmpty(arguments)){
			// TODO: Debug this
			//this.set(record=arguments);
		}
		
		return super.init();
	}
	
	// @hint This function is utilized by the fw1 populate method to only update persistent properties in the entity.
	public string function getUpdateKeys() {
		if(!structKeyExists(variables, "updateKeys")) {
			var props = getProperties();
			variables.updateKeys = "";
			
			// Loop over properties and any persitant properties to the updateKeys
			for(var i=1; i <= arrayLen(props); i++ ) {
				var propertyStruct = props[i];
				if(!isDefined("propertyStruct.Persistent") or (isDefined("propertyStruct.Persistent") && propertyStruct.Persistent == true && !isDefined("propertyStruct.FieldType"))) {
					variables.updateKeys = listAppend(variables.updateKeys,propertyStruct["name"]);
				}
			}
		}
		
		return variables.updateKeys;
	}
	
	// @hint The set function allows a bulk setting of all properties either from a query or a struct.  This is specifically utilized for Integration with external systems.
	public void function set(required any record) {
	
		var keyList = "";
		
		// Set a list of key fieds based on either a query record passed or a string
		if(isQuery(arguments.record)) {
			keyList = arguments.record.columnList;
		} else if(isStruct(arguments.record)) {
			keyList = structKeyList(arguments.record);
		}

		for(var i=1; i <= listLen(keyList); i++) {
			var evalString = "";
			var subKeyArray = listToArray(listGetAt(keyList, i), "_");
			var data = arguments.record[listGetAt(keyList, i)];
			
			for(var ii=1; ii <= arrayLen(subKeyArray); ii++) {
				if(ii == arrayLen(subKeyArray)) {
					evalString &= "set#subKeyArray[ii]#( '#data#' )";
				} else {
					evalString &= "get#subKeyArray[ii]#().";
				}
			}
			
			evaluate("#evalString#");
		}
	}
	
	public any function populate(required struct data, string propList=getUpdateKeys(),boolean cleanseInput=false) {
		var props = getProperties();
		for( var i=1;i<=arrayLen(props);i++ ) {
			local.theProperty = props[i];
			// If a propList was passed in, use it to filter
			if( !listLen(arguments.propList) || listContains(arguments.propList,local.theProperty.name) ) {
				// do columns (not related properties)
				if( !structKeyExists(local.theProperty,"fieldType") || local.theProperty.fieldType == "column" ) {
					// the property has a matching argument 
					if(structKeyExists(arguments.data,local.theProperty.name)) {
						local.varValue = arguments.data[local.theProperty.name];
					// if data struct doesn't contain the key, set it to the default value of the property or the existing value
					} else {
						continue;
					}
					// for nullable fields that are blank, set them to null
					if( (!structKeyExists(local.theProperty,"notNull") || !local.theProperty.notNull) && !len(local.varValue) ) {
						_setPropertyNull( local.theProperty.name );
					} else {
						// cleanse input?
						//param name="local.theProperty.cleanseInput" default="#arguments.cleanseInput#";
						if( arguments.cleanseInput ) {
							local.varValue =  HTMLEditFormat(local.varValue);
						}
						_setProperty(local.theProperty.name,local.varValue); 
					}
				// do many-to-one
				} else if( local.theProperty.fieldType == "many-to-one" ) {
					if( structKeyExists(arguments.data, local.theProperty.fkcolumn) ) {
						var manyToOneData = arguments.data[local.theProperty.fkcolumn];
					} else if( structKeyExists(arguments.data, local.theProperty.name) ) {
						var manyToOneData = arguments.data[local.theProperty.name];
					} else {
						var manyToOneData = "";
					}
					if(isSimpleValue(manyToOneData) && manyToOneData != "") {
						var fkValue = manyToOneData;
						var varValue = EntityLoadByPK("Slatwall" & local.theProperty.cfc, fkValue);
						if( !isNull(varValue) ) {
							_setProperty(local.theProperty.name, varValue);
						} else {
							_setPropertyNull(local.theProperty.name);
						}
					}
				}
			}
		}
		return this;
	}
	
	public array function getProperties(struct metaData=getMetaData(this)) {
		var properties = arguments.metaData["properties"];
		var parentProperties = "";
		// recursively get properties of any super classes
		if(structKeyExists(arguments.metaData.extends,"properties")) {
			parentProperties = getProperties(arguments.metaData["extends"]);
			return arrayConcat(parentProperties,properties);
		} else {
			return properties;
		}
	}
	
	// @hint utility function to sort array of ojbects can be used to override getCollection() method to add sorting. 
	// From Aaron Greenlee http://cookbooks.adobe.com/post_How_to_sort_an_array_of_objects_or_entities_with_C-17958.html
	public array function sortObjectArray(required array objects, required string orderby, string sorttype="text", string direction = "asc") {
		var property = arguments.orderby;
		var sortedStruct = {};
		var sortedArray = [];
        for (var i=1; i <= arrayLen(arguments.objects); i++) {
                // Each key in the struct is in the format of
                // {VALUE}.{RAND NUMBER} This is important otherwise any objects
                // with the same value would be lost.
                var rn = randRange(1,100);
                var sortedStruct[ evaluate("arguments.objects[i].get#property#() & '.' & rn") ] = objects[i];
		}
		var keyArray = structKeyArray(sortedStruct);
		arraySort(keyArray,arguments.sorttype,arguments.direction);
		for(var i=1; i<=arrayLen(keyArray);i++) {
			arrayAppend(sortedArray, sortedStruct[keyArray[i]]);
		}
		return sortedArray;
	}

	public boolean function isNew() {
		var identifierColumns = getIdenentifierColumns();
		var returnNew = true;
		for(var i=1; i <= arrayLen(identifierColumns); i++){
			if(structKeyExists(variables, identifierColumns[i]) && (!isNull(variables[identifierColumns[i]]) && variables[identifierColumns[i]] != "" )) {
				returnNew = false;
			}
		}
		return returnNew;
	}
	
	public any function getIdenentifierColumns() {
		return ormGetSessionFactory().getClassMetadata(getMetaData(this).entityName).getIdentifierColumnNames();
	}
	
	public any function getIdentifierValue() {
		var identifierColumns = getIdenentifierColumns();
		var idValue = "";
		for(var i=1; i <= arrayLen(identifierColumns); i++){
			if(structKeyExists(variables, identifierColumns[i])) {
				idValue &= variables[identifierColumns[i]];
			}
		}
		return idValue;
	}
	
	public string function getClassName(){
		return ListLast(GetMetaData(this).entityname, "." );
	}
	
    public string function getPropertyList() {
        if( !structKeyExists(variables,"propertyList") ) {
            variables.propertyList = "";
            var props = getMetadata(this)["properties"];
            for( var i=1; i<=arrayLen(props); i++ ) {
                variables.propertyList = listAppend(variables.propertyList,props[i].name);
            }
        }
        return variables.propertyList;
    }
	
	public void function addError(required string name, required string message) {
		getErrorBean().addError(argumentCollection=arguments);
	}
	
	public void function clearErrors() {
		structClear(getErrorBean().getErrors());
	}
	
	// @hint A way to see if the entity has any errors.
	public boolean function hasErrors() {
		return this.getErrorBean().hasErrors();
	}
	
	public string function simpleValueSerialize() {
		var data = {};
		for(var key in variables) {
			if(isSimpleValue(variables[key]) && key != "updateKeys") {
				data[key] = variables[key];
			}
		}
		return serializeJSON(data);
	}
	
	// These private methods are used by the populate() method
	
	private void function _setProperty( required any name, any value ) {
		var theMethod = this["set" & arguments.name];
		if( isNull(arguments.value) ) {
			structDelete(variables,arguments.name);
		} else {
			theMethod(arguments.value);
		}
	}
	
	private void function _setPropertyNull( required any name ) {
		_setProperty(arguments.name);
	}
	
	private array function arrayConcat(required array a1, required array a2) {
	/**
		* Concatenates two arrays.
		*
		* @param a1      The first array.
		* @param a2      The second array.
		* @return Returns an array.
		* @author Craig Fisher (craig@altainetractive.com)
		* @version 1, September 13, 2001
		* Modified by Tony Garcia 18Oct09 to deal with metadata arrays, which don't act like normal arrays
		*/
			var newArr = [];
		    var i=1;
		    if ((!isArray(a1)) || (!isArray(a2))) {
		        writeoutput("Error in <Code>ArrayConcat()</code>! Correct usage: ArrayConcat(<I>Array1</I>, <I>Array2</I>) -- Concatenates Array2 to the end of Array1");
		        return arrayNew(1);
		    }
		    /*we have to copy the array elements to a new array because the properties array in ColdFusion 
		      is a "read only" array (see http://www.bennadel.com/blog/760-Converting-A-Java-Array-To-A-ColdFusion-Array.htm)*/
		    for (i=1;i <= ArrayLen(a1);i++) {
		        newArr[i] = a1[i];
		    }
		    for (i=1;i <= ArrayLen(a2);i++) {
		        newArr[arrayLen(a1)+i] = a2[i];
		    }
		    return newArr;
	}
	
	// Start: ORM functions
	public void function preInsert(){
		var timestamp = now();
		
		if(structKeyExists(this,"setCreatedDateTime")){
			this.setCreatedDateTime(timestamp);
		}
		if(structKeyExists(this,"setCreatedByAccount")){
			setCreatedByAccount(getService("SessionService").getCurrentAccount());
		}
		
		if(structKeyExists(this,"setModifiedDateTime")){
			this.setModifiedDateTime(timestamp);
		}
		if(structKeyExists(this,"setModifiedByAccount")){
			setModifiedByAccount(getService("SessionService").getCurrentAccount());
		}
		
	}
	
	public void function preUpdate(Struct oldData){
		var timestamp = now();
		
		if(structKeyExists(this,"setModifiedDateTime")){
			this.setModifiedDateTime(timestamp);
		}
		if(structKeyExists(this,"setModifiedByAccount")){
			setModifiedByAccount(getService("SessionService").getCurrentAccount());
		}
	}
	
	public void function preDelete(any entity){

	}
	
	public void function preLoad(any entity){

	}
	
	public void function postInsert(any entity){

	}
	
	public void function postUpdate(any entity){

	}
	
	public void function postDelete(any entity){

	}
	
	public void function postLoad(any entity){

	}
	// End: ORM Functions
	
}
