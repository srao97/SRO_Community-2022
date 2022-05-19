import { LightningElement, api } from 'lwc';

export default class NgButton extends LightningElement {
  @api link
  @api button
  @api buttonLabel
  @api buttonLink
  @api buttonStyle
  @api type

  handleButtonClick() {
    this.dispatchEvent(new CustomEvent('buttonpress'));
  }

  get buttonClassStyle() {
    return `ng-button ng-button--${this.buttonStyle}`
  }
}