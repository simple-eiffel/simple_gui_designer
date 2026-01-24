# S05: CONSTRAINTS - simple_gui_designer

**Document**: S05-CONSTRAINTS.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Technical Constraints

### Server Constraints

1. **Port**
   - Must be between 1 and 65535
   - Default: 8080
   - Must not be in use

2. **Specs Directory**
   - Fixed at D:\prod\simple_gui_designer\specs
   - Must exist and be writable
   - JSON files only

### Spec Constraints

1. **App Name**
   - Must not be empty
   - Used as identifier

2. **Version**
   - Must be >= 1
   - Increments on submit

3. **Screens**
   - ID must be unique within spec
   - ID must not be empty

4. **Controls**
   - ID must be unique within screen
   - Type must not be empty
   - Valid types: button, input, label, etc.

### JSON Constraints

1. **Required Fields**
   - Spec: "app" or "app_name"
   - Screen: "id"
   - Control: "id", "type"

2. **Format**
   - UTF-8 encoding
   - Valid JSON syntax

### UI Constraints

1. **HTMX**
   - Requires HTMX-capable browser
   - JavaScript must be enabled

2. **Browser Support**
   - Modern browsers (Chrome, Firefox, Edge)
   - No IE support

### Performance Constraints

- Single-threaded HTTP server
- Synchronous request handling
- Specs loaded into memory

## Platform Constraints

| Platform | Support |
|----------|---------|
| Windows | Full |
| Linux | Full |
| macOS | Full |
