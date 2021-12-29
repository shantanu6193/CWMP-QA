@isTest
private class MARS_Incident_Search_Ctrl_Test {
	@isTest
    static void getIncidentListTest(){
        Incident__c newIncident = new Incident__c();
        newIncident.Name='test'; 
        newIncident.isActive__c=true; 
        newIncident.Incident_Start_Date__c=System.today(); 
        newIncident.Incident_End_Date__c=System.today().addDays(2);
        newIncident.Available_for_Application__c = 'MARS';
        newIncident.Order_No__c = '12234';
        insert newIncident;
        
        MARS_Incident_Search_Ctrl.getIncidentList('test');
        MARS_Incident_Search_Ctrl.getIncidentListByNumber('12234');
    }

}