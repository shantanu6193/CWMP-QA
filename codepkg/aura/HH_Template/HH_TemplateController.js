/**
 * Created by Pankaj on 11-03-2021.
 */

 ({
    doInit : function(component, event, helper) {
        try{
                var relativeUrl = $A.get("$Label.c.HH_Community_Relative_Url");
            console.log('Relative: ',relativeUrl);
                component.set('v.hhCommunityRelativeUrl', relativeUrl);
            component.set('v.submitApplicationUrl',relativeUrl+'/s/check-draft-applications');
            component.set('v.applicationsUrl',relativeUrl+'/s/hh-application/HH_Application__c?HH_Application__c-filterId=All');
                component.set('v.homeUrl',relativeUrl+'/s/');
            component.set('v.viewReportsUrl',relativeUrl+'/s/report/Report/Recent');
            component.set('v.viewDashboardsUrl',relativeUrl+'/s/dashboard/Dashboard/Recent');
            window.addEventListener('resize', $A.getCallback(function(){
                let windowWidth = screen.width;
                let footer = document.getElementById('footer');
                let footerHeight = footer.clientHeight;
                let contentWrap = document.getElementById('content-wrap');
                contentWrap.style.paddingBottom = footerHeight + 16 + 'px';
        }));
        helper.getUserName(component,event,helper);
        }catch(e) {
            console.log('Error in PA Temp==>',e)
        }
    },
    handleDropdownClick : function(component, event, helper) {
        let dropdownCmp = component.find('dropdown');
        let dropdown = document.getElementById('dropdown');
        if(dropdown.className.includes('slds-is-open')) {
            window.setTimeout(
                $A.getCallback(function() {
            $A.util.addClass(dropdownCmp, 'slds-is-close');
            $A.util.removeClass(dropdownCmp, 'slds-is-open');
                }), 500
           );
        }
        else {
            $A.util.addClass(dropdownCmp, 'slds-is-open');
            $A.util.removeClass(dropdownCmp, 'slds-is-close');
        }
    },

    handleDropdownClick1 : function(component, event, helper) {
        let dropdownCmp = component.find('dropdown1');
        let dropdown = document.getElementById('dropdown1');
        if(dropdown.className.includes('slds-is-open')) {
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(dropdownCmp, 'slds-is-close');
                    $A.util.removeClass(dropdownCmp, 'slds-is-open');
                }), 500
           );
        }
        else {
            $A.util.addClass(dropdownCmp, 'slds-is-open');
            $A.util.removeClass(dropdownCmp, 'slds-is-close');
        }
    },

    handleDropdownBlur : function(component, event, helper) {
        let dropdownCmp = component.find('dropdown');
        let dropdown = document.getElementById('dropdown');
        if(dropdown.className.includes('slds-is-open')) {
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(dropdownCmp, 'slds-is-close');
                    $A.util.removeClass(dropdownCmp, 'slds-is-open');
                }), 500
           );
        }
    },

    handleDropdownBlur1 : function(component, event, helper) {
        let dropdownCmp = component.find('dropdown1');
        let dropdown = document.getElementById('dropdown1');
        if(dropdown.className.includes('slds-is-open')) {
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(dropdownCmp, 'slds-is-close');
                    $A.util.removeClass(dropdownCmp, 'slds-is-open');
                }), 500
           );
        }
    },

    doneRendering: function(component, event, helper) {
        try{
            //console.log('======in render template=====');
            let windowWidth = screen.width;
            let footer = document.getElementById('footer');
            let footerHeight = footer.clientHeight;
            let contentWrap = document.getElementById('content-wrap');
            contentWrap.style.paddingBottom = footerHeight + 16 + 'px';
        }
        catch(e){
            console.log(e);
        }
    }
});