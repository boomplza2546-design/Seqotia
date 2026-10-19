enum DocumentType {
  purchaseOrder('purchase_order', 'Purchase Order'),
  purchaseRequest('purchase_request', 'Purchase Request'),
  quotation('quotation', 'Quotation'),
  invoice('invoice', 'Invoice'),
  receipt('receipt', 'Receipt'),
  deliveryNote('delivery_note', 'Delivery Note'),
  paymentRequest('payment_request', 'Payment Request'),
  memo('memo', 'Memo'),
  letter('letter', 'Letter'),
  contract('contract', 'Contract'),
  proposal('proposal', 'Proposal'),
  report('report', 'Report'),
  meetingDocument('meeting_document', 'Meeting Document'),
  generalBusinessDocument('general_business_document', 'Business Document');

  const DocumentType(this.wireValue, this.label);
  final String wireValue;
  final String label;

  static DocumentType fromWire(String value) => DocumentType.values.firstWhere(
        (type) => type.wireValue == value,
        orElse: () => DocumentType.generalBusinessDocument,
      );
}

class DocumentParty {
  const DocumentParty({this.name, this.taxId, this.email, this.phone});

  final String? name;
  final String? taxId;
  final String? email;
  final String? phone;

  factory DocumentParty.fromJson(Map<String, dynamic>? json) => DocumentParty(
        name: json?['name'] as String?,
        taxId: json?['tax_id'] as String?,
        email: json?['email'] as String?,
        phone: json?['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (taxId != null) 'tax_id': taxId,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      };
}

class DocumentLineItem {
  const DocumentLineItem({
    required this.description,
    this.quantity = 1,
    this.unit,
    this.unitPrice = 0,
    this.discount = 0,
    this.taxRate = 0,
  });

  final String description;
  final num quantity;
  final String? unit;
  final num unitPrice;
  final num discount;
  final num taxRate;

  factory DocumentLineItem.fromJson(Map<String, dynamic> json) =>
      DocumentLineItem(
        description: json['description'] as String? ?? '',
        quantity: json['quantity'] as num? ?? 1,
        unit: json['unit'] as String?,
        unitPrice: json['unit_price'] as num? ?? 0,
        discount: json['discount'] as num? ?? 0,
        taxRate: json['tax_rate'] as num? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        if (unit != null) 'unit': unit,
        'unit_price': unitPrice,
        'discount': discount,
        'tax_rate': taxRate,
      };
}

class StructuredDocumentData {
  const StructuredDocumentData({
    required this.documentType,
    this.title,
    this.documentNumber,
    this.issueDate,
    this.dueDate,
    this.referenceNumber,
    this.company,
    this.supplier,
    this.customer,
    this.lineItems = const [],
    this.currency = 'THB',
    this.paymentTerms,
    this.notes,
  });

  final DocumentType documentType;
  final String? title;
  final String? documentNumber;
  final String? issueDate;
  final String? dueDate;
  final String? referenceNumber;
  final DocumentParty? company;
  final DocumentParty? supplier;
  final DocumentParty? customer;
  final List<DocumentLineItem> lineItems;
  final String currency;
  final String? paymentTerms;
  final String? notes;

  factory StructuredDocumentData.fromJson(Map<String, dynamic> json) {
    final metadata = Map<String, dynamic>.from(
      json['metadata'] as Map? ?? const <String, dynamic>{},
    );
    return StructuredDocumentData(
      documentType: DocumentType.fromWire(json['document_type'] as String? ?? ''),
      title: metadata['title'] as String?,
      documentNumber: metadata['document_number'] as String?,
      issueDate: metadata['issue_date'] as String?,
      dueDate: metadata['due_date'] as String?,
      referenceNumber: metadata['reference_number'] as String?,
      company: json['company'] == null
          ? null
          : DocumentParty.fromJson(Map<String, dynamic>.from(json['company'] as Map)),
      supplier: json['supplier'] == null
          ? null
          : DocumentParty.fromJson(Map<String, dynamic>.from(json['supplier'] as Map)),
      customer: json['customer'] == null
          ? null
          : DocumentParty.fromJson(Map<String, dynamic>.from(json['customer'] as Map)),
      lineItems: (json['line_items'] as List? ?? const [])
          .map((item) => DocumentLineItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      currency: json['currency'] as String? ?? 'THB',
      paymentTerms: json['payment_terms'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'document_type': documentType.wireValue,
        'metadata': {
          if (title != null) 'title': title,
          if (documentNumber != null) 'document_number': documentNumber,
          if (issueDate != null) 'issue_date': issueDate,
          if (dueDate != null) 'due_date': dueDate,
          if (referenceNumber != null) 'reference_number': referenceNumber,
        },
        if (company != null) 'company': company!.toJson(),
        if (supplier != null) 'supplier': supplier!.toJson(),
        if (customer != null) 'customer': customer!.toJson(),
        'line_items': lineItems.map((item) => item.toJson()).toList(),
        'currency': currency,
        if (paymentTerms != null) 'payment_terms': paymentTerms,
        if (notes != null) 'notes': notes,
      };

  String get previewText {
    final buffer = StringBuffer()
      ..writeln((title ?? documentType.label).toUpperCase())
      ..writeln('Document No.: ${documentNumber ?? 'Draft'}');
    if (issueDate != null) buffer.writeln('Date: $issueDate');
    if (company?.name != null) buffer.writeln('From: ${company!.name}');
    if (supplier?.name != null) buffer.writeln('Supplier: ${supplier!.name}');
    for (final item in lineItems) {
      buffer.writeln('${item.description} — ${item.quantity} ${item.unit ?? ''}'.trim());
    }
    if (notes != null) buffer.writeln('\n$notes');
    return buffer.toString().trim();
  }
}

class DocumentValidationIssue {
  const DocumentValidationIssue({required this.field, required this.message, required this.severity});

  final String field;
  final String message;
  final String severity;

  factory DocumentValidationIssue.fromJson(Map<String, dynamic> json) =>
      DocumentValidationIssue(
        field: json['field'] as String? ?? '',
        message: json['message'] as String? ?? 'Needs review.',
        severity: json['severity'] as String? ?? 'warning',
      );
}

class DocumentGenerationProposal {
  const DocumentGenerationProposal({
    required this.prompt,
    required this.confidence,
    required this.explanation,
    required this.templateId,
    required this.data,
    required this.issues,
  });

  final String prompt;
  final double confidence;
  final String explanation;
  final String templateId;
  final StructuredDocumentData data;
  final List<DocumentValidationIssue> issues;

  factory DocumentGenerationProposal.fromJson(Map<String, dynamic> json) {
    final validation = Map<String, dynamic>.from(json['validation'] as Map? ?? const {});
    return DocumentGenerationProposal(
      prompt: json['prompt'] as String? ?? '',
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      explanation: json['explanation'] as String? ?? '',
      templateId: json['template_id'] as String? ?? '',
      data: StructuredDocumentData.fromJson(Map<String, dynamic>.from(json['data'] as Map)),
      issues: (validation['issues'] as List? ?? const [])
          .map((item) => DocumentValidationIssue.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
    );
  }
}
