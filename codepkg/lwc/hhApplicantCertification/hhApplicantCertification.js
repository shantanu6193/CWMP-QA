import { LightningElement,wire,track } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_Para_1_2_3 from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_Para_1_2_3';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_para_4 from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_para_4';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_Warning_Checkbox_Label from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_Warning_Checkbox_Label';
import HH_EN_Applicant_s_Certification_Message from '@salesforce/label/c.HH_EN_Applicant_s_Certification_Message';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_Disclaimer from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_Disclaimer';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_Title from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_Title';
export default class HhApplicantCertification extends Utility {
	isLoading = true;

	@track label = {
		HH_EN_Applicant_Certification_Right_of_Entry_Page_Title,
		HH_EN_Applicant_Certification_Right_of_Entry_Page_Para_1_2_3,
		HH_EN_Applicant_Certification_Right_of_Entry_Page_para_4,
		HH_EN_Applicant_Certification_Right_of_Entry_Page_Warning_Checkbox_Label,
		HH_EN_Applicant_s_Certification_Message,
		HH_EN_Applicant_Certification_Right_of_Entry_Page_Disclaimer
	}

	initData() {	

		
	}

	handleChecked(event)  {
			this.recordLocal.Agreement_Disclosure__c = event.target.checked;
			console.log('checked: '+event.target.checked);
	}

}