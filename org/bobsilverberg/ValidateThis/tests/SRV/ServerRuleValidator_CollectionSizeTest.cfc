
-```<!---
	
	// **************************************** LICENSE INFO **************************************** \\
	
	Copyright 2010, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
	
--->
<cfcomponent extends="validatethis.tests.SRV.BaseForServerRuleValidatorTests" output="false">
	
	<cffunction name="setUp" access="public" returntype="void">
		<cfscript>
			super.setup();
			SRV = getSRV("CollectionSize");
			
			// Define Validation mock Test Values
			parameters={};
			objectValue = "t";
			isRequired = true;
			hasMin = true;
			hasMax = false;	
			
			defaultMin = 1;
			defaultMax = 10;
			
		</cfscript>
	</cffunction>
	
	<cffunction name="configureValidationMock" access="private">
		<cfscript>
			
			super.configureValidationMock();
			
			validation.hasParameter("min").returns(hasMin);
			validation.hasParameter("max").returns(hasMax);
			validation.getParameterValue("min").returns(defaultMin);
			validation.getParameterValue("max").returns(defaultMax);
			validation.getParameterValue("min",0).returns(defaultMin);
			validation.getParameterValue("min",1).returns(defaultMin);
			validation.getParameterValue("max",0).returns(defaultMax);
			
		</cfscript>
	</cffunction>
	
	<cffunction name="validateTestIsReliableWithNoFalsePositives" access="public" returntype="void">
		<cfscript>
			objectValue = [{test="test"},{test2="test2"}];	
			isRequired=true;
			hasMin = true;
			hasMax = false;
			defaultMin=3;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsTrueForCorrectArrayLength" access="public" returntype="void">
		<cfscript>
			objectValue = [{test="test"}];	
			hasMin = true;
			hasMax = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForInvalidArrayLength" access="public" returntype="void">
		<cfscript>
			objectValue = [{test2="test2"},{test="test"}];
			hasMin = true;
			hasMax = false;
			defaultMin=3;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>

	<cffunction name="validateReturnsTrueForCorrectStructCount" access="public" returntype="void">
		<cfscript>
			objectValue = {name="test"};
			hasMin = true;
			hasMax = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForIncorrectStructCount" access="public" returntype="void">
		<cfscript>
			objectValue = {test="name",name="test"};
			hasMin = true;
			hasMax = false;
			defaultMin=3;
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>

	<cffunction name="validateReturnsTrueForCorrectStringLength" access="public" returntype="void">
		<cfscript>
			objectValue  = "t";
			hasMin = true;
			hasMax = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>	
	
	<cffunction name="validateReturnsTrueForCorrectListLength" access="public" returntype="void">
		<cfscript>
			objectValue  = "t,e,s,t";
			hasMin = true;
			hasMax = false;
			defaultMin=4;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>	
	
	<cffunction name="validateReturnsFalseForIncorrectListLength" access="public" returntype="void">
		<cfscript>
			objectValue = "t,t";
			hasMin = true;
			hasMax = false;
			defaultMin=3;
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForEmptyArrayIfRequired" access="public" returntype="void">
		<cfscript>
			isRequired = true;
			objectValue = [];			
			hasMin = true;
			hasMax = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForEmptyStructIfRequired" access="public" returntype="void">
		<cfscript>
			isRequired = true;
			objectValue = {};
			hasMin = true;
			hasMax = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>

	<cffunction name="validateReturnsTrueForEmptyPropertyIfNotRequired" access="public" returntype="void">
		<cfscript>
			objectValue = "";
			hasMin = true;
			hasMax = false;
			isRequired = false;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForEmptyPropertyIfRequired" access="public" returntype="void">
		<!--- <cfscript>
			objectValue = "";
			hasMin = true;
			hasMax = false;
			isRequired = true;
			defaultMin=1;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>   --->
	</cffunction>
	
	<cffunction name="validateReturnsTrueForValueInRange" access="public" returntype="void">
		<cfscript>
			objectValue = "test";
			parameters={min=1,max=10};
			hasMin = true;
			hasMax = true;
			
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}");
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForValueOutOfRangeLow" access="public" returntype="void">
		<cfscript>
			objectValue = "";
			parameters={min=1,max=10};
			hasMin = true;
			hasMax = true;
			
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}");
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForValueOutOfRangeHigh" access="public" returntype="void">
		<cfscript>
			objectValue = "asdfasdfasdfasdfasdf";
			parameters={min=1,max=10};
			hasMin = true;
			hasMax = true;
			
			configureValidationMock();
			
			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}");
		</cfscript>  
	</cffunction>
	
</cfcomponent>
