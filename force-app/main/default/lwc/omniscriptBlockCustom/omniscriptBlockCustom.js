import { LightningElement } from "lwc";
    import omniscriptBlock from "vlocity_ins/omniscriptBlock";
    import template from "./omniscriptBlockCustom.html"
    export default class omniscriptBlockCustom extends omniscriptBlock{
        // your properties and methods here
        
        render()
          {
            return template;
          }
    }