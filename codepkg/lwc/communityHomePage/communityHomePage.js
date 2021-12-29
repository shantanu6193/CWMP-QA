import { LightningElement,track,wire } from 'lwc';
import logoResource from '@salesforce/resourceUrl/AppLogos';
import appLogo from '@salesforce/resourceUrl/Common_Community_Resource';
import Utility from 'c/utility';
import getAllApplications from '@salesforce/apex/CommunityHomePageCtrl.getAllApplications';
import accepteTermsAndPolicy from '@salesforce/apex/CommunityHomePageCtrl.accepteTermsAndPolicy';
import { RecordFieldDataType } from 'lightning/uiRecordApi';
import strUserId from '@salesforce/user/Id';
export default class CommunityHomePage extends Utility {

    phosLogo = appLogo + '/PHOS.jpg';
    hmaLogo = appLogo + '/HMA.jpg';
    hhLogo = appLogo + '/HH.jpg';
    sealLogo = appLogo + '/announcementLogo/SEAL.png';
    cdphLogo = appLogo + '/CDPH-Logo.jpg';
    caRespondsLogo = appLogo + '/CA-Responds-Banner.jpg';
    governorLogo = appLogo + '/other/Governor.png';
    directorLogo = appLogo + '/other/Director.jpg';
    grantsManagementLogo = appLogo + '/Popular_Contents/Grants_Management.png'
    CSTILogo = appLogo + '/Popular_Contents/CSTI.png'
    homelandSecurityLogo = appLogo + '/Popular_Contents/Homeland-Security.png'
    internshipLogo = appLogo + '/Popular_Contents/internshipicon.png'
    newsMedia = appLogo + '/Popular_Contents/News_Media.png'
    PSCLogo = appLogo + '/Popular_Contents/PSC.png'
    spanishiconLogo = appLogo + '/Popular_Contents/spanishicon.png'
    STACLogo = appLogo + '/Popular_Contents/STAC.png'


    @track applicationList = [];
    announcementList = [];
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded
    @track isModalOpen = false;
    @track selectedApp = '';
    @track selectedAppId = '';
    @track userId = strUserId;
    @track userRegistrationInfo = [];
    @track isPhos;
    contactRecord;
    @track isNotifyModalOpen = false;
    isRejected = false;
    isAccepted = false;

    /*
        * Get application list, announcements and checked user has permission for specific app
    */
    @wire(getAllApplications)
    wiredApplications({ error, data }) {
        if (data) {
            let applicationListLocal = JSON.parse(JSON.stringify(data.Apps));
            this.announcementList = JSON.parse(JSON.stringify(data.Announcements));
            //this.userRegistrationInfo = JSON.parse(JSON.stringify(data.userRegistrationInfo));
            console.log('userRegistrationInfo---------',data);
            this.contactRecord = data.ContactDetails;
            this.isTermsPolicyAccepted(data.isTermsPolicyAccepted);
            //console.log('userRegistrationInfo---------',JSON.stringify(this.userRegistrationInfo));
            for(let i=0; i<applicationListLocal.length; i++) {
                applicationListLocal[i].showLogo = true;
                applicationListLocal[i].Logo_Name__c = appLogo + '/appLogo/' + applicationListLocal[i].Logo_Name__c;
                applicationListLocal[i].sentForApproval = false;
                if(applicationListLocal[i].Community_Application_to_Users__r) {
                    applicationListLocal[i].login = true;
                } else {
                    if(applicationListLocal[i].CommunityRegistration__r != undefined && applicationListLocal[i].CommunityRegistration__r.length > 0){
                        applicationListLocal[i].sentForApproval = true;
                    }
                    applicationListLocal[i].login = false;
                }
            }
            for(let i=0;i<this.announcementList.length;i++){
                this.announcementList[i].Image__c = appLogo + '/announcementLogo/' + this.announcementList[i].Image__c;          
            }
            this.applicationList = applicationListLocal;
        } else if (error) {
            this.showErrorNotification('Error', error);
        }
    }
    
    onBlur(event) {
        let selectedIndex = event.currentTarget.dataset.index;
        this.applicationList[selectedIndex].showLogo = true;
    }

    onFocus(event) {
        let selectedIndex = event.currentTarget.dataset.index;
        this.applicationList[selectedIndex].showLogo = false;
    }
    
    /*
        * Open registration modal on the basis of app
    */
    registerForApp(event) {
        let selectedIndex = event.currentTarget.dataset.index;
        this.selectedApp = this.applicationList[selectedIndex].Name;
        this.selectedAppId = this.applicationList[selectedIndex].Id;
        this.isModalOpen = true;
        /*console.log('userId--------',this.userId);
        getProcessStatus({'userId': this.userId}).then(result=>{
            console.log('result----->',result.userRegistrationStatus[0]);
           // this.isPhos = true;
            this.userRegistrationStatus = result.userRegistrationStatus[0].Status__c;
        }).catch(error=>{
            console.log('error-->',error);
        });*/
    }
     
    /*
        * Redirect to community on the basis of app
    */
    gotoApp(event) {
        let selectedIndex = event.currentTarget.dataset.index;
        let appURL = this.applicationList[selectedIndex].App_URL__c;
        window.location.href = appURL;
    }

    /*
        * Check whether selected app is PHOS
    */
    get isPHOSApp() {
        if(this.selectedApp == 'PHOS') return true;
        return false;
    }

    /*
        * Check whether selected app is HMA
    */
    get isHMAApp() {
        if(this.selectedApp == 'HMA') return true;
        return false;
    }

    /*
        * Check whether selected app is MARS
    */
   get isMARSApp() {
        if(this.selectedApp == 'MARS') return true;
        return false;
    }


     /*
        * Check whether selected app is HH
    */
   get isHHApp() {
        if(this.selectedApp == 'CWMP') return true;
        return false;
    }
    

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    /*
        * Close Modal
    */
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    rejectHandle(){
        this.isNotifyModalOpen = false;
        //isRejected = false;
        //isAccepted = false;
    }
    acceptHandle(){
        this.isNotifyModalOpen = false;
        let paramMap;
        this.executeAction(accepteTermsAndPolicy, paramMap, (response) => {           
        })
    }
    closeNotifyModal(){
        this.isNotifyModalOpen = false;
    }    
    /*
        check user accepted terms condition or not
    */
    isTermsPolicyAccepted(response){      
       if(response == false){
            this.isNotifyModalOpen = true;
       }
    }
}