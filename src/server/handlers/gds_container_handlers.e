note
	description: "[
		Container control handlers for GUI Designer.

		Handles operations for container controls (cards, tabs):
		- POST /api/specs/{spec_id}/screens/{screen_id}/controls/{parent_id}/children - Add child
		- PUT /api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}/active-tab - Set active tab
		- POST /api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}/tabs - Add tab
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_CONTAINER_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_container_routes
			-- Register container API routes with server.
		do
			server.on_post ("/api/specs/{spec_id}/screens/{screen_id}/controls/{parent_id}/children", agent handle_add_child_control)
			server.on_put ("/api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}/active-tab", agent handle_set_active_tab)
			server.on_post ("/api/specs/{spec_id}/screens/{screen_id}/controls/{control_id}/tabs", agent handle_add_tab)
		end

feature -- Container Control Handlers

	handle_add_child_control (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Add child control to a container (card or tab panel).
		local
			l_control: GUI_DESIGNER_CONTROL
			l_panel_idx: INTEGER
			l_spec_id, l_screen_id, l_parent_id: detachable STRING_32
			l_parent: detachable GUI_DESIGNER_CONTROL
			l_json: detachable SIMPLE_JSON_OBJECT
		do
			log_request ("POST", s8 (a_request.path))
			log_debug ("[CONTAINER] === handle_add_child_control START ===")

			-- Extract path parameters with logging
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_parent_id := a_request.path_parameter ("parent_id")

			log_debug ("[CONTAINER] spec_id=" + s8 (l_spec_id))
			log_debug ("[CONTAINER] screen_id=" + s8 (l_screen_id))
			log_debug ("[CONTAINER] parent_id=" + s8 (l_parent_id))

			-- Lookup parent container using helper
			if attached screen_in_spec (l_spec_id, l_screen_id) as l_screen then
				log_debug ("[CONTAINER] Found screen: " + s8 (l_screen.id) + " with " + l_screen.controls.count.out + " controls")
				-- List all controls for debugging
				across l_screen.controls as c loop
					log_debug ("[CONTAINER] Screen control: " + s8 (c.id) + " type=" + s8 (c.control_type) + " is_container=" + c.is_container.out)
				end
				if attached l_parent_id then
					l_parent := l_screen.control_by_id (l_parent_id)
				end
			end

			-- Get JSON body
			l_json := a_request.body_as_json
			log_debug ("[CONTAINER] JSON body: " + if attached l_json then "found" else "nil" end)

			-- Now do the actual work
			if attached l_parent and then l_parent.is_container and then attached l_json and then attached l_parent_id then
				log_debug ("[CONTAINER] Parent is valid container, processing add child")
				if l_json.has_all_keys (<<"id", "type">>) then
					if attached l_json.string_item ("id") as l_id and then
					   attached l_json.string_item ("type") as l_type then
						log_debug ("[CONTAINER] Creating child: id=" + s8 (l_id) + " type=" + s8 (l_type))
						create l_control.make (l_id, l_type)
						if attached l_json.optional_string ("label") as l_label then
							l_control.set_label (l_label)
						end
						l_control.set_grid_position (
							l_json.optional_integer ("grid_row", 1).to_integer_32,
							l_json.optional_integer ("grid_col", 1).to_integer_32
						)
						l_control.set_col_span (l_json.optional_integer ("col_span", 3).to_integer_32)

						if l_parent.is_tabs then
							-- Add to specific tab panel
							l_panel_idx := l_json.optional_integer ("panel_index", 1).to_integer_32.max (1).min (l_parent.tab_panels.count)
							log_debug ("[CONTAINER] Adding to tab panel " + l_panel_idx.out + " of " + l_parent.tab_panels.count.out)
							l_parent.add_child_to_tab (l_control, l_panel_idx)
							log_info ("[CONTAINER] Added '" + s8 (l_id) + "' to tab " + l_panel_idx.out + " of '" + s8 (l_parent_id) + "'")
						else
							-- Add to card children
							log_debug ("[CONTAINER] Adding to card children (before: " + l_parent.children.count.out + ")")
							l_parent.add_child (l_control)
							log_debug ("[CONTAINER] Added to card children (after: " + l_parent.children.count.out + ")")
							log_info ("[CONTAINER] Added '" + s8 (l_id) + "' to card '" + s8 (l_parent_id) + "'")
						end

						a_response.set_status (201)
						a_response.send_json (l_control.to_json.representation)
					else
						send_bad_request (a_response, "Missing required fields")
					end
				else
					send_bad_request (a_response, "JSON must have id and type")
				end
			else
				log_debug ("[CONTAINER] FAILED: parent=" + (if attached l_parent then "found" else "nil" end) + " is_container=" + (if attached l_parent then l_parent.is_container.out else "n/a" end) + " json=" + (if attached l_json then "found" else "nil" end))
				send_not_found (a_response, "Container", l_parent_id)
			end
			log_debug ("[CONTAINER] === handle_add_child_control END ===")
		end

	handle_set_active_tab (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Set active tab index for tabs control.
		local
			l_tab_idx: INTEGER
			l_spec_id, l_screen_id, l_control_id: detachable STRING_32
		do
			log_request ("PUT", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_control_id := a_request.path_parameter ("control_id")
			if attached control_in_screen (l_spec_id, l_screen_id, l_control_id) as l_control and then
			   l_control.is_tabs and then
			   attached a_request.body_as_json as l_json then
				l_tab_idx := l_json.optional_integer ("active_tab", 1).to_integer_32.max (1).min (l_control.tab_panels.count)
				log_debug ("[TABS] Setting active tab to " + l_tab_idx.out + " for '" + s8 (l_control_id) + "'")
				l_control.set_active_tab (l_tab_idx)
				a_response.send_json ("{%"active_tab%":" + l_tab_idx.out + "}")
			else
				send_not_found (a_response, "Tabs control", l_control_id)
			end
		end

	handle_add_tab (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Add new tab panel to tabs control.
		local
			l_tab_name: STRING_32
			l_spec_id, l_screen_id, l_control_id: detachable STRING_32
		do
			log_request ("POST", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_control_id := a_request.path_parameter ("control_id")
			if attached control_in_screen (l_spec_id, l_screen_id, l_control_id) as l_control and then
			   l_control.is_tabs and then
			   attached a_request.body_as_json as l_json then
				if attached l_json.string_item ("name") as l_name then
					l_tab_name := l_name
				else
					l_tab_name := "Tab " + (l_control.tab_panels.count + 1).out
				end
				log_debug ("[TABS] Adding new tab '" + s8 (l_tab_name) + "' to '" + s8 (l_control_id) + "'")
				l_control.add_tab_panel (l_tab_name)
				log_info ("[TABS] Added tab '" + s8 (l_tab_name) + "' (now " + l_control.tab_panels.count.out + " tabs)")
				a_response.set_status (201)
				a_response.send_json ("{%"tab_count%":" + l_control.tab_panels.count.out + ",%"name%":%"" + s8 (l_tab_name) + "%"}")
			else
				send_not_found (a_response, "Tabs control", l_control_id)
			end
		end

end
