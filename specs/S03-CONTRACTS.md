# S03: CONTRACTS - simple_gui_designer

**Document**: S03-CONTRACTS.md
**Library**: simple_gui_designer
**Status**: BACKWASH (reverse-engineered from implementation)
**Date**: 2026-01-23

---

## GUI_DESIGNER_SERVER Contracts

### Class Invariant
```eiffel
invariant
    specs_attached: specs /= Void
    current_spec_attached: current_spec /= Void
```

### Creation
```eiffel
make (a_port: INTEGER)
    require
        valid_port: a_port > 0 and a_port < 65536
    ensure
        port_set: port = a_port
        specs_created: specs /= Void
        current_spec_created: current_spec /= Void
```

## GUI_DESIGNER_SPEC Contracts

### Class Invariant
```eiffel
invariant
    app_name_not_empty: not app_name.is_empty
    version_positive: version >= 1
    screens_attached: screens /= Void
```

### Creation
```eiffel
make (a_app_name: STRING_32)
    require
        name_not_empty: not a_app_name.is_empty
    ensure
        name_set: app_name.same_string (a_app_name)
        version_one: version = 1
        not_finalized: not is_finalized

make_from_json (a_json: SIMPLE_JSON_OBJECT)
    require
        has_app: a_json.has_key ("app") or a_json.has_key ("app_name")
```

### Modification
```eiffel
add_screen (a_screen: GUI_DESIGNER_SCREEN)
    require
        unique_id: screen_by_id (a_screen.id) = Void
    ensure
        added: screens.has (a_screen)

add_global_note (a_note: STRING_32)
    require
        not_empty: not a_note.is_empty

increment_version
    ensure
        incremented: version = old version + 1
```

### Conversion
```eiffel
to_final_spec: GUI_FINAL_SPEC
    require
        is_finalized: is_finalized
    ensure
        result_attached: Result /= Void
```

## GUI_DESIGNER_SCREEN Contracts

```eiffel
invariant
    id_not_empty: not id.is_empty
    title_attached: title /= Void
    controls_attached: controls /= Void
```

## GUI_DESIGNER_CONTROL Contracts

```eiffel
invariant
    id_not_empty: not id.is_empty
    control_type_not_empty: not control_type.is_empty
```
