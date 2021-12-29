/***********************************************************************************************************************************
* Class Name   : TriggerHelper
* Description  : This is TriggerHelper class for handle the events
* Author       : Pankaj
* Created On   : 04/07/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                04/07/2020       Initial Implementation
**************************************************************************************************************************************/

global virtual with sharing class TriggerHelper {

        global static Boolean skipTrigger = Boolean.valueOf(KeyValueHelper.getTextValue('Skip_Trigger'));
        global static Boolean skipFieldHistoryTrigger = false;
        global void process() {
            if (!skipTrigger) {
                if(Trigger.isBefore){
                    if(Trigger.isInsert){
                        processBeforeInsert();
                    }
                    else if(Trigger.isUpdate){
                        processBeforeUpdate();
                    }
                    else if(Trigger.isDelete){
                        processBeforeDelete();
                    }
                    else if(Trigger.isUndelete){
                        processBeforeUndelete();
                    }
                }
                else if(Trigger.isAfter){
                    if(Trigger.isInsert){
                        processAfterInsert();
                    }
                    else if(Trigger.isUpdate){
                        processAfterUpdate();
                    }
                    else if(Trigger.isDelete){
                        processAfterDelete();
                    }
                    else if(Trigger.isUndelete){
                        processAfterUndelete();
                    }
                    if(skipFieldHistoryTrigger == false) {
                        HistoryTrackerHelper.processFieldTracking();
                    }
                }
            }

        }

        /* The following methods can be overridden in the sub classes as per the need */

        global virtual void processBeforeInsert() {}
        global virtual void processBeforeUpdate() {}
        global virtual void processBeforeDelete() {}
        global virtual void processBeforeUndelete() {}
        global virtual void processAfterInsert() {}
        global virtual void processAfterUpdate() {}
        global virtual void processAfterDelete() {}
        global virtual void processAfterUndelete() {}

        /* PRIVATE METHODS */


    }