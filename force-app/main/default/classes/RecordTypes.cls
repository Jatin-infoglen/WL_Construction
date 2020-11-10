public class RecordTypes {
    
    public static Final String CreditMemo = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Credit Memo').getRecordTypeId();
    public static Final String standardOrder = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Standard Order').getRecordTypeId();
    public static Final String feedbackRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Feedback').getRecordTypeId();
	public static Final String PaymentReminderRecordType = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Payment Reminder').getRecordTypeId();
}