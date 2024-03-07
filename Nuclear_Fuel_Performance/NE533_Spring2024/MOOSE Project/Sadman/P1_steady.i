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
    type = HeatConductionMaterial
    thermal_conductivity = .0300 #W/cm-K
    block = '2'
  [../]
  [./gapMat]
    type = HeatConductionMaterial
    thermal_conductivity = .0026 #W/cm-K
    block = '1'
  [../]
  [./cladMat]
    type = HeatConductionMaterial
    thermal_conductivity = .1700 #W/cm-K
    block = '0'
  [../]
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
[]

[Functions]
  [./volumetric_heat]
     type = ConstantFunction
     value = 445.63 # Calculating q as a function of LHR
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
  type = Steady
  solve_type = PJFNK
[]

[Outputs]
  exodus = true
[]
