import OmniScriptRadio from 'vlocity_ins/omniscriptRadio';
import omniscriptRadioOverrideTemplate from './omniscriptRadioOverride.html';

export default class OmniscriptRadioOverride extends OmniScriptRadio {
    render(){
        return omniscriptRadioOverrideTemplate;
    }
}