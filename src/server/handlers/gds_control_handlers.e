note
	description: "[
		Control API handlers for GUI Designer.

		Handles CRUD operations for controls within a screen:
		- GET /api/palette - Get available control types
		- POST /api/specs/{spec_id}/screens/{screen_id}/controls - Add control
		- PUT /api/specs/{spec_id}/screens/{screen_id}/controls/{control_id} - Update control
		- DELETE /api/specs/{spec_id}/screens/{screen_id}/controls/{control_id} - Delete control
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_CONTROL_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_control_routes
			-- Register control API routes with server.
		do
			server.on_get ("/api/palette", agent handle_control_palette)
			server.on_post ("/api/specs/{spec_id}/screens/{screen_id}/controls", agent handle_add_control)
			server.on_put ("/api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}", agent handle_update_control)
			server.on_delete ("/api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}", agent handle_delete_control)
		end

feature -- Control API Handlers

	handle_control_palette (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Return available control types.
		do
			log_request ("GET", "/api/palette")
			log_debug ("[API] Serving control palette JSON")
			a_response.send_json (control_palette_json)
		end

	handle_add_control (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Add control to screen.
		local
			l_control: GUI_DESIGNER_CONTROL
			l_spec_id, l_screen_id: detachable STRING_32
		do
			log_request ("POST", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			if attached screen_in_spec (l_spec_id, l_screen_id) as l_screen then
				if attached a_request.body_as_json as l_json and then
				   l_json.has_all_keys (<<"id", "type">>) then
					create l_control.make_from_json (l_json)
					log_control_added (s8 (l_control.id), s8 (l_control.control_type), s8 (l_screen_id))
					l_screen.add_control (l_control)
					send_created_json (a_response, l_control.to_json.as_json)
				else
					send_bad_request (a_response, "id and type required")
				end
			else
				send_not_found (a_response, "Screen", l_screen_id)
			end
		end

	handle_update_control (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Update control from form data or JSON.
		local
			l_form: HASH_TABLE [STRING_32, STRING_32]
			l_form_fields: STRING
			l_spec_id, l_screen_id, l_control_id: detachable STRING_32
		do
			log_request ("PUT", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_control_id := a_request.path_parameter ("control_id")
			if attached control_in_screen (l_spec_id, l_screen_id, l_control_id) as l_control then
				log_debug ("[CONTROL] Found control " + s8 (l_control_id) + " BEFORE update: row=" + l_control.grid_row.out + " col=" + l_control.grid_col.out + " span=" + l_control.col_span.out)
				-- Try JSON first, then form data
				if attached a_request.body_as_json as l_json then
					log_debug ("[CONTROL] Applying JSON update to " + s8 (l_control_id))
					l_control.apply_json (l_json)
					log_control_updated (s8 (l_control_id), l_control.grid_row, l_control.grid_col, l_control.col_span)
					a_response.send_json (l_control.to_json.as_json)
				else
					-- Form data from HTMX
					l_form := a_request.form_data
					if not l_form.is_empty then
						create l_form_fields.make_empty
						across l_form as al_field loop
							l_form_fields.append (s8 (@al_field.key) + "=" + s8 (al_field) + " ")
						end
						log_form_data (l_form_fields)
						apply_form_to_control (l_control, l_form)
						log_control_updated (s8 (l_control_id), l_control.grid_row, l_control.grid_col, l_control.col_span)
						a_response.send_json (l_control.to_json.as_json)
					else
						send_bad_request (a_response, "No data received")
					end
				end
			else
				send_not_found (a_response, "Control", l_control_id)
			end
		end

	handle_delete_control (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Delete control.
		local
			l_spec_id, l_screen_id, l_control_id: detachable STRING_32
		do
			log_request ("DELETE", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_control_id := a_request.path_parameter ("control_id")
			if attached screen_in_spec (l_spec_id, l_screen_id) as l_screen and attached l_control_id then
				log_control_deleted (s8 (l_control_id), s8 (l_screen_id))
				l_screen.remove_control (l_control_id)
				a_response.set_no_content
				a_response.send_empty
			else
				send_not_found (a_response, "Screen", l_screen_id)
			end
		end

feature {NONE} -- Implementation

	apply_form_to_control (a_control: GUI_DESIGNER_CONTROL; a_form: HASH_TABLE [STRING_32, STRING_32])
			-- Apply form field values to control.
		do
			log_debug ("[FORM->CONTROL] Processing form for " + s8 (a_control.id))
			if attached a_form.item ("label") as l_label then
				log_debug ("[FORM->CONTROL] Setting label: " + s8 (l_label))
				a_control.set_label (l_label)
			end
			if attached a_form.item ("row") as l_row and then l_row.is_integer then
				log_debug ("[FORM->CONTROL] Setting row: " + s8 (l_row))
				a_control.set_grid_row (l_row.to_integer)
			end
			if attached a_form.item ("col") as l_col and then l_col.is_integer then
				log_debug ("[FORM->CONTROL] Setting col: " + s8 (l_col))
				a_control.set_grid_col (l_col.to_integer)
			end
			if attached a_form.item ("col_span") as l_span and then l_span.is_integer then
				log_debug ("[FORM->CONTROL] Setting col_span: " + s8 (l_span))
				a_control.set_col_span (l_span.to_integer)
			end
			if attached a_form.item ("notes") as l_notes then
				log_debug ("[FORM->CONTROL] Setting notes (length=" + l_notes.count.out + ")")
				a_control.set_notes_from_string (l_notes)
			end
		end

feature -- Deferred

	control_palette_json: STRING
			-- JSON string of available control types.
		deferred
		end

end
