import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';


import Name from '@salesforce/schema/HH_Application__c.Name';
import Stage__c from '@salesforce/schema/HH_Application__c.Stage__c';
import Status__c from '@salesforce/schema/HH_Application__c.Status__c';
import City__c from '@salesforce/schema/HH_Application__c.City__c';
import Property_Street_Address__c from '@salesforce/schema/HH_Application__c.Property_Street_Address__c';
import State__c from '@salesforce/schema/HH_Application__c.State__c';
import Zip_Postal_Code__c from '@salesforce/schema/HH_Application__c.Zip_Postal_Code__c';
import County__c from '@salesforce/schema/HH_Application__c.County__c';
import Year_of_Construction__c from '@salesforce/schema/HH_Application__c.Year_of_Construction__c';

export default class HhApplicationRecordViewForm extends Utility {

name = Name;
stage = Stage__c;
status = Status__c;
propertyAddress = Property_Street_Address__c;
city = City__c;
state = State__c;
county = County__c;
yoc = Year_of_Construction__c;
zipcode = Zip_Postal_Code__c;

@api recordId;
objectApiName = 'HH_Application__c';



handleToggleSection(event) {
	this.activeSectionMessage =
			'Open section name:  ' + event.detail.openSections;
}


}