component extends="ClientBaseTestCase" displayName="EndToEnd-Client-newValidations" {

    public void function beforeTests() {
        browserUrl = "http://localhost/validatethis/tests/selenium/FacadeDemo/";
        super.beforeTests();
        selenium.setTimeout(30000);
    }

    public void function testEndToEndClientnewValidations() {
        selenium.open("http://localhost/validatethis/tests/selenium/FacadeDemo/index.cfm?init=true&context=newValidations-client");
        assertEquals("ValidateThis Demo Page", selenium.getTitle());
        selenium.type("UserName", "");
        selenium.type("UserPass", "");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address is required.", selenium.getText(errLocator("UserName")));
        selenium.type("UserName", "a");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address must contain a date between 2010-01-01 and 2011-12-31.", selenium.getText(errLocator("UserName")));
        selenium.type("UserName", "2010-02-02");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address must be a date in the future. The date entered must come after 2010-12-31.", selenium.getText(errLocator("UserName")));
        selenium.type("UserName", "2011-02-02");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address must be a date in the past. The date entered must come before 2011-02-01.", selenium.getText(errLocator("UserName")));
        selenium.type("UserName", "2011-01-31");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address was not found in list: (2011-01-30,2011-01-29).", selenium.getText(errLocator("UserName")));
        selenium.type("UserName", "2011-01-29");
        selenium.click("//button[@type='submit']");
        assertEquals("The Email Address was found in list: (2011-01-29,2011-01-28).", selenium.getText(errLocator("UserName")));
        selenium.type("Nickname", "<input>");
        selenium.click("//button[@type='submit']");
        assertEquals("The Nickname cannot contain HTML tags.", selenium.getText(errLocator("Nickname")));
        selenium.type("Nickname", "something 2011-01-29 something else");
        selenium.click("//button[@type='submit']");
        assertEquals("The Nickname must not contain the values of properties named: UserName,UserPass.", selenium.getText(errLocator("Nickname")));
        selenium.type("Nickname", "something thePass something else");
        selenium.type("UserPass", "thePass");
        selenium.click("//button[@type='submit']");
        assertEquals("The Nickname must not contain the values of properties named: UserName,UserPass.", selenium.getText(errLocator("Nickname")));
        selenium.type("Nickname", "a");
        selenium.click("//button[@type='submit']");
        assertEquals("Did not match the patterns for the Nickname.", selenium.getText(errLocator("Nickname")));
        selenium.type("Nickname", "aB1");
        selenium.click("//button[@type='submit']");
        assertEquals("Please enter a valid URL.", selenium.getText(errLocator("Nickname")));
        selenium.type("Nickname", "http://aB1.com");
        selenium.click("//button[@type='submit']");
        assertNotEquals("Please enter a valid URL.", selenium.getText(errLocator("Nickname")));
        selenium.type("UserPass", "");
        selenium.click("//button[@type='submit']");
        assertEquals("The Password is required.", selenium.getText(errLocator("UserPass")));
        selenium.type("UserPass", "@");
        selenium.click("//button[@type='submit']");
        assertEquals("The Password must be a valid boolean value.", selenium.getText(errLocator("UserPass")));
        selenium.type("UserPass", "true");
        selenium.click("//button[@type='submit']");
        assertEquals("The Password must be false.", selenium.getText(errLocator("UserPass")));
        selenium.type("UserPass", "no");
        selenium.click("//button[@type='submit']");
        assertEquals("The Password must be true.", selenium.getText(errLocator("UserPass")));
        // test for optionality of dateRange
        selenium.type("FirstName", "2001-01-01");
        selenium.click("//button[@type='submit']");
        assertEquals("The First Name must contain a date between 2010-01-01 and 2011-12-31.", selenium.getText(errLocator("FirstName")));
        selenium.type("FirstName", "");
        selenium.click("//button[@type='submit']");
        assertEquals("", selenium.getText(errLocator("FirstName")));

    }
}

