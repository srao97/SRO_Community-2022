import { LightningElement,api } from 'lwc';

export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    fileData
    openfileUpload(event){
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload =()=>{
            var base64 = reader.result
            this.fileData = {
                'filename':file.name,
                'base64':base64,
                'recordId':this.recordId
            }
            console.log(this.fileData)

        }
        reader.readAsDataURL(file)
    }

}