<!---
	
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
			SRV = getSRV("Range");
			parameters = {min="2010-12-01",max="2010-12-31"};
			
		</cfscript>
	</cffunction>
	
	<cffunction name="validateReturnsTrueForDateInRange" access="public" returntype="void">
		<cfscript>
			objectValue = "2010-12-19";
			
			configureValidationMock();

			SRV.validate(validation);
			validation.verifyTimes(0).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
	<cffunction name="validateReturnsFalseForDateOutOfRange" access="public" returntype="void">
		<cfscript>
            objectValue = "2010-2-19";
            
            configureValidationMock();

			SRV.validate(validation);
			validation.verifyTimes(1).fail("{*}"); 
		</cfscript>  
	</cffunction>
	
</cfcomponent>
