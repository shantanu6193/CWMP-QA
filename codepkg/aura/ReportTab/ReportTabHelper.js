({
	validatedata : function(component) {
		console.log('inside validatedata ');
		let disablebutton=true;
          if(component.get("v.selectedShipToEntity")==="SELECT" || component.get("v.selectedReportId")===""||
            component.get("v.selectedTimeFilter")==null || component.get("v.selectedTimeFilter")===""||
            component.get("v.selectedTimeFilter")==="SELECT" || cmp.get("v.selectedStartDate") == "" || cmp.get("v.selectedEndDate") == ""){
			disablebutton=true;
          }else{
			disablebutton=false;
		  }
		  component.set("v.reportDisabled",disablebutton);
	},

	handleStaticTextChange : function(cmp){
        let naturalLanguage = cmp.get("v.naturalLanguage");

        let startDate = $A.localizationService.formatDate(cmp.get("v.selectedStartDate"), "MM/dd/yyyy");
        let endDate = $A.localizationService.formatDate(cmp.get("v.selectedEndDate"), "MM/dd/yyyy");

        naturalLanguage = naturalLanguage.replace('{startdate}',startDate);
        naturalLanguage = naturalLanguage.replace('{enddate}',endDate);
        cmp.set("v.naturalLanguageToDisplay",naturalLanguage);
     }
})