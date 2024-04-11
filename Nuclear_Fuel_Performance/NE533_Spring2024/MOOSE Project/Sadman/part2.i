 [Mesh] 
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    xmin = 0
    xmax = 0.605
    ny = 300
    ymin = 0
    ymax = 100
  []
  [subdomain1]
    input = gen
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '0.5050 100.0 0'
    block_id = 1
  []
  [subdomain2] 
    input = subdomain1
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '0.5000 100.0 0'
    block_id = 2
  []
  [fuel_sideset]
	type = SideSetsBetweenSubdomainsGenerator
	input = subdomain2
	primary_block = 2
	paired_block = 1
	new_boundary = 'fuel_with_gap'
  []
  [clad_sideset]
	type = SideSetsBetweenSubdomainsGenerator
	input = fuel_sideset
	primary_block = 0
	paired_block = 1
	new_boundary = 'clad_with_gap'
  []
  [part2_geom]
	type = BlockDeletionGenerator
	input = clad_sideset
	block = 1
  []
  coord_type = RZ
  
 []

[Variables]
  [temp]
  []
[]

[Materials]
  [fuelMat]
    type = HeatConductionMaterial
	temp = temp
	block = '2'
    thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
	specific_heat = 0.28
  []
  #[gapMat]
    #type = HeatConductionMaterial
    #thermal_conductivity = .0026 #W/cm-K
    #block = '1'
  #[]
  [cladMat]
    type = HeatConductionMaterial
    thermal_conductivity = .1700 #W/cm-K
	specific_heat = 0.35
    block = '0'
  []
[]

[Problem]
  type = FEProblem
[]

[Kernels]
  [heat_source]
    type = HeatSource
    function = LHR
    variable = temp
    block = '2'
  []
  [conduction]
    type = HeatConduction
    variable = temp
    block= '0 2'
  []
[]

[Functions]
  [LHR]
     type = ParsedFunction
     expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)
  []
  [coolant_temp]
	 type = ParsedFunction
	 expression = (500+14.4676*(sin(1.2)+sin(1.2*((y/50)-1)))) 
  []
[]

[ThermalContact]
  [gap_contact]
	type = GapHeatTransfer
	emissivity_primary = 0
	emissivity_secondary = 0
	variable = temp
	primary = 'fuel_with_gap'
	secondary = 'clad_with_gap'
	gap_conductivity = 0.0026
	quadrature = true
  []
[]
	

[BCs]
  [inlet_temp]
    type = NeumannBC
    variable = temp
    boundary = left
    value = 0 
  []
  [outlet_temp]
    type = FunctionDirichletBC
    variable = temp
    boundary = right
    function = coolant_temp
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  automatic_scaling = true
[]

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = temp
    start_point = '0 51 0'
    end_point = '0.605 51 0'
    num_points = 20
    sort_by = x
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = part2_out
    execute_on = final
  []
[]
