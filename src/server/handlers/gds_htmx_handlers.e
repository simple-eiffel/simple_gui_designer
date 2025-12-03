note
	description: "[
		HTMX partial handlers for GUI Designer.

		Handles HTMX requests that return HTML fragments:
		- GET /htmx/canvas/{spec_id}/{screen_id} - Canvas HTML
		- GET /htmx/palette - Control palette HTML
		- GET /htmx/properties/{spec_id}/{screen_id}/{control_id} - Properties panel HTML
		- GET /htmx/screen-list/{spec_id} - Screen list HTML
		- GET /htmx/spec-list - Spec list HTML

		Note: This class depends on GDS_HTML_RENDERER for render_* features.
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_HTMX_HANDLERS

inherit
	GDS_SHARED_STATE

feature -- Route Setup

	setup_htmx_routes
			-- Register HTMX partial routes with server.
		do
			server.on_get ("/htmx/canvas/{spec_id}/{screen_id}", agent handle_canvas_partial)
			server.on_get ("/htmx/palette", agent handle_palette_partial)
			server.on_get ("/htmx/properties/{spec_id}/{screen_id}/{control_id}", agent handle_properties_partial)
			server.on_get ("/htmx/screen-list/{spec_id}", agent handle_screen_list_partial)
			server.on_get ("/htmx/spec-list", agent handle_spec_list_partial)
		end

feature -- HTMX Partial Handlers

	handle_canvas_partial (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Render canvas HTML partial.
		local
			l_spec_id, l_screen_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			if attached screen_in_spec (l_spec_id, l_screen_id) as l_screen and attached l_spec_id then
				log_canvas_render (s8 (l_screen_id), l_screen.controls.count)
				-- Log each control's position for debugging
				across l_screen.controls as l_ctrl loop
					log_debug ("[CANVAS] Rendering control " + s8 (l_ctrl.id) + " at row=" + l_ctrl.grid_row.out + " col=" + l_ctrl.grid_col.out + " span=" + l_ctrl.col_span.out)
				end
				a_response.send_html (render_canvas (l_screen, l_spec_id))
			else
				log_not_found ("Screen", l_screen_id)
				a_response.set_not_found
				a_response.send_html ("<div class=%"error%">Screen not found</div>")
			end
		end

	handle_palette_partial (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Render control palette HTML partial.
		do
			log_request ("GET", "/htmx/palette")
			log_debug ("[HTMX] Rendering palette partial")
			a_response.send_html (render_palette)
		end

	handle_properties_partial (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Render properties panel HTML partial.
		local
			l_spec_id, l_screen_id, l_control_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			l_screen_id := a_request.path_parameter ("screen_id")
			l_control_id := a_request.path_parameter ("control_id")
			if attached control_in_screen (l_spec_id, l_screen_id, l_control_id) as l_control and
			   attached l_spec_id and attached l_screen_id then
				log_control_selected (s8 (l_control_id))
				log_debug ("[PROPERTIES] Control " + s8 (l_control_id) + " row=" + l_control.grid_row.out + " col=" + l_control.grid_col.out + " span=" + l_control.col_span.out)
				a_response.send_html (render_properties (l_control, l_spec_id, l_screen_id))
			else
				log_not_found ("Control", l_control_id)
				a_response.set_not_found
				a_response.send_html ("<div class=%"error%">Control not found</div>")
			end
		end

	handle_screen_list_partial (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Render screen list HTML partial.
		local
			l_spec_id: detachable STRING_32
		do
			log_request ("GET", s8 (a_request.path))
			l_spec_id := a_request.path_parameter ("spec_id")
			if attached spec_by_id (l_spec_id) as l_spec then
				log_debug ("[HTMX] Rendering screen list for " + s8 (l_spec_id) + " with " + l_spec.screens.count.out + " screens")
				a_response.send_html (render_screen_list (l_spec))
			else
				log_not_found ("Spec", l_spec_id)
				a_response.set_not_found
				a_response.send_html ("<div class=%"error%">Spec not found</div>")
			end
		end

	handle_spec_list_partial (a_request: SIMPLE_WEB_SERVER_REQUEST; a_response: SIMPLE_WEB_SERVER_RESPONSE)
			-- Render spec list HTML partial for index page.
		do
			log_request ("GET", "/htmx/spec-list")
			log_debug ("[HTMX] Rendering spec list with " + specs.count.out + " specs")
			a_response.send_html (render_spec_list)
		end

feature -- Deferred Renderers (from GDS_HTML_RENDERER)

	render_canvas (a_screen: GUI_DESIGNER_SCREEN; a_spec_id: STRING_32): STRING
			-- Render screen as HTML canvas.
		deferred
		end

	render_palette: STRING
			-- Render control palette HTML.
		deferred
		end

	render_properties (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render properties panel HTML.
		deferred
		end

	render_screen_list (a_spec: GUI_DESIGNER_SPEC): STRING
			-- Render screen list HTML.
		deferred
		end

	render_spec_list: STRING
			-- Render spec list HTML.
		deferred
		end

end
