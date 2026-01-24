# S02: CLASS CATALOG - simple_gui_designer

**Document**: S02-CLASS-CATALOG.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Server Classes

| Class | Type | Description |
|-------|------|-------------|
| GUI_DESIGNER_SERVER | Effective | Main server with all handlers |
| GDS_SHARED_STATE | Deferred | Shared state interface |
| GDS_SPEC_HANDLERS | Effective | Spec CRUD handlers |
| GDS_SCREEN_HANDLERS | Effective | Screen CRUD handlers |
| GDS_CONTROL_HANDLERS | Effective | Control CRUD handlers |
| GDS_CONTAINER_HANDLERS | Effective | Container operations |
| GDS_HTMX_HANDLERS | Effective | HTMX partial responses |
| GDS_EXPORT_HANDLERS | Effective | Export functionality |
| GDS_DOWNLOAD_UPLOAD_HANDLERS | Effective | File operations |
| GDS_STATIC_HTML | Effective | Static page templates |
| GDS_HTML_RENDERER | Effective | HTML generation helpers |

## Model Classes (Designer)

| Class | Type | Description |
|-------|------|-------------|
| GUI_DESIGNER_SPEC | Effective | Working specification |
| GUI_DESIGNER_SCREEN | Effective | Screen definition |
| GUI_DESIGNER_CONTROL | Effective | Control definition |
| GUI_DESIGNER_TAB_PANEL | Effective | Tab container |

## Model Classes (Final/Production)

| Class | Type | Description |
|-------|------|-------------|
| GUI_FINAL_SPEC | Effective | Production specification |
| GUI_FINAL_SCREEN | Effective | Production screen |
| GUI_FINAL_CONTROL | Effective | Production control |
| GUI_API_ENDPOINT | Effective | API endpoint definition |

## Utility Classes

| Class | Type | Description |
|-------|------|-------------|
| GUI_DESIGNER_LOGGER | Effective | Logging utility |
| GUI_DESIGNER_APP | Effective | Application entry |

## Inheritance Hierarchy

```
GDS_SHARED_STATE (deferred)
├── GDS_SPEC_HANDLERS
├── GDS_SCREEN_HANDLERS
├── GDS_CONTROL_HANDLERS
├── GDS_CONTAINER_HANDLERS
├── GDS_HTMX_HANDLERS
├── GDS_EXPORT_HANDLERS
├── GDS_DOWNLOAD_UPLOAD_HANDLERS
└── GDS_STATIC_HTML
    └── GDS_HTML_RENDERER

GUI_DESIGNER_SERVER
    inherits all handler classes (multiple inheritance)
```
