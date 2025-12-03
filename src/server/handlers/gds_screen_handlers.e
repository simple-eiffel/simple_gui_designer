note
	description: "[
		Screen API handlers for GUI Designer.

		Handles CRUD operations for screens within a spec:
		- GET /api/specs/{spec_id}/screens - List screens
		- POST /api/specs/{spec_id}/screens - Create screen
		- PUT /api/specs/{spec_id}/screens/{screen_id} - Update screen
		- DELETE /api/specs/{spec_id}/screens/{screen_id} - Delete screen
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_SCREEN_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_screen_routes
			-- Register screen API routes with server.
		do
			server.on_get ("/api/specs/{spec_id}/screens", agent handle_list_screens)
			server.on_post ("/api/specs/{spec_id}/screens", agent handle_create_screen)
			server.on_put ("/api/specs/{spec_id}/screens/{screen_id}", agent handle_update_screen)
			server.on_delete ("/api/specs/{spec_id}/screens/{screen_id}", agent handle_delete_screen)
		end

feature -- Screen API Handlers

	handle_list_screens (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- List screens in a spec.
		local
			l_arr: SIMPLE_JSON_ARRAY
			l_spec_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			if attached spec_by_id (l_spec_id) as l_spec then
				log_debug ("[API] Listing " + l_spec.screens.count.out + " screens for spec " + s8 (l_spec_id))
				create l_arr.make
				across l_spec.screens as al_screen loop
					l_arr.add_object (al_screen.to_json).do_nothing
				end
				a_response.send_json (l_arr.as_json)
			else
				send_not_found (a_response, "Spec", l_spec_id)
			end
		end

	handle_create_screen (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Create new screen.
		local
			l_screen: GUI_DESIGNER_SCREEN
			l_spec_id: detachable STRING_32
		do
			log_request ("POST", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			if attached spec_by_id (l_spec_id) as l_spec then
				if attached a_request.body_as_json as l_json and then
				   attached l_json.string_item ("id") as l_id and then
				   attached l_json.string_item ("title") as l_title then
					log_screen_created (s8 (l_spec_id), s8 (l_id))
					create l_screen.make (l_id, l_title)
					l_spec.add_screen (l_screen)
					send_created_json (a_response, l_screen.to_json.as_json)
				else
					send_bad_request (a_response, "id and title required")
				end
			else
				send_not_found (a_response, "Spec", l_spec_id)
			end
		end

	handle_update_screen (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Update screen.
		local
			l_spec_id, l_screen_id: detachable STRING_32
		do
			log_request ("PUT", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			if attached screen_in_spec (l_spec_id, l_screen_id) as l_screen then
				if attached a_request.body_as_json as l_json then
					log_screen_updated (s8 (l_spec_id), s8 (l_screen_id))
					l_screen.apply_json (l_json)
					a_response.send_json (l_screen.to_json.as_json)
				else
					send_bad_request (a_response, "Invalid JSON")
				end
			else
				send_not_found (a_response, "Screen", l_screen_id)
			end
		end

	handle_delete_screen (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Delete screen.
		local
			l_spec_id, l_screen_id: detachable STRING_32
		do
			log_request ("DELETE", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			if attached spec_by_id (l_spec_id) as l_spec and attached l_screen_id then
				log_screen_deleted (s8 (l_spec_id), s8 (l_screen_id))
				l_spec.remove_screen (l_screen_id)
				a_response.set_no_content
				a_response.send_empty
			else
				send_not_found (a_response, "Spec", l_spec_id)
			end
		end

end
