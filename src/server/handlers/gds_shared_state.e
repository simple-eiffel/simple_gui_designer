note
	description: "[
		Deferred class providing shared state access for all GUI Designer handler mixins.

		This class defines the interface for accessing shared resources that all
		handlers need: specs collection, server instance, logging, etc.

		GUI_DESIGNER_SERVER will implement these features and all handler mixins
		will inherit this class to access them.
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_SHARED_STATE

inherit
	GUI_DESIGNER_LOGGER

feature -- Shared State Access

	specs: HASH_TABLE [GUI_DESIGNER_SPEC, STRING_32]
			-- All loaded specs by ID/app_name.
		deferred
		end

	current_spec: GUI_DESIGNER_SPEC
			-- Currently active spec.
		deferred
		end

	server: SIMPLE_WEB_SERVER
			-- HTTP server instance.
		deferred
		end

	specs_directory: STRING
			-- Directory to load/save spec files from.
		deferred
		end

feature -- Lookup Helpers

	spec_by_id (a_id: detachable STRING_32): detachable GUI_DESIGNER_SPEC
			-- Find spec by ID, or Void if not found.
		do
			if attached a_id as l_id then
				Result := specs.item (l_id)
			end
		end

	screen_in_spec (a_spec_id, a_screen_id: detachable STRING_32): detachable GUI_DESIGNER_SCREEN
			-- Find screen by spec and screen IDs.
		do
			if attached spec_by_id (a_spec_id) as l_spec and attached a_screen_id as l_screen_id then
				Result := l_spec.screen_by_id (l_screen_id)
			end
		end

	control_in_screen (a_spec_id, a_screen_id, a_control_id: detachable STRING_32): detachable GUI_DESIGNER_CONTROL
			-- Find control by spec, screen, and control IDs.
		do
			if attached screen_in_spec (a_spec_id, a_screen_id) as l_screen and attached a_control_id as l_control_id then
				Result := l_screen.control_by_id (l_control_id)
			end
		end

feature -- Response Helpers

	send_not_found (a_response: SIMPLE_WEB_SERVER_RESPONSE; a_entity: STRING; a_id: detachable STRING_32)
			-- Send standard 404 response.
		do
			log_not_found (a_entity, a_id)
			a_response.set_not_found
			a_response.send_json ("{%"error%":%"" + a_entity + " not found%"}")
		end

	send_bad_request (a_response: SIMPLE_WEB_SERVER_RESPONSE; a_message: STRING)
			-- Send standard 400 response.
		do
			log_bad_request (a_message)
			a_response.set_bad_request
			a_response.send_json ("{%"error%":%"" + a_message + "%"}")
		end

	send_created_json (a_response: SIMPLE_WEB_SERVER_RESPONSE; a_json: STRING)
			-- Send 201 Created with JSON body.
		do
			a_response.set_created
			a_response.send_json (a_json)
		end

feature -- String Helpers

	s8 (a_string_32: detachable STRING_32): STRING
			-- Convert STRING_32 to STRING_8, handling Void.
		do
			if attached a_string_32 as l_s then
				Result := l_s.to_string_8
			else
				Result := "(nil)"
			end
		end

end
