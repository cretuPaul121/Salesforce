@isTest
public with sharing class Test_JsonParser {
    
    @isTest 
    public static void documentHasBeenSaved() {
        //given
        ContentVersion contentVersion = new ContentVersion();

        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'file.json';
        contentVersion.Title = 'Json records';
        contentVersion.VersionData = EncodingUtil.base64Decode('json content');

        //when
        insert contentVersion;

        ContentVersion createdContentVersion = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion 
                                                WHERE ID =:contentVersion.Id][0];
        
        //then      
        System.assertEquals(true, createdContentVersion != null);
        System.assertEquals(true, createdContentVersion.VersionData != null);

    }


    @isTest
    public static void recordsHasBeenCreated() {
        //given
        String validJson = '[{"recordType": "Account", "fields": {"Name": "ValidName"}}, {"recordType": "Account", "fields": {"Name": "ValidName"}}, {"recordType": "Account", "fields": {"Name": "ValidName"}}]';

        
        List<SObject> createdObjects;

        //when
        Test.startTest();
        createdObjects = JsonParser.parseRawJson(validJson);
        Test.stopTest();


        //then
        List<Account> newAcc = [SELECT Id FROM Account];

        System.assertEquals(3, newAcc.size());

    }


    @isTest 
    public static void recordsCannotBeCreated() {
        //given
        String jsonWithInvalidSObjects = '[{"recordType": "UnknownObject1", "fields": {"tt": "tt"}}, {"recordType": "UnknownObject2", "fields": {"Name": "ValidName"}}]';
    
        List<SObject> createdObjects;

        //when
        Test.startTest();
        createdObjects = JsonParser.parseRawJson(jsonWithInvalidSObjects);
        Test.stopTest();


        //then
        List<Account> newAcc = [SELECT Id FROM Account];

        System.assertEquals(0, newAcc.size());
        
    }

}
