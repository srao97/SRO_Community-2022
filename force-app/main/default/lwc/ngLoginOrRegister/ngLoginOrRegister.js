import { LightningElement, api } from 'lwc';

export default class ngHeroBanner extends LightningElement {

    @api heading;
    @api description;
    @api button1Label;
    @api button1Link;
    @api button2Label;
    @api button2Link;

}