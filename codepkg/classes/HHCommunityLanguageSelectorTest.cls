@isTest
public class HHCommunityLanguageSelectorTest {
	@isTest
    public static void testgetLanguage() {
        Test.startTest();
       	String result = HHCommunityLanguageSelector.getLanguage();
        System.assert(result != null);
        HHCommunityLanguageSelector.updateLanguage('es');
        Test.stopTest();
        
    }
}