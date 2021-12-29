({  
    //On page load below method is call. It is used to get json array data from server side controller.
    doInit: function (component, event, helper) {
        debugger;
        var action = component.get('c.getReportData');

        action.setCallback(this, function(response){
            var state = response.getState();
            var res = response.getReturnValue();
            console.log('res',res);
            if(state === 'SUCCESS') {
                component.set("v.reportTypes", res.reports);
            } else if (state === "ERROR") {
                var errors = response.getError();
                let errorMsg = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("libraryController.js -- Error message: " +
                                 errors[0].message);
                        errorMsg = errors[0].message;
                    }
                }else{
                    errorMsg = 'Unknown error';
                    console.log("libraryController.js -- Unknown error");

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: errorMsg,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();
                }

            } else {
                console.log('libraryController.js -- Unknown error')
                $A.util.toggleClass(spinner, "slds-hide");
            }
        });
        $A.enqueueAction(action);

    },

    onChangeVal: function(cmp,event,helper){
        let val = event.getSource().get("v.value");
        if(val == 'SELECT') {
            cmp.set('v.selectedReportId', '');
            cmp.set('v.selectedTimeFilter', 'SELECT');
            cmp.set("v.selectedStartDate","");
            cmp.set("v.selectedEndDate","");
        }
        helper.validatedata(cmp);
    },
    onChangeReportType: function(cmp,event,helper){
        //let val = event.getSource().get("v.value");
        let val = cmp.get('v.selectedReportId');
        let reportData = cmp.get("v.reportTypes");
        for(let index=0; index < reportData.length; index++) {
            if(val == reportData[index].Id){
                 let naturalLanguageText = reportData[index]['Report_Help_Text__c'];
                 if(naturalLanguageText != null){
                   cmp.set("v.naturalLanguage",naturalLanguageText);
                 }else{
                    cmp.set("v.naturalLanguage","");
                 }
            }

        }

        if(val == '') {
            cmp.set('v.selectedTimeFilter', 'SELECT');
            cmp.set("v.selectedStartDate","");
            cmp.set("v.selectedEndDate","");
            cmp.set("v.naturalLanguageToDisplay","");

        }else{
             helper.handleStaticTextChange(cmp);
        }
        helper.validatedata(cmp);
    },
    onFilterChangeVal: function(cmp,event,helper){

        let val = event.getSource().get("v.value");
        let d=new Date();        
        let cmpStartDate = cmp.find("startdate");
        let cmpEndDate = cmp.find("enddate");
        cmpStartDate.setCustomValidity("");
        cmpEndDate.setCustomValidity("");
        cmpStartDate.reportValidity();
        cmpEndDate.reportValidity();
        
        if(val!=="Custom" && val!=="SELECT"){
            if(val==="Today"){
                cmp.set("v.selectedStartDate",d.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",d.toISOString().substring(0,10));
            }
            if(val==="YESTERDAY"){
                
                let priorDate = new Date();
                priorDate.setDate(priorDate.getDate() - 1);
                let yesterday_date=priorDate.getFullYear()+"-"+(priorDate.getMonth()+1)+"-"+priorDate.getDate();
                cmp.set("v.selectedStartDate",priorDate.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",priorDate.toISOString().substring(0,10));
            }
            if(val==="THIS WEEK"){
                let today = new Date;
                let day = today.getDay();
                let firstday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (day == 0?-6:1)-day );
                cmp.set("v.selectedStartDate",firstday.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",today.toISOString().substring(0,10));
            }
            if(val==="LAST WEEK"){
                let today = new Date;
                let day = today.getDay();
                let firstday = new Date(today.getFullYear(), today.getMonth(), today.getDate() + (day == 0?-6:1)-(day+7) );
                let lastday=new Date(today.getFullYear(), today.getMonth(), today.getDate() + (day == 0?-6:1)-(day+1) );
                cmp.set("v.selectedStartDate",firstday.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",lastday.toISOString().substring(0,10));
            }
            if(val==="THIS MONTH"){
                let today=new Date();
                cmp.set("v.selectedEndDate",today.toISOString().substring(0,10));
                today.setDate(1);                
                cmp.set("v.selectedStartDate",today.toISOString().substring(0,10));
                
            }
            if(val==="LAST MONTH"){
                let today = new Date();
                let priorDate = new Date();
                priorDate.setDate(0);
                cmp.set("v.selectedEndDate",priorDate.toISOString().substring(0,10));
                priorDate.setDate(1);
                cmp.set("v.selectedStartDate",priorDate.toISOString().substring(0,10));
            }
            if(val==="LAST 90 DAYS"){
                let today = new Date();
                let priorDate = new Date();
                priorDate.setDate(priorDate.getDate() - 90);
                cmp.set("v.selectedStartDate",priorDate.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",today.toISOString().substring(0,10));
            }
            if(val==="LAST 365 DAYS"){
                let today = new Date();
                let priorDate = new Date();
                priorDate.setDate(priorDate.getDate() - 365);
                cmp.set("v.selectedStartDate",priorDate.toISOString().substring(0,10));
                cmp.set("v.selectedEndDate",today.toISOString().substring(0,10));
            }
            cmp.set('v.reportDisabled', false);
            helper.handleStaticTextChange(cmp);



        }else{
            cmp.set('v.reportDisabled', true);
            cmp.set("v.selectedStartDate","");
            cmp.set("v.selectedEndDate","");
            
        }
        //helper.validatedata(cmp);
        console.log('value of filter :',val);
        
    },

    handleViewClick : function(cmp,event,helper){
        debugger;

        let reportURLAction = cmp.get("c.generatingReportURL");

        reportURLAction.setParams({
            reportId: cmp.get("v.selectedReportId"),
            shipToEntityId: cmp.get("v.selectedShipToEntity"),
            timeFilter: cmp.get("v.selectedTimeFilter"),
            startDate: cmp.get("v.selectedStartDate"),
            endDate: cmp.get("v.selectedEndDate")
        });

        reportURLAction.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                console.log("Success message: " +
                                            response.getReturnValue());
                window.open(response.getReturnValue(), "_blank");
            }else if (response.getState() === "ERROR"){
                let errors = response.getError();
                let errorMsg = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        errorMsg = errors[0].message;
                    }
                } else {
                    console.log("Unknown error");
                    errorMsg = "Unknown error";
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: errorMsg,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(reportURLAction);
    },
    closeReportTabEvent : function(cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        var appEvent = $A.get("e.c:ReportCloseAppEvent");
        appEvent.setParams({
            "reportclose" : false});
        appEvent.fire();

        var navService = cmp.find('navService');
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                name: "Home"
            }
        };
        navService.navigate(pageReference);
    },

    handleDateChange : function(cmp,event,helper){

        let evtsource = event.getSource();
        let evtvalue= evtsource.get("v.value");
        let evtlabel=evtsource.get("v.label");
        let filtervalue=cmp.get("v.selectedTimeFilter");
        let today=new Date();
        let validdate=true;
        

        if(filtervalue!=="Custom"){
            cmp.set("v.selectedTimeFilter","Custom");
        }

        let startDate = new Date(cmp.get("v.selectedStartDate"));
        let endDate = new Date(cmp.get("v.selectedEndDate"));
        let cmpStartDate = cmp.find("startdate");
        let cmpEndDate = cmp.find("enddate");
        cmpStartDate.setCustomValidity("");
        cmpEndDate.setCustomValidity("");

        if(startDate > endDate) {
            cmpStartDate.setCustomValidity("From date should be less than To date");
            validdate=false;
        } else if(startDate > today) {
           cmpStartDate.setCustomValidity("From date should be less than today's date");
           validdate=false;
        } else {
            cmpStartDate.setCustomValidity("");
        }
        cmpStartDate.reportValidity();

        if(endDate < startDate) {
            cmpEndDate.setCustomValidity("To date should be greater than From date");
            validdate=false;
        } else if(endDate > today) {
             cmpEndDate.setCustomValidity("To date cannot be greater than today's date");
             validdate=false;
        } else {
            cmpEndDate.setCustomValidity("");
        }
        cmpEndDate.reportValidity();

        if(cmp.get("v.selectedStartDate") == null || cmp.get("v.selectedStartDate")==="" || cmp.get("v.selectedEndDate") == null || cmp.get("v.selectedEndDate")===""){
            validdate=false;
        }


        if(validdate===true){

            cmp.set("v.reportDisabled",false);
            helper.handleStaticTextChange(cmp);
        }else{
            cmp.set("v.reportDisabled",true);
        }
        
    },


})