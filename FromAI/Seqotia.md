# Seqotia
## Product, Experience, and Prototype Specification

> **Work faster. Documents, simplified.**

## Executive Summary

Seqotia is a premium, macOS-first AI document workspace. It combines a real document editor, semantic document understanding, and a conversational editing assistant in one calm, focused environment.

Seqotia is not merely a word processor, and it is not merely an AI chatbot. It understands the structure and meaning of a document, identifies the exact content a user wants to change, presents the proposed edit clearly, and lets the user apply, undo, or compare the result.

The defining experience is:

> **See → Ask → Preview → Apply**

A user should be able to upload a document and make a meaningful change within seconds without needing to search through pages, understand formatting technology, or navigate complex menus.

---

## 1. Product Vision

Seqotia should feel like **Apple built an AI document assistant**: fast, quiet, precise, trustworthy, and beautifully composed.

The experience should combine the strongest qualities of:

| Influence | Contribution to Seqotia |
|---|---|
| Native macOS software | Clarity, keyboard-first interaction, restraint, and familiarity |
| Modern productivity tools | Structure, focus, and flexible workspaces |
| Microsoft Word | Document fidelity, pages, formatting, and export |
| AI assistants | Natural-language commands and intelligent guidance |
| Document automation | Precise, repeatable, reversible changes |

Seqotia must not feel like a generic web dashboard or another chat interface. The document remains the center of attention. AI supports the document rather than replacing it.

### Product promise

Seqotia helps people change documents by expressing intent instead of manually locating and editing content.

For example, when a user uploads `บันทึกติดต่องาน.docx` and writes:

> เปลี่ยนวันที่จาก 31 มีนาคม 2569 เป็น 5 เมษายน 2569

Seqotia should identify the relevant date, explain what it found, show the proposed replacement in context, and wait for the user to approve the change.

### Product qualities

Seqotia should consistently communicate the following qualities:

- **Fast:** The path from upload to meaningful edit is short.
- **Trustworthy:** Every meaningful change is visible, explainable, and reversible.
- **Intelligent:** The system understands document semantics, not only raw text.
- **Simple:** The user expresses an outcome instead of operating formatting tools.
- **Professional:** The result preserves the visual integrity of the original document.

---

## 2. Primary User Journey

The primary workflow is deliberately linear and understandable:

1. The user signs in.
2. The user arrives at the dashboard.
3. The user uploads or opens a document.
4. Seqotia analyzes the document and detects its structure.
5. The document opens in the Document Workspace.
6. The user enters a natural-language command.
7. Seqotia identifies the target and proposes a change.
8. The user previews the affected content.
9. The user applies or cancels the change.
10. Seqotia saves a new version without overwriting the original.
11. The user exports or continues editing.

The user should never need to think:

- “Where is this text?”
- “Which menu should I use?”
- “How do I preserve the formatting?”

The user should only need to think:

> “I want this changed.”

---

## 3. Product Scope and Priorities

The Document Workspace and AI editing interaction are the highest priorities. Secondary dashboard features should not delay or weaken this core experience.

### MVP priorities

| Priority | Capability | Definition of done |
|---|---|---|
| P0 | Document upload | Users can upload DOCX, PDF, and TXT files. |
| P0 | Document display | The document appears in a clean, paper-like viewer. |
| P0 | Text extraction | Text and basic structural elements are available to the application. |
| P0 | Semantic analysis | Dates, amounts, organizations, names, headings, tables, and signatures can be identified. |
| P0 | AI command input | Users can enter natural-language editing instructions in Thai or English. |
| P0 | Proposed changes | The system shows what it found, where it found it, and what will change. |
| P0 | Preview and apply | Users can preview, apply, cancel, and undo edits. |
| P0 | Change highlighting | Affected text is highlighted in the document preview. |
| P0 | Version history | Each applied change creates a recoverable version. |
| P0 | Export | Users can export an edited document as DOCX, PDF, or TXT. |
| P1 | Compare mode | Users can compare before and after versions side by side. |
| P1 | Command bar | Users can invoke AI actions globally with `⌘ K`. |
| P1 | Manual editing | Users can make basic text edits directly in the document. |
| P1 | Search and comments | Users can search, highlight, and annotate document content. |
| P2 | Collaboration | Team chat, sharing, contacts, and collaborative workflows. |
| P2 | Additional formats | PPTX, XLSX, ODT, and image-based OCR documents. |

If full DOCX fidelity is difficult in the first iteration, prioritize the following order:

1. Accurate text extraction.
2. Semantic structure.
3. Safe AI editing.
4. Clear visual preview.
5. Version history.
6. Incremental improvement of formatting fidelity.

---

## 4. Visual Direction

Seqotia should be a premium desktop application with a calm, nature-inspired visual language.

### Design characteristics

- Native macOS feeling.
- Apple-inspired simplicity.
- Deep forest green and emerald accents.
- Frosted translucent surfaces.
- Soft gradients and restrained shadows.
- Subtle forest or nature imagery where appropriate.
- Elegant, highly legible typography.
- Generous spacing and clear hierarchy.
- Minimal controls with strong affordances.
- Smooth, short animations.

Glassmorphism should be used as a supporting material, not as decoration. Panels must remain readable, accessible, and visually quiet.

### Color system

| Role | Direction |
|---|---|
| Primary | Deep forest green |
| Accent | Emerald |
| Secondary accent | Soft mint |
| Background | Charcoal, black-green, or quiet nature imagery |
| Surface | Translucent dark green or black |
| Text | White and soft white |
| Muted text | Cool gray-green |
| Success | Restrained mint or green |
| Warning | Warm amber used only for attention |
| Destructive | Muted red used only for irreversible or risky actions |

Avoid excessive neon, highly saturated gradients, dense dashboards, and visual noise.

### Glass panel treatment

Glass panels should use:

- A semi-transparent dark green or black surface.
- A backdrop blur of approximately 20–40 px where supported.
- A thin, low-opacity white border.
- Soft ambient shadows.
- Rounded corners in the 18–28 px range.
- A subtle highlight or reflection along the upper edge.

### Typography and controls

Use a modern sans-serif typeface with a macOS-like tone and strong support for Thai text. Typography should prioritize legibility over novelty.

Buttons should be rounded, clearly labeled, and restrained. Hover and focus states may use a subtle scale or glow, but interaction feedback must remain calm and professional.

---

## 5. Application Shell

The primary target is a macOS desktop window at 1440 × 900. The layout must remain usable at 1280 × 800, 1680 × 1050, and 1920 × 1080.

The shell should include:

- macOS-style traffic-light window controls.
- A persistent left navigation sidebar.
- A focused content area.
- Keyboard shortcuts for frequent actions.
- A global AI command bar.
- Clear save and security states.

The interface must reflow gracefully when resized. The Document Workspace must preserve the document’s reading area and prevent the assistant panel from overwhelming the document.

---

## 6. Login Experience

The login screen should feel premium rather than corporate.

### Content

- Seqotia leaf logo.
- Product name: **Seqotia**.
- Tagline: **Work faster. Documents, simplified.**
- Username or email field.
- Password field.
- Remember me option.
- Forgot password link.
- Primary **Sign In** action.
- **Continue with Apple** action.
- A concise security status indicator.

### Composition

Use a dark forest background with a subtle, cinematic, blurred nature image. Place a large frosted-glass login card in the center or slightly off-center. The card should have translucent depth, a thin border, a quiet glow, and generous internal spacing.

The screen should establish Seqotia’s core promise immediately: intelligent work, handled with care.

---

## 7. Dashboard

After sign-in, users should arrive at a focused dashboard rather than a dense administrative console.

### Sidebar navigation

**Seqotia**

- Dashboard
- Workspace
- Documents
- Templates
- AI Writer
- Projects
- Team Chat
- Contacts
- Settings

### Main content

The dashboard should begin with a simple welcome message such as **Welcome back** and a short list of useful next actions.

#### Quick actions

- New Document
- Upload Document
- AI Edit
- Create from Template

#### Dashboard sections

- Recent Documents
- Recently Edited
- AI Activity
- Pending Review
- Templates

Example document cards may include:

- Marketing Report
- Business Proposal
- Project Summary
- Approval Request
- Meeting Report

Each card should show the document icon, filename, type, last modified time, current status, and AI processing status. Cards should support recent files and favorites without becoming visually heavy.

---

## 8. The Document Workspace

The Document Workspace is the heart of Seqotia and must receive the highest level of design and implementation attention.

### Three-part layout

| Area | Purpose |
|---|---|
| Left panel | Document structure, pages, and navigation |
| Center canvas | Actual document preview and editing surface |
| Right panel | Seqotia AI assistant and proposed changes |

### Top toolbar

The toolbar should include:

- Back navigation.
- Document name.
- Save state, such as **Saved just now**.
- Undo.
- Redo.
- Share.
- Export.
- More actions.

The toolbar should remain visually quiet. The most important control is the document itself, followed by the AI assistant.

---

## 9. Document Viewer and Editor

When a DOCX, PDF, or TXT file is uploaded, Seqotia should render it in a clean, paper-like canvas. For paginated documents, use an A4-like white page with realistic margins and document spacing.

The preview should remain visually close to the original document. Importing a file must not unnecessarily destroy its layout.

### Required interactions

- Zoom in and out.
- Page navigation.
- Text selection.
- Search.
- Highlighting.
- Comments.
- Basic manual editing.
- Word count and page count.
- Clear indication of the current page.

For DOCX documents, prioritize preservation of:

- Text and paragraphs.
- Headings.
- Tables.
- Images.
- Alignment.
- Font size.
- Bold, italic, and underline.
- Spacing.
- Page structure.
- Headers and footers where feasible.

The original file should remain available as an untouched source. The default save behavior should create a new **Seqotia Edited Version** rather than overwrite the original.

---

## 10. Seqotia AI Assistant

The right panel should be titled **Seqotia AI** with the subtitle:

> Tell me what you’d like to change.

The assistant is not a generic chat window. It is a document action surface. Each response should be grounded in the open document and should lead to a concrete, reviewable result.

### Example interaction

**User**

> เปลี่ยนวันที่เป็น 5 เมษายน 2569

**Seqotia AI**

> I found one matching date: **31 มีนาคม 2569**
>
> Change to: **5 เมษายน 2569**
>
> Location: Page 1, Document Information

Actions:

- Preview Change
- Apply Change
- Cancel

The assistant should communicate uncertainty when multiple matches exist. It should ask the user to choose rather than silently changing an ambiguous occurrence.

---

## 11. Natural-Language Editing

The AI must not blindly rewrite the entire document. Every editing request should follow a controlled sequence:

1. Understand the user’s instruction.
2. Analyze the document and its semantic structure.
3. Identify the precise target or targets.
4. Explain what was found.
5. Generate a proposed edit.
6. Highlight the affected area.
7. Allow the user to preview the change.
8. Apply the change only after approval.
9. Create a recoverable version.
10. Provide undo.

### Supported command examples

Users should be able to write commands such as:

- `เปลี่ยนวันที่เป็นวันนี้`
- `เปลี่ยนวันที่เป็น 10 เมษายน 2569`
- `แก้ชื่อผู้จัดทำเป็น นายสมชาย`
- `เปลี่ยนจำนวนเงินเป็น 1,500 บาท`
- `ลบย่อหน้าที่พูดถึงเครื่องถ่ายเอกสาร`
- `เพิ่มข้อความว่า ได้ดำเนินการเรียบร้อยแล้ว หลังย่อหน้าที่ 2`
- `ทำให้ข้อความนี้เป็นทางการขึ้น`
- `สรุปเอกสารนี้ให้สั้นลง`
- `ตรวจคำผิดให้หน่อย`
- `จัดรูปแบบเอกสารให้ดูเป็นทางการ`
- `สร้างหัวข้อให้ชัดเจนขึ้น`
- `เปลี่ยนทุกคำว่า บริษัท ABC เป็น บริษัท XYZ`
- `หาข้อมูลจำนวนเงินทั้งหมดในเอกสาร`
- `เอกสารนี้เกี่ยวกับอะไร`

The system should support Thai and English commands and should preserve the document’s language unless the user requests a translation or rewrite.

---

## 12. Change Proposal and Safety Model

Seqotia must never silently modify a document.

Every meaningful AI modification must show:

| Information | Example |
|---|---|
| What was found | `535 บาท` |
| Where it was found | `Page 1, Paragraph 6` |
| What will change | `535 บาท → 850 บาท` |
| Scope | One occurrence or all matching occurrences |
| Confidence | Clear, ambiguous, or requires review |
| Available actions | Preview, Apply, Cancel, Undo |

### Single change

**Found**

`535 บาท`

**Location**

Page 1, Paragraph 6

**Proposed change**

`535 บาท` → `850 บาท`

Actions:

- Preview
- Apply
- Cancel

After applying:

> Changed successfully.

Action:

- Undo

### Multiple changes

For multiple edits, show a reviewable list such as:

> **3 changes proposed**
>
> 1. Date
> 2. Company name
> 3. Amount

Actions:

- Review All
- Apply All
- Cancel All

Applying multiple changes should still create one clearly labeled version, with enough detail to restore or inspect each individual modification.

---

## 13. Change Highlighting

When Seqotia proposes a modification, the affected text should be highlighted directly in the document.

Use a subtle green or warm yellow highlight that remains legible on the page. The assistant panel should show a compact before-and-after explanation.

Example:

| Before | After |
|---|---|
| 535 บาท | 850 บาท |

The transition from original to proposed text may be animated briefly. Animation must clarify the change rather than distract from it.

---

## 14. Semantic Document Understanding

Seqotia should treat the document as a structured, meaningful object rather than a flat block of text.

The semantic layer should recognize concepts including:

- Dates.
- People.
- Organizations and companies.
- Addresses.
- Amounts and currencies.
- Subjects.
- Departments.
- Recipients and senders.
- Approvals.
- Signatures.
- Document numbers.
- Titles and headings.
- Paragraphs.
- Tables.
- Headers and footers.
- Attachments and attachment references.

Examples:

- “เปลี่ยนวันที่” should be interpreted as a date modification.
- “เปลี่ยนชื่อบริษัท” should be interpreted as an organization modification.
- “เปลี่ยนยอดเงิน” should be interpreted as a monetary-value modification.

The AI should use surrounding labels, position, formatting, and document context to distinguish similar values.

---

## 15. Document Analysis

When a document is uploaded, Seqotia should analyze it automatically and communicate progress in plain language.

Example progress sequence:

- Analyzing document…
- Document imported.
- Structure detected.
- 12 paragraphs found.
- 3 headings found.
- 2 signatures found.
- 1 monetary value found.
- 2 dates found.
- 1 attachment reference found.

### Structure tree

The left panel should expose a navigable structure tree similar to:

```text
DOCUMENT
├── Header
├── Document Information
│   ├── Organization
│   ├── Subject
│   ├── Date
│   └── Recipient
├── Main Content
├── Approval
├── Signature
└── Footer
```

Selecting an item in the tree should navigate to the corresponding area in the document when possible.

---

## 16. Internal Document Representation

The application should maintain an internal representation that preserves document structure and gives every meaningful text element a stable identifier.

Conceptually:

```text
Document
├── Metadata
├── Sections
├── Paragraphs
├── Tables
├── Runs
├── Images
├── Headers
├── Footers
└── Semantic Entities
```

Example identifiers:

```text
paragraph_12
run_12_03
entity_date_02
```

Stable identifiers allow the AI to target a precise element instead of regenerating or replacing the entire document. They also support highlighting, version history, comparison, validation, and undo.

---

## 17. AI Service Architecture

Create a provider-independent AI abstraction layer. The product should not be coupled to a single model vendor or expose API keys in the frontend.

A conceptual service interface may include:

```text
AIService
├── analyzeDocument()
├── understandCommand()
├── findTarget()
├── proposeEdit()
├── validateEdit()
├── summarizeDocument()
├── rewriteText()
└── checkGrammar()
```

The backend should own all model calls, validation, document access, and audit information. The frontend should receive structured results suitable for rendering in the assistant panel and document canvas.

If an API key is not available during prototyping, use deterministic mock responses that demonstrate the complete user journey. Mock responses should follow the same data shape as the eventual AI service.

At minimum, each proposed edit should include:

- Target identifier.
- Original text.
- Proposed text.
- Location.
- Change type.
- Confidence or ambiguity state.
- Preview metadata.
- Validation result.

---

## 18. Version History and Comparison

Every applied change should create a version history entry.

Example:

| Version | Time | Description |
|---|---|---|
| Version 4 | Today, 10:24 AM | Changed amount |
| Version 3 | Today, 10:20 AM | Changed company name |
| Version 2 | Today, 10:15 AM | Updated date |
| Version 1 | Original | Original document |

Each version should support:

- View.
- Restore.
- Compare.

### Compare mode

Provide a split-screen **Before | After** view. Changed text should be highlighted, and the interface should make the direction of each change unambiguous.

Examples:

```text
31 มีนาคม 2569  →  5 เมษายน 2569
535 บาท          →  850 บาท
```

The comparison view should work for a single edit and for a grouped set of edits.

---

## 19. Export and File Support

### MVP formats

- DOCX.
- PDF.
- TXT.

### Future formats

- PPTX.
- XLSX.
- ODT.
- Images with OCR.

Export should preserve formatting as closely as possible. The original document must never be overwritten unless the user explicitly requests that behavior.

Default behavior:

```text
Original document
        ↓
Seqotia Edited Version
```

The export flow should clearly show the selected format and destination and should retain the current version context.

---

## 20. Sample Document Validation

Use the provided Thai administrative work-contact and approval document as a primary semantic-editing test case.

The sample should exercise recognition of:

- Organization.
- Subject.
- Department.
- Recipient.
- Date.
- Approval checkbox.
- Attachment reference.
- Explanation or reason section.
- Company name.
- Repair cost.
- Approval section.
- Signatures.
- Document creator.
- Approver.

### Required test commands

1. `เปลี่ยนวันที่ 31 มีนาคม 2569 เป็น 5 เมษายน 2569`
2. `เปลี่ยนจำนวนเงิน 535 บาท เป็น 850 บาท`
3. `เปลี่ยนชื่อบริษัท ไอ แอนด์ เอ็ม คอนซัลท์จำกัด เป็น บริษัท ABC จำกัด`
4. `เปลี่ยนชื่อผู้จัดทำเป็น นายสมชาย ใจดี`
5. `ทำให้ข้อความส่วนเหตุผลกระชับขึ้น`
6. `ตรวจคำผิดในเอกสารนี้`

For every test, Seqotia must show exactly what it intends to change before applying it.

---

## 21. Global AI Command Bar

The global command bar is one of Seqotia’s signature features. It should be inspired by Spotlight and Raycast while remaining visually consistent with the document workspace.

### Invocation

- `⌘ K` opens the command bar.
- `Esc` closes it.
- `Enter` submits the command.
- Arrow keys navigate suggestions.

### Prompt

> What would you like to change?

Example:

> เปลี่ยนวันที่เป็นวันนี้

### Suggested actions

- Change text.
- Rewrite.
- Summarize.
- Translate.
- Format.
- Check grammar.
- Extract information.
- Create section.

The command bar should feel immediate. It should open quickly, focus the input automatically, and return a grounded document action rather than a disconnected chat response.

---

## 22. Trust and Privacy Experience

Seqotia handles potentially sensitive documents. The interface should communicate care without making unrealistic security claims.

Use precise, verifiable language such as:

- Document protected.
- Changes are reversible.
- Original document preserved.
- Workspace status: Protected.

Avoid vague claims such as “completely secure” or “military-grade” unless they can be technically and legally substantiated.

Settings should include:

- AI processing preferences.
- Privacy controls.
- Document storage.
- Auto-save.
- Version history.
- Export preferences.

The user should always understand whether a document is saved, being analyzed, awaiting review, or already updated.

---

## 23. Empty State

When no document is open, show a calm and inviting empty state rather than a blank canvas.

### Content

- Large centered Seqotia leaf logo.
- Heading: **What are we working on?**
- Subtitle: **Drop a document here, or tell Seqotia what you need.**
- Primary action: **Upload Document**.
- Secondary action: **Create Document**.
- Drag-and-drop label: **Drop your document here**.

The empty state should make the first action obvious while preserving the product’s quiet, premium character.

---

## 24. Motion and Interaction Design

Use motion to communicate state and continuity, not to decorate the interface.

Recommended interactions include:

- A file becoming a floating upload card and then a document page.
- A restrained processing indicator during analysis.
- A target highlight that transitions into a preview state.
- Smooth sidebar and panel transitions.
- Short button hover and focus feedback.
- A brief confirmation after an applied change.

Animations should be short, subtle, and interruptible. Avoid excessive parallax, looping effects, or attention-seeking transitions.

The overall feeling should remain calm and professional.

---

## 25. Keyboard Shortcuts

Support the following macOS shortcuts:

| Shortcut | Action |
|---|---|
| `⌘ O` | Open document |
| `⌘ S` | Save current version |
| `⌘ Z` | Undo |
| `⌘ ⇧ Z` | Redo |
| `⌘ K` | Open AI command bar |
| `⌘ F` | Search document |
| `Esc` | Close active overlay or cancel preview |

The interface should expose shortcuts contextually without overwhelming new users.

---

## 26. Implementation Requirements

Build an actual functional prototype, not a set of static mockups.

The prototype must support the following complete loop:

1. Upload a document.
2. Display the document.
3. Extract text.
4. Detect and show document structure.
5. Open the AI assistant.
6. Enter a natural-language command.
7. Generate a structured proposed change.
8. Highlight the affected text.
9. Preview the change.
10. Apply or cancel the change.
11. Undo the change.
12. Save a version-history entry.
13. Export the edited document.

Use realistic sample data from the beginning, but keep the architecture ready for real document parsing and model integration.

---

## 27. Acceptance Criteria

The prototype is successful when a new user can complete the following scenario without assistance:

1. Open Seqotia.
2. Upload the Thai sample document.
3. See the document rendered in the workspace.
4. See the detected structure in the left panel.
5. Enter `เปลี่ยนจำนวนเงิน 535 บาท เป็น 850 บาท`.
6. See the exact match and its location.
7. See the original text highlighted in the document.
8. Preview the proposed replacement.
9. Apply the change.
10. See a success state and an updated document.
11. Undo the change.
12. Restore or compare versions.
13. Export a new edited file without changing the original.

The experience should be understandable at a glance and should never require the user to guess whether a change has occurred.

---

## 28. Final Product Standard

Seqotia should feel extremely fast, deliberate, and dependable.

Its most important product equation is:

```text
A real document
+ structural understanding
+ natural-language instruction
+ precise target detection
+ visible preview
+ explicit approval
+ complete reversibility
= Seqotia
```

The product should not stop at the dashboard. The defining value is the interaction between the real document and the AI editing workflow.

Build the interface with realistic sample data, then connect the functional document pipeline. Keep secondary features subordinate to the central promise:

> **Upload a document. Tell Seqotia what to change. See exactly what will happen. Apply it with confidence.**

---

## References

[1]: https://developer.apple.com/design/human-interface-guidelines/ "Apple Human Interface Guidelines"
[2]: https://www.apple.com/macos/ "macOS product page"
