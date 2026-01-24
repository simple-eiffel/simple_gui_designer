# S01: PROJECT INVENTORY - simple_gui_designer

**Document**: S01-PROJECT-INVENTORY.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Project Structure

```
simple_gui_designer/
├── src/
│   ├── app/
│   │   └── gui_designer_app.e        -- Application entry
│   ├── server/
│   │   ├── gui_designer_server.e     -- Main server
│   │   └── handlers/
│   │       ├── gds_shared_state.e    -- Shared state base
│   │       ├── gds_spec_handlers.e   -- Spec CRUD
│   │       ├── gds_screen_handlers.e -- Screen CRUD
│   │       ├── gds_control_handlers.e-- Control CRUD
│   │       ├── gds_container_handlers.e-- Container ops
│   │       ├── gds_htmx_handlers.e   -- HTMX partials
│   │       ├── gds_export_handlers.e -- Export/finalize
│   │       ├── gds_download_upload_handlers.e
│   │       ├── gds_static_html.e     -- Static pages
│   │       └── gds_html_renderer.e   -- HTML generation
│   ├── spec/
│   │   ├── gui_designer_spec.e       -- Main spec class
│   │   ├── gui_designer_screen.e     -- Screen class
│   │   ├── gui_designer_control.e    -- Control class
│   │   ├── gui_designer_tab_panel.e  -- Tab container
│   │   ├── gui_final_spec.e          -- Production spec
│   │   ├── gui_final_screen.e        -- Final screen
│   │   ├── gui_final_control.e       -- Final control
│   │   └── gui_api_endpoint.e        -- API endpoint def
│   └── shared/
│       └── gui_designer_logger.e     -- Logging utility
├── testing/
│   ├── test_app.e                    -- Test runner
│   ├── test_gui_designer.e           -- Test cases
│   └── lib_tests.e                   -- Library tests
├── specs/                            -- Generated specs
├── research/                         -- 7S documents
├── specs/                            -- Specification docs
└── simple_gui_designer.ecf           -- ECF configuration
```

## Key Files

### Server Layer
| File | Purpose |
|------|---------|
| gui_designer_server.e | Main server, route setup |
| gds_*_handlers.e | Request handlers by function |
| gds_html_renderer.e | HTMX/HTML generation |

### Model Layer
| File | Purpose |
|------|---------|
| gui_designer_spec.e | Designer-time specification |
| gui_designer_screen.e | Screen with controls |
| gui_designer_control.e | UI control definition |
| gui_final_spec.e | Production specification |
