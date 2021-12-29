global with sharing class ReplyChainEmailServicesHandler implements Messaging.InboundEmailHandler {
    global ReplyChainEmailServicesHandler() {

    }

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          try {
              System.debug('Recived Mail...');

            String fromAddress = email.fromAddress;
            System.debug('From Address Val....'+fromAddress);

            String htmlBodyVal = email.htmlBody;
            System.debug('Html Body Val====='+htmlBodyVal);

            String plainBodyVal = email.plainTextBody;
            System.debug('plain text body val====='+plainBodyVal);

            String subjectVal = email.subject;
            System.debug('Subject Val==='+subjectVal);

        List<String> toAddressesList = email.toAddresses;
        String toAddressesStr = String.join(toAddressesList, ';');
        //String toAddress = email.toAddresses;
        // System.debug('To Address Val------'+toAddress);

            String recId = '';
        String addressToGenNotification = '';

            if(String.isNotBlank(htmlBodyVal)){
                if(htmlBodyVal.contains('[ Ref:')){
                    recId = htmlBodyVal.substringAfter('[ Ref: ').substringBefore(' ]').trim();
                }
            } 

            if(String.isNotBlank(plainBodyVal) && String.isBlank(recId)){
                if(plainBodyVal.contains('[ Ref:')){
                    recId = plainBodyVal.substringAfter('[ Ref: ').substringBefore(' ]').trim();
                }
            }

        if(String.isNotBlank(plainBodyVal) && String.isBlank(addressToGenNotification)) {
            if(plainBodyVal.contains('[ RefToEmail:')){
                addressToGenNotification = plainBodyVal.substringAfter('[ RefToEmail: ').substringBefore(' :Email]').trim();
            }
        }

        // System.debug('RecordId Val======'+recId);
        // System.debug('To Addresses Val======'+toAddresses);

            // new email object to be created
            EmailMessage newEmailMessage = new EmailMessage();
            newEmailMessage.RelatedToId = recId;
            newEmailMessage.htmlBody =  String.isNotBlank(htmlBodyVal) ? htmlBodyVal : plainBodyVal;
            newEmailMessage.subject =  subjectVal;
            newEmailMessage.status = '3';
            newEmailMessage.IsExternallyVisible = true;
            //newEmailMessage.fromAddress = ;
            newEmailMessage.fromAddress = fromAddress;
        //String toAddressesStr = toAddresses;//String.join(toAddresses, ',');
        System.debug('toAddresses----'+toAddressesStr);
        newEmailMessage.ToAddress = toAddressesStr;
            String[] toIds = new String[]{recId};   
            newEmailMessage.toIds = toIds; 
            
            newEmailMessage.ThreadIdentifier = email.messageId;
            insert newEmailMessage;


            // Handling of Text Attachments along Email through InboundEmail Object....
            
            List<ContentVersion> cvList = new List<ContentVersion>();
            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
            if(email.textAttachments !=null){
                System.debug('Email Text Attachments flow.....');
                for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                    ContentVersion testContentInsert = new ContentVersion();
                    testContentInsert.Title = tAttachment.fileName;
                    testContentInsert.VersionData = Blob.valueOf(tAttachment.body);
                    testContentInsert.PathOnClient = '/' + tAttachment.fileName ;
                    cvList.add(testContentInsert);
                }
                insert cvList;
                List<Id> idList = new List<Id>(new Map<Id, ContentVersion>(cvList).keySet());
                System.debug('Collection of CV Id List===='+idList);
                cvList = [select id, ContentDocumentId from ContentVersion WHERE Id in :idList];
                for (ContentVersion cv : cvList) {
                        ContentDocumentLink cl = new ContentDocumentLink();
                        cl.ContentDocumentId = cv.ContentDocumentId;
                        cl.LinkedEntityId = recId; //Shared with record ID
                        cl.ShareType = 'V';
                        cl.Visibility = 'AllUsers';
                        cdlList.add(cl);

                    //This contentDocumentLink is for email message
                    ContentDocumentLink contentDocEmailMessageAttachmentLink = new ContentDocumentLink();
                    contentDocEmailMessageAttachmentLink.ContentDocumentId = cv.ContentDocumentId;
                    contentDocEmailMessageAttachmentLink.LinkedEntityId = newEmailMessage.Id;
                    cdlList.add(contentDocEmailMessageAttachmentLink);

                }
                insert cdlList;
            }


            // Handling of binary Attachments along Email through InboundEmail Object....
             List<ContentVersion> cvBinaryList = new List<ContentVersion>();
            List<ContentDocumentLink> cdlBinaryList = new List<ContentDocumentLink>();
            if(email.binaryAttachments != null){
                System.debug('Email binaray Attachments flow.....');
                for(Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                    
                    ContentVersion testContentInsert = new ContentVersion();
                    testContentInsert.Title = bAttachment.fileName;
                    testContentInsert.VersionData = bAttachment.body;
                    testContentInsert.PathOnClient = '/' + bAttachment.fileName ;
                    cvBinaryList.add(testContentInsert);
                }
                insert cvBinaryList;
                List<Id> idList = new List<Id>(new Map<Id, ContentVersion>(cvBinaryList).keySet());
                System.debug('Collection of CV Id List===='+idList);
                cvBinaryList = [select id, ContentDocumentId from ContentVersion WHERE Id in :idList];
                for (ContentVersion cv : cvBinaryList) {
                    /*This contentDocumentLink is for parent record.
                    Example : If this component is configured on application__c then attachment will be
                                linked to application record
                    */
                    ContentDocumentLink contentDocParentRecordLink = new ContentDocumentLink();
                    contentDocParentRecordLink.ContentDocumentId = cv.ContentDocumentId;
                        
                    contentDocParentRecordLink.LinkedEntityId = recId; //Shared with record ID
                    System.debug('Linked Enity Val===='+contentDocParentRecordLink.LinkedEntityId);
                       // cl.ShareType = 'V';
                       // cl.Visibility = 'AllUsers';
                    cdlBinaryList.add(contentDocParentRecordLink);

                    //This contentDocumentLink is for email message
                    ContentDocumentLink contentDocEmailMessageAttachmentLink = new ContentDocumentLink();
                    contentDocEmailMessageAttachmentLink.ContentDocumentId = cv.ContentDocumentId;
                    contentDocEmailMessageAttachmentLink.LinkedEntityId = newEmailMessage.Id;
                    cdlBinaryList.add(contentDocEmailMessageAttachmentLink);

                }
                insert cdlBinaryList;

            }

        //Email Message system notification for HMA Manager and HMA Analyst
        List<String> addressesstoGenerateNotifications = addressToGenNotification.split(';');

        generateNotificationsForHMAManagerAnalyst(addressesstoGenerateNotifications, recId, newEmailMessage);

            // Add Email Message Relation for id of the sender
            // EmailMessageRelation emailMsgRelation = new EmailMessageRelation();
            // emailMsgRelation.EmailMessageId = newEmailMessage.id;
            // //emailMsgRelation.RelationId = userId here;
            // emailMsgRelation.RelationAddress = UserInfo.getUserEmail();
            // emailMsgRelation.RelationType = 'FromAddress';
            // insert emailMsgRelation;
            result.success = true;
          } catch (Exception ex) {
                result.success = false;
                result.message = 'Oops, I failed. Error : '+ex.getMessage();  
          }  
        return result;
      }

    private static void generateNotificationsForHMAManagerAnalyst(List<String> toAddresses, String recId, EmailMessage newEmailMessage) {
        System.debug('list of emails to generate notifications---'+toAddresses);
        Set<String> uniqueEmailAddresses = new Set<String>();
        Map<String, User> emailtoUserMap = new Map<String, User>();
        if(toAddresses.size() < 0) return;
        uniqueEmailAddresses.addAll(toAddresses);

        //Get recId
        String appName = '';
        if(String.isNotBlank(recId) && recId.startsWith('a0A')) {
            appName = [SELECT Name, Id FROM Application__c WHERE Id = :recId]?.Name;
        }

        List<User> existingUsers = [SELECT Email,Id,u.UserRole.Name 
                                            FROM User u 
                                            WHERE 
                                                ((u.UserRole.Name = 'HMA Manager' OR u.UserRole.Name = 'HMA Analyst') AND 
                                                (Email IN :uniqueEmailAddresses))];

        for(User u : existingUsers) {
            emailtoUserMap.put(u.Email, u);
        }
        
        List<FeedItem> notifications = new List<FeedItem>();
        if(emailtoUserMap.size() > 0) {
            for(String emailForNotification : emailtoUserMap.keySet()) {
                FeedItem post = new FeedItem();
                post.ParentId = emailtoUserMap.get(emailForNotification).Id;
                post.Body = 'Email from '+emailForNotification+' for Application '+appName;
                post.Title = 'Email Notification';
                post.LinkUrl = '/lightning/r/EmailMessage/' + newEmailMessage.Id + '/view';
                notifications.add(post);
            }
            if(notifications.size() > 0) insert notifications;
        }
    }
}