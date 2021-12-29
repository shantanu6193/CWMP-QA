/**
    * Created by nehab on 27-10-2020.
    */
    public with sharing class ALS_AcountContactEdit_Ctrl {
    @AuraEnabled
    public Static Map<String,Object> saveDetails(String ContactDetail,String junctionRecord ,Boolean isContact,Boolean isEdit,String AccountIds){
    String AccIds =AccountIds;
    if(ContactDetail == null || junctionRecord == null )
    {
        throw new AuraHandledException('Contact Or AccountContacRoles Should not be null..'); //Throw Exception if Contact or Contact Role is Null..
    }
    Boolean existingContact = isContact; //To Check if it is Existing contact or NOt
    Contact contactRec = (Contact) JSON.deserialize(ContactDetail, Contact.class);//Deserialization of Contact Record
    AccountContactRole__c junctionRec = (AccountContactRole__c) JSON.deserialize(junctionRecord, AccountContactRole__c.class);//Deserialization of Contact Role Record

        If(isEdit == false){
            If(existingContact == false){
                    string msg='';
                    try{
                        INSERT contactRec;//If it not Existing Contact then create new one
                    }
                    catch (DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            //Get Validation Rule & Trigger Error Messages
                            msg =+ e.getDmlMessage(i) +  '\n' ;
                        }
                        throw new AuraHandledException(msg);
                    }
                    junctionRec.Contact_Name__c = contactRec.Id;//Attach new Created Contact to Contact role record
            }else if( existingContact == true ){
                            junctionRec.Contact_Name__c = contactRec.Id;//If Contact is already Created one then attach it to Contact Role record
                            //INSERT newAccConRole;
                            string msg='';
                    try{
                        UPDATE contactRec;
                    }catch (DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            //Get Validation Rule & Trigger Error Messages
                            msg =+ e.getDmlMessage(i) +  '\n' ;
                        }
                        throw new AuraHandledException(msg);
                    }
                }
                junctionRec.Account_Name__c = AccIds;//Attch Account to Contact Role
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
        }else If(isEdit == true){ //If record is already exist update the changes made by user
                string msg='';
                try{
                    UPDATE contactRec;
                UPDATE junctionRec;
                }catch (DmlException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        //Get Validation Rule & Trigger Error Messages
                        msg =+ e.getDmlMessage(i) +  '\n' ;
                    }
                    throw new AuraHandledException(msg);
                }
            }
            Map<String,Object> resultSet = new Map<String,Object>();
            resultSet.put('contactRec', contactRec) ;
            resultSet.put('junctionRec', junctionRec) ;

            return resultSet ;
    }
    //Get the details of Contact Role
    @AuraEnabled
    public Static Map<String,Object> getDetails(String junctionIds){

        String objId = junctionIds;
        Map<String, Object> resultMap = new Map<String, Object>();

        AccountContactRole__c accountContactsRole = [SELECT Id ,Contact_Name__r.Name ,Account_Name__c , Contact_Name__c, Contact_Name__r.FirstName ,
                                                    Contact_Name__r.LastName , Contact_Name__r.Title ,Contact_Name__r.Email,Contact_Name__r.Phone,
                                                    Status__c,Contact_Role_Global_List__c
                                                    FROM AccountContactRole__c WHERE Id = : objId];//Role__c **

        Contact contact =[SELECT Id,Name,FirstName,LastName,Title,Email,Phone FROM Contact WHERE Id =: accountContactsRole.Contact_Name__c] ;
        resultMap.put('JunctionObj',accountContactsRole);
        resultMap.put('ContactObj',contact);
        return resultMap;
    }
    }