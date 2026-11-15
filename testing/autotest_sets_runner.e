note
	description: "[
		Runs the tests in simple_gui_designer's AutoTest test sets that TEST_APP did not call
		(port-coordination #17: 7 of them ran in no gate). Each goes through AutoTest's own
		EQA_TEST_EVALUATOR: a fresh test set (on_prepare), the test, then clean (on_clean),
		as AutoTest runs it. A failing test prints "FAIL:" with its tag and is counted.
	]"

class
	AUTOTEST_SETS_RUNNER

feature -- Counts

	passed, failed: INTEGER
			-- Tests run here.

feature -- Running

	run_all
			-- Every test below, 7 in all.
		do
			run_test_gui_designer
		end

feature {NONE} -- Test sets

	run_test_gui_designer
		local
			l_evaluator: EQA_TEST_EVALUATOR [TEST_GUI_DESIGNER]
		do
			create l_evaluator
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_is_valid_control_type_valid_types), "TEST_GUI_DESIGNER.test_is_valid_control_type_valid_types")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_is_valid_control_type_invalid_types), "TEST_GUI_DESIGNER.test_is_valid_control_type_invalid_types")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_is_valid_control_type_with_string_32), "TEST_GUI_DESIGNER.test_is_valid_control_type_with_string_32")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_control_creation), "TEST_GUI_DESIGNER.test_control_creation")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_control_from_json_with_row_keys), "TEST_GUI_DESIGNER.test_control_from_json_with_row_keys")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_control_from_json_with_grid_row_keys), "TEST_GUI_DESIGNER.test_control_from_json_with_grid_row_keys")
			report (l_evaluator.execute (agent {TEST_GUI_DESIGNER}.test_control_is_container), "TEST_GUI_DESIGNER.test_control_is_container")
		end

feature {NONE} -- Implementation

	report (a_result: EQA_PARTIAL_RESULT; a_name: STRING)
			-- Count and print `a_result' of test `a_name'.
		do
			if a_result.is_pass then
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			else
				print ("  FAIL: " + a_name + " [" + {UTF_CONVERTER}.string_32_to_utf_8_string_8 (a_result.tag) + "]%N")
				failed := failed + 1
			end
		end

end
