<cfcomponent extends="mura.plugin.pluginGenericEventHandler">
	
	<cfset variables.preserveKeyList="context,base,cfcbase,subsystem,subsystembase,section,item,services,action,controllerExecutionStarted,generateses,view,layout">
	
	<!--- Include FW/1 configuration that is shared between then adapter and the application. --->
	<cfinclude template="fw1Config.cfm">
	
	<cffunction name="onMissingMethod">
		<cfargument name="missingMethodName" />
		<cfargument name="missingMethodArguments" />
		
		<cfset doAction(missingMethodArguments.$, "frontend:event.#lcase(missingMethodName)#") />
	</cffunction>
	
	<cffunction name="onRenderStart">
		<cfargument name="$" />

		<cfset doAction($, "frontend:event.onrenderstart") />

		<cfif $.event('#variables.framework.action#') neq "">
			<cfif $.event('overrideContent') eq true>
				<cfset $.content('body', doAction($, $.event(variables.framework.action))) />
			<cfelse>
				<cfset $.content('body', $.content('body') & doAction($, $.event(variables.framework.action))) />
			</cfif> 
		</cfif>
	</cffunction>
	
	<cffunction name="onGlobalSessionStart" output="false">
		<cfargument name="$">
		<cfset var state=preserveInternalState(request)>
		<cfinvoke component="Application" method="onSessionStart" />
		<cfset restoreInternalState(request,state)>
	</cffunction>

	<cffunction name="onApplicationLoad" output="false">
		<cfargument name="$">
		<cfset var state=preserveInternalState(request)>
		<cfset request.pluginConfig=variables.pluginConfig>
		<cfinvoke component="Application" method="onApplicationStart" />
		<cfset restoreInternalState(request,state)>
	</cffunction>

	<cffunction name="preserveInternalState" output="false">
		<cfargument name="state">
		<cfset var preserveKeys=structNew()>
		<cfset var k="">
		
		<cfloop list="#variables.preserveKeyList#" index="k">
			<cfif isDefined("arguments.state.#k#")>
				<cfset preserveKeys[k]=arguments.state[k]>
				<cfset structDelete(arguments.state,k)>
			</cfif>
		</cfloop>
		
		<cfset structDelete( arguments.state, "serviceExecutionComplete" )>
		
		<cfreturn preserveKeys>
	</cffunction>
	
	<cffunction name="restoreInternalState" output="false">
		<cfargument name="state">
		<cfargument name="restore">
		
		<cfloop list="#variables.preserveKeyList#" index="k">
				<cfset structDelete(arguments.state,k)>
		</cfloop>
		
		<cfset structAppend(state,restore,true)>
		<cfset structDelete( state, "serviceExecutionComplete" )>
	</cffunction>
		
	<cffunction name="doAction" output="false">
		<cfargument name="$">
		<cfargument name="action" type="string" required="false" default="" hint="Optional: If not passed it looks into the event for a defined action, else it uses the default"/>
		
		<cfset var result = "" />
		<cfset var savedEvent = "" />
		<cfset var savedAction = "" />
		<cfset var fw1 = createObject("component","Application") />
		<cfset var local=structNew()>
		<cfset var state=structNew()>
		
		<!--- Put the event url struct, to be used by FW/1 --->
		<cfset url.$ = $ />
		
		<!--- Check to see if the action is the page request action --->
		<cfif not len( arguments.action )>
			<cfif len(arguments.$.event(variables.framework.action))>
				<cfset arguments.action=arguments.$.event(variables.framework.action)>
			<cfelse>
				<cfset arguments.action=variables.framework.home>
			</cfif>
		</cfif>
		
		<!--- put the action passed into the url scope, saving any pre-existing value --->
		<cfif StructKeyExists(request, variables.framework.action)>
			<cfset savedEvent = request[variables.framework.action] />
		</cfif>
		<cfif StructKeyExists(url,variables.framework.action)>
			<cfset savedAction = url[variables.framework.action] />
		</cfif>
		
		<cfset url[variables.framework.action] = arguments.action />
		
		<cfset state=preserveInternalState(request)>
		
		<!--- call the frameworks onRequestStart --->
		<cfset fw1.onRequestStart(CGI.SCRIPT_NAME) />
		
		<cfset request.generateses = false />
		<!--- call the frameworks onRequest --->
		<!--- we save the results via cfsavecontent so we can display it in mura --->
		<cfsavecontent variable="result">
			<cfset fw1.onRequest(CGI.SCRIPT_NAME) />
		</cfsavecontent>
		
		<!--- Remove anything custom set in the request scope from this action call --->
		<cfif structKeyExists(request, "overrideviewaction")>
			<cfset structDelete(request, "overrideviewaction") />
		</cfif>
		<cfif structKeyExists(request, "view")>
			<cfset structDelete(request, "view") />
		</cfif>
		<cfif structKeyExists(request, "controllers")>
			<cfset structDelete(request, "controllers") />
		</cfif>
	
		<!--- restore the url scope --->
		<cfif structKeyExists(url,variables.framework.action)>
			<cfset structDelete(url,variables.framework.action) />
		</cfif>
		<!--- if there was a passed in action via the url then restore it --->
		<cfif Len(savedAction)>
			<cfset url[variables.framework.action] = savedAction />
		</cfif>
		<!--- if there was a passed in request event then restore it --->
		<cfif Len(savedEvent)>
			<cfset request[variables.framework.action] = savedEvent />
		</cfif>
		
		<cfset restoreInternalState(request,state)>

		<!--- return the result --->
		<cfreturn result>
	</cffunction>
	
</cfcomponent>