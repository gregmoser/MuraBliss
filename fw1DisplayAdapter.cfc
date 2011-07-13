<cfcomponent extends="fw1EventAdapter">

	<cffunction name="onMissingMethod">
		<cfargument name="missingMethodName" />
		<cfargument name="missingMethodArguments" />
		<cfset var action = "frontend:#lcase(Replace(missingMethodName,"_","."))#" />
		<cfset var return = doAction(missingMethodArguments.$, action, true) />

		<cfreturn return />
	</cffunction>

</cfcomponent>