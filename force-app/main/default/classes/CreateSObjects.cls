/** Description : 
 *  
 *  This class contain methods that manage creation of an SObject dynamically, 
 *  based on an SObject record type and a group of fields for the specified object
 * 
 *  1. The class will verify if the specified sObject exist on the salesforce org
 *  2. The class is responsible of checking each fieldName for the specified record if it exist
 *  3. The class will ignore the fieldNames of an SObject if the data type doesn't match
 *  
 *  
 */
public with sharing class CreateSObjects {
    
    /**
     *  @param String sObjectRecordType - represent the record type of an SObject
     *  @param Map<String, Object> sObjectFields - hold the fieldnames and values of an sObject
     *  
     *  @description: Based on the input values this method will create an SObject
     * 
     *  @return: SObject
     */
    public static SObject createSObject(String sObjectRecordType, Map<String, Object> sObjectFields) {
        SObject newSObject;
        Schema.SObjectType newSObjectSchemaType = sObjectExist(sObjectRecordType);


        if(newSObjectSchemaType != null) {
            newSObject = newSObjectSchemaType.newSObject();

            for(String sObjectFieldName : sObjectFields.keySet()) {
                if( sObjectFieldNameExist(newSObjectSchemaType, sObjectFieldName) ) {
                    String dataType = getFieldDataType(newSObjectSchemaType, sObjectFieldName);
                    Object fieldNameValue = sObjectFields.get(sObjectFieldName);

                    // for DATE data type a conversion has to be made from String to date object
                    switch on dataType {
                        when 'DATE' {
                            fieldNameValue = date.parse(String.valueOf(fieldNameValue));
                        }
                        when 'DATETIME' {
                            fieldNameValue = DateTime.Valueof(String.valueOf(fieldNameValue).replace('T', ' '));

                        }
                    }

                    if( sObjectFieldNameDataTypeFit(newSObject, sObjectFieldName, fieldNameValue) ) {
                        newSObject.put(sObjectFieldName, fieldNameValue);
                    } else {
                        System.debug('Field type doesnt match');
                    }
                } else {
                    System.debug('Field name - '+ sObjectFieldName + '-  doesnt exist on the sObject ' + newSObjectSchemaType);
                }
            }
        }
        return newSObject;
    }

    /**
     *  @param String sObjectRecordType - represent the record type of an SObject
     *  
     *  @description: This method check if the specified SObject exist on salesforce org
     *                If it exists it will return an Schema.SObjectType, otherwise null
     * 
     *  @return: Schema.SObjectType
     */
    private static Schema.SObjectType sObjectExist(String sObjectRecordType) {
        return Schema.getGlobalDescribe().get(sObjectRecordType);
    }

    /**
     *  @param Schema.SObjectType newSObjectSchemaType - represents the actual existing object in salesforce
     *  @param String fieldNameToCheck - contains the fieldName of an SObject that needs to be verified
     *  
     *  @description: This method check if the specified fieldName exist on the SObjectType 
     * 
     *  @return: Boolean
     */
    private static Boolean sObjectFieldNameExist(Schema.SObjectType newSObjectSchemaType, String fieldNameToCheck) {
        Set<String> sObjectExistingFieldNames = newSObjectSchemaType.getDescribe().fields.getMap().keySet();

        return sObjectExistingFieldNames.contains(fieldNameToCheck.toLowerCase());
    }

    /**
     *  @param SObject obj - represent SObject that needs to be created
     *  @param String fieldName - contains the fieldname the SObject
     *  @param Object fieldValue - contains the value of the fieldname 
     * 
     *  @description: Based on the input values this method will create an SObject
     * 
     *  @return: Boolean
     */
    private static Boolean sObjectFieldNameDataTypeFit(SObject obj, String fieldName, Object fieldValue) {
        try {
          
            obj.put(fieldName, fieldValue);
            return true;
        } catch(Exception ex) {
            return false;
        }
    }

    private static String getFieldDataType(Schema.SObjectType newSObjectSchemaType, String fieldName) {
        Schema.DisplayType displayValue = newSObjectSchemaType.getDescribe().fields.getMap().get(fieldName).getDescribe().getType();

        return String.valueOf(displayValue);
    }


}
