<cfset variables.framework=structNew()>
<cfset variables.framework.applicationKey="Bliss">
<cfset variables.framework.base="/#variables.framework.applicationKey#">
<cfset variables.framework.action="#variables.framework.applicationKey#Action">
<cfset variables.framework.error="common:main.error">
<cfset variables.framework.home="admin:main.dashboard">
<cfset variables.framework.defaultSection="main">
<cfset variables.framework.defaultItem="dashboard">
<cfset variables.framework.usingsubsystems=true>
<cfset variables.framework.defaultSubsystem = "admin">
<cfset variables.framework.subsystemdelimiter=":">
<cfset variables.framework.generateSES = false>
<cfset variables.framework.SESOmitIndex = true>
<cfif isDefined("application.configBean")>
	<cfset variables.framework.baseURL = "#application.configBean.getContext()#/plugins/#variables.framework.applicationKey#/" />
<cfelse>
	<cfset variables.framework.baseURL = "/plugins/#variables.framework.applicationKey#/" />
</cfif>