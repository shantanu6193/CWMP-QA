public class DyTest {
public static void DeleteEmail()
{
    List<Order__c> orders = [SELECT Delivery_Recipient_Email_Text__c,Requestor_Email_Text__c
                             FROM Order__c Order By LastModifiedDate asc limit 900];
for(Order__c ord: orders) {
ord.Delivery_Recipient_Email_Text__c = ord.Delivery_Recipient_Email_Text__c + '.invalid';
ord.Requestor_Email_Text__c= ord.Requestor_Email_Text__c+ '.invalid';
}
TriggerHelper.skipTrigger = true;
update orders;

}
}