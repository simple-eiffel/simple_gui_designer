note
	description: "Tests for GUI Designer"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_GUI_DESIGNER

inherit
	EQA_TEST_SET

feature -- Tests

	test_placeholder
			-- Placeholder test.
		do
			assert ("placeholder", True)
		end

end
