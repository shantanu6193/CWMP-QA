import {
    LightningElement,
    wire,
    api,
    track
  } from 'lwc';
import Utility from 'c/utility';

export default class MarsF42EntrySummary extends Utility {
    @api
    f42Entry;
    @api
    actualHoursTotal;
}