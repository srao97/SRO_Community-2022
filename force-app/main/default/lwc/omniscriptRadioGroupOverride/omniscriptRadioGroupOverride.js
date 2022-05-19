import OmniScriptRadioGroup from "vlocity_ins/radioGroup";
import omniscriptRadioGroupOverrideNdsTemplate from "./omniscriptRadioGroupOverride-nds.html";
import omniscriptRadioGroupOverrideTemplate from "./omniscriptRadioGroupOverride.html";
export default class OmniscriptRadioGroupOverride extends OmniScriptRadioGroup {
  //@api theme = "slds";
  render() {
    //return this.theme === "nds" ? omniscriptRadioGroupOverrideNdsTemplate : omniscriptRadioGroupOverrideTemplate;
    return omniscriptRadioGroupOverrideTemplate;
  }

  connectedCallback(){
    this.radioGroupLabelId = this.radioId + '_label'
    super.connectedCallback();
    console.log('here')
  }
    // if(this._propSetMap.radioLabels){
    //   this._radioGroup || (this._radioGroup = JSON.parse(JSON.stringify(this._propSetMap.radioLabels)),
    //   this._radioGroup.forEach(e=>{
    //       e.options = JSON.parse(JSON.stringify(this._propSetMap.options))
    //   }
    //   ),
    //   this.generateUniqueIds(this._radioGroup)),
    //   this.elementValue && this.prefill(this.elementValue)
    // }
}