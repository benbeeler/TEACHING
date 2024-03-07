 [Mesh] 
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 1000
    xmin = 0
    xmax = 0.605
    ny = 100
    ymin = 0
    ymax = 1
  []
  [./subdomain1]
    input = gen
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '0.5050 1.000 0'
    block_id = 1
  [../]
  [./subdomain2] 
    input = subdomain1
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = '0.5000 1.000 0'
    block_id = 2
  [../]

[]

[Variables]
  [./temp] 
  [../]

[]

[Materials]
  [./fuelMat]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.03 0.28 10.90' #W/cm-K J/g-K g/cm3 
    block = '2'
  [../]
  [./gapMat]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.0026 5.193 0.0022'
    block = '1'
  [../]
  [./cladMat]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.17 0.35 6.525'
    block = '0'
  [../]
[]

[Postprocessors]
   [centerline_temperature]
	type = SideExtremeValue
	variable = temp
	boundary = left
   []
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y 
[]

[Kernels]
  [./heat_source]
    type = HeatSource
    function = volumetric_heat
    variable = temp
    block = '2'
  [../]
  [./conduction]
    type = HeatConduction
    variable = temp
    block= '0 1 2'
  [../]
  [./heat_conduction_time_derivative]
    type= HeatConductionTimeDerivative
    variable = temp
    block = '0 1 2'
  [../]
[]

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     value = 250*exp(-((t-20)*(t-20))/10)+150 #W/cm3
  [../]
[]

[BCs]
  [inlet_temp]
    type = NeumannBC
    variable = temp
    boundary = left
    value = 0 
  []
  [outlet_temp]
    type = DirichletBC
    variable = temp
    boundary = right
    value = 550 # (K)
  []
[]

[Executioner]
  type = Transient
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10
  start_time = 0.0
  dt = 1
  num_steps = 100
  solve_type = PJFNK
[]

[Outputs]
  exodus = true
[]
