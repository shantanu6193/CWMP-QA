({
    doInit: function (component, event, helper) {
        window.addEventListener('resize', $A.getCallback(function () {
            let windowWidth = screen.width;
            let footer = document.getElementById('footer');
            let footerHeight = footer.clientHeight;
            let contentWrap = document.getElementById('content-wrap');
            contentWrap.style.paddingBottom = footerHeight + 16 + 'px';
        }));

        let action = component.get("c.checkPermission");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                component.set("v.showUserRegistration", response.getReturnValue().UserRegPermission);
            } else {
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Information!",
                            "mode": 'sticky',
                            "type": 'info',
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
        });

        $A.enqueueAction(action);
    },
    handleDropdownClick: function (component, event, helper) {
        let dropdownCmp = component.find('dropdown');
        let dropdown = document.getElementById('dropdown');

        console.log('======in render template=====');

        if (dropdown.className.includes('slds-is-open')) {
            $A.util.addClass(dropdownCmp, 'slds-is-close');
            $A.util.removeClass(dropdownCmp, 'slds-is-open');
        } else {
            $A.util.addClass(dropdownCmp, 'slds-is-open');
            $A.util.removeClass(dropdownCmp, 'slds-is-close');
        }
    },
    doneRendering: function (component, event, helper) {
        try {
            let windowWidth = screen.width;
            let footer = document.getElementById('footer');
            let footerHeight = footer.clientHeight;
            let contentWrap = document.getElementById('content-wrap');
            contentWrap.style.paddingBottom = footerHeight + 16 + 'px';
        } catch (e) {
            console.log(e);
        }
    },
    requestNewAgencyClick: function (component, event, helper) {
        var userAgency = component.find('marsUserAgencyAccess');
        //console.log('###: comp: ' + JSON.stringify(userAgency));
        //userAgency.handleAgencyRequest(event);
        userAgency.handleAgencyRequest();
    }
});