trigger FundingOppTrigger on Funding_Opportunity__c (before insert,before update) {
	new FundingOppTriggerHelper().process();
}