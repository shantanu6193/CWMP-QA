@IsTest(SeeAllData=false)
public class PHOS_InformRequestorForFinalStatusTest {
	@IsTest
    public static void test1() {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        Order orderRec = new Order();
        orderRec.Name = 'Test';
        orderRec.Requestor_Email_Text__c = 'test@test.com';
        orderRec.AccountId = acc.Id;
        orderRec.Status = 'Draft';
        orderRec.EffectiveDate = System.Today();
        insert orderRec;
        List<ID> ids = new List<ID>();
        List<Order> orderList = [Select id from Order];
        for(Order o : orderList){
            ids.add(o.id);
        }
        
        PHOS_InformRequestorForFinalStatus.informRequestor(ids);
        String body = 'test';
        PHOS_InformRequestorForFinalStatus.formatPlainBody(body);
    }
}