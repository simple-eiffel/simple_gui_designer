note
	description: "[
		Download and upload handlers for GUI Designer.

		Handles spec download and upload:
		- GET /api/specs/{id}/download - Download single spec
		- GET /api/specs/download-all - Download all specs
		- POST /api/specs/upload - Upload spec from JSON
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_DOWNLOAD_UPLOAD_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_download_upload_routes
			-- Register download/upload API routes with server.
		do
			server.on_get ("/api/specs/{id}/download", agent handle_download_spec)
			server.on_get ("/api/specs/download-all", agent handle_download_all_specs)
			server.on_post ("/api/specs/upload", agent handle_upload_spec)
		end

feature -- Download/Upload Handlers

	handle_download_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Download single spec as JSON file.
		local
			l_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec and attached l_id then
				log_info ("[DOWNLOAD] Serving spec download: " + s8 (l_id))
				a_response.set_header ("Content-Disposition", "attachment; filename=%"" + s8 (l_id) + ".json%"")
				a_response.set_header ("Content-Type", "application/json")
				a_response.send_json (l_spec.to_json.as_json)
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

	handle_download_all_specs (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Download all specs as JSON array file.
		local
			l_arr: SIMPLE_JSON_ARRAY
		do
			log_request ("GET", "/api/specs/download-all")
			log_info ("[DOWNLOAD] Serving all " + specs.count.out + " specs download")
			create l_arr.make
			across specs as l_spec loop
				l_arr.add_object (l_spec.to_json).do_nothing
			end
			a_response.set_header ("Content-Disposition", "attachment; filename=%"all_specs.json%"")
			a_response.set_header ("Content-Type", "application/json")
			a_response.send_json (l_arr.as_json)
		end

	handle_upload_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Upload and add a new spec from JSON.
		local
			l_spec: GUI_DESIGNER_SPEC
			l_name: STRING_32
			l_validation_error: detachable STRING
		do
			log_request ("POST", "/api/specs/upload")
			if attached a_request.body_as_json as l_json then
				log_debug ("[UPLOAD] Received JSON body for spec upload")
				l_validation_error := validate_spec_json (l_json)
				if l_validation_error = Void then
					create l_spec.make_from_json (l_json)
					l_name := l_spec.app_name
					if specs.has (l_name) then
						-- Update existing
						log_info ("[UPLOAD] Updating existing spec: " + s8 (l_name))
						specs.force (l_spec, l_name)
						a_response.send_json ("{%"status%":%"updated%",%"name%":%"" + s8 (l_name) + "%"}")
					else
						-- Add new
						log_spec_created (s8 (l_name))
						specs.force (l_spec, l_name)
						send_created_json (a_response, "{%"status%":%"created%",%"name%":%"" + s8 (l_name) + "%"}")
					end
				else
					send_bad_request (a_response, l_validation_error)
				end
			else
				send_bad_request (a_response, "Invalid JSON body")
			end
		end

feature {NONE} -- Validation

	validate_spec_json (a_json: SIMPLE_JSON_OBJECT): detachable STRING
			-- Validate spec JSON structure. Returns error message or Void if valid.
		local
			l_screens_arr: SIMPLE_JSON_ARRAY
			l_screen_obj: SIMPLE_JSON_OBJECT
			l_controls_arr: SIMPLE_JSON_ARRAY
			l_control_obj: SIMPLE_JSON_OBJECT
			i, j: INTEGER
		do
			-- Must have app or app_name
			if not (a_json.has_key ("app") or a_json.has_key ("app_name")) then
				Result := "Missing required field: app or app_name"
			elseif attached a_json.array_item ("screens") as l_screens then
				-- Validate each screen
				l_screens_arr := l_screens
				from i := 1 until i > l_screens_arr.count or Result /= Void loop
					if attached l_screens_arr.item (i).as_object as l_obj then
						l_screen_obj := l_obj
						if not l_screen_obj.has_key ("id") then
							Result := "Screen " + i.out + " missing required field: id"
						elseif attached l_screen_obj.array_item ("controls") as l_controls then
							-- Validate each control in this screen
							l_controls_arr := l_controls
							from j := 1 until j > l_controls_arr.count or Result /= Void loop
								if attached l_controls_arr.item (j).as_object as l_ctrl then
									l_control_obj := l_ctrl
									if not l_control_obj.has_key ("id") then
										Result := "Control " + j.out + " in screen " + i.out + " missing required field: id"
									elseif not l_control_obj.has_key ("type") then
										Result := "Control " + j.out + " in screen " + i.out + " missing required field: type"
									end
								end
								j := j + 1
							end
						end
					else
						Result := "Screen " + i.out + " is not a valid object"
					end
					i := i + 1
				end
			end
			-- No screens array is OK (empty spec)
		end

end
