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

// TODO: needs slatwall path replacement

component displayname="Base Object" output="false" {
	
	public any function init() {
		
		return this;
	
	}
	
	// @hint helper function for returning the any of the services in the application
	public any function getService(required string service) {
		return getPluginConfig().getApplication().getValue("serviceFactory").getBean(arguments.service);
	}
	
	// @hint absolute url path from site root
	public string function getSlatwallRootPath() {
		return "#application.configBean.getContext()#/plugins/Slatwall";
	}
	
	// @hint the file system directory
	public string function getSlatwallRootDirectory() {
		return expandPath("#application.configBean.getContext()#/plugins/Slatwall");
	}
	
	// @hint Private helper function to return the plugin RB Factory in any component
	private any function getRBFactory() {
		return getPluginConfig().getApplication().getValue("rbFactory");
	}
	
	// @hint Private helper function to return the RB Key from RB Factory in any component
	private string function rbKey(required string key) {
		return getRBFactory().getKeyValue(session.rb,arguments.key);
	}
	
	// @hint Private helper function to return a Setting
	private any function setting(required string settingName) {
		return getService("settingService").getSettingValue(arguments.settingName);
	}
	
	// @hint Private helper function for returning the plugin config inside of any component in the application
	private any function getPluginConfig() {
		return application.slatwall.pluginConfig;
	}
	
	// @hint Private helper function for returning the fw
	private any function getFW() {
		return getPluginConfig().getApplication().getValue('fw');
	}
	
	public any function inject(required string property, required any value) {
		variables[ arguments.property ] = arguments.value;
	}
	
	public any function injectRemove(required string property) {
		structDelete(variables, arguments.property);
	}
	
	public any function getVariables() {
		return variables;
	}
	
	public string function buildURL() {
		return getFW().buildURL(argumentCollection = arguments);
	}
	
	public string function secureDisplay() {
		return getFW().secureDisplay(argumentCollection = arguments);
	}
	
	
}
