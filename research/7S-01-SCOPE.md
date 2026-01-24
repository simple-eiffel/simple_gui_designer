# 7S-01: SCOPE - simple_gui_designer

**Document**: 7S-01-SCOPE.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Problem Domain

simple_gui_designer provides a web-based GUI design tool for creating application specifications:

1. **Visual Design** - Web interface for designing GUI layouts
2. **Specification Management** - Create, edit, and manage GUI specs
3. **Screen/Control Hierarchy** - Organize screens with controls
4. **Export Capabilities** - Generate production-ready specifications

## Target Users

- **Application Designers**: Creating GUI layouts visually
- **Developers**: Defining application structure before coding
- **Product Managers**: Reviewing and annotating designs
- **AI Integration**: Collecting AI suggestions for improvement

## Boundaries

### In Scope
- Web-based design interface (HTMX-powered)
- Spec creation and management
- Screen and control editing
- Container layouts (cards, tabs)
- JSON specification format
- Export to final production specs
- Local file storage

### Out of Scope
- Actual GUI rendering (design-time only)
- Code generation from specs
- Real-time collaboration
- Cloud storage

## Dependencies

- simple_web_server: HTTP server
- simple_htmx: HTML generation with HTMX
- simple_json: JSON serialization

## Integration Points

- GUI_DESIGNER_SERVER: Main server class
- GUI_DESIGNER_SPEC: Spec data model
- HTMX-based web interface
