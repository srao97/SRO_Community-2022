import { LightningElement, api } from 'lwc';

export default class ngHeroBanner extends LightningElement {

    @api heading;
    @api description;
    @api imagesrc;
    @api buttonLabel;
    @api link;

}