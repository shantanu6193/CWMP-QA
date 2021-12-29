/**
 * Created by PREM on 08-09-2020.
 */

import { LightningElement, api } from 'lwc';
import Utility from 'c/utility';

export default class RedirectToCommonCommunity extends Utility {
    /*
    * Redirect to community
    */
    initData() {
        let baseURL = window.location.origin;
        window.location.href = baseURL + '/s/';
    }
}