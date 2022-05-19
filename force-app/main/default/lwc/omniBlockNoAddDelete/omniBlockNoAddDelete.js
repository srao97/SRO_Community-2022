import { LightningElement } from "lwc";
    import omniscriptBlock from "vlocity_ins/omniscriptBlock";
    import template from "./omniBlockNoAddDelete.html"
    export default class omniBlockNoAddDelete extends omniscriptBlock{
        // your properties and methods here
        // override initial rendercallback
    initialRenderCallback() {
        console.log("Initial Render Callback for Custom Block");

        if(
            this.jsonDef.propSetMap
            && this.jsonDef.propSetMap.syncBlockSizeOnInit === true
            && this.jsonDef.propSetMap.repeat === true
        ) {

            // check if data is present in cache(seeddata)
            let stepName = this.jsonDef.JSONPath.substr(0, this.jsonDef.JSONPath.indexOf(`:${this._elementId}`));
            let seedData = this.seedJson && this.seedJson[stepName] || this.seedJson;
            if(seedData.hasOwnProperty(this._elementId)) {

                seedData = seedData[this._elementId];

                let sourceLength = 0;
                if(seedData instanceof Array) {
                    sourceLength = seedData.length;
                } else if(typeof seedData === "object") {
                    sourceLength = 1;
                }
                let targetSize = null === this.jsonDef.ct ? 0 : parseInt(this.jsonDef.ct); //this.jsonDef.ct represents the total count of block instances
                if(sourceLength != 0 && targetSize != 0 && targetSize > sourceLength) { // reduce target size
                    if(this.jsonDef.index+1 > sourceLength){
                        this.handleRemove();
                    }
                }
            }
        }
        
        //invoke default handler
        super.initialRenderCallback();

    }
        render()
          {
            return template;
          }
    }