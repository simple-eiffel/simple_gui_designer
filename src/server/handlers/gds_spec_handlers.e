note
	description: "[
		Spec API handlers for GUI Designer.

		Handles CRUD operations for specifications:
		- GET /api/specs - List all specs
		- GET /api/specs/{id} - Get single spec
		- POST /api/specs - Create new spec
		- PUT /api/specs/{id} - Update spec
		- DELETE /api/specs/{id} - Delete spec
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_SPEC_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_spec_routes
			-- Register spec API routes with server.
		do
			server.on_get ("/api/specs", agent handle_list_specs)
			server.on_get ("/api/specs/{id}", agent handle_get_spec)
			server.on_post ("/api/specs", agent handle_create_spec)
			server.on_put ("/api/specs/{id}", agent handle_update_spec)
			server.on_delete ("/api/specs/{id}", agent handle_delete_spec)
		end

feature -- Spec API Handlers

	handle_list_specs (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- List all specs.
		local
			l_arr: SIMPLE_JSON_ARRAY
			l_obj: SIMPLE_JSON_OBJECT
		do
			log_request ("GET", "/api/specs")
			log_debug ("[API] Listing " + specs.count.out + " specs")
			create l_arr.make
			across specs as al_spec loop
				create l_obj.make
				l_obj.put_string (al_spec.app_name, "name").do_nothing
				l_obj.put_integer (al_spec.version, "version").do_nothing
				l_obj.put_integer (al_spec.screens.count, "screen_count").do_nothing
				l_arr.add_object (l_obj).do_nothing
			end
			a_response.send_json (l_arr.as_json)
		end

	handle_get_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Get single spec.
		local
			l_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec then
				log_debug ("[API] Found spec: " + s8 (l_id) + " with " + l_spec.screens.count.out + " screens")
				a_response.send_json (l_spec.to_json.as_json)
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

	handle_create_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Create new spec.
		local
			l_spec: GUI_DESIGNER_SPEC
		do
			log_request ("POST", "/api/specs")
			if attached a_request.body_as_json as l_json and then
			   attached l_json.string_item ("name") as l_name then
				log_spec_created (s8 (l_name))
				create l_spec.make (l_name)
				specs.force (l_spec, l_name)
				set_current_spec (l_spec)
				send_created_json (a_response, l_spec.to_json.as_json)
			else
				send_bad_request (a_response, "Invalid request - name required")
			end
		end

	handle_update_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Update existing spec.
		local
			l_id: detachable STRING_32
		do
			log_request ("PUT", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec then
				if attached a_request.body_as_json as l_json then
					log_debug ("[API] Updating spec: " + s8 (l_id))
					l_spec.apply_json (l_json)
					a_response.send_json (l_spec.to_json.as_json)
				else
					send_bad_request (a_response, "Invalid JSON")
				end
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

	handle_delete_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Delete spec.
		local
			l_id: detachable STRING_32
		do
			log_request ("DELETE", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached l_id and then specs.has (l_id) then
				log_spec_deleted (s8 (l_id))
				specs.remove (l_id)
				a_response.set_no_content
				a_response.send_empty
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

feature -- Deferred Setters

	set_current_spec (a_spec: GUI_DESIGNER_SPEC)
			-- Set the current spec.
		deferred
		end

end
