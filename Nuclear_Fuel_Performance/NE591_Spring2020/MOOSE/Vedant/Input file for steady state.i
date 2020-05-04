[Mesh] # cm_unit
 [gen]
  type = GeneratedMeshGenerator #fuel+clad+gap
  dim = 2
  nx = 100
  ny = 100
  xmax = 0.7
  ymax = 1
[]
[./subdomain1] #fuel+gap
  input = gen
  type = SubdomainBoundingBoxGenerator
  bottom_left = '0 0 0'
  top_right = '0.6 1 0'
  block_id = 1
[../]
[./subdomain2] #fuel
  input = subdomain1
  type = SubdomainBoundingBoxGenerator
  bottom_left = '0 0 0'
  top_right = '0.5 1 0'
  block_id = 2
[../]
[]

[Variables]
  [./temp]
  [../]
[]

[Materials]
  [./fuelMat]
    type = HeatConductionMaterial
    thermal_conductivity = 0.3
    block = '2'
  [../]
  [./gapMat]
    type = HeatConductionMaterial
    thermal_conductivity = 0.3
    block = '1'
  [../]
  [./cladMat]
    type = HeatConductionMaterial
    thermal_conductivity = 0.17
    block = '0'
  [../]
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y #symmetry_about_Y_axis
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
    block = '0 1 2'
  [../]
[]
[Functions]
  [./volumetric_heat]
    type = ConstantFunction
    value = 250 #W/cm3
  [../]
[]

[BCs]
  [inlet_temp]
    type = NeumannBC
    variable = temp
    boundary = left
    value = 0
  []
  [outlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = right
    value = 500 # (K)
  []
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
[]

[Outputs]
  exodus = true
  csv = true
[]
