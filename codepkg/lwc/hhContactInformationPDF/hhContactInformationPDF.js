import { LightningElement } from 'lwc';
import HHPDF from '@salesforce/resourceUrl/ContactInformationPDF';

export default class HhContactInformationPDF extends LightningElement {
    HHPDFs = HHPDF;
}