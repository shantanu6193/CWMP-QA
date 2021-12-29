/**
 * Created by PREM on 29-03-2020.
 */

({
    doInit : function(component, event, helper){
        component.set('v.loaded', false);
        helper.retrieveProducts(component, event, helper);
        var action = component.get('c.getProducts');
        //todo- - move to helper class
        action.setCallback(this, function(response) {
            var state = response.getState();
            var productFamily = [];
            if (state === 'SUCCESS') {
                //todo - remove all console. there should be one debug in do init. no other debugs required
                console.log('response----',response.getReturnValue());
                let products = response.getReturnValue().Products;
                component.set('v.products', products);
                let productsMap = component.get('v.productsMap');
                productsMap={};
                console.log('productsMap---', productsMap);
                for(let i = 0 ; i < products.length ; i++){
                   // console.log('products[i].Id---', products[i].Id);
                  //  console.log('products[i].Name---', products[i]);
                    productsMap[products[i].Id] = products[i];
                    if(products[i].Name == 'Other'){
                        component.set('v.otherproductId', products[i].Id);
                    }
                    if(!productFamily.includes(products[i].Family)){
                        productFamily.push(products[i].Family);
                    }
                }
                component.set("v.productFamily", productFamily);
                console.log('productsMap---', productsMap);
                component.set('v.productsMap', productsMap);

                if(component.get('v.orderRec.Is_this_a_Medical_Staffing_Request__c') == 'Yes') {
                    component.set('v.showGACHQuestion',true);
                }
                if(component.get('v.orderRec.Is_this_for_a_GACH__c') == 'Yes') {
                    component.set('v.showGACHSubQuestions',true);
                }

                /*helper.getPicklistValues(component, event, helper,'Order__c','Bed_to_staff_ratio_bed_staff__c','bedToStaffOptions');*/
                helper.getPicklistValues(component, event, helper,'Order__c','Does_site_need_personnel_to_keep_ICU__c','keepICUOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Total_ICU_beds_occupied__c','totalBedsOccupiedOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Have_you_attempted_to_transfer_patients__c','transferPatientsOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Have_you_cancelled_all_surgeries__c','cancelledSurgeriesOptions');
                //helper.getPicklistValues(component, event, helper,'Order__c','Is_your_emergency_dept_on_diversion__c','diversionOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Do_you_have_an_active_staffing_waiver__c','staffingWaiverOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Would_you_be_able_to_accept_transfers__c','acceptTransfersOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Is_this_for_a_GACH__c','gachOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Is_this_a_Medical_Staffing_Request__c','staffingRequestOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Allows_additional_ICU_or_M_S_T_beds__c','additionalMSTBedsOptions');
                helper.getPicklistValues(component, event, helper,'Order__c','Average_time_of_T_to_T_for_ESI_Cat_3__c','ESICatOptions');

                component.set('v.loaded', true);
                console.log('loaded---', component.get('v.loaded'));
            } else {
                console.log('Error---', response.getError());
            }
        })
        $A.enqueueAction(action);
        let orderItems = component.get('v.orderItems');
        if(orderItems.length == 0) {
            let item = {};
            orderItems.push(item);
            component.set('v.orderItems', orderItems);
        }
    },
    addNewRow : function(component, event, helper){
        let items = component.get('v.orderItems');
        let item = {};
        items.push(item);
        component.set('v.orderItems', items);
        console.log('------',items);
    },
    deleteRow : function(component, event, helper){
        let index = event.currentTarget.id;
        console.log('-index-----',index);
        if(index != undefined){
            let items = component.get('v.orderItems');
            items.splice(index,1);
            if(items.length == 0) {
                let item = {};
                items.push(item);
            }
            component.set('v.orderItems', items);
            console.log('------',items);
        }
    },
    setItemCode: function(component, event, helper){
        let items = JSON.parse(JSON.stringify(component.get('v.orderItems')));
        let productsMap = JSON.parse(JSON.stringify(component.get('v.productsMap')));
        console.log('items------',items);
        console.log('productsMap------',productsMap);
        for(let i = 0 ; i < items.length ; i++){
            console.log('items------',items[i]);
            let productCode2Id = items[i].Product2Id;
            console.log('productCode2Id------',productCode2Id);
            let product = productsMap[productCode2Id];
            console.log('product------',product);
            if(product.Name != 'Other'){
	            items[i].Item_Code__c = product.ProductCode;
	            console.log('items[i]------',items[i]);
            }
        }
        component.set('v.orderItems', items);
    },
    checkValidation : function(component, event) {
        debugger;
            var allValid = true;
            var childComp = component.find('order_row');
            if(childComp == undefined) return false;
            if(childComp.length != undefined) {
                for(let i=0; i < childComp.length; i++) {
                    let value = childComp[i].orderRowValidation();
                    if(value == false) {
                        allValid = false;
                    }
                }
            }
            else {
                let value = childComp.orderRowValidation();
                if(value == false) {
                    allValid = false;
                }
            }
            return allValid;
        },
    handleMedicalStaffingChange : function(component, event, helper) {
        let value = event.getParam("value");
        if(value == 'Yes') {
            component.set('v.showGACHQuestion',true);
        }
        else {
            component.set('v.showGACHQuestion',false);
            component.set('v.showGACHSubQuestions',false);
            component.set('v.orderRec.Bed_to_staff_ratio_bed_staff__c','');
            component.set('v.orderRec.Does_site_need_personnel_to_keep_ICU__c','');
            component.set('v.orderRec.Total_ICU_beds_occupied__c','');
            component.set('v.orderRec.Have_you_attempted_to_transfer_patients__c','');
            component.set('v.orderRec.Have_you_cancelled_all_surgeries__c','');
            //component.set('v.orderRec.Is_your_emergency_dept_on_diversion__c','');
            component.set('v.orderRec.Do_you_have_an_active_staffing_waiver__c','');
            component.set('v.orderRec.Would_you_be_able_to_accept_transfers__c','');
            component.set('v.orderRec.Is_this_for_a_GACH__c','' );
            //component.set('v.orderRec.Patients_in_ED_awaiting_admit_transfer__c','' );
            component.set('v.orderRec.How_many_total_staff_are_you_requesting__c','');
            component.set('v.orderRec.Allows_additional_ICU_or_M_S_T_beds__c','');
            component.set('v.orderRec.Average_time_of_T_to_T_for_ESI_Cat_3__c','');
        }
    },
    handleGACHChange : function(component, event, helper) {
        let value = event.getParam("value");
        if(value == 'Yes') {
            component.set('v.showGACHSubQuestions',true);
        }
        else {
            component.set('v.showGACHSubQuestions',false);
            component.set('v.orderRec.Bed_to_staff_ratio_bed_staff__c','');
            component.set('v.orderRec.Does_site_need_personnel_to_keep_ICU__c','');
            component.set('v.orderRec.Total_ICU_beds_occupied__c','');
            component.set('v.orderRec.Have_you_attempted_to_transfer_patients__c','');
            component.set('v.orderRec.Have_you_cancelled_all_surgeries__c','');
            //component.set('v.orderRec.Is_your_emergency_dept_on_diversion__c','');
            component.set('v.orderRec.Do_you_have_an_active_staffing_waiver__c','');
            component.set('v.orderRec.Would_you_be_able_to_accept_transfers__c','');
            //component.set('v.orderRec.Patients_in_ED_awaiting_admit_transfer__c','' );
            component.set('v.orderRec.How_many_total_staff_are_you_requesting__c','');
            component.set('v.orderRec.Allows_additional_ICU_or_M_S_T_beds__c','');
            component.set('v.orderRec.Average_time_of_T_to_T_for_ESI_Cat_3__c','');
        }
    },
    handlePersonalChange : function (component, event, helper) {
        let value = component.get('v.orderRec.Personnel__c');
        if(value == false) {
            component.set('v.orderRec.Is_this_a_Medical_Staffing_Request__c','');
            component.set('v.orderRec.Is_this_for_a_GACH__c','');
            component.set('v.orderRec.Bed_to_staff_ratio_bed_staff__c','');
            component.set('v.orderRec.Does_site_need_personnel_to_keep_ICU__c','');
            component.set('v.orderRec.Total_ICU_beds_occupied__c','');
            component.set('v.orderRec.Have_you_attempted_to_transfer_patients__c','');
            component.set('v.orderRec.Have_you_cancelled_all_surgeries__c','');
            //component.set('v.orderRec.Is_your_emergency_dept_on_diversion__c','');
            component.set('v.orderRec.Do_you_have_an_active_staffing_waiver__c','');
            component.set('v.orderRec.Would_you_be_able_to_accept_transfers__c','');
            //component.set('v.orderRec.Patients_in_ED_awaiting_admit_transfer__c','' );
            component.set('v.orderRec.How_many_total_staff_are_you_requesting__c','');
            component.set('v.orderRec.Allows_additional_ICU_or_M_S_T_beds__c','');
            component.set('v.orderRec.Average_time_of_T_to_T_for_ESI_Cat_3__c','');
        }
        else {
            component.set('v.showGACHQuestion',false);
            component.set('v.showGACHSubQuestions',false);
        }
    }
});