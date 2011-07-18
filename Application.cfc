component extends="core.utility.framework" output="false" {

	// If the page request was an admin request then we need to setup all of the defaults from mura
	if(isAdminRequest()) {
		include "../../config/applicationSettings.cfm";
		include "../../config/mappings.cfm";
		include "../mappings.cfm";
	}
	
	include "config.cfm";
	
	//TODO: Not sure we have to do here. Seems like we have a lot of references to Slatwall here that are hard-coded
	
	
	
	variables.slatwallVfsRoot = "ram:///" & this.name;
	this.mappings[ "/slatwallVfsRoot" ] = variables.slatwallVfsRoot;
	
	
	public void function setPluginConfig(required any pluginConfig) {
		application.slatwall.pluginConfig = arguments.pluginConfig; 
	}
	
	public any function getPluginConfig() {
		if( isDefined('application.slatwall.pluginConfig') ) {
			return application.slatwall.pluginConfig;	
		}
	}

	// Start: Standard Application Functions. These are also called from the fw1EventAdapter.
	public void function setupApplication(any $) {
		// Check to see if the base application has been loaded, if not redirect then to the homepage of the site.
		if( isAdminRequest() && (!structKeyExists(application, "appinitialized") || application.appinitialized == false)) {
			location(url="http://#cgi.HTTP_HOST#", addtoken=false);
		}
		
		// This insures that the required session values are setup
		setupMuraSessionRequirements();
		
		if ( not structKeyExists(request,"pluginConfig") or request.pluginConfig.getPackage() neq variables.framework.applicationKey){
	  		include "plugin/config.cfm";
		}
		setPluginConfig(request.PluginConfig);	
		
		// Set this in the application scope to be used on the frontend
		getPluginConfig().getApplication().setValue( "fw", this);
		
		// Set the setup confirmed as false
		getPluginConfig().getApplication().setValue('applicationSetupConfirmed', false);
		
		// Set vfs root for slatwall
		getPluginConfig().getApplication().setValue('slatwallVfsRoot', slatwallVfsRoot);
		
		// Make's sure that our entities get updated
		ormReload();
		
		// Get Coldspring Config
		var serviceFactory = "";
		var rbFactory = "";
		var xml = "";
		var xmlPath = "";

	    xmlPath = expandPath( '/plugins/Slatwall/config/coldspring.xml' );
		xml = FileRead("#xmlPath#"); 
		
		// Build Coldspring factory & Set in FW/1
		serviceFactory=createObject("component","coldspring.beans.DefaultXmlBeanFactory").init();
		serviceFactory.loadBeansFromXmlRaw( xml );
		serviceFactory.setParent(application.servicefactory);
		getpluginConfig().getApplication().setValue( "serviceFactory", serviceFactory );
		setBeanFactory(getPluginConfig().getApplication().getValue( "serviceFactory" ));
		
		// Build RB Factory
		rbFactory= new mura.resourceBundle.resourceBundleFactory(application.settingsManager.getSite('default').getRBFactory(),"#getDirectoryFromPath(getCurrentTemplatePath())#resourceBundles/");
		getpluginConfig().getApplication().setValue( "rbFactory", rbFactory);
		
		// Setup Default Data... This is only for development and should be moved to the update function of the plugin once rolled out.
		getBeanFactory().getBean("dataService").loadDataFromXMLDirectory(xmlDirectory = ExpandPath("/plugins/Slatwall/config/DBData"));
		
		// Call the setup methods in the setting service
		getBeanFactory().getBean("settingService").reloadConfiguration();
		getBeanFactory().getBean("settingService").verifyMuraRequirements();
		
		getBeanFactory().getBean("logService").logMessage(message="Application Setup Complete", generalLog=true);
	}
	
	public void function setupRequest() {
		getBeanFactory().getBean("logService").logMessage(message="Slatwall Lifecycle Started: #request.context.slatAction#");
		
		// Check to see if the base application has been loaded, if not redirect then to the homepage of the site.
		if( isAdminRequest() && (!structKeyExists(application, "appinitialized") || application.appinitialized == false)) {
			location(url="http://#cgi.HTTP_HOST#", addtoken=false);
		}
		
		// This verifies that all mura session variables are setup
		setupMuraSessionRequirements();
		
		// Enable the request cache service
		getBeanFactory().getBean("requestCacheService").enableRequestCache();
		
		if(!getBeanFactory().getBean("requestCacheService").keyExists(key="ormHasErrors")) {
			getBeanFactory().getBean("requestCacheService").setValue(key="ormHasErrors", value=false);
		}
		
		// Look for mura Scope in the request context.  If it doens't exist add it.
		if (!structKeyExists(request.context,"$")){
			if (!structKeyExists(request, "muraScope")) {
				request.muraScope = getBeanFactory().getBean("muraScope").init(session.siteid);
			}
			request.context.$ = request.muraScope;
		}
		
		// Make sure that the mura Scope has a siteid.  If it doesn't then use the session siteid
		if(request.context.$.event('siteid') == "") {
			request.context.$.event('siteid', session.siteid);
		}		
		
		// Setup slatwall scope in request cache If it doesn't already exist
		if(!getBeanFactory().getBean("requestCacheService").keyExists(key="slatwallScope")) {
			getBeanFactory().getBean("requestCacheService").setValue(key="slatwallScope", value= new Slatwall.com.utility.SlatwallScope());	
		}
		
		// Inject slatwall scope into the mura scope
		if( !structKeyExists(request, "custommurascopekeys") || !structKeyExists(request.custommurascopekeys, "slatwall") ) {
			request.context.$.setCustomMuraScopeKey("slatwall", getBeanFactory().getBean("requestCacheService").getValue(key="slatwallScope"));
		}
		
		// Add a reference to the mura scope to the request cache service
		getBeanFactory().getBean("requestCacheService").setValue(key="muraScope", value=request.context.$);
		
		// Confirm Session Setup
		getBeanFactory().getBean("SessionService").confirmSession();
		
		// Setup structured Data
		request.context.structuredData = getBeanFactory().getBean("formUtilities").buildFormCollections(request.context);
		
		// Run subsytem specific logic.
		if(isAdminRequest()) {
			controller("admin:BaseController.subSystemBefore");
		} else {
			controller("frontend:BaseController.subSystemBefore");
		}
		
	}
	// End: Standard Application Functions. These are also called from the fw1EventAdapter.

	// Helper Functions
	public boolean function isAdminRequest() {
		return not structKeyExists(request,"servletEvent");
	}
	
	public string function getExternalSiteLink(required String Address) {
		return buildURL(action='external.site', queryString='es=#arguments.Address#');
	}
	
	public boolean function secureDisplay(required string action, boolean testing=false) {
		var hasAccess = false;
		var permissionName = UCASE("PERMISSION_#getSubsystem(arguments.action)#_#getSection(arguments.action)#_#getItem(arguments.action)#");
		
		if(getSubsystem(arguments.action) eq "frontend") {
			hasAccess = true;
		} else {
			if(request.context.$.currentUser().getS2()) {
				hasAccess = true;
			} else if (listLen( request.context.$.currentUser().getMemberships() ) >= 1) {
				var rolesWithAccess = "";
				if(find("save", permissionName)) {
					rolesWithAccess = application.slatwall.pluginConfig.getApplication().getValue("serviceFactory").getBean("settingService").getPermissionValue(permissionName=replace(permissionName, "save", "edit")); 
					listAppend(rolesWithAccess, application.slatwall.pluginConfig.getApplication().getValue("serviceFactory").getBean("settingService").getPermissionValue(permissionName=replace(permissionName, "save", "update")));
				} else {
					rolesWithAccess = application.slatwall.pluginConfig.getApplication().getValue("serviceFactory").getBean("settingService").getPermissionValue(permissionName=permissionName);
				}
				
				for(var i=1; i<= listLen(rolesWithAccess); i++) {
					if( find( listGetAt(rolesWithAccess, i), request.context.$.currentUser().getMemberships() ) ) {
						hasAccess=true;
						break;
					}
				}
			}
		}
		return hasAccess;
	}
	
	private void function setupMuraSessionRequirements() {
		// Set default mura session variables when needed
		param name="session.rb" default="en";
		param name="session.locale" default="en";
		param name="session.siteid" default="default";
		param name="session.dashboardSpan" default="30";
	}
	
	
	// Override autowire function from fw/1 so that properties work
	private void function autowire(cfc, beanFactory) {
		var key = 0;
		var property = 0;
		var args = 0;
		var meta = getMetaData(arguments.cfc); 
		
		for(key in arguments.cfc) {
			if(len(key) > 3 && left(key,3) is "set") {
				property = right(key, len(key)-3);
				if(arguments.beanFactory.containsBean(property)) {
					evaluate("arguments.cfc.#key#(arguments.beanFactory.getBean(property))");
				}
			}
		}
		if(structKeyExists(meta, "accessors") && meta.accessors && structKeyExists(meta, "properties")) {
			for(var i = 1; i <= arrayLen(meta.properties); i++) {
				if(arguments.beanFactory.containsBean(meta.properties[i].name)) {
					evaluate("arguments.cfc.set#meta.properties[i].name#(arguments.beanFactory.getBean(meta.properties[i].name))");
				}
			}
		}
	}
	
	// Override onRequest function to add some custom logic to the end of the request
	public any function onRequest() {
		super.onRequest(argumentCollection=arguments);
		endSlatwallLifecycle();
	}
	
	// Override redirect function to flush the ORM when needed
	public void function redirect() {
		endSlatwallLifecycle();
		super.redirect(argumentCollection=arguments);
	}
	
	// Additional redirect function to redirect to an exact URL and flush the ORM Session when needed
	public void function redirectExact(required string location, boolean addToken=false) {
		endSlatwallLifecycle();
		location(arguments.location, arguments.addToken);
	}
	
	// This handels all of the ORM persistece.
	private void function endSlatwallLifecycle() {
		if(getBeanFactory().getBean("requestCacheService").getValue("ormHasErrors")) {
			getBeanFactory().getBean("requestCacheService").clearCache(keys="currentSession,currentProduct,currentProductList");
			ormClearSession();
			getBeanFactory().getBean("logService").logMessage("ormClearSession() Called");
		} else {
			ormFlush();
			getBeanFactory().getBean("logService").logMessage("ormFlush() Called");
		}
		getBeanFactory().getBean("logService").logMessage("Slatwall Lifecycle Finished: #request.context.slatAction#");
	}
	
	// This is used to setup the frontend path to pull from the siteid directory
	public string function customizeViewOrLayoutPath( struct pathInfo, string type, string fullPath ) {
		if(arguments.pathInfo.subsystem == "frontend" && arguments.type == "view") {
			arguments.fullPath = replace(arguments.fullPath, "/Slatwall/frontend/views/", "#application.configBean.getContext()#/#request.context.$.event('siteid')#/includes/display_objects/custom/slatwall/");
		}
		return arguments.fullPath;
	}
	
	// Start assetWire functions ==================================
	public any function getAssetWire() {
		if(!structKeyExists(request, "assetWire")) {
			request.assetWire = new assets.assetWire(this); 
		}
		return request.assetWire;
	}
	
	private void function buildViewAndLayoutQueue() {
		super.buildViewAndLayoutQueue();
		if(structKeyExists(request, "view")) {
			getAssetWire().addViewToAssets(request.view);
		}
	}
	
	private string function internalLayout( string layoutPath, string body ) {
		var rtn = super.internalLayout(argumentcollection=arguments);
		
		if(arguments.layoutPath == request.layouts[arrayLen(request.layouts)]) {
			if(getSubsystem(request.action) == "admin" || request.action == "frontend:event.onRenderEnd") {
				getBeanFactory().getBean("tagProxyService").cfhtmlhead(getAssetWire().getAllAssets());
			}
		}
		return rtn;
	}
		
	public string function view( string path, struct args = { } ) {
		getAssetWire().addViewToAssets(trim(parseViewOrLayoutPath( path, "view" )));
		return super.view(argumentcollection=arguments);
	}
	
	// End assetWire functions ==================================
}