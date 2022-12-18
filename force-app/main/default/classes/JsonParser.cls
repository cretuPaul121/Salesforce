public with sharing class JsonParser {
    private static List<SObject> newRecords;


    /**
     *  @param contentDocument: represent the ContentDocument sent by lightning-file-upload 
     *                          if the document has been uploaded succesfully
     *  @description : this method, based on the documentID of ContentVersion returned by lightning-file-upload,
     *                 will query the json document data
     *  @return List<CreatedObjects> : list of the new created SObjects
     */
    @AuraEnabled 
    public static List<CreatedObjects> parseDocument(String contentDocument) {
        ContentDocumentResponse contentDocumentResponse = (ContentDocumentResponse) JSON.deserialize(contentDocument, ContentDocumentResponse.class);

        ContentVersion contentVersion = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentResponse.documentId][0];

        String jsonContent = contentVersion.VersionData.toString();

        newRecords = parseRawJson(jsonContent);

        List<CreatedObjects> lwcCustomResponse = createCustomLwcResponse(newRecords);


        return lwcCustomResponse;
    } 

    /**
     *  @param jsonContent: - hold the json content
     *  @param List<SObject>: - represents list of the newly created SObjects
     *  @description: This method is responsible to deserialize the data from the json file
     *                and extract the record type and the fields of a record
     *  @return: List<SObject> - list of SObject records
     */
    @TestVisible
    private static List<SObject> parseRawJson(String jsonContent) {

        List<Object> records = (List<Object>) JSON.deserializeUntyped(jsonContent);
        List<SObject> toBeInserted = new List<SObject>();


       for(Object record : records) {
            Map<String, Object> element = (Map<String, Object> ) JSON.deserializeUntyped(JSON.serialize(record));
            String sObjectRecordType = String.valueOf(element.get('recordType'));
            Map<String, Object> sObjectFields = (Map<String, Object>) element.get('fields');

            SObject newSObject = CreateSObjects.createSObject(sObjectRecordType, sObjectFields);
       
            if(newSObject != null) {
                toBeInserted.add(newSObject);
            }
       }
        
       insert toBeInserted;
       return toBeInserted;
       
    }


    /**
     *  @param List<SObject> sObjects: - list of Sobjects used to create the wrapper for lwc
     *  @return: List<CreatedObjects> - list of the lwc custom records response
     */
    private static List<CreatedObjects> createCustomLwcResponse(List<SObject> sObjects) {
        List<CreatedObjects> newObjList = new List<CreatedObjects>();
        for(SObject obj : newRecords) {
            newObjList.add(new CreatedObjects(String.valueOf(obj.getSObjectType()), obj));
        }
        return newObjList;
    }


    public class ContentDocumentResponse {
        public String contentVersionId {get; set; }
        public String documentId {get; set; }
    }

    /**
     *  Wrapper class that contains a custom response for LWC component
     *  The class will contain the record type of the created object in order
     *  to be able to group records along with their fields from recordValues variable
     *  
     */
    private class CreatedObjects {
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public SObject recordValues;

        public CreatedObjects(String recordType, SObject recordValues) {
            this.recordType = recordType;
            this.recordValues = recordValues;
        }
    }

}
