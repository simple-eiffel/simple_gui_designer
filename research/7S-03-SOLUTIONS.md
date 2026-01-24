# 7S-03: SOLUTIONS - simple_gui_designer

**Document**: 7S-03-SOLUTIONS.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## Existing Solutions Comparison

### GUI Design Tools

| Solution | Platform | Pros | Cons |
|----------|----------|------|------|
| Figma | Web | Full-featured, collaborative | External service, not Eiffel |
| Sketch | macOS | Professional design | macOS only, not Eiffel |
| Qt Designer | Desktop | Qt integration | Different toolkit |
| Glade | Desktop | GTK integration | Different toolkit |
| simple_gui_designer | Web | Eiffel-native, simple | Basic features |

### Why Build Our Own?

- Eiffel-specific: Generates Eiffel-compatible specs
- Self-hosted: No external dependencies
- HTMX-powered: Demonstrates simple_htmx usage
- Customizable: Tailored to our workflow
- AI-ready: Built-in AI suggestion support

## Design Decisions

1. **Web Interface**: Accessible from any browser
2. **HTMX**: No JavaScript frameworks needed
3. **JSON Specs**: Easy to version control
4. **Two-Stage Specs**: Designer vs Final
5. **Multiple Inheritance**: Handler mixins for organization

## Trade-offs

- No real-time collaboration (single user)
- No visual preview of rendered GUI
- Local storage only (no cloud sync)
- Basic feature set (not Figma-level)

## Recommendation

Use simple_gui_designer for:
- Prototyping Eiffel application UIs
- Creating specifications for AI-assisted development
- Learning HTMX patterns
