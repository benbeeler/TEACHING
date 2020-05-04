[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmax = 0.7 # Length of test chamber
  ymax = 1# Test chamber radius
[] 

[MeshModifiers]
  [./subdomain1]
    type = SubdomainBoundingBox
    bottom_left = '0 0 0'
    top_right = '0.5 1.0 0'
    block_id = 1
  [../]
  [./subdomain2]
    type = SubdomainBoundingBox
    bottom_left = '0.5 0 0'
    top_right = '0.6 1.0 0'
    block_id = 2
  [../]
  [./subdomain3]
    type = SubdomainBoundingBox
    bottom_left = '0.6 0 0'
    top_right = '0.7 1.0 0'
    block_id = 3
  [../]
[] 

[Functions]
  [./volumetric_heat]
     type = ParsedFunction
     #
     #value = 250
     value = 'if(t<200,150*exp(-0.03*t)+250,250)'
     #value = 150*exp(-0.03*t)+250
  [../]
[] 

[Variables]
  [./temperature]
  [../] 
[] 

[Kernels]
  [./clad_conduction]
    type = ADHeatConduction
    variable = temperature
    block = '1 2 3'
  [../]
  [./fuel_heat]
    type = HeatSource
    function = volumetric_heat
    variable = temperature
    value = 1.0
    block = 1
  [../]
  [./heat_conduction_time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    block = '1 2 3'
  [../]
[]

[BCs]
  [outlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = right
    value = 500 # (K)
  []
  [inlet_temperature]
    type = NeumannBC
    variable = temperature
    boundary = left
    value = 0 # (K)
  []
    
[] 

[Materials]
  [./fuel]
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.3 0.33 10.98'
    block = 1
  [../]
  [./gap]
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.1 0.158 5.9'
    block = 2
  [../]
  [./clad]
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.17 0.35 6.5'
    block = 3
  [../]
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  start_time = 0.0
  num_steps = 300
  dt = 1
[]

[Outputs]
  exodus = true
[]
