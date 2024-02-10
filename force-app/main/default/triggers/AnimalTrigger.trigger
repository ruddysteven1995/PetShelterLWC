trigger AnimalTrigger on Animal__c (after insert) {

    if( Trigger.isInsert ){
        if(Trigger.isAfter) {
            AnimalTriggerHandler.OnAfterInsert();
        }
    }
}