/**************************************************************\
 * Author: Sravan Reddy Pinninti (sravanreddyp6@gmail.com)
 * ModifiedDate: 7/27/2021
 * Purpose: handle the save and submit logic for F-42 Entry form
 **************************************************************/


public without sharing class MARS_F42Entry_Ctrl {

    @AuraEnabled
    public static List<MARS_F42Entry_Ctrl.f42Draft> getDraftF42Entries(string accId){
        try{
            list<MARS_F42Entry_Ctrl.f42Draft> entries = new list<MARS_F42Entry_Ctrl.f42Draft>();
            MARS_F42Entry_Ctrl.f42Draft entry;
            for(F42_Entry__c f42 :[SELECT Id, Account__r.Name, Account__r.Macs_Id__c, Incident__r.Name, Status__c, LastModifiedby.Name, Entered_By__r.Name, lastmodifiedDate
                        FROM  F42_Entry__c 
                        WHERE Status__c = 'Online Draft'
                        AND Account__c = :accId
                        order by lastmodifiedDate desc]){
                    
                    entry = new MARS_F42Entry_Ctrl.f42Draft();
                    entry.Id = f42.Id;
                    entry.macsID = f42.Account__r.Macs_Id__c;
                    entry.incidentName = f42.Incident__r.Name;
                    entry.status        = f42.Status__c;
                    entry.lastmodifiedBy = f42.lastmodifiedby.name;
                    entry.lastmodifiedDate = f42.lastmodifiedDate;

                    entries.add(entry);
            }
            
            return entries;
        }catch(exception e){
            throw new AuraHandledException('An unexpected error occurred: '+e.getMessage()+'Stack trace is '+e.getStackTraceString());
        }               
    }

    @AuraEnabled
    public static  List<MARS_F42Entry_Ctrl.f42Draft> disregardF42Entry(string entryId, string accId){
        try {
            F42_Entry__c entry = new F42_Entry__c(Id=entryId);
            entry.Status__c = 'Disregarded';
            update entry;
            return getDraftF42Entries(accId);
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred: '+e.getMessage()+'Stack trace is '+e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static MARS_F42Entry_Ctrl.F42EntryWrapper initializeWrapper(string agencyId, string f42EntryId){
        try{
            MARS_F42Entry_Ctrl.F42EntryWrapper f42entry = new MARS_F42Entry_Ctrl.F42EntryWrapper();
            if(string.isNotBlank(f42EntryId)){
                F42_Entry__c draftEntry   = [SELECT Id, JSON__c 
                                                FROM F42_Entry__c 
                                                WHERE 
                                                Id = :f42EntryId 
                                                LIMIT 1];

                f42entry = (MARS_F42Entry_Ctrl.F42EntryWrapper) JSON.deserialize(draftEntry.JSON__c, MARS_F42Entry_Ctrl.F42EntryWrapper.class);
                f42entry.f42Id =  draftEntry.Id;
            }else{//brand new entry
                f42Entry.loggedinUser               = [SELECT Id, Name, Phone, ContactId FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
                f42entry.agency                     = [SELECT Id, Name, MACS_ID__c,ShippingState,Mars_Agency_Designator__c FROM Account WHERE Id=: agencyId LIMIT 1];
                f42entry.incident                   = new Incident__c();
                f42entry.dispatchInfoIncident       = new Incident__c();
                f42entry.dispatchFromIncident       = new Incident__c();
                f42entry.dispatchToIncident         = new Incident__c();
                f42entry.OH_icsTitle                = new ICS_Title__c();
                f42Entry.ER_specialEquipment        = new Agency_Special_Equipment_Line_Item__c();
                f42Entry.personnelInfoList          = new list<MARS_F42Entry_Ctrl.PersonnelInfo>();
                f42Entry.otherpersonnelInfoList     = new list<MARS_F42Entry_Ctrl.PersonnelInfo>();
                f42Entry.actualHoursList            = new list<MARS_F42Entry_Ctrl.ActualHours>();
                f42Entry.comments                   = new list<MARS_F42Entry_Ctrl.CommentWrapper>();
                f42Entry.RA_agencyName              = f42Entry.agency.Name;
                f42Entry.RA_yourName                = f42Entry.loggedinUser.Name;
                f42Entry.RA_yourPhone               = f42Entry.loggedinUser.Phone;
                f42Entry.RA_signURL                 = '';
                f42Entry.PA_signURL                 = '';

            }
            return f42entry;
        }catch (exception e){
            throw new AuraHandledException('An unexpected error occurred: '+e.getMessage()+'Stack trace is '+e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static MARS_F42Entry_Ctrl.F42EntryWrapper saveWrapper(string wrapper, string RAsignatureBlob, string PAsignatureBlob, string saveorSubmit){
        try{
            MARS_F42Entry_Ctrl.F42EntryWrapper f42EntryData = (MARS_F42Entry_Ctrl.F42EntryWrapper) JSON.deserialize(wrapper, MARS_F42Entry_Ctrl.F42EntryWrapper.class);
            F42_Entry__c entry = new F42_Entry__c(Id=f42EntryData.f42Id);
            entry.Account__c = f42EntryData.agency.Id;
            entry.Incident__c = f42EntryData.incident.Id;
            entry.Json__c = JSON.serialize(f42EntryData);//wrapper;
            entry.Status__c = saveorSubmit == 'Save' ? 'Online Draft': 'Submitted';
            entry.Name = f42EntryData.agency.Mars_Agency_Designator__c+'-F42Entry-'+entry.Status__c;
            entry.Entered_By__c = f42EntryData.loggedinUser.ContactId;
            upsert entry;

            f42EntryData.f42Id = entry.Id;
            if(string.isNotBlank(RAsignatureBlob)) {
                f42EntryData.RA_signURL = '';
                //Delete existing signatures if any for this specific record
                list<ContentDocument> toDelete = new list<ContentDocument>();
                for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :entry.Id
                                                AND ContentDocument.Title LIKE '%Responding Agency Signature%']){
                    toDelete.add(new ContentDocument(Id=cdl.ContentDocumentId));
                }
                delete toDelete;
                string RASign = SignatureHelper.saveSignwithNameandReturnIds(RAsignatureBlob, entry.Id, 'Responding Agency Signature');
                string cvId = RASign.substringbefore('~~');
                string cdId = RASign.substringBetween('~~', '--');
                f42EntryData.RA_signURL =  '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ cvId + '&operationContext=CHATTER&contentId=' + cdId;
            }
            if(string.isNotBlank(PAsignatureBlob)) {
                f42EntryData.PA_signURL = '';
                //Delete existing signatures if any for this specific record
                list<ContentDocument> toDelete = new list<ContentDocument>();
                for(ContentDocumentLink cdl: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :entry.Id
                                            AND ContentDocument.Title LIKE '%Paying Agency Signature%']){
                    toDelete.add(new ContentDocument(Id=cdl.ContentDocumentId));
                }
                delete toDelete;
                string PASign =  SignatureHelper.saveSignwithNameandReturnIds(PAsignatureBlob, entry.Id, 'Paying Agency Signature');
                string pacvId = PASign.substringbefore('~~');
                string pacdId = PASign.substringBetween('~~', '--');
                f42EntryData.PA_signURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId='+ pacvId + '&operationContext=CHATTER&contentId=' + pacdId;
            }
            if(string.isNOTBlank(f42EntryData.RA_signURL) || string.isNOTBlank(f42EntryData.PA_signURL)){
                update new F42_Entry__c(Id = entry.Id, JSON__c = JSON.serialize(f42EntryData));
            }
            if(saveorSubmit == 'Save'){
                return f42EntryData;
            }else{//Logic for Submit

                list<F42__c> f42List                      = new list<F42__c>();
                F42__c f42                                 = new F42__c();
                list<F_42_Comment__c> comments              = new list<F_42_Comment__c>();
                list<F_42_Personnel_Info__c> personnelInfo  = new list<F_42_Personnel_Info__c>();
                list<F_42_Actual_Hours__c> actualHours      = new list<F_42_Actual_Hours__c>();
                list<ContentDocumentLink> f42Files          = new list<ContentDocumentLink>();
                set<string> userIds                        = new set<string>();
                string QueueId;

                //Boolean CDFEquipPresent = false;
                //Boolean CDFMacIdPresent = false;
                //Boolean CDFonlyPresent = false;

                Boolean OESEquipPresent = false;
                Boolean OESMacIdPresent = false;
                Boolean OESonlyPresent = false;


                map<string, string>macsIdtoAccountIdMap = new map<string, string>();
                for(MARS_F42Entry_Ctrl.PersonnelInfo pi: f42EntryData.personnelInfoList){
                    macsIdtoAccountIdMap.put(pi.MACSID, '');
                    if(pi.MACSID == 'OES'){
                        OESMacIdPresent = true;
                    }
                }
                for(MARS_F42Entry_Ctrl.PersonnelInfo pi: f42EntryData.otherpersonnelInfoList){
                    macsIdtoAccountIdMap.put(pi.MACSID, '');
                    if(pi.MACSID == 'OES'){
                        OESMacIdPresent = true;
                    }
                }

                if(f42EntryData.ER_cdfoesVehicle == 'Yes'){
                    OESEquipPresent = true;
                    macsIdtoAccountIdMap.put('OES', '');
                }

                if(macsIdtoAccountIdMap.containsKey('OES') && macsIdtoAccountIdMap.keySet().size() == 1){
                    OESonlyPresent = true;
                }

                for(Account acc: [SELECT Id, MACS_ID__c 
                                    FROM Account 
                                    WHERE MACS_ID__c IN: macsIdtoAccountIdMap.keySet()
                                    OR ID = :f42EntryData.agency.Id]){
                    macsIdtoAccountIdMap.put(acc.MACS_ID__c, acc.Id);
                }



                for(GroupMember g: [SELECT Id, UserOrGroupId, GroupId FROM GroupMember
                                    WHERE Group.Type = 'Queue' 
                                    AND Group.DeveloperName = 'MARS_F_42_APPROVAL_QUEUE']){
                    userIds.add(g.UserOrGroupId);
                    QueueId = g.GroupId;
                }
                
                //1-4 AGENCY/INCIDENT
                f42.Account__c                              = f42EntryData.agency.Id;
                f42.Strike_Team__c                          = f42EntryData.strikeTeam;
                f42.Incident__c                             = f42EntryData.incident.Id;
                f42.Incident_Request_Number__c              = f42EntryData.incidentRequestNumber;
                //5. DISPATCH INFO
                f42.DI_Committed_to_Incident_Date__c        = f42EntryData.DI_committedtoIncident;
                f42.DI_Committed_to_Incident_Time__c        = f42EntryData.DI_committedtoIncidentTime;
                f42.DI_Return_from_Incident_Date__c         = f42EntryData.DI_returnfromIncident;
                f42.DI_Return_from_Incident_Time__c         = f42EntryData.DI_returnfromIncidentTime;
                f42.DI_Mobilization_Center_Preposition__c   = f42EntryData.DI_mobilizationCenter == 'Yes' ? true : false ;
                f42.DI_Redispatched_Date__c                 = f42EntryData.DI_reDispatched;
                f42.DI_Redispatched_Time__c                 = f42EntryData.DI_reDispatchedTime;
                f42.DI_REPORTING_LOCATION__c                = f42EntryData.DI_reportingLocation;
                //6. DISPATCH FROM
                f42.DF_OLD_INCIDENT__c                      = f42EntryData.dispatchFromIncident.Id;
                f42.DF_Dispatch_From_End_Date__c	        = f42EntryData.DF_endDate;
                f42.DF_OLD_INCIDENT_REQUEST__c              = f42EntryData.DF_incidentRequestNumber;
                //7. DISPATCH TO
                f42.DT_Dispatch_To_Start_Date__c            = f42EntryData.DT_startDate;
                f42.DT_NEW_INCIDENT__c                      = f42EntryData.dispatchToIncident.Id;
                f42.DT_NEW_INCIDENT_REQUEST__c              = f42EntryData.DT_incidentRequestNumber;
                
                //8. OVERHEAD
                f42.OH_OVERHEAD_TYPE__c                     = f42EntryData.OH_overheadType;
                f42.OH_ICS_Title__c                         = f42EntryData.OH_icsTitle.Name;
                f42.OH_OTHER_ICS_TITLE__c                   = f42EntryData.OH_otherICStitle;
                //9. SUPPORT VEHICLE INFO
                f42.SV_VEHICLE_OWNERSHIP__c                 = f42EntryData.SV_vehicleOwnership;
                f42.SV_LICENSE__c                           = f42EntryData.SV_licenseplateNumber;
                f42.SV_TYPE__c                              = f42EntryData.SV_vehicleType;
                //10. PRIVATELY OWNED VEHICLE
                f42.SV_BEGINNING_ODODMETER__c               = string.isNotBlank(f42EntryData.PO_odometerStart) ? decimal.valueOf(f42EntryData.PO_odometerStart) : null;
                f42.SV_ENDING_ODOMETER__c                   = string.isNotBlank(f42EntryData.PO_odometerEnd) ? decimal.valueOf(f42EntryData.PO_odometerEnd) : null;
                //11. EQUIPMENT RESOURCE INFO
                f42.ER_APPARATUS__c                         = f42EntryData.ER_apparatus;
                f42.ER_TYPE__c                              = f42EntryData.ER_type;
                f42.ER_UNIT__c                              = f42EntryData.ER_unitNumber;
                f42.ER_LICENSE_NUMBER__c                    = f42EntryData.ER_licenseNumber;
                f42.ER_CDF_OES_VEHICLE__c                   = f42EntryData.ER_cdfoesVehicle == 'Yes' ? true : false;
                f42.ER_FEMA_CODES__c                        = f42EntryData.ER_femaCode;
                f42.ER_SPECIAL_EQUIPMENT__c                 = f42EntryData.ER_specialEquipment.Special_Equipment_Type__c;

                //12-12
                f42.PI_NUMBER_OF_PERSONNEL_ON_APPARATUS__c  = f42EntryData.PI_numberofPersonnel;
                f42.PI_DOCUMENTATION_ONLY__c                = f42EntryData.PI_documentationOnly == 'Yes' ? true : false;

                //15-16 Supply Number
                f42.SN_LOSS_DAMAGE_CLAIM__c                 = f42EntryData.LD_claim == 'Yes' ? true : false;
                f42.SN_SUPPLY_NUMBER__c                     = f42EntryData.SN_supplyNumber;
                
                //17. RESPONDING AGENCY INFORMATION
                f42.RA_AGENCY_NAME__c                       = f42EntryData.RA_agencyName;
                f42.RA_YOUR_NAME__c                         = f42EntryData.RA_yourName;
                f42.RA_YOUR_PHONE__c                        = f42EntryData.RA_yourPhone;
                f42.RA_YOUR_TITLE__c                        = f42EntryData.RA_yourTitle;
                //18. PAYING AGENCY
                f42.PA_PAYING_AGENCY__c                     = f42EntryData.PA_payingAgency;
                f42.PA_OTHER__c                             = f42EntryData.PA_payingAgencyOther;
                f42.PA_PRINTED_NAME__c                      = f42EntryData.PA_printedName;
                f42.PA_DATE__c                              = f42EntryData.PA_printedNameDate;
                f42.PA_ICS_POSITION_TITLE__c                = f42EntryData.PA_icsPosition;
                f42.PA_OTHER_POSITION_TITLE__c              = f42EntryData.PA_otherIcsPosition;
                f42.PA_Cal_OES_REPRESENTATIVE__c            = f42EntryData.PA_caloesRep;
                f42.PA_CALOESREP_DATE__c                    = f42EntryData.PA_caloesRepDate;

                f42.Name                                    = f42EntryData.strikeTeam+'-'+f42EntryData.incidentRequestNumber;
                f42.Status__c                               = 'CALOES REVIEW';
                if(string.isNotBlank(QueueId)){
                    f42.OwnerId                             = QueueId;
                }
                f42.F42_Entry__c                            = entry.Id; 
                f42.Submitted_Year__c                       = String.valueOf(Date.today().year());
    
                F42__c f;
                for(string s: macsIdtoAccountIdMap.keySet()){
                    f = f42.clone(false,false,false,false);
                    if(!OESonlyPresent && OESEquipPresent && s == 'OES'){
                        f.OH_OVERHEAD_TYPE__c                     = '';
                        f.OH_ICS_Title__c                         = '';
                        f.OH_OTHER_ICS_TITLE__c                   = '';
                        //9. SUPPORT VEHICLE INFO
                        f.SV_VEHICLE_OWNERSHIP__c                 = '';
                        f.SV_LICENSE__c                           = '';
                        f.SV_TYPE__c                              = '';
                        //10. PRIVATELY OWNED VEHICLE
                        f.SV_BEGINNING_ODODMETER__c               = null;
                        f.SV_ENDING_ODOMETER__c                   = null;
                        //15-16 Supply Number
                        f.SN_LOSS_DAMAGE_CLAIM__c                 = false;
                        f.SN_SUPPLY_NUMBER__c                     = '';
                    }
                    if(!OESonlyPresent && !OESEquipPresent && s == 'OES'){ //this is coming from Personnel Info
                        //8. OVERHEAD
                        f.OH_OVERHEAD_TYPE__c                     = '';
                        f.OH_ICS_Title__c                         = '';
                        f.OH_OTHER_ICS_TITLE__c                   = '';
                        //9. SUPPORT VEHICLE INFO
                        f.SV_VEHICLE_OWNERSHIP__c                 = '';
                        f.SV_LICENSE__c                           = '';
                        f.SV_TYPE__c                              = '';
                        //10. PRIVATELY OWNED VEHICLE
                        f.SV_BEGINNING_ODODMETER__c               = null;
                        f.SV_ENDING_ODOMETER__c                   = null;
                        //11. EQUIPMENT RESOURCE INFO
                        f.ER_APPARATUS__c                         = '';
                        f.ER_TYPE__c                              = '';
                        f.ER_UNIT__c                              = '';
                        f.ER_LICENSE_NUMBER__c                    = '';
                        f.ER_CDF_OES_VEHICLE__c                   = false;
                        f.ER_FEMA_CODES__c                        = null;
                        f.ER_SPECIAL_EQUIPMENT__c                 = '';
                        //15-16 Supply Number
                        f.SN_LOSS_DAMAGE_CLAIM__c                 = false;
                        f.SN_SUPPLY_NUMBER__c                     = '';
                       
                    }

                    if(!OESonlyPresent && OESEquipPresent && s != 'OES'){ //This is coming from Equipment info
                        //11. EQUIPMENT RESOURCE INFO
                        //f.ER_APPARATUS__c                         = '';
                        f.ER_TYPE__c                              = '';
                       // f.ER_UNIT__c                              = ''; Commenting this because unit number should be present on the local government F-42
                        //f.ER_LICENSE_NUMBER__c                    = '';
                        f.ER_CDF_OES_VEHICLE__c                   = false;
                        f.ER_FEMA_CODES__c                        = null;
                        f.ER_SPECIAL_EQUIPMENT__c                 = '';
                    }
                    f.Account__c = macsIdtoAccountIdMap.get(s);
                    f.Name = s+'-'+f.Name;
                    f42List.add(f);
                }

                insert f42List;
                map<string,string> accIdtof42IdMap = new map<string,string>();
                for(F42__c f42e: [SELECT Id, Account__r.MACS_ID__c FROM F42__c WHERE Id IN: f42List]){
                    accIdtof42IdMap.put(f42e.Account__r.MACS_ID__c, f42e.Id);
                }

            
                //12 Personnel Info
                set<string> p2pFalseIds = new set<string>();
                F_42_Personnel_Info__c pInfo;
                for(MARS_F42Entry_Ctrl.PersonnelInfo pi: f42EntryData.personnelInfoList){
                    pInfo                   = new F_42_Personnel_Info__c();
                    pInfo.F_42__c           = accIdtof42IdMap.get(pi.MACSID);                                //f42.Id;
                    pInfo.Name              = pi.fullName;
                    pInfo.MACS_ID__C        = pi.MACSID;
                    pInfo.SSN__c            = pi.ssn;
                    pInfo.Rank_Job_Title__c = pi.jobTitle;
                    pInfo.Start_Date__c     = pi.startDate;
                    pInfo.Start_Time__c     = pi.startTime;
                    pInfo.End_Date__c       = pi.endDate;
                    pInfo.End_Time__c       = pi.endTime;
                    if(pi.p2p != null){
                        pInfo.Portal_To_Portal__c = pi.p2p;
                    }
                    if(pi.cdf != null){
                        pInfo.CDF__c = pi.cdf;
                    }
                    if(pi.baseRate != null){
                        pInfo.Base_Rate__c = pi.baseRate;
                    }
                    
                    if(pInfo.Portal_To_Portal__c == false){
                        p2pFalseIds.add(pInfo.F_42__c);
                    }
                    personnelInfo.add(pInfo);
                }

                F_42_Personnel_Info__c pInfoOther;
                for(MARS_F42Entry_Ctrl.PersonnelInfo pi: f42EntryData.otherpersonnelInfoList){
                    pInfoOther                   = new F_42_Personnel_Info__c();
                    pInfoOther.F_42__c           = accIdtof42IdMap.get(pi.MACSID); //f42.Id;
                    pInfoOther.Name              = pi.fullName;
                    pInfoOther.MACS_ID__C        = pi.MACSID;
                    pInfoOther.SSN__c            = pi.ssn;
                    pInfoOther.Rank_Job_Title__c = pi.jobTitle;
                    pInfoOther.Start_Date__c     = pi.startDate;
                    pInfoOther.Start_Time__c     = pi.startTime;
                    pInfoOther.End_Date__c       = pi.endDate;
                    pInfoOther.End_Time__c       = pi.endTime;
                    pInfoOther.IS_Job_Title_Other__c = true;
                    
                    if(pi.cdf != null){
                        pInfoOther.CDF__c = pi.cdf;
                    }
                    if(pi.baseRate != null){
                        pInfoOther.Base_Rate__c = pi.baseRate;
                    }
                    p2pFalseIds.add(pInfoOther.F_42__c);
                    personnelInfo.add(pInfoOther);
                }

                insert personnelInfo;

                //13. Actual Hours
                F_42_Actual_Hours__c ah;
                for(MARS_F42Entry_Ctrl.ActualHours ach: f42EntryData.actualHoursList){
                    for(string s: p2pFalseIds){
                        ah                  = new F_42_Actual_Hours__c();
                        ah.F_42__c          = s;
                        ah.Hours__c         = ach.totalHours;
                        ah.Date__c          = ach.dayOfHours;
                        ah.Start_Time__c    = ach.startTime;
                        ah.End_time__c      = ach.endTime;
                        actualHours.add(ah);
                    }
                
                }

                insert actualHours;

                //14. Comments
                F_42_Comment__c comment;
                for(MARS_F42Entry_Ctrl.CommentWrapper comm: f42EntryData.comments){
                    for(F42__c fx : f42List){
                        comment             = new F_42_Comment__c();
                        comment.F_42__c     = fx.Id;
                        comment.Comment__c  = comm.comment;
                        comment.Date__c     = comm.dateofComment;
                        comment.Time__c     = comm.timeofComment;
                        comments.add(comment);
                    }
                    
                }

                insert comments;

                //Share files
                ContentDocumentLink link;
                for(ContentDocumentLink l: [SELECT ContentDocumentId FROM ContentDocumentLink
                                            WHERE LinkedEntityId=: entry.Id]){
                    for(F42__c fs : f42List){
                        link                   = new ContentDocumentLink();
                        link.ContentDocumentId = l.ContentDocumentId;
                        link.LinkedEntityId    = fs.Id;
                        link.ShareType         = 'I';
                        link.Visibility        = 'AllUsers';
                        f42Files.add(link);
                    }
                    
                }

                insert f42Files;

                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                            WHERE DeveloperName='Publish_Notification'];
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('New F-42 is Submitted');
                notification.setBody('New F-42 is Submitted for INCIDENT '+f42EntryData.incidentRequestNumber+' by strike team '+f42EntryData.strikeTeam);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(f42List[0].Id);
                if(!userIds.isEmpty()){
                    notification.send(userIds);
                }

                f42EntryData = new MARS_F42Entry_Ctrl.F42EntryWrapper(); 
                f42EntryData.loggedinUser               = [SELECT Id, Name, Phone, ContactId FROM User WHERE Id = :Userinfo.getUserId() LIMIT 1];
                f42EntryData.agency                     = [SELECT Id, Name, MACS_ID__c,ShippingState,Mars_Agency_Designator__c FROM Account WHERE Id=: entry.Account__c LIMIT 1];
                f42EntryData.incident                   = new Incident__c();
                f42EntryData.dispatchInfoIncident       = new Incident__c();
                f42EntryData.dispatchFromIncident       = new Incident__c();
                f42EntryData.dispatchToIncident         = new Incident__c();
                f42EntryData.OH_icsTitle                = new ICS_Title__c();
                f42EntryData.ER_specialEquipment        = new Agency_Special_Equipment_Line_Item__c();
                f42EntryData.personnelInfoList          = new list<MARS_F42Entry_Ctrl.PersonnelInfo>();
                f42EntryData.otherpersonnelInfoList     = new list<MARS_F42Entry_Ctrl.PersonnelInfo>();
                f42EntryData.actualHoursList            = new list<MARS_F42Entry_Ctrl.ActualHours>();
                f42EntryData.comments                   = new list<MARS_F42Entry_Ctrl.CommentWrapper>();
                f42EntryData.RA_agencyName              = f42EntryData.agency.Name;
                f42EntryData.RA_yourName                = f42EntryData.loggedinUser.Name;
                f42EntryData.RA_yourPhone               = f42EntryData.loggedinUser.Phone;

                return f42EntryData;
            }
        }catch (exception e){
            throw new AuraHandledException('An unexpected error occurred: '+e.getMessage()+'Stack trace is '+e.getStackTraceString());
        }
    }




    /***********************************************
    * Method Name : apexSearchIncident
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Incidents
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIncident(String searchTerm, List<String> selectedIds) {
        String query = 'Select Id,Name,Order_No__c,Declaration_Number__c From Incident__c WHERE Available_for_Application__c includes (\'MARS\') ';
        searchTerm = searchTerm.replace(' ','%');
      
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Order_No__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + '20';
        List<Incident__c> incidents = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String icon = 'utility:dialing';
        for (Incident__c inc : incidents) {
            results.add(
                    new LookupSearchResult(
                            inc.Id,
                            'Incident__c',
                            icon,
                            inc.Name,
                            'Order #'+inc.Order_No__c+' Declaration #'+inc.Declaration_Number__c,
                            inc
                    )
            );
        }

        results.sort();
        return results;
    }

    /***********************************************
    * Method Name : apexSearchIcsTitle
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Incidents
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIcsTitle(String searchTerm, List<String> selectedIds) {
        String query = 'Select Id,Name,Description__c From ICS_Title__c WHERE IsActive__c = true ';
        searchTerm = searchTerm.replace(' ','%');
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Description__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + '20';
       
        List<ICS_Title__c> titles = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String icon = 'standard:groups';
        for (ICS_Title__c inc : titles) {
            results.add(
                    new LookupSearchResult(
                            inc.Id,
                            'ICS_Title__c',
                            icon,
                            inc.Name,
                            inc.Description__c,
                            inc
                    )
            );
        }

        results.sort();
        return results;
    }

     /***********************************************
    * Method Name : apexSearchSpecialEquipment
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Incidents
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchSpecialEquipment(String searchTerm, List<String> selectedIds, string agencyId) {
        String query = 'Select Id,Name,Special_Equipment_Type__c,Description__c From Agency_Special_Equipment_Line_Item__c WHERE Status__c = \'Active\' AND Agency_Special_Equipment__r.Agency__c =:agencyId AND Agency_Special_Equipment__r.Approval_Status__c = \'Reviewed\' ';
        searchTerm = searchTerm.replace(' ','%');
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Special_Equipment_Type__c like\'%' + searchTerm + '%\')';
        }
        query += ' Limit ' + '20';
        system.debug('QUERY '+query);
        List<Agency_Special_Equipment_Line_Item__c> specialEquipments = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String icon = 'utility:lightning_extension';
        for (Agency_Special_Equipment_Line_Item__c eq : specialEquipments) {
            results.add(
                    new LookupSearchResult(
                            eq.Id,
                            'Agency_Special_Equipment_Line_Item__c',
                            icon,
                            eq.Special_Equipment_Type__c,
                            eq.Description__c,
                            eq
                    )
            );
        }

        results.sort();
        return results;
    }

     /***********************************************
    * Method Name : apexSearchRank
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Salary Survey related to the Current agency
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchRank(String searchTerm, List<String> selectedIds, string agencyId) {
        String query = 'Select Id,Classification_Title__c,P_T_P__c From Salary_Survey_Line_Items__c WHERE Agency_Salary_Survey__r.Account__r.MACS_ID__c =:agencyId ';
        query += ' AND Agency_Salary_Survey__r.Status__c = \'Reviewed\' ';
        searchTerm = searchTerm.replace(' ','%');
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Classification_Title__c like\'%' + searchTerm + '%\')';
        }
        query += ' Limit ' + 50;
        System.debug('Query '+query);
        List<Salary_Survey_Line_Items__c> items = Database.query(query);


        String nonsupquery = 'Select Id,Classification_Title__c From Agency_Non_Suppression_Line_Item__c WHERE Agency_Non_Suppression_Personnel__r.Agency__r.MACS_ID__c =:agencyId ';
        nonsupquery += ' AND Agency_Non_Suppression_Personnel__r.Approval_Status__c = \'Reviewed\' ';
        if(String.isNotEmpty(searchTerm)) {
            nonsupquery += ' AND ( Classification_Title__c like\'%' + searchTerm + '%\')';
        }
        query += ' Limit ' + 50;
        System.debug('nonsupquery '+nonsupquery);

        List<Agency_Non_Suppression_Line_Item__c> nonSupitems = Database.query(nonsupquery);

        for(Agency_Non_Suppression_Line_Item__c nonsup: nonSupitems){
            items.add(new Salary_Survey_Line_Items__c(Classification_Title__c = nonsup.Classification_Title__c, P_T_P__c = false
            ));
        }

        set<string> ptpRanks = new set<string>();

        for(Agency_Rate_Agreement_Line_Item__c ag: [SELECT Id, Name, OT__c,PTP__c 
                                                    FROM Agency_Rate_Agreement_Line_Item__c 
                                                    WHERE Agency_Rate_Agreement__r.Agency__r.MACS_ID__c =:agencyId
                                                    AND Agency_Rate_Agreement__r.Approval_Status__c  = 'Approved'
                                                    AND PTP__c = true]){
            for(string name: ag.Name.split(';')){
                ptpRanks.add(name); 
            }                                             
        }
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'utility:money';
        integer i=0;
        for (Salary_Survey_Line_Items__c item : items) {
            i++;
            if(ptpRanks.contains(item.Classification_Title__c)){
                item.P_T_P__c = true;
            }else{
                item.P_T_P__c = false;
            }
            results.add(
                    new LookupSearchResult(
                        'a0U35000001kaoPEA'+i,
                        'Rank or Title',
                        accountIcon,
                        item.Classification_Title__c,
                        null,
                        item
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    /***********************************************
    * Method Name : apexSearchFireAgency
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Fire Agency but exclude the 
                    ones that user already has access to or pending approval on
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFireAgency(String searchTerm, List<String> selectedIds) {
        String fireAgency = 'Fire Agency';
        String query = 'Select Id,Name,MACS_ID__c, Mars_Agency_Designator__c From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + fireAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR MACS_ID__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + 500;
        List<Account> accounts = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
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
		system.debug('results: '+results);
        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    /***********************************************
    * Method Name : apexSearchFemaCode
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from FEMA CODE LINE Item table with status as active
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFemaCode(String searchTerm, List<String> selectedIds) {
        String query = 'SELECT Id,Name, Equipment__c, HP__c,Current_Rate__c FROM FEMA_Code_LineItem__c WHERE FEMA_Code__r.Status__c = \'Active\' ';
        searchTerm = searchTerm.replace(' ','%');
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR Equipment__c  like\'%' + searchTerm + '%\' )';
        }
        query += ' Limit ' + 50;
        system.debug('Query '+query);
        List<FEMA_Code_LineItem__c> lineItems = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String icon = 'utility:lightning_extension';
        for (FEMA_Code_LineItem__c code : lineItems) {
            results.add(
                    new LookupSearchResult(
                            code.Id,
                            'FEMA CODE',
                            icon,
                            code.Name,
                            code.Equipment__c+', HP-'+code.HP__c,
                            code
                    )
            );
        }
		system.debug('results: '+results);
        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    public class F42EntryWrapper{
        @AuraEnabled
        public string           f42Id{get; set;}
        @AuraEnabled
        public User             loggedinUser {get; set;}
        @AuraEnabled
        public Account          agency{get;set;}
        @AuraEnabled
        public string           strikeTeam{get;set;}
        @AuraEnabled
        public Incident__c      incident{get;set;}
        @AuraEnabled
        public string           incidentRequestNumber{get;set;}
        @AuraEnabled
        public Incident__c      dispatchInfoIncident{get;set;}
        @AuraEnabled
        public string           DI_reportingLocation {get; set;}
        @AuraEnabled
        public date             DI_committedtoIncident {get; set;}
        @AuraEnabled
        public string           DI_committedtoIncidentTime {get; set;}
        @AuraEnabled
        public date             DI_returnfromIncident {get; set;}
        @AuraEnabled
        public string           DI_returnfromIncidentTime {get; set;}
        @AuraEnabled
        public date             DI_reDispatched{get; set;}
        @AuraEnabled
        public string           DI_reDispatchedTime{get; set;}
        @AuraEnabled
        public string           DI_mobilizationCenter {get; set;}
        @AuraEnabled
        public Incident__c      dispatchFromIncident{get;set;}
        @AuraEnabled
        public date             DF_endDate{get; set;}
        @AuraEnabled
        public string           DF_incidentRequestNumber{get; set;}
        @AuraEnabled
        public Incident__c      dispatchToIncident{get;set;}
        @AuraEnabled
        public date             DT_startDate{get; set;}
        @AuraEnabled
        public string           DT_incidentRequestNumber{get; set;}
        @AuraEnabled
        public string           LD_claim{get; set;}
        @AuraEnabled
        public string           OH_overheadType{get;set;}
        @AuraEnabled
        public ICS_Title__c     OH_icsTitle {get; set;}
        @AuraEnabled
        public string           OH_otherICStitle {get; set;}
        @AuraEnabled
        public string           SV_vehicleOwnership{get; set;}
        @AuraEnabled
        public string           SV_licenseplateNumber {get; set;}
        @AuraEnabled
        public string           SV_vehicleType {get; set;}
        @AuraEnabled
        public string           ER_type {get; set;}
        @AuraEnabled
        public string           ER_apparatus {get; set;}
        @AuraEnabled
        public string           ER_unitNumber {get; set;}
        @AuraEnabled
        public string           ER_licenseNumber {get; set;}
        @AuraEnabled
        public string           ER_cdfoesVehicle {get; set;}
        @AuraEnabled
        public Agency_Special_Equipment_Line_Item__c ER_specialEquipment{get; set;}
        @AuraEnabled
        public string           ER_femaCode {get; set;}
        @AuraEnabled
        public string           PI_numberofPersonnel {get; set;}
        @AuraEnabled
        public string           PI_documentationOnly {get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl.PersonnelInfo> personnelInfoList {get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl.PersonnelInfo> otherpersonnelInfoList {get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl.ActualHours> actualHoursList {get; set;}
        @AuraEnabled
        public string           PO_odometerStart {get;set;}
        @AuraEnabled
        public string           PO_odometerEnd {get; set;}
        @AuraEnabled
        public string           PO_totalMiles {get;set;}
        @AuraEnabled
        public string           SN_supplyNumber{get; set;}
        @AuraEnabled
        public string           RA_agencyName{get; set;}
        @AuraEnabled
        public string           RA_yourName{get; set;}
        @AuraEnabled
        public string           RA_yourTitle{get; set;}
        @AuraEnabled
        public string           RA_yourPhone{get; set;}
        @AuraEnabled
        public string           RA_signURL{get; set;}
        @AuraEnabled
        public string           PA_payingAgency{get; set;}
        @AuraEnabled
        public string           PA_payingAgencyOther{get; set;}
        @AuraEnabled
        public string           PA_printedName{get; set;} 
        @AuraEnabled
        public date             PA_printedNameDate{get; set;} 
        @AuraEnabled
        public string           PA_icsPosition{get; set;}
        @AuraEnabled
        public string           PA_otherIcsPosition{get; set;}
        @AuraEnabled
        public string           PA_caloesRep{get; set;}
        @AuraEnabled
        public date             PA_caloesRepDate{get; set;} 
        @AuraEnabled
        public string           PA_signURL{get; set;}
        @AuraEnabled
        public list<MARS_F42Entry_Ctrl.CommentWrapper>  comments{get; set;}
        
        public F42EntryWrapper(){
    
        }

    }

    public class PersonnelInfo{
        @AuraEnabled
        public string fullName {get; set;}
        @AuraEnabled
        public string MACSID {get; set;}
        @AuraEnabled
        public string jobTitle {get; set;}
        @AuraEnabled
        public string ssn {get; set;}
        @AuraEnabled
        public Date startDate {get; set;}
        @AuraEnabled
        public string startTime {get; set;}
        @AuraEnabled
        public Date endDate {get; set;}
        @AuraEnabled
        public string endTime {get; set;}
        @AuraEnabled
        public Boolean cdf {get; set;}
        @AuraEnabled
        public Boolean p2p {get; set;}
        @AuraEnabled
        public Boolean p2pDisabled {get; set;}
        @AuraEnabled
        public string base {get; set;}
        @AuraEnabled
        public Boolean baseRate {get; set;}
        @AuraEnabled
        public boolean editable {get; set;}
        @AuraEnabled
        public boolean readOnly {get; set;}
       
    }

    public class ActualHours{
        @AuraEnabled
        public Date dayOfHours {get; set;}
        @AuraEnabled
        public string startTime {get; set;}
        @AuraEnabled
        public string endTime {get; set;}
        @AuraEnabled
        public Decimal totalHours {get; set;}
       
    }

    public class CommentWrapper{
        @AuraEnabled
        public date dateofComment {get; set;}
        @AuraEnabled
        public string timeofComment {get; set;}
        @AuraEnabled
        public string comment{get; set;}
    }

    public class f42Draft{
        @AuraEnabled
        public string Id {get; set;}
        @AuraEnabled
        public string macsID {get; set;}
        @AuraEnabled
        public string incidentName {get; set;}
        @AuraEnabled
        public string status {get; set;}
        @AuraEnabled
        public Datetime lastmodifiedDate {get; set;}
        @AuraEnabled
        public string lastmodifiedBy {get; set;}
    }
}