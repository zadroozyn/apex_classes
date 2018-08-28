public abstract class TriggerHandler {

	public void handleTrigger() {
		if(Trigger.isInsert) {
			if(Trigger.isBefore) {
				handleBeforeInsert();
			} else if(Trigger.isAfter) {
				handleAfterInsert();
			}
		} else if(Trigger.isUpdate) {
			if(Trigger.isBefore) {
				handleBeforeUpdate();
			} else if(Trigger.isAfter) {
				handleAfterUpdate();
			}
		} else if(Trigger.isDelete) {
			if(Trigger.isBefore) {
				handleBeforeDelete();
			} else if(Trigger.isAfter) {
				handleAfterDelete();
			}
		} else if(Trigger.isUndelete) {
			if(Trigger.isAfter) {
				handleAfterUndelete();
			}
		}
	}

	protected virtual void handleBeforeInsert() {

	}

	protected virtual void handleAfterInsert() {

	}

	protected virtual void handleBeforeUpdate() {

	}

	protected virtual void handleAfterUpdate() {

	}

	protected virtual void handleBeforeDelete() {

	}

	protected virtual void handleAfterDelete() {

	}

	protected virtual void handleAfterUndelete() {

	}


}