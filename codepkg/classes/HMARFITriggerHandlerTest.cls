@isTest
public with sharing class HMARFITriggerHandlerTest {
    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFIType() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'OES BCA');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFITypeOESPROG() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'OES PROGRAMMATIC');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFITypeFEMAPROG() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'FEMA PROGRAMMATIC');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFITypeFEMAEHP() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'FEMA EHP');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFITypeFEMA() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'FEMA OES EHP');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testSetDefaultRFIStatusAccordingToRFITypeFEMAOESPROG() {
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, app.Id, 2, 'FEMA OES PROGRAMMATIC');
        Test.startTest();
        insert rfi;
        Test.stopTest();
    }

    @isTest
    public static void testRfiUpdateNONFEMA() {
        User analystUser = HMA_TestHelper.getInternalUser(true, 'HMA_Analyst');
        System.runAs(analystUser) {
            Contact portalCon = HMA_TestHelper.getPortalContact(true);
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'Responsible Representative';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
            Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 1, 'OES BCA');

            Test.startTest();
            HMA_RFISendEmailNotifications obj = new HMA_RFISendEmailNotifications();
            /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Sent to Subapplicant
             */
            rfi.Status__c = 'Sent to Subapplicant';
            update rfi;

            /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Time Extension Requested
             */
            rfi.Status__c = 'Time Extension Requested';
            update rfi;

            /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Time Extension Accepted
             */
            rfi.RFI_Deadline__c = Date.TODAY()+2;
            rfi.Status__c = 'Time Extension Accepted';
            update rfi;  
            
             /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Response Submitted
             */
            rfi.Status__c = 'Response Submitted';
            update rfi;
            
            /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Response Accepted
             */
            rfi.Status__c = 'Response Accepted';
            update rfi;

             /**Used for Cover Code from HMA_RFISendEmailNotifications with
             * RFI_Type = NON-FEMA
             * Status__c = Time Extension Rejected
             */
            rfi.Status__c = 'Time Extension Requested';
            update rfi;
            rfi.Status__c = 'Time Extension Rejected';
            update rfi;
            Test.stopTest();
        }        
    }

    @isTest
    public static void testRfiUpdateFEMA() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        newApplication.Status__c = 'FEMA Review';
        update newApplication;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;         
    
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'FEMA Programmatic Analyst';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 1, 'FEMA OES Programmatic');

        Test.startTest();
        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = Submitted to Cal OES Analyst
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.Status__c = 'Submitted to Cal OES Analyst';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Time Extension Requested
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.Status__c = 'FEMA Time Extension Requested';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Time Extension Requested
         * RFI_TYPE__c = FEMA OES EHP
         */
        rfi.RFI_TYPE__c = 'FEMA OES EHP';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Time Extension Accepted
         * RFI_TYPE__c = FEMA OES EHP
         */
        rfi.Status__c = 'FEMA Time Extension Accepted';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = Response Submitted by Cal OES Analyst
         * RFI_TYPE__c = FEMA OES EHP
         */
        rfi.Status__c = 'Response Submitted by Cal OES Analyst';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = Response Submitted by Cal OES Analyst
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.RFI_TYPE__c = 'FEMA OES Programmatic';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Programmatic RFI Accepted
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.Status__c = 'FEMA Programmatic RFI Accepted';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Programmatic RFI Rejected
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.Status__c = 'FEMA Programmatic RFI Rejected';
        update rfi;

        /**Used for Cover Code from HMA_RFISendEmailNotifications with
         * RFI_Type = FEMA
         * Status__c = FEMA Time Extension Rejected
         * RFI_TYPE__c = FEMA OES Programmatic
         */
        rfi.Status__c = 'FEMA Time Extension Rejected';
        update rfi;

        Test.stopTest();
    }

    @isTest
    public static void testRfiBeforeInsert() {
        User managerUser = HMA_TestHelper.getInternalUser(true, 'HMA_Manager');
        System.runAs(managerUser) {
            Contact portalCon = HMA_TestHelper.getPortalContact(true);
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            newApplication.Status__c = 'FEMA Review';
            update newApplication;
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;         
        
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'FEMA Programmatic Analyst';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
            try {
                Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 1, 'FEMA OES Programmatic');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You do not have permission to create RFI Types'));
            }
        }
    }

    @isTest
    public static void testRfiBeforeInsert1() {
        User managerUser = HMA_TestHelper.getInternalUser(true, 'HMA_Manager');
        System.runAs(managerUser) {
            Contact portalCon = HMA_TestHelper.getPortalContact(true);
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            newApplication.Status__c = 'Draft';
            newApplication.Status_Reason__c = 'In Progress';
            update newApplication;
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;         
        
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'FEMA Programmatic Analyst';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
            try {
                Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, -1, 'FEMA EHP');
            } catch (Exception e) {
                System.assert(e.getMessage().contains('RFI Deadline cannot be a past date'));
            }
        }
    }

    @isTest
    public static void testRfiAfterInsertElse() {

        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User portalUser = HMA_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalCon.Id;
        insert portalUser;
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        newApplication.Status__c = 'Draft';
        newApplication.Status_Reason__c = 'In Progress';
        update newApplication;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;         
    
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'Responsible Representative';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;
        
        Test.startTest();
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 1, 'FEMA EHP');
        Test.stopTest();
    }
}