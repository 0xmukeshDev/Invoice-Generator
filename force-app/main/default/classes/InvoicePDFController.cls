public class InvoicePDFController {

    public Id invoiceId { get; set; }
    public List<Invoice_Line__c> lines { get; set; }
    public Invoice__c invoiceHeader { get; set; }

    public InvoicePDFController() {
        invoiceId = ApexPages.currentPage().getParameters().get('id');


        if(invoiceId != null){

            invoiceHeader = [
                SELECT Id, Account__r.name, Opportunity__r.name,Total_Amount__c, CreatedDate from Invoice__c where id = :invoiceId LIMIT 1
            ];
    
            lines = [
                SELECT Product__c, Product__r.Name, Quantity__c, Price__c, Total__c
                FROM Invoice_Line__c
                WHERE Invoice__c = :invoiceId
            ];
        }

    }

    public String getFormattedInvoiceNumber() {
        if (invoiceHeader == null || invoiceHeader.Id == null) {
            return '';
        }
        String idStr = String.valueOf(invoiceHeader.Id);
        String last4 = idStr.substring(idStr.length() - 4);
        String datePart = invoiceHeader.CreatedDate.format('yyyyMMdd');
        return 'INV-' + datePart + '-' + last4;
}
}