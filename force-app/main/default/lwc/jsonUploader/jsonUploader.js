import { LightningElement, api, track } from 'lwc';
import uploadJsonAndCreateRecords from '@salesforce/apex/JsonParser.parseDocument';
import LastActivityDate from '@salesforce/schema/Account.LastActivityDate';

export default class JsonUploader extends LightningElement {
    @api recordId;

    // uploadJsonAndCreateRecords errors
    @track retrievedRecordsError;

    sObjects = [];

    get acceptedFormats() {
        return ['.json'];
    }


    handleUploadFinished(event) {
        const uploadedFile = event.detail.files;



        uploadJsonAndCreateRecords({ contentDocument: JSON.stringify(uploadedFile[0]) }) 
        .then((insertedSObjects) => {
            let tempArray = [];
            console.log('initial ', insertedSObjects);
            if( insertedSObjects !== undefined ) {
                for(let i = 0; i <  insertedSObjects.length; i++) {
                    let arr = [];
                    for(let key in insertedSObjects[i]["recordValues"]) {
                        arr.push({key: key, value: insertedSObjects[i]["recordValues"][key]})
                    }
                    tempArray.push({
                        recordType: insertedSObjects[i].recordType,
                        fields: arr
                    });
                }
                
            }
            this.sObjects = tempArray;
        })
        .catch((error) => {
            this.retrievedRecordsError = error;
        })

    }
    
}