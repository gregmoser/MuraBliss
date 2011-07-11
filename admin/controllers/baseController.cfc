component persistent="false" accessors="true" output="false" {
	
	property name="fw" type="any";
	
	public any function init(required any fw) {
		setFW(arguments.fw);
		
		return super.init();
	}
	
	public void function subSystemBefore(required struct rc) {
		
	}
}
