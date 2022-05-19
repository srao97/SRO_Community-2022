import omniscriptTextBlock from 'vlocity_ins/omniscriptTextBlock';
import omniscriptTextBlockOverrideTemplate from './omniscriptTextBlockOverride.html'

export default class OmniscriptTextBlockOverride extends omniscriptTextBlock {
    render(){
        return omniscriptTextBlockOverrideTemplate;
    }
}