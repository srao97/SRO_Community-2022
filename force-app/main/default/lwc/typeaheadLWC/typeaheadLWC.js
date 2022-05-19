import { LightningElement} from 'lwc';
import tmpl from './typeaheadLWC.html';
import OmniscriptTypeahead from "vlocity_ins/omniscriptTypeahead";
export default class TypeaheadLWC extends OmniscriptTypeahead{
		render(){
        return tmpl;
    }
		
}