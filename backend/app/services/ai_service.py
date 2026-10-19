import re
from dataclasses import dataclass

from schemas.structured_documents import (
    DocumentGenerationResponse,
    DocumentMetadata,
    DocumentType,
    LineItem,
    Party,
    StructuredDocumentData,
)
from services.document_rules import DocumentRules


@dataclass(frozen=True)
class Prediction:
    intent: str
    confidence: float
    matched_text: str | None
    proposed_text: str | None
    explanation: str


class AIService:
    """Deterministic baseline until a model provider is configured.

    Predictions and corrections are stored separately so a future trained model
    can be evaluated against real user feedback instead of silently changing behavior.
    """

    @staticmethod
    def predict(command: str, document_text: str) -> Prediction:
        replace_match = re.search(
            r'(?:change|replace|เปลี่ยน).*?(?:from|จาก)\s+["“]?(.+?)["”]?\s+'
            r'(?:to|เป็น)\s+["“]?(.+?)["”]?(?:$|\.)',
            command.strip(),
            re.IGNORECASE,
        )
        if replace_match:
            old_text, new_text = replace_match.groups()
            old_text = old_text.strip().strip('"“”')
            new_text = new_text.strip().strip('"“”')
            if old_text in document_text:
                return Prediction(
                    intent='replace_text',
                    confidence=0.96,
                    matched_text=old_text,
                    proposed_text=new_text,
                    explanation=f'Found the requested text in the document and proposed replacing it with {new_text}.',
                )
            return Prediction(
                intent='replace_text',
                confidence=0.42,
                matched_text=None,
                proposed_text=new_text,
                explanation=f'I understood the replacement, but could not find {old_text} in this document.',
            )

        return Prediction(
            intent='needs_review',
            confidence=0.18,
            matched_text=None,
            proposed_text=None,
            explanation='I need a clearer instruction, such as “replace X with Y”.',
        )

    @staticmethod
    def generate_document(prompt: str) -> DocumentGenerationResponse:
        """Return a reviewable, schema-validated document proposal.

        This deterministic provider is deliberately conservative. Replacing it
        with a model provider must preserve this method's structured response;
        only a user-approved POST to /documents/structured can create a record.
        """
        normalized = ' '.join(prompt.strip().split())
        lower_prompt = normalized.lower()
        is_purchase_order = any(token in lower_prompt for token in (
            'purchase order', 'purchase-order', ' po ', 'ใบสั่งซื้อ', 'สั่งซื้อ',
        ))
        document_type = (
            DocumentType.purchase_order
            if is_purchase_order else DocumentType.general_business_document
        )
        template_id = 'commercial-v1' if is_purchase_order else 'business-v1'
        item_match = re.search(
            r'(?:for|ซื้อ|จำนวน)\s+(\d+(?:\.\d+)?)\s+(.+?)(?:\s+(?:from|จาก)\s+|$)',
            normalized,
            re.IGNORECASE,
        )
        supplier_match = re.search(r'(?:from|จาก)\s+(.+?)(?:[.!?]|$)', normalized, re.IGNORECASE)
        line_items = []
        if item_match:
            line_items.append(LineItem(
                quantity=item_match.group(1),
                description=item_match.group(2).strip(),
            ))
        data = StructuredDocumentData(
            document_type=document_type,
            metadata=DocumentMetadata(
                title='Purchase Order' if is_purchase_order else 'Business Document',
            ),
            supplier=Party(name=supplier_match.group(1).strip()) if supplier_match else None,
            line_items=line_items,
            notes=normalized if not line_items else None,
        )
        return DocumentGenerationResponse(
            prompt=prompt,
            confidence=0.82 if is_purchase_order else 0.55,
            explanation=(
                'I identified a purchase-order request and prepared fields for review.'
                if is_purchase_order else
                'I prepared a general business-document draft. Confirm the document type and required fields.'
            ),
            template_id=template_id,
            data=data,
            validation=DocumentRules.validate(data),
        )
