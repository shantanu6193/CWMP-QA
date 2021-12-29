import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';

export default class PageFieldHelpText extends Utility {
    @api helpText;

    initData() {
        
    }
}