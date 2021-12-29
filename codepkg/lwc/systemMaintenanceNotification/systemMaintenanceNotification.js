import { LightningElement } from 'lwc';
import systemNotification from '@salesforce/label/c.System_Maintenance_Notification';
export default class SystemMaintenanceNotification extends LightningElement {
    SystemMaintenanceMessage = systemNotification;

}