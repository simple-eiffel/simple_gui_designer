# 7S-06: SIZING - simple_gui_designer

**Document**: 7S-06-SIZING.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Implementation Size

### Source Metrics

| Directory | Files | Lines (approx) |
|-----------|-------|----------------|
| src/server/ | 10 | 2,500 |
| src/spec/ | 6 | 1,200 |
| src/app/ | 1 | 100 |
| src/shared/ | 1 | 150 |
| testing/ | 3 | 300 |
| **Total** | 21 | ~4,250 |

### File Breakdown

**Server Handlers:**
- gui_designer_server.e (225 lines)
- gds_spec_handlers.e (300 lines)
- gds_screen_handlers.e (300 lines)
- gds_control_handlers.e (350 lines)
- gds_container_handlers.e (200 lines)
- gds_htmx_handlers.e (250 lines)
- gds_export_handlers.e (150 lines)
- gds_download_upload_handlers.e (200 lines)
- gds_static_html.e (300 lines)
- gds_html_renderer.e (200 lines)

**Spec Model:**
- gui_designer_spec.e (285 lines)
- gui_designer_screen.e (200 lines)
- gui_designer_control.e (250 lines)
- gui_designer_tab_panel.e (150 lines)
- gui_final_spec.e (200 lines)
- gui_api_endpoint.e (100 lines)

### Complexity Assessment

| Component | Complexity | Rationale |
|-----------|------------|-----------|
| Server | Medium | Handler organization |
| Handlers | Low | CRUD operations |
| Spec Model | Medium | JSON serialization |
| HTML Rendering | Medium | HTMX generation |

### Development Effort

- **Core Server**: 20 hours
- **Handlers**: 24 hours
- **Spec Model**: 12 hours
- **UI/HTML**: 16 hours
- **Testing**: 8 hours
- **Total**: ~80 hours
