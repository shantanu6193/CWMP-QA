@IsTest(SeeAllData=false)
public class CountyUserReigstrationCtrlTest {
	@testSetup
    public static void setup(){
        
        Account acc = new Account();
        acc.Name  = '01 - Alameda';
        acc.Queue_Name__c = 'RDMHS_Region_11';
        insert acc;
        Account acc1 = new Account();
        acc1.Name  = 'State 1';
        acc1.Entity_Type__c = 'State Agency';
        insert acc1;
        
        Group grp = new Group(Name='RDMHS Region 11',Type='Queue', DeveloperName='RDMHS_Region_11');
        insert grp;
        
        QueueSobject mappingObject = new QueueSobject(QueueId = grp.Id, SobjectType = 'User_Registration__c');
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
		System.RunAs(usr){
        insert mappingObject;
        }
        
        /*Group testGroup = new Group(Name='RDMHS Region 11', DeveloperName='RDMHS_Region_11', Type='Queue');
		insert testGroup;*/
        
		User_Registration__c userReg = new User_Registration__c();
        userReg.First_Name__c = 'Test';
        userReg.Last_Name__c = 'User';
        userReg.Phone__c = '123456789';
        userReg.Email__c = 'test@test.com';
        userReg.County__c = '01 - Alameda';
        userReg.Status__c = 'Pending for Approval';
        userReg.Entity_Type__c = 'County';
        insert userReg;
    }
    
    @IsTest
    public static void test1() {
        
        Test.startTest();
        //CountyUserReigstrationCtrl.createUserRegistrationRequest('Test','User','test@test.com','123456789','County','01 - Alameda','','','');
        CountyUserReigstrationCtrl.getStateAgencies();
        CountyUserReigstrationCtrl.apexSearchStateAgency('01 - Alameda',null);
        Test.stopTest();
    }
}