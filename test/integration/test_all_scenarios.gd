extends "res://test/integration/templates/MainGameIntegrationTest.gd"

const SCENARIOS_ROOT := "res://test/integration/scenarios"


func test_all_main_integration_scenarios() -> void:
	var scenario_paths: Array[String] = []
	_collect_scenario_paths(SCENARIOS_ROOT, scenario_paths)
	scenario_paths.sort()
	assert_gt(scenario_paths.size(), 0, "At least one integration scenario exists")

	for scenario_path in scenario_paths:
		var scenario := load(scenario_path) as MainGameIntegrationScenario
		assert_not_null(scenario, "Could not load scenario: %s" % scenario_path)
		if scenario != null:
			assert_scenario(scenario)


func _collect_scenario_paths(
	directory_path: String,
	result: Array[String]
) -> void:
	for file_name in DirAccess.get_files_at(directory_path):
		if file_name == "Scenario.tres":
			result.append(directory_path.path_join(file_name))

	for child_directory in DirAccess.get_directories_at(directory_path):
		_collect_scenario_paths(
			directory_path.path_join(child_directory),
			result
		)
