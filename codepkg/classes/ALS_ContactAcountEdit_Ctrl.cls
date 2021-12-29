public with sharing class ALS_ContactAcountEdit_Ctrl {
    @AuraEnabled
    public Static Map<String,Object> saveDetails(String AccountDetail,String junctionRecord ,Boolean isAccount,Boolean isEdit,String ContactIds){
        if(AccountDetail == null || junctionRecord == null )
        {
            throw new AuraHandledException('Contact Or AccountContacRoles Should not be null..');//Throw Exception if Account or Contact Role is Null..
        } 
        String ConId = ContactIds;       
        Boolean existingAccount = isAccount; 
        Account accountRec = (Account) JSON.deserialize(AccountDetail, Account.class);//Deserialization of Account Record
        AccountContactRole__c junctionRec = (AccountContactRole__c) JSON.deserialize(junctionRecord, AccountContactRole__c.class);//Deserialization of Contact Role Record
            If(isEdit == false){
            If(existingAccount == false){
                    INSERT accountRec;//If it not Existing Account then create new one
                    junctionRec.Account_Name__c = accountRec.Id;//Attach new Created Account to Contact role record
                    junctionRec.Contact_Name__c = ConId;//Attach Current Contact Id to Contact Role
            }else if( existingAccount == true ){
                    junctionRec.Account_Name__c = accountRec.Id;//If Contact is already Created one Account then attach it to Contact Role record
                    junctionRec.Contact_Name__c = ConId;//Attach Current Contact Id to Contact Role
                    UPDATE accountRec;
                    //INSERT newAccConRole;
                }
              string msg='';
              try{
                        INSERT junctionRec;
                    }catch (DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            //Get Validation Rule & Trigger Error Messages
                            msg =+ e.getDmlMessage(i) +  '\n' ;
                        }
                        throw new AuraHandledException(msg);
                    }
            }else If(isEdit == true){//If user Updating the already created record then update the Record.
                    UPDATE accountRec;
                    UPDATE junctionRec;
                }
            Map<String,Object> resultSet = new Map<String,Object>();
            resultSet.put('accountRec', accountRec) ;
            resultSet.put('junctionRec', junctionRec) ;
            return resultSet ;
    }
    
    @AuraEnabled
    //Fetch Data of Selected Id
    public Static Map<String,Object> getDetails(String junctionIds){
        String objId = junctionIds;
        Map<String, Object> resultMap = new Map<String, Object>();
        AccountContactRole__c accountContactsRole = [SELECT Id ,Contact_Name__r.Name , Account_Name__r.Name,Account_Name__c , Contact_Name__c, 
                                                     Status__c,Contact_Role_Global_List__c FROM AccountContactRole__c WHERE Id = : objId]; //Role__c **
    
        Account account =[SELECT Id,Name FROM Account WHERE Id =: accountContactsRole.Account_Name__c] ;
        resultMap.put('JunctionObj',accountContactsRole);
        resultMap.put('accountObj',account);
        return resultMap;
    }
    }