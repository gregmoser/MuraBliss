<!---
	
filename:		\validatethis\samples\ValidationTestSuite.cfm
date created:	2008-10-22
author:			Bob Silverberg (http://www.silverwareconsulting.com/)
purpose:		I am the unit testing suite
				
	// **************************************** LICENSE INFO **************************************** \\
	
	Copyright 2008, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
	
	// ****************************************** REVISIONS ****************************************** \\
	
	DATE		DESCRIPTION OF CHANGES MADE												CHANGES MADE BY
	===================================================================================================
	2008-10-22	New																		BS

--->
<cfset testSuite = createObject("component","mxunit.framework.TestSuite").TestSuite() />
<cfloop list="AbstractDecoratorTest,BaseLocaleLoaderTest,BaseTranslatorTest,BOValidatorTest,ClientScriptWriter_jQueryTest,ClientValidatorTest,CommonScriptGeneratorTest,FileSystemTest,RBLocaleLoaderTest,RBTranslatorTest,ResourceBundleTest,ResultTest,ServerRuleValidatorTest,ServerValidatorTest,TransientFactoryTest,ValidateThisTest,ValidationTest,ValidationFactoryTest,externalFileReaderTest" index="i">
	<cfset testSuite.addAll("validatethis.tests.#i#") />
</cfloop>
<cfset results = testSuite.run() />
<cfoutput>#results.getResultsOutput('html')#</cfoutput>
 