import { LightningElement } from "lwc";

export default class ngFooter extends LightningElement {

    viclogo = '/lenders/s/sfsites/c/resource/VIC_Logo';

    get backgroundStyle() {
        return `background-image:url(${BACKGROUND_IMAGE})`;
    }
}