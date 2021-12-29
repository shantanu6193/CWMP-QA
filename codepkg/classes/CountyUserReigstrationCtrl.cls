/***********************************************************************************************************************************
* Class Name   : CountyUserReigstrationCtrl
* Description  : This class for community new user to set password
* Author       : Pankaj
* Created On   : 05/01/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             05/01/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class CountyUserReigstrationCtrl{
    private final static Integer MAX_RESULTS = 500;
    
    /***********************************************
    * Method Name : createUserRegistrationRequest
    * Author : Pankaj
    * Inputs : String fname, String lname, String email, String phone, String entity, String county, String state, String nongov, String federalTaxId
    * Description: This method create new user registration record and call approval process
    *********************************************/
    @AuraEnabled
    public static void createUserRegistrationRequest(String fname, String lname, String email, String phone, String entity, String county, String state, String nongov, String federalTaxId){
        /*try{
            List<User> users = [Select id,Name,Email from User where Username =: email];
            if(users.size() > 0){
                throw new CustomException('User with this email already exists.');
            }else{
                User_Registration__c userReg = new User_Registration__c();
                userReg.First_Name__c = fname;
                userReg.Last_Name__c = lname;
                userReg.Phone__c = phone;
                userReg.Email__c = email;
                if(entity == 'State Agency') {
                    county = 'State Agency';
                    //county = '59 - State Agency';
                } else if(entity == 'Non-Governmental Entity') {
                    county = 'Non-Governmental Entity';
                    //county = '60 - Non-Governmental Entity';
                }
                userReg.County__c = county;
                userReg.Status__c = 'Pending for Approval';
                userReg.Entity_Type__c = entity;
                if(String.isNotBlank(state)){
                    userReg.State_Agency__c = state;
                }
                userReg.Non_Governmental_Entity__c = nongov;
                userReg.Federal_Tax_ID__c = federalTaxId;
                insert userReg;
                processUserRegApprovalRequest(userReg.Id);
            }
        }
        catch(Exception ex) {
            throw new CustomException(ex.getMessage());
        }*/
    }

    /***********************************************
    * Method Name : getStateAgencies
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of OptionWrapper(account Name and Id)
    *********************************************/
    @AuraEnabled (cacheable=true)
    public static List<OptionWrapper> getStateAgencies(){
        /*List<OptionWrapper> accNameList = new List<OptionWrapper>();
        for(Account acc :[Select id,Name from Account where Entity_Type__c = 'State Agency' order by Name]){
            accNameList.add(new OptionWrapper(acc.Name, acc.Id));
        }
        System.debug(accNameList);
        return accNameList;*/
        return null;
    }

    /***********************************************************************************************************************************
    * Class Name   : OptionWrapper
    * Description  : This is wrapper class for return account name and id
    * Author       : Pankaj
    * Created On   : 05/01/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj             05/01/2020       Initial Implementation
    **************************************************************************************************************************************/
    public class OptionWrapper {
        /*@AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public OptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }*/
    }

    /***********************************************
    * Method Name : processUserRegApprovalRequest
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method send records to aprroval and update user registration record owner
    *********************************************/
    public static void processUserRegApprovalRequest(String recordId){
        /*User_Registration__c userReg = [Select id,County__c,Non_Governmental_Entity__c,State_Agency__c,Entity_Type__c from User_Registration__c where Id =: recordId];
        system.debug('>>>'+userReg.County__c);      
        String comment = 'Record for approval';
        List<Group> queues = new List<Group>();
        if(String.isNotBlank(userReg.Entity_Type__c) && (userReg.Entity_Type__c == 'County' || userReg.Entity_Type__c == 'State Agency')) {
            Account acc;
            if(userReg.Entity_Type__c == 'County') {
                acc = [Select id, Name, Queue_Name__c, Parent.Queue_Name__c from Account where Name =: userReg.County__c AND Entity_Type__c='County' LIMIT 1];
                //acc = [Select id, Name, Queue_Name__c, Parent.Queue_Name__c from Account where Name =: userReg.County__c LIMIT 1];
            } else {
                acc = [Select id, Name, Queue_Name__c, Parent.Queue_Name__c from Account where Id =: userReg.State_Agency__c LIMIT 1];
            }


            String queueName = acc.Parent.Queue_Name__c;
            if(String.isEmpty( queueName )) {
                queueName = acc.Queue_Name__c;
            }
            if(String.isEmpty( queueName )) return;
            queues = [SELECT Id FROM Group WHERE DeveloperName=:queueName AND Type='Queue'];
        }else if(String.isNotBlank(userReg.Non_Governmental_Entity__c)){
            queues = [SELECT Id FROM Group WHERE DeveloperName='SOC_OPS_Non_Government' AND Type='Queue'];
        }
        if(queues.size() == 0) return;
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Id> userIdsToApprove = new List<Id>();
        Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(userReg.Id);
        req1.setProcessDefinitionNameOrId('RDMHS_Approval');
        req1.setNextApproverIds(new List<String>{queues.get(0).Id});
        req1.setSkipEntryCriteria(true);
        
        approvalRequestList.add(req1);
        if(approvalRequestList.size() > 0 && Test.isRunningTest() == false) {
            Approval.process(approvalRequestList);
        }
        User_Registration__c updateUserReg = new User_Registration__c();
        updateUserReg.Id = userReg.Id;
        updateUserReg.OwnerId = queues.get(0).Id;
        update updateUserReg;*/
    }

    /***********************************************************************************************************************************
    * Class Name   : CustomException
    * Description  : This class for throwing custom exception
    * Author       : Pankaj
    * Created On   : 05/01/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj             05/01/2020       Initial Implementation
    **************************************************************************************************************************************/
    public class CustomException extends Exception{
    
    }

    /***********************************************
    * Method Name : apexSearchStateAgency
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult for Account with entity type State Agency
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchStateAgency(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        //searchTerm += '*';
        /*String stateAgency = 'State Agency';
        String query = 'Select Id,Name From Account';
        query += ' Where Entity_Type__c = \'' + stateAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
        }
        query += ' Limit ' + MAX_RESULTS;
        system.debug('query===='+query);
        List<Account> accounts = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
                results.add(
                        new LookupSearchResult(
                                opAccountReference.Id,
                                'Account',
                                accountIcon,
                                opAccountReference.Name, 
                                null, 
                                opAccountReference
                        )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;*/
        return null;
    }
}