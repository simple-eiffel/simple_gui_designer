# 7S-04: SIMPLE-STAR - simple_gui_designer

**Document**: 7S-04-SIMPLE-STAR.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Ecosystem Integration

### Dependencies (Incoming)

| Library | Usage |
|---------|-------|
| simple_web_server | HTTP server infrastructure |
| simple_htmx | HTML generation with HTMX |
| simple_json | JSON serialization |

### Dependents (Outgoing)

| User | Usage |
|------|-------|
| Developers | GUI specification creation |
| AI tools | Consuming specs for code generation |

### Integration Patterns

1. **Starting the Designer**
```eiffel
local
    server: GUI_DESIGNER_SERVER
do
    create server.make (8080)
    server.start
    -- Open http://localhost:8080 in browser
end
```

2. **Spec Model Usage**
```eiffel
local
    spec: GUI_DESIGNER_SPEC
    screen: GUI_DESIGNER_SCREEN
    control: GUI_DESIGNER_CONTROL
do
    create spec.make ("MyApp")
    create screen.make ("main", "Main Screen")
    create control.make ("btn_save", "button")
    control.set_property ("label", "Save")
    screen.add_control (control)
    spec.add_screen (screen)
end
```

3. **Export Pattern**
```eiffel
local
    spec: GUI_DESIGNER_SPEC
    final: GUI_FINAL_SPEC
do
    spec.mark_finalized
    final := spec.to_final_spec
    -- Use final spec for production
end
```

### API Compatibility

- Follows simple_* naming conventions
- Uses SIMPLE_JSON_SERIALIZABLE for JSON
- Handler mixin pattern for organization
- HTMX patterns for UI
