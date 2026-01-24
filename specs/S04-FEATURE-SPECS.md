# S04: FEATURE SPECS - simple_gui_designer

**Document**: S04-FEATURE-SPECS.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## GUI_DESIGNER_SERVER Features

### Initialization
| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (a_port: INTEGER) | Create server on port |

### Server Control
| Feature | Signature | Description |
|---------|-----------|-------------|
| start | | Start server (blocking) |

### Access
| Feature | Signature | Description |
|---------|-----------|-------------|
| port | INTEGER | Server port |
| server | SIMPLE_WEB_SERVER | HTTP server |
| specs | HASH_TABLE[...] | All loaded specs |
| current_spec | GUI_DESIGNER_SPEC | Active spec |
| specs_directory | STRING | Spec file directory |

## GUI_DESIGNER_SPEC Features

### Initialization
| Feature | Signature | Description |
|---------|-----------|-------------|
| make | (STRING_32) | Create empty spec |
| make_from_json | (SIMPLE_JSON_OBJECT) | Load from JSON |

### Access
| Feature | Signature | Description |
|---------|-----------|-------------|
| app_name | STRING_32 | Application name |
| version | INTEGER | Revision number |
| screens | ARRAYED_LIST[...] | All screens |
| global_notes | ARRAYED_LIST[STRING_32] | User notes |
| ai_suggestions | ARRAYED_LIST[STRING_32] | AI suggestions |
| is_finalized | BOOLEAN | Approved for production? |

### Query
| Feature | Signature | Description |
|---------|-----------|-------------|
| screen_by_id | (STRING_32): detachable SCREEN | Find screen |
| screen_ids | ARRAYED_LIST[STRING_32] | All screen IDs |

### Modification
| Feature | Signature | Description |
|---------|-----------|-------------|
| add_screen | (GUI_DESIGNER_SCREEN) | Add screen |
| remove_screen | (STRING_32) | Remove by ID |
| add_global_note | (STRING_32) | Add note |
| add_ai_suggestion | (STRING_32) | Add suggestion |
| clear_ai_suggestions | | Clear suggestions |
| increment_version | | Bump version |
| mark_finalized | | Mark as final |

### Conversion
| Feature | Signature | Description |
|---------|-----------|-------------|
| to_final_spec | GUI_FINAL_SPEC | Convert to production |
| to_json | SIMPLE_JSON_OBJECT | Serialize |
| apply_json | (SIMPLE_JSON_OBJECT) | Apply changes |

## GUI_DESIGNER_SCREEN Features

### Access
| Feature | Signature | Description |
|---------|-----------|-------------|
| id | STRING_32 | Screen identifier |
| title | STRING_32 | Display title |
| controls | ARRAYED_LIST[...] | Child controls |

### Modification
| Feature | Signature | Description |
|---------|-----------|-------------|
| add_control | (GUI_DESIGNER_CONTROL) | Add control |
| remove_control | (STRING_32) | Remove by ID |
| control_by_id | (STRING_32): detachable | Find control |
