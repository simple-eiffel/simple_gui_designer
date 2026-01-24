# S06: BOUNDARIES - simple_gui_designer

**Document**: S06-BOUNDARIES.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## System Boundaries

```
+---------------------------------------------+
|              Web Browser                    |
|    (HTMX-powered UI)                        |
+---------------------------------------------+
                     |
                     v (HTTP)
+---------------------------------------------+
|          GUI_DESIGNER_SERVER                |
|  +---------------+  +-------------------+   |
|  | Route Handlers|  | HTML Renderer     |   |
|  | (GDS_*)       |  | (HTMX_FACTORY)   |   |
|  +---------------+  +-------------------+   |
+---------------------------------------------+
                     |
                     v
+---------------------------------------------+
|              Spec Model                     |
|  +---------------+  +-------------------+   |
|  | GUI_DESIGNER_ |  | GUI_FINAL_*       |   |
|  | SPEC/SCREEN/  |  | (Production)      |   |
|  | CONTROL       |  |                   |   |
|  +---------------+  +-------------------+   |
+---------------------------------------------+
                     |
                     v
+---------------------------------------------+
|              File System                    |
|    (JSON spec files)                        |
+---------------------------------------------+
```

## Interface Boundaries

### Public API (HTTP Endpoints)

**Pages:**
- GET / - Index page
- GET /designer - Designer page

**Spec Operations:**
- GET/POST/DELETE /api/specs
- GET/PUT/DELETE /api/specs/:id

**Screen Operations:**
- POST/PUT/DELETE /api/specs/:id/screens

**Control Operations:**
- POST/PUT/DELETE /api/specs/:id/screens/:sid/controls

**Export:**
- POST /api/specs/:id/finalize
- GET /api/specs/:id/export

### Internal Classes

- Handler implementation details
- HTML generation internals
- JSON serialization

## Data Boundaries

### Input
- HTTP requests (form data, JSON)
- JSON spec files

### Output
- HTML pages (HTMX partials)
- JSON responses
- JSON spec files

## Trust Boundaries

- Browser input is untrusted
- Server validates all input
- File system access restricted
