import OmniScriptText from 'vlocity_ins/omniscriptText';
import OmniscriptReadonlyTextOverrideTemplate from './omniscriptReadonlyTextOverride.html';

export default class OmniscriptReadonlyTextOverride extends OmniScriptText {
    render(){
        return OmniscriptReadonlyTextOverrideTemplate;
    }
    connectedCallback() {
        super.connectedCallback();
        console.log('here');
    }
}