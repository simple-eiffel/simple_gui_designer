# 7S-02: STANDARDS - simple_gui_designer

**Document**: 7S-02-STANDARDS.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Applicable Standards

### Web Standards

1. **HTML5**
   - Reference: W3C HTML5 Specification
   - Modern markup for UI
   - Semantic elements

2. **CSS3**
   - Reference: W3C CSS Specification
   - Styling and layout
   - Responsive design

3. **HTMX**
   - Reference: https://htmx.org/
   - AJAX without JavaScript
   - Partial page updates

### Data Format

1. **JSON (RFC 7159)**
   - Specification storage
   - API responses
   - Import/export format

### HTTP

1. **RFC 7231 - HTTP/1.1**
   - RESTful API design
   - CRUD operations
   - Form handling

### GUI Design Patterns

1. **Screen/Control Hierarchy**
   - App contains Screens
   - Screens contain Controls
   - Controls can be containers

2. **Designer/Final Spec Split**
   - Designer spec for editing
   - Final spec for production

## Implementation Compliance

| Standard | Compliance Level | Notes |
|----------|------------------|-------|
| HTML5 | Full | Via simple_htmx |
| HTMX | Full | All UI interactions |
| JSON | Full | Via simple_json |
| HTTP/REST | Full | Via simple_web_server |
