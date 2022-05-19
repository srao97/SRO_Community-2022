import OmniScriptSelect from 'vlocity_ins/omniscriptSelect';
import omniscriptSelectOverrideTemplate from './omniscriptSelectOverride.html';

export default class OmniscriptSelectOverride extends OmniScriptSelect {
    selectLabel;
    hideLabel;
    connectedCallback() {
        super.connectedCallback();
        this._isReadOnly = this.jsonDef.propSetMap.readOnly;
        if (!this.jsonDef.propSetMap.label) {
          this.hideLabel = true;
          this.selectLabel = this.jsonDef.propSetMap.helpText;
        } else {
          this.hideLabel = false;
          this.selectLabel = this.jsonDef.propSetMap.label;
        }
      }
      render(){
        return omniscriptSelectOverrideTemplate;
    }
}