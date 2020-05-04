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
    type = SubdomainBoundingBox #fuel
    bottom_left = '0 0 0'
    top_right = '0.5 1.0 0'
    block_id = 1
  [../]
  [./subdomain2]
    type = SubdomainBoundingBox #gap
    bottom_left = '0.5 0 0'
    top_right = '0.6 1.0 0'
    block_id = 2
  [../]
  [./subdomain3]
    type = SubdomainBoundingBox #clad
    bottom_left = '0.6 0 0'
    top_right = '0.7 1.0 0'
    block_id = 3
  [../] 
[]

[Variables]
  [./temperature]
  [../]
[]


[Kernels]
  [./clad_conduction]
    type = HeatConduction
    variable = temperature
    block = '1 2 3'
  [../]
  [./fuel_heat]
    type = HeatSource
    value = 250
    variable = temperature
    block = 1
  [../]
[]


[BCs]
  [outlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = right
    value = 500 # (K)
  []
  [inlet_temp]
    type = NeumannBC
    variable = temperature
    boundary = left
    value = 0 
  []
[]

[Materials]
  [./fuel]
    type = HeatConductionMaterial
    thermal_conductivity = 0.3
    block = 1
  [../]
  [./gap]
    type = HeatConductionMaterial
    thermal_conductivity = 0.1
    block = 2
  [../]
  [./clad]
    type = HeatConductionMaterial
    thermal_conductivity = 0.17
    block = 3
  [../]
[]

[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
[]

[Outputs]
  exodus = true
[]