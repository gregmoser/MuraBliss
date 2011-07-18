<cfif thisTag.executionMode IS "start"><cfexit method="exittemplate" /></cfif>
<cfsilent>
<!--- 
filename:		tags/forms/UniForm/checkbox.cfm
date created:	12/15/07
author:			Matt Quackenbush (http://www.quackfuzed.com/)
purpose:		I display an XHTML Strict 1.0 checkbox field using the Uni-Form markup
				
	// **************************************** LICENSE INFO **************************************** \\
	
	Copyright 2007, Matt Quackenbush
	
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
	12/15/07		New																				MQ
	
 --->

<!--- // use example
	
	// REQUIRED ATTRIBUTES
	@value					Required (string)		- the value for the checkbox
	@label					Required (string)		- text to display in the label tag
	
	// OPTIONAL ATTRIBUTES
	@name					Optional (string)	 	- the checkbox name
	@hint					Optional (string)	 	- help text to display for the checkbox
	@isChecked				Optional (boolean)		- indicates whether or not the checkbox should be checked
															defaults to 'false'
	
	// STEPS TO USE THIS TAG
		
		For more info on all of the steps, see the "use example" comments in the UniForm Form.cfm tag.
		This tag is used in Step 3 of the form building process.
		
			<uform:field label="Display Options" name="displayOptions" type="checkboxgroup">
				<uform:checkbox label="Display my email address" value="email" /> <------- this here is how you're calling this tag!!!
				<uform:checkbox label="Display my picture" value="pic" /> <------- this here is how you're calling this tag!!! (again!)
			</uform:field>
		
 --->

<!--- define the tag attributes --->
	<!--- required attributes --->
	<cfparam name="attributes.value" type="string" />
	<cfparam name="attributes.label" type="string" />
	
	<!--- optional attributes --->
	<cfparam name="attributes.hint" type="string" default="" />
	<cfparam name="attributes.isChecked" type="boolean" default="no" />
	<cfparam name="attributes.name" type="string" default="" />

<cfscript>
	// if tag has content nested inside
	if ( len(trim(thisTag.generatedContent)) ) {
		/*
		*	add content as a tag attribute so its available to fieldset tag, 
		*		and reset generatedContent so nothing is rendered
		*/
		thisTag.generatedContent = "";
	}
</cfscript>

<cfassociate basetag="cf_field" datacollection="checkboxes" />
</cfsilent>
