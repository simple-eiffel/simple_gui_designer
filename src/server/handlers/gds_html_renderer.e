note
	description: "[
		HTML rendering features for GUI Designer.

		Provides all HTML rendering functions:
		- render_canvas: Screen canvas with controls
		- render_control: Single control (simple, card, or tabs)
		- render_palette: Control palette sidebar
		- render_properties: Properties panel for selected control
		- render_screen_list: Screen list sidebar
		- render_spec_list: Spec list for index page
	]"
	author: "Claude Code"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GDS_HTML_RENDERER

inherit
	GDS_SHARED_STATE

feature -- Canvas Rendering

	render_canvas (a_screen: GUI_DESIGNER_SCREEN; a_spec_id: STRING_32): STRING
			-- Render screen as HTML canvas with 12-column grid.
		local
			l_row, l_max_row: INTEGER
		do
			create Result.make (2000)
			Result.append ("<div class=%"canvas-grid%">%N")
			Result.append ("  <h3>")
			Result.append (s8 (a_screen.title))
			Result.append ("</h3>%N")

			l_max_row := a_screen.row_count.max (6)
			from l_row := 1 until l_row > l_max_row loop
				Result.append ("  <div class=%"grid-row%">%N")
				across a_screen.controls_at_row (l_row) as l_control loop
					Result.append (render_control (l_control, a_spec_id, a_screen.id))
				end
				Result.append ("  </div>%N")
				l_row := l_row + 1
			end
			Result.append ("</div>")
		end

feature -- Control Rendering

	render_control (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render single control HTML with click handler for properties.
			-- Handles containers (card, tabs) specially with drop zones.
		do
			if a_control.is_card then
				Result := render_card_control (a_control, a_spec_id, a_screen_id)
			elseif a_control.is_tabs then
				Result := render_tabs_control (a_control, a_spec_id, a_screen_id)
			else
				Result := render_simple_control (a_control, a_spec_id, a_screen_id)
			end
		end

	render_simple_control (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render non-container control.
		do
			create Result.make (500)
			Result.append ("    <div class=%"control col-")
			Result.append (a_control.col_span.out)
			Result.append (" type-")
			Result.append (s8 (a_control.control_type))
			Result.append ("%" data-id=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%" draggable=%"true%" ")
			Result.append ("hx-get=%"/htmx/properties/")
			Result.append (s8 (a_spec_id))
			Result.append ("/")
			Result.append (s8 (a_screen_id))
			Result.append ("/")
			Result.append (s8 (a_control.id))
			Result.append ("%" hx-target=%"#properties%" hx-swap=%"innerHTML%" ")
			Result.append ("onclick=%"event.stopPropagation(); document.querySelectorAll('.control.selected').forEach(c=>c.classList.remove('selected')); this.classList.add('selected');%">%N")
			Result.append ("      <span class=%"control-label%">")
			if a_control.label.is_empty then
				Result.append ("[" + s8 (a_control.id) + "]")
			else
				Result.append (s8 (a_control.label))
			end
			Result.append ("</span>%N")
			Result.append ("    </div>%N")
		end

	render_card_control (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render card container with drop zone for children.
		do
			log_debug ("[RENDER] Card '" + s8 (a_control.id) + "' with " + a_control.children.count.out + " children")
			create Result.make (1000)
			Result.append ("    <div class=%"control container-control card-control col-")
			Result.append (a_control.col_span.out)
			Result.append ("%" data-id=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%" data-container=%"card%" ")
			Result.append ("hx-get=%"/htmx/properties/")
			Result.append (s8 (a_spec_id))
			Result.append ("/")
			Result.append (s8 (a_screen_id))
			Result.append ("/")
			Result.append (s8 (a_control.id))
			Result.append ("%" hx-target=%"#properties%" hx-swap=%"innerHTML%" ")
			Result.append ("onclick=%"event.stopPropagation(); document.querySelectorAll('.control.selected').forEach(c=>c.classList.remove('selected')); this.classList.add('selected');%">%N")
			-- Card header
			Result.append ("      <div class=%"card-header%">")
			if a_control.label.is_empty then
				Result.append ("Card")
			else
				Result.append (s8 (a_control.label))
			end
			Result.append ("</div>%N")
			-- Card body (drop zone)
			Result.append ("      <div class=%"card-body drop-zone%" data-parent=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%">%N")
			if a_control.children.is_empty then
				Result.append ("        <div class=%"drop-placeholder%">Drop controls here</div>%N")
			else
				across a_control.children as l_child loop
					Result.append (render_control (l_child, a_spec_id, a_screen_id))
				end
			end
			Result.append ("      </div>%N")
			Result.append ("    </div>%N")
		end

	render_tabs_control (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render tabs container with tab headers and panels.
		local
			l_tab_idx: INTEGER
			l_active_idx: INTEGER
		do
			log_debug ("[RENDER] Tabs '" + s8 (a_control.id) + "' with " + a_control.tab_panels.count.out + " panels")
			l_active_idx := a_control.active_tab_index.max (1)
			create Result.make (2000)
			Result.append ("    <div class=%"control container-control tabs-control col-")
			Result.append (a_control.col_span.out)
			Result.append ("%" data-id=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%" data-container=%"tabs%" ")
			Result.append ("hx-get=%"/htmx/properties/")
			Result.append (s8 (a_spec_id))
			Result.append ("/")
			Result.append (s8 (a_screen_id))
			Result.append ("/")
			Result.append (s8 (a_control.id))
			Result.append ("%" hx-target=%"#properties%" hx-swap=%"innerHTML%" ")
			Result.append ("onclick=%"event.stopPropagation(); document.querySelectorAll('.control.selected').forEach(c=>c.classList.remove('selected')); this.classList.add('selected');%">%N")
			-- Tab headers
			Result.append ("      <div class=%"tabs-header%">%N")
			l_tab_idx := 1
			across a_control.tab_panels as l_panel loop
				Result.append ("        <div class=%"tab-header")
				if l_tab_idx = l_active_idx then
					Result.append (" active")
				end
				Result.append ("%" data-tab-idx=%"")
				Result.append (l_tab_idx.out)
				Result.append ("%" data-tabs-id=%"")
				Result.append (s8 (a_control.id))
				Result.append ("%" onclick=%"switchTab(this, event)%">")
				Result.append (s8 (l_panel.name))
				Result.append ("</div>%N")
				l_tab_idx := l_tab_idx + 1
			end
			Result.append ("        <div class=%"tab-add-btn%" onclick=%"addTab('" + s8 (a_control.id) + "', event)%">+</div>%N")
			Result.append ("      </div>%N")
			-- Tab panels (only active one visible)
			l_tab_idx := 1
			across a_control.tab_panels as l_panel loop
				Result.append ("      <div class=%"tab-panel drop-zone")
				if l_tab_idx = l_active_idx then
					Result.append (" active")
				end
				Result.append ("%" data-tab-idx=%"")
				Result.append (l_tab_idx.out)
				Result.append ("%" data-parent=%"")
				Result.append (s8 (a_control.id))
				Result.append ("%" data-panel-idx=%"")
				Result.append (l_tab_idx.out)
				Result.append ("%">%N")
				if l_panel.children.is_empty then
					Result.append ("        <div class=%"drop-placeholder%">Drop controls here</div>%N")
				else
					across l_panel.children as l_child loop
						Result.append (render_control (l_child, a_spec_id, a_screen_id))
					end
				end
				Result.append ("      </div>%N")
				l_tab_idx := l_tab_idx + 1
			end
			Result.append ("    </div>%N")
		end

feature -- Palette Rendering

	render_palette: STRING
			-- Render control palette HTML.
		do
			create Result.make (3000)
			Result.append ("<div class=%"palette%">%N")
			Result.append ("  <h4>Controls</h4>%N")

			-- Input controls
			Result.append ("  <div class=%"palette-group%">%N")
			Result.append ("    <h5>Input</h5>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"text_field%">Text Field</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"text_area%">Text Area</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"dropdown%">Dropdown</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"checkbox%">Checkbox</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"date_picker%">Date Picker</div>%N")
			Result.append ("  </div>%N")

			-- Action controls
			Result.append ("  <div class=%"palette-group%">%N")
			Result.append ("    <h5>Actions</h5>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"button%">Button</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"link%">Link</div>%N")
			Result.append ("  </div>%N")

			-- Display controls
			Result.append ("  <div class=%"palette-group%">%N")
			Result.append ("    <h5>Display</h5>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"label%">Label</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"heading%">Heading</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"table%">Table</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"list%">List</div>%N")
			Result.append ("  </div>%N")

			-- Layout controls
			Result.append ("  <div class=%"palette-group%">%N")
			Result.append ("    <h5>Layout</h5>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"card%">Card</div>%N")
			Result.append ("    <div class=%"palette-item%" draggable=%"true%" data-type=%"tabs%">Tabs</div>%N")
			Result.append ("  </div>%N")

			Result.append ("</div>")
		end

feature -- Properties Rendering

	render_properties (a_control: GUI_DESIGNER_CONTROL; a_spec_id, a_screen_id: STRING_32): STRING
			-- Render properties panel HTML for control.
		do
			create Result.make (2000)
			Result.append ("<div class=%"properties-panel%">%N")
			Result.append ("  <h4>")
			Result.append (s8 (a_control.label))
			Result.append ("</h4>%N")
			Result.append ("  <p style=%"color:#666; font-size:12px; margin-top:-10px;%">")
			Result.append (s8 (a_control.control_type))
			Result.append ("</p>%N")
			Result.append ("  <form hx-put=%"/api/specs/")
			Result.append (s8 (a_spec_id))
			Result.append ("/screens/")
			Result.append (s8 (a_screen_id))
			Result.append ("/controls/")
			Result.append (s8 (a_control.id))
			Result.append ("%" hx-trigger=%"submit%" hx-swap=%"none%" ")
			Result.append ("hx-on::after-request=%"refreshCanvas()%"")
			Result.append (" data-canvas-url=%"/htmx/canvas/")
			Result.append (s8 (a_spec_id))
			Result.append ("/")
			Result.append (s8 (a_screen_id))
			Result.append ("%"")
			Result.append (" data-props-url=%"/htmx/properties/")
			Result.append (s8 (a_spec_id))
			Result.append ("/")
			Result.append (s8 (a_screen_id))
			Result.append ("/")
			Result.append (s8 (a_control.id))
			Result.append ("%"")
			Result.append (" data-control-id=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%">%N")

			-- ID (read-only, not editable)
			Result.append ("    <label>ID</label>%N")
			Result.append ("    <input type=%"text%" value=%"")
			Result.append (s8 (a_control.id))
			Result.append ("%" disabled class=%"readonly-field%">%N")

			-- Type (read-only, not editable)
			Result.append ("    <label>Type</label>%N")
			Result.append ("    <input type=%"text%" value=%"")
			Result.append (s8 (a_control.control_type))
			Result.append ("%" disabled class=%"readonly-field%">%N")

			-- Label (auto-submit on change)
			Result.append ("    <label>Label</label>%N")
			Result.append ("    <input type=%"text%" name=%"label%" value=%"")
			Result.append (s8 (a_control.label))
			Result.append ("%" onchange=%"htmx.trigger(this.form, 'submit')%">%N")

			-- Grid position with spinner buttons
			Result.append ("    <label>Row</label>%N")
			Result.append ("    <div class=%"spinner-group%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.nextElementSibling; inp.stepDown(); htmx.trigger(inp.form, 'submit')%">-</button>%N")
			Result.append ("      <input type=%"number%" name=%"row%" value=%"")
			Result.append (a_control.grid_row.out)
			Result.append ("%" min=%"1%" class=%"spin-input%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.previousElementSibling; inp.stepUp(); htmx.trigger(inp.form, 'submit')%">+</button>%N")
			Result.append ("    </div>%N")

			Result.append ("    <label>Column</label>%N")
			Result.append ("    <div class=%"spinner-group%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.nextElementSibling; inp.stepDown(); htmx.trigger(inp.form, 'submit')%">-</button>%N")
			Result.append ("      <input type=%"number%" name=%"col%" value=%"")
			Result.append (a_control.grid_col.out)
			Result.append ("%" min=%"1%" max=%"24%" class=%"spin-input%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.previousElementSibling; inp.stepUp(); htmx.trigger(inp.form, 'submit')%">+</button>%N")
			Result.append ("    </div>%N")

			Result.append ("    <label>Column Span</label>%N")
			Result.append ("    <div class=%"spinner-group%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.nextElementSibling; inp.stepDown(); htmx.trigger(inp.form, 'submit')%">-</button>%N")
			Result.append ("      <input type=%"number%" name=%"col_span%" value=%"")
			Result.append (a_control.col_span.out)
			Result.append ("%" min=%"1%" max=%"24%" class=%"spin-input%">%N")
			Result.append ("      <button type=%"button%" class=%"spin-btn%" onclick=%"var inp=this.previousElementSibling; inp.stepUp(); htmx.trigger(inp.form, 'submit')%">+</button>%N")
			Result.append ("    </div>%N")

			-- Notes section (auto-submit on change)
			Result.append ("    <label>Notes</label>%N")
			Result.append ("    <textarea name=%"notes%" onchange=%"htmx.trigger(this.form, 'submit')%">")
			across a_control.notes as l_note loop
				Result.append (s8 (l_note))
				Result.append ("%N")
			end
			Result.append ("</textarea>%N")

			Result.append ("  </form>%N")

			-- Delete button (outside the form)
			Result.append ("  <hr style=%"margin: 20px 0; border: none; border-top: 1px solid #ddd;%">%N")
			Result.append ("  <button type=%"button%" class=%"delete-btn%" ")
			Result.append ("onclick=%"deleteControl('")
			Result.append (s8 (a_spec_id))
			Result.append ("', '")
			Result.append (s8 (a_screen_id))
			Result.append ("', '")
			Result.append (s8 (a_control.id))
			Result.append ("')%">Delete Control</button>%N")

			Result.append ("</div>")
		end

feature -- List Rendering

	render_screen_list (a_spec: GUI_DESIGNER_SPEC): STRING
			-- Render screen list HTML.
		do
			create Result.make (1000)
			Result.append ("<ul class=%"screen-list%">%N")
			across a_spec.screens as l_screen loop
				Result.append ("  <li hx-get=%"/htmx/canvas/")
				Result.append (s8 (a_spec.app_name))
				Result.append ("/")
				Result.append (s8 (l_screen.id))
				Result.append ("%" hx-target=%"#canvas%">")
				Result.append (s8 (l_screen.title))
				Result.append ("</li>%N")
			end
			Result.append ("</ul>")
		end

	render_spec_list: STRING
			-- Render spec list HTML for index page.
		do
			create Result.make (2000)
			if specs.is_empty then
				Result.append ("<p style=%"color:#888; font-style:italic;%">No specifications loaded. Upload a JSON spec file to get started.</p>")
			else
				Result.append ("<ul class=%"spec-list%">%N")
				across specs as l_spec loop
					Result.append ("  <div class=%"spec-item%">%N")
					Result.append ("    <div class=%"spec-info%">%N")
					Result.append ("      <div class=%"spec-name%">")
					Result.append (s8 (l_spec.app_name))
					Result.append ("</div>%N")
					Result.append ("      <div class=%"spec-meta%">Version ")
					Result.append (l_spec.version.out)
					Result.append (" | ")
					Result.append (l_spec.screens.count.out)
					Result.append (" screen(s)</div>%N")
					Result.append ("    </div>%N")
					Result.append ("    <div class=%"spec-actions%">%N")
					Result.append ("      <a href=%"/api/specs/")
					Result.append (s8 (l_spec.app_name))
					Result.append ("/download%" class=%"btn btn-secondary btn-sm%">Download</a>%N")
					Result.append ("      <a href=%"/designer?spec=")
					Result.append (s8 (l_spec.app_name))
					Result.append ("%" class=%"btn btn-success btn-sm%">Edit</a>%N")
					Result.append ("    </div>%N")
					Result.append ("  </div>%N")
				end
				Result.append ("</ul>")
			end
		end

end
