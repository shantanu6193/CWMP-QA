public with sharing class FundingOppTriggerHelper extends TriggerHelper{

    public override void processBeforeInsert(){
        FetchProgramWithParent();
    }

    public override void processBeforeUpdate(){
        FetchProgramWithParent();
        preventChangingProgramAndIncident();
    }
    
    //To allow user to select only those Program record which is having associated Parent Program, while creating or Updating Funding Opp record...
    private void FetchProgramWithParent()
    {
        Set<Id> programIds=new Set<Id>(); // To collect all the Program Ids, which we are going to use in Funding Opp....
        for(Funding_Opportunity__c fundOpp : (List<Funding_Opportunity__c>) Trigger.new)
        {
            if(fundOpp.Program_Name__c != null) //Checking for null pointer exception...
            {
                programIds.add(fundOpp.Program_Name__c); //Adding the Program Id to the Collection...
            }
        }
        
        //Fetching all the Program record data whose Id is available in the Set Collection(programIds)
        Map<Id,Program__c> mapPrograms=new Map<Id,Program__c>([SELECT Id, Name, Parent_Program__c FROM Program__c
                                                               WHERE Id IN : programIds]);
        
        for(Funding_Opportunity__c fundOpp : (List<Funding_Opportunity__c>) Trigger.new)
        {
            //Fetching the Program of the Funding Opp from Map Collection...
            Program__c prog = mapPrograms.get(fundOpp.Program_Name__c); // Fetching the Program data from Map collection, which is associated to current Funding opp...
            if(prog != null && prog.Parent_Program__c == null) //To check that Parent Program field is nkot empty for the selected Program record..
            {
                fundOpp.Program_Name__c.addError('Please select the program record,which is having associated parent program.');
            }
        }
    }

    //To prevent changing of the Program and Incident if there is aProject associated with the Funding Opportunity...
    private void preventChangingProgramAndIncident()
    {
        Map<Id, Funding_Opportunity__c> fundingOppsToProcessMap = new Map<Id, Funding_Opportunity__c>(); //To collect the funding opp for Processing...
        Set<Id> currentUserIds = new Set<Id>(); //TO collect the current user id...
        for(Funding_Opportunity__c fundOpp : (List<Funding_Opportunity__c>) Trigger.new) { //Iterating Trigger.new Collection...
            Funding_Opportunity__c oldFundingOpp = (Funding_Opportunity__c)Trigger.oldMap.get(fundOpp.Id); //Fetching old record from Trigger.oldMap collection...
            if (fundOpp.Incident_Name__c != oldFundingOpp.Incident_Name__c
                    || fundOpp.Program_Name__c != oldFundingOpp.Program_Name__c) { //Comparing old and new records Program and Incident value...
                fundingOppsToProcessMap.put(fundOpp.Id, fundOpp); //Adding funding opp Id to the collection for processing...
                Id userId= UserInfo.getUserId(); // Fetching current user Id...
                currentUserIds.add(userId); //Adding user id to collection...
            }
        }
        //Fetching the Funding Opp with related Projects...
        Map<Id,Funding_Opportunity__c> fundingOppTOProjectMap = new Map<Id, Funding_Opportunity__c>([SELECT Id, Name, (SELECT Id, Name, Funding_Opportunity_Name__c FROM Projects__r) FROM Funding_Opportunity__c WHERE Id IN : fundingOppsToProcessMap.keySet()]);
        //Fetching the User info whose Id is present in the collection...
        Map<Id,User> currentUserInfo = new Map<Id,User>([SELECT Id,Name, ProfileId, Profile.Name FROM User WHERE Id IN:currentUserIds]);
        //Iterating the fundingOppToProcess collection...
        for(Funding_Opportunity__c fundOppToProcess : fundingOppsToProcessMap.values()) {
            Funding_Opportunity__c fundingOppToCompare = fundingOppTOProjectMap.get(fundOppToProcess.Id); //Fetching the Old Funding Opp record...
            User currentUser = currentUserInfo.get(UserInfo.getUserId()); //Fetching the current user Info...
            if(fundingOppToCompare.Projects__r.size() > 0 && currentUser.Profile.Name != ALS_CONSTANTS.ProfileName_SystemAdmin) //To check if there is a project associated to current Funding opp...
            {
                fundOppToProcess.addError('You are not allowed to change the Program and Incident, If there is a Project associated to it.');
            }
        }
    }
}