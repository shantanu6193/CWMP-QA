public with sharing class ALS_ProjectJunctionEditController_Ctrl {
    @AuraEnabled
    public Static Map<String,Object> saveDetails(String projectRecordId, String AccountDetail, String ProjectRoleDetail, String ContactDetail, String contactRole, Boolean isEdit, String srcObject, String programs) {
        //Project__c projectDetails = (Project__c) JSON.deserialize(projectDetail, Project__c.class);//Deserialization of Project Record
        String projectId = projectRecordId;
        Account accountDetails = (Account) JSON.deserialize(AccountDetail, Account.class);//Deserialization of Account Record
        Contact contactDetails = (Contact) JSON.deserialize(ContactDetail, Contact.class);//Deserialization of Contact Record
        AccountContactRole__c contactRoles = (AccountContactRole__c) JSON.deserialize(contactRole, AccountContactRole__c.class);//Deserialization of Contact Role Record
        Project_Role__c projectRoleDetails = (Project_Role__c) JSON.deserialize(ProjectRoleDetail, Project_Role__c.class);//Deserialization of Project Role Record
        if(isEdit != true){ //Create a new Project Role..
           if(ContactDetails.Id != null){
               if(contactRoles.Contact_Role_Global_List__c==null){
                   // Scenario : Existing Contact role
                   AccountContactRole__c cRole = [SElect Id from AccountContactRole__c Where Contact_Name__c=:contactDetails.Id AND Account_Name__c=: accountDetails.Id LIMIT 1];
                   projectRoleDetails.AccountContactJunction__c = cRole.Id;
               }else if(contactRoles.Contact_Role_Global_List__c!=null){
                    // Existing Contact and New contact role
                   contactRoles.Account_Name__c = accountDetails.Id;
                   contactRoles.Contact_Name__c = contactDetails.Id;
                   string msg='';
                   try{
                   insert contactRoles;
                  }catch (DmlException e){
                    System.debug('Inside the error for duplicate records');
                          for(Integer i = 0; i < e.getNumDml(); i++){
                        //Get Validation Rule & Trigger Error Messages
                        msg =+ e.getDmlMessage(i) +  '\n' ;
                    }
                    throw new AuraHandledException(msg);
                }
                   projectRoleDetails.AccountContactJunction__c = contactRoles.Id;
               }
           }else{
                // Creating new contact and New contact role
               string msg='';
                try{
                insert contactDetails;
                  }catch (DmlException e){
                System.debug('Inside the error for duplicate records');
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                throw new AuraHandledException(msg);
            }
               contactRoles.Account_Name__c = accountDetails.Id;
               contactRoles.Contact_Name__c = contactDetails.Id;
                insert contactRoles;
               projectRoleDetails.AccountContactJunction__c = contactRoles.Id;
             }
            List<Project__c> projectList = new List<Project__c>();
            switch on srcObject {
                when 'Project__c' {
                    projectRoleDetails.Project_Name__c =projectId;
                }
                when 'Incident_Subrecipient_Stage__c' {
                    projectRoleDetails.Incident_Subrecipient_Summary__c =projectId;

                }
                when 'Account' {
                    projectRoleDetails.Subrecipient__c =projectId;
                }
            }
            if(programs != null) {
                    projectRoleDetails.Programs__c = programs;

           }


           string msg='';
           try{
             insert projectRoleDetails;
           }catch (DmlException e){
            System.debug('Inside the error for duplicate records');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
              throw new AuraHandledException(msg);
            }
       
          }else if(isEdit == true){//Update a Existing Project Role..
        string msg='';
            try{
              UPDATE projectRoleDetails;
            }catch (DmlException e){
              System.debug('Inside the error for duplicate records');

              for(Integer i = 0; i < e.getNumDml(); i++) {
                  //Get Validation Rule & Trigger Error Messages
                  msg =+ e.getDmlMessage(i) +  '\n' ;
              }
              throw new AuraHandledException(msg);
            }
      }

          //send the email if project role is authorized Agent
            ProjectSharingHelper.shareRecords(projectRoleDetails.Id);
          
        Map<String,Object> resultMap = new Map<String,Object>();
        resultMap.put('Success','success');
        return resultMap;
    }

    @AuraEnabled
    //Get detail of selected record
    public Static Map<String,Object> getDetails(String junctionIds ){
        String objId = junctionIds;
        Map<String, Object> resultMap = new Map<String, Object>();
        Project_Role__c projecRoleRecord = [SELECT Id, Has_Signing_Authority__c, Is_Mailing_Contact__c, Contact_Type__c,Programs__c, Project_Name__c, AccountContactJunction__c, AccountContactJunction__r.Account_Name__c, AccountContactJunction__r.Contact_Name__c, Project_Role_Global_List__c  FROM Project_Role__c WHERE Id =: objId]; //Role__c **
        resultMap.put('JunctionObj',projecRoleRecord);
        return resultMap;
    }
    @AuraEnabled
    public static Map<String, String> getIncidentAndSubrecipientName(String incidentSubrecipientSummaryId) {
        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('incidentName', '');
        resultMap.put('subrecipientName', '');
        List<Incident_Subrecipient_Stage__c> issRecord = [
                SELECT Incident__r.Name, Account__r.Name FROM Incident_Subrecipient_Stage__c
                WHERE Id =:incidentSubrecipientSummaryId
        ];
        if(issRecord.size() > 0) {
            resultMap.put('incidentName', issRecord[0].Incident__r.Name);
            resultMap.put('subrecipientName', issRecord[0].Account__r.Name);
        }
        return resultMap;
    }
}