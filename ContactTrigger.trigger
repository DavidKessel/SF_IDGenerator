trigger ContactTrigger on Contact (before insert, before update) {

    if (Trigger.isBefore) {

        if (Trigger.isInsert) {
            ContactController.updateWithId(Trigger.New, Trigger.OldMap);
        }
        if (Trigger.isUpdate) {
            ContactController.updateWithId(Trigger.New, Trigger.OldMap);
        }

    }

}