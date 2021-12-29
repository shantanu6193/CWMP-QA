import { LightningElement, api, track, wire } from 'lwc';
import saveNewRecord from '@salesforce/apex/LookupSearchResult.saveNewRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search
import Utility from 'c/utility';

export default class Lookup extends Utility {
    @api label;
    @api required;
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems;
    @api customKey;
    @api loadDataOnInit = false;
    @api localSearch = false;
    @api createNewAccount = false;
    @api newRecordLabels = [];
    @api isDisabled = false;
    showModal = false;
    labelValueMap = {};
    @api objectName = '';
	@api defaultLocalSearchResult;
    value = '';
    @api searchTerm = '';
    @track searchResults = [];
    originalSearchResults;
    hasFocus = false;
    loading = false;
    isDirty = false;
    @track phoneValue;

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;
    curSelection = [];

    hasInitiated = false;
    _cancelBlur = false;



    connectedCallback() {
        //this.orderDetail = this.orderDetailUsingParameter.clone();
        console.log('data-----------',JSON.stringify(this.newRecordLabels));
        console.log('data-----------',this.newRecordLabels);
        /*try{
            for(let i=0; i < this.newRecordLabels.length; i++) {

                console.log('data-----------',this.newRecordLabels[i].type);

                this.newRecordLabels[i]['isText'] = false;
                //this.newRecordLabels[i].isPicklist = false;
                if(this.newRecordLabels[i].type == 'text') {
                    this.newRecordLabels[i]['isText'] = true;
                }
                if(this.newRecordLabels[i].type == 'picklist') {
                    //this.newRecordLabels[i].isPicklist = true;
                }
            }
            console.log('data-----------',JSON.stringify(this.newRecordLabels));
        }
        catch(e) {
            console.log(e);
        }*/

        if(this.hasInitiated == false) {
            this.hasInitiated = true;
            if(this.loadDataOnInit == true) {
                 this.fireEventToGetData('', []);
            }
        }
    }
    handleNewRecordClick() {
        try{
            console.log('test-----------');
            this.phoneValue = '';
        this.showModal = true;
        }
        catch(e){
            console.log(e);
        }
    }
    closeModal() {
        this.showModal = false;
    }

    // EXPOSED FUNCTIONS
    @api
    setSelection(initialSelection) {
        if(initialSelection == undefined) return;
        this.curSelection = Array.isArray(initialSelection) ? initialSelection : [initialSelection];
        this.isDirty = false;
    }
    
    @api
    set selection(initialSelection) {
        if(initialSelection == undefined) return;
        this.curSelection = Array.isArray(initialSelection) ? initialSelection : [initialSelection];
        this.isDirty = false;
    }
    get selection() {
        return this.curSelection;
    }

    get searchResult() {
        return this.searchResults;
    }

    onInitDataLoaded = false;

    @api
    setSearchResults(results) {
        // Reset the spinner
        this.loading = false;
        // Clone results before modifying them to avoid Locker restriction
        const resultsLocal = JSON.parse(JSON.stringify(results));

        if(this.onInitDataLoaded == false && this.originalSearchResults == undefined && this.localSearch == true) {
            this.onInitDataLoaded = true;
            this.originalSearchResults = JSON.parse(JSON.stringify(results));
        }
        // Format results
        this.searchResults = resultsLocal.map((result) => {
            // Clone and complete search result if icon is missing
            if (this.searchTerm.length > 0) {
                const regex = new RegExp(`(${this.searchTerm})`, 'gi');
                result.titleFormatted = result.title
                    ? result.title.replace(regex, '<strong>$1</strong>')
                    : result.title;
                result.subtitleFormatted = result.subtitle
                    ? result.subtitle.replace(regex, '<strong>$1</strong>')
                    : result.subtitle;
            } else {
                result.titleFormatted = result.title;
                result.subtitleFormatted = result.subtitle;
            }
            if (typeof result.icon === 'undefined') {
                const { id, sObjectType, title, subtitle } = result;
                return {
                    id,
                    sObjectType,
                    icon: 'standard:default',
                    title,
                    subtitle
                };
            }
            return result;
        });
    }

    @api
    getSelection() {
        return this.curSelection;
    }

    @api
    getkey() {
        return this.customKey;
    }

    // INTERNAL FUNCTIONS

    updateSearchTerm(newSearchTerm) {
        this.searchTerm = newSearchTerm;

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (this.cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Save clean search term
        //this.cleanSearchTerm = newCleanSearchTerm;
        this.cleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '');

        if(this.localSearch == true) {
            this.searchWithLocalData(newCleanSearchTerm, newSearchTerm);
        } else {
            this.searchOnServer(newCleanSearchTerm, newSearchTerm);
        }
    }

    searchWithLocalData(newCleanSearchTerm, newSearchTerm) {
        let resultsLocal = JSON.parse(JSON.stringify(this.originalSearchResults));
        if(newSearchTerm != undefined && newSearchTerm != '') {
            console.log('in if------');
            // in case we have to show any option by default. ex. In case of product search always show other option
            if(this.defaultLocalSearchResult != undefined) {
                resultsLocal = resultsLocal.filter((item) => {
                    return (
                        //Removed special characters from search term as well as local array of result for better results 
                        item.title.toLowerCase().replace(/[^a-zA-Z0-9]/g, "").includes(newSearchTerm.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")) ||
                        item.title.toLowerCase() == this.defaultLocalSearchResult.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")||
                        item.subtitle.toLowerCase().replace(/[^a-zA-Z0-9]/g, "").includes(newSearchTerm.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")) ||
                        item.subtitle.toLowerCase() == this.defaultLocalSearchResult.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")
                    );
                })
            } else {
                resultsLocal = resultsLocal.filter(arr => arr.title.toLowerCase().replace(/[^a-zA-Z0-9]/g, "").includes(newSearchTerm.toLowerCase().replace(/[^a-zA-Z0-9]/g, "")));
            }

        }
        // Format results
        this.searchResults = resultsLocal.map((result) => {
            // Clone and complete search result if icon is missing
            if (this.searchTerm.length > 0) {
                const regex = new RegExp(`(${this.searchTerm})`, 'gi');
                result.titleFormatted = result.title
                    ? result.title.replace(regex, '<strong>$1</strong>')
                    : result.title;
                result.subtitleFormatted = result.subtitle
                    ? result.subtitle.replace(regex, '<strong>$1</strong>')
                    : result.subtitle;
            } else {
                result.titleFormatted = result.title;
                result.subtitleFormatted = result.subtitle;
            }
            if (typeof result.icon === 'undefined') {
                const { id, sObjectType, title, subtitle } = result;
                return {
                    id,
                    sObjectType,
                    icon: 'standard:default',
                    title,
                    subtitle
                };
            }
            return result;
        });
    }

    searchOnServer(newCleanSearchTerm, newSearchTerm) {
        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this.searchThrottlingTimeout) {
            clearTimeout(this.searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchThrottlingTimeout = setTimeout(() => {
            // Send search event if search term is long enougth
            if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                // Display spinner until results are returned
                this.loading = true;

                this.fireEventToGetData(this.cleanSearchTerm, this.curSelection.map((element) => element.id));

            }
            this.searchThrottlingTimeout = null;
        }, SEARCH_DELAY);
    }

    fireEventToGetData(searchTerm, selectedIds) {
        const searchEvent = new CustomEvent('search', {
            detail: {
                searchTerm: searchTerm,
                selectedIds: selectedIds
            }
        });
        this.dispatchEvent(searchEvent);
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    hasResults() {
        return this.searchResults.length > 0;
    }

    hasSelection() {
        return this.curSelection.length > 0;
    }

    // EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;

        // Save selection
        let selectedItem = this.searchResults.filter((result) => result.id === recordId);
        if (selectedItem.length === 0) {
            return;
        }
        selectedItem = selectedItem[0];
        const newSelection = [...this.curSelection];
        newSelection.push(selectedItem);
        this.curSelection = newSelection;
        this.isDirty = true;

        // Reset search
        this.searchTerm = '';
        if(this.localSearch == false) {
            this.searchResults = [];
        }

        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange', { detail: {selectedItem}}));
    }

    handleComboboxMouseDown(event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this._cancelBlur = true;
        }
    }

    handleComboboxMouseUp() {
        this._cancelBlur = false;
        // Re-focus to text input for the next blur event
        this.template.querySelector('input').focus();
    }

    handleComboboxClick() {
        // Hide combobox immediatly
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
        this.hasFocus = false;
    }

    handleFocus() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.hasFocus = true;
    }

    handleChange(event) {
        let value = event.target.value;
        const searchEvent = new CustomEvent('searchtermchange', {
            detail: {
                searchTerm : value
            }
        });
        this.dispatchEvent(searchEvent);
    }

    handleBlur() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed() || this._cancelBlur) {
            return;
        }
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
            this.hasFocus = false;
            this.blurTimeout = null;
        }, 300);
    }

    handleRemoveSelectedItem(event) {
        const recordId = event.currentTarget.name;
        this.curSelection = this.curSelection.filter((item) => item.id !== recordId);
        this.isDirty = true;
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

	@api //Sravan added this to invoke clearing the selection when clear button is selected
    handleClearSelection() {
        if(this.isDisabled) return;
        this.curSelection = [];
        this.isDirty = true;
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    // STYLE EXPRESSIONS

    get getContainerClass() {
        let css = 'slds-combobox_container slds-has-inline-listbox ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        if (this.hasFocus && this.cleanSearchTerm && this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
            css += ' slds-is-open';
        }
        if(this.loadDataOnInit == true && this.hasFocus) {
            css += ' slds-is-open';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input has-custom-height ';
        if (this.errors.length > 0 || (this.isDirty && this.required && !this.hasSelection())) {
            css += 'has-custom-error ';
        }
        if (!this.isMultiEntry) {
            css += 'slds-combobox__input-value ' + (this.hasSelection() ? 'has-custom-border' : '');
        }
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += this.hasSelection() ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right';
        }
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += this.hasSelection() ? 'slds-hide' : '';
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return (
            'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
            (this.hasSelection() ? '' : 'slds-hide')
        );
    }

    get getSelectIconName() {
        return this.hasSelection() ? this.curSelection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon ' + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        if (this.isMultiEntry) {
            return this.searchTerm;
        }
        return this.hasSelection() ? this.curSelection[0].title : (this.searchTerm ? this.searchTerm : '');
    }

    get getInputTitle() {
        if (this.isMultiEntry) {
            return '';
        }

        return this.hasSelection() ? this.curSelection[0].title : '';
    }

    get getListboxClass() {
        return (
            'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid slds-scrollable ' +
            (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '')
        );
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasResults();
    }
    handleLabelOneChange(event) {
        try{
            console.log('handle event--->', JSON.parse(JSON.stringify(event.currentTarget.dataset.label)));
            let currentLabel = event.currentTarget.dataset.label;
            //this.labelValueMap[this.labelAPIMap[currentLabel]] = event.target.value;
            for(let i=0; i<this.newRecordLabels.length; i++) {
                if(this.newRecordLabels[i].label == currentLabel) {
                    this.labelValueMap[this.newRecordLabels[i].api] = event.target.value;
                }
            }
        } catch(e) {
            console.log(e);
        }
    }
    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant,
            mode : mode
        });
        this.dispatchEvent(event);
    }

    saveRecord() {
        const allValid = [...this.template.querySelectorAll('.modalInput')]
                    .reduce((validSoFar, inputField) => {
                        inputField.reportValidity();
                        return validSoFar && inputField.checkValidity();
                    }, true);
        console.log('allValid----',allValid);
        let phoneValid = this.handlePhoneValidation();
        if(allValid && phoneValid) {
            try{
                let paramMap = {};
                paramMap = this.labelValueMap;
                console.log('parmaMap---->',paramMap);

                //TODO create account with any number of parameters

                saveNewRecord({
                    objectName : this.objectName,
                    paramMap : paramMap
                }).then(res => {
                    console.log('res from save new record---', res);
                    this.showModal = false;
                    const title = 'Toast Successful';
                    const message = 'Record has been created';
                    const variant = 'success';
                    const mode = 'dismissable';
                    this.showToastMessage(title, message, variant, mode);
                    //Select New Account
                    // Save selection
                    console.log('save record----',res);
                    let selectedItem = res;
                    if (selectedItem == undefined) {
                        return;
                    }
                    const newSelection = [...this.curSelection];
                    newSelection.push(selectedItem);
                    this.curSelection = newSelection;
                    this.dispatchEvent(new CustomEvent('selectionchange', { detail: {selectedItem}}));
                }).catch(err => {
                    console.log('err from save new record ---', err);
                    this.showModal = false;
                    const title = err.body.pageErrors[0].message;
                    const message = err;
                    const variant = 'error';
                    const mode = 'dismissable';
                    this.showToastMessage(title, message, variant, mode);
                });
            } catch(e) {
                console.log(e);
            }
        }
    }
     handlePhoneValidation(event){
        var inp = this.template.querySelector(".phoneInput");
        this.phoneValue = inp.value;
        let number = this.phoneValue;
        let cleanedNumber = ('' + number).replace(/\D/g, '');
        let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
        let newNumber = '';
        let allValidPhone = true;
        if (phoneNumber) {
            newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
            console.log('newNumber',newNumber);
            this.phoneValue = newNumber;
        }

        let inputCmp = this.template.querySelector('.phoneInput');
        var value = this.phoneValue;
        console.log('value---',value);
        if (value != newNumber) {
            allValidPhone =false;
            inputCmp.setCustomValidity("Enter a valid phone number ex:(555) 555-5555");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        console.log('allValidPhone---',allValidPhone);
        return allValidPhone;
    }
}