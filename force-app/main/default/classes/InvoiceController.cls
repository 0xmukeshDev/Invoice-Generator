public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityWithProducts(Id oppId){
        return [
            SELECT Id, Name, AccountId,
                (SELECT Id, Quantity, UnitPrice, PricebookEntry.Product2Id, 
                        PricebookEntry.Product2.Name 
                 FROM OpportunityLineItems)
            FROM Opportunity
            WHERE Id = :oppId
        ];
    }
    // @AuraEnabled
    // public static Id createInvoice(Id oppId, List<Invoice_Line__c> lines){
    //     Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId];
    //     Invoice__c inv = new Invoice__c(
    //         Opportunity__c = opp.Id,
    //         Account__c = opp.AccountId
    //     );
    //     insert inv;
    //     for(Invoice_Line__c line : lines){
    //         line.Invoice__c = inv.Id;
    //     }
    //     insert lines;
    //     return inv.Id;
    // }
    @AuraEnabled
public static Id createInvoice(Id oppId, List<Invoice_Line__c> lines){
    Savepoint sp = Database.setSavepoint();
    try {
        Opportunity opp = [
            SELECT Id, AccountId 
            FROM Opportunity 
            WHERE Id = :oppId
            LIMIT 1
        ];
        Invoice__c inv = new Invoice__c(
            Opportunity__c = opp.Id,
            Account__c = opp.AccountId
        );
        insert inv;
        if(lines != null && !lines.isEmpty()){
            for(Invoice_Line__c line : lines){
                if(line.Quantity__c <= 0 || line.Price__c <= 0){
                    throw new AuraHandledException('Invalid quantity or price');
                }
                line.Invoice__c = inv.Id;
                
            }
            insert lines;
        }
        return inv.Id;
        
    } catch(Exception e){
        Database.rollback(sp);
        throw new AuraHandledException(e.getMessage());
    }
}
@AuraEnabled
    public static Id generateAndAttachPdf(Id invoiceId) {

        // Generate PDF
        PageReference pdfPage = Page.InvoicePDF;
        pdfPage.getParameters().put('id', invoiceId);

        Blob pdfBody = pdfPage.getContentAsPDF();

        // Save file    
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Invoice_' + invoiceId;
        cv.PathOnClient = 'Invoice.pdf';
        cv.VersionData = pdfBody;
        insert cv;

        // Get ContentDocumentId
        Id contentDocId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        // Link to Invoice
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = contentDocId;
        link.LinkedEntityId = invoiceId;
        link.ShareType = 'V';
        insert link;

        // Return ContentVersion Id (for download)
        return cv.Id;
    }
// @AuraEnabled
//     public static String getPdfUrl(Id invoiceId) {
//         return '/apex/InvoicePDF?id=' + invoiceId;
//     }
}