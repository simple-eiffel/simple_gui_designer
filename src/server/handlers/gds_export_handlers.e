note
	description: "[
		Export and save handlers for GUI Designer.

		Handles spec export and persistence:
		- POST /api/specs/{id}/finalize - Mark spec as finalized
		- GET /api/specs/{id}/export - Export finalized spec
		- POST /api/specs/{id}/save - Save spec to disk
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_EXPORT_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_export_routes
			-- Register export API routes with server.
		do
			server.on_post ("/api/specs/{id}/finalize", agent handle_finalize_spec)
			server.on_get ("/api/specs/{id}/export", agent handle_export_spec)
			server.on_post ("/api/specs/{id}/save", agent handle_save_spec_to_disk)
		end

feature -- Export Handlers

	handle_finalize_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Mark spec as finalized.
		local
			l_id: detachable STRING_32
		do
			log_request ("POST", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec then
				log_spec_finalized (s8 (l_id))
				l_spec.mark_finalized
				a_response.send_json ("{%"status%":%"finalized%"}")
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

	handle_export_spec (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Export final spec.
		local
			l_final: GUI_FINAL_SPEC
			l_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec then
				if l_spec.is_finalized then
					log_info ("[EXPORT] Exporting finalized spec: " + s8 (l_id))
					l_final := l_spec.to_final_spec
					a_response.set_header ("Content-Disposition", "attachment; filename=%"" + s8 (l_id) + "_final.json%"")
					a_response.set_header ("Content-Type", "application/json")
					a_response.send_json (l_final.to_json.as_json)
				else
					send_bad_request (a_response, "Spec must be finalized first")
				end
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

	handle_save_spec_to_disk (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Save spec back to specs directory (overwrites existing file).
		local
			l_file: PLAIN_TEXT_FILE
			l_path: STRING
			l_json: STRING
			l_id: detachable STRING_32
		do
			log_request ("POST", s8 (a_request.path))
			l_id := a_request.path_parameter ("id")
			if attached spec_by_id (l_id) as l_spec and attached l_id then
				l_path := specs_directory + "/" + s8 (l_id) + ".json"
				l_json := l_spec.to_json.as_json
				log_debug ("[SAVE] Writing " + l_json.count.out + " bytes to " + l_path)
				create l_file.make_open_write (l_path)
				l_file.put_string (l_json)
				l_file.close
				log_spec_saved (s8 (l_id), l_path)
				a_response.send_json ("{%"status%":%"saved%",%"path%":%"" + l_path + "%"}")
			else
				send_not_found (a_response, "Spec", l_id)
			end
		end

end
