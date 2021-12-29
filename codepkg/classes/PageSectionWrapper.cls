/**
 * Created by harsh on 27-01-2021.
 */

public with sharing class PageSectionWrapper implements Comparable{
    @AuraEnabled
    public Page_Section__mdt pageSectionObj;
    public PageSectionWrapper(Page_Section__mdt  pageSection){
        pageSectionObj = pageSection;
    }

    public Integer compareTo(Object compareTo) {
        // Cast argument to PageSectionWrapper
        PageSectionWrapper compareToPageSection = (PageSectionWrapper)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (pageSectionObj.Sequence__c > compareToPageSection.pageSectionObj.Sequence__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (pageSectionObj.Sequence__c < compareToPageSection.pageSectionObj.Sequence__c) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((pageSectionObj.Sequence__c == null) && (compareToPageSection.pageSectionObj.Sequence__c != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((pageSectionObj.Sequence__c != null) && (compareToPageSection.pageSectionObj.Sequence__c == null)){
            // nulls-first implementation
            returnValue = 1;
        }
        return returnValue;
    }
}