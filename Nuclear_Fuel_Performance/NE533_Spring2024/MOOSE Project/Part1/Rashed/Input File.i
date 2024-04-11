[Mesh]
    #This is to generate the geometry stated in the problem. 
  [total]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 250
    ny = 250
    xmax = 0.605 
    ymax = 1
  []
  [subdomain1] 
    #The gap dimensions
    type = SubdomainBoundingBoxGenerator
    input = total
    bottom_left = '0.5 0 0'
    top_right = '0.505 1 0'
    block_id = '1'
  []
  [subdomain2]
    #The fuel dimensions
    type = SubdomainBoundingBoxGenerator
    input = subdomain1
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'
    block_id = '2'
  []
[]
[Functions]
  [volumetric_heat]
    #This is Q value as calculated from LHR  
    type = ConstantFunction
    value = 445.6338 
  []
[]
[Variables]
  [./T]
   order = FIRST
  [../]
[]
[Kernels]
  [./generated_heat]
    type = HeatSource
    variable = T
    function = volumetric_heat
    block = 2
  [../]
  [./temperature_conduction2]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = 0.03
    block = 2
  [../]
  [./temperature_conduction1]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = 0.0026
    block = 1
  [../]  
  [./temperature_conduction0]
    type = ADHeatConduction
    variable = T
    thermal_conductivity = 0.17
    block = 0
  [../]  
[]
[BCs]
  [./left]
    type = ADNeumannBC
    variable = T
    boundary = left
    value = 0 
  [../]
  [./right]
    type = ADDirichletBC
    variable = T
    boundary = right
    value = 550 
  [../]
[]
[Materials]
  [./fuel]
    type = HeatConductionMaterial
    thermal_conductivity = 0.03
    block = 2
  [../]
  [./gap]
    type = HeatConductionMaterial
    thermal_conductivity = 0.0026
    block = 1
  [../]
  [./cladding]
    type = HeatConductionMaterial
    thermal_conductivity = 0.17
    block = 0
  [../]
[]
[Problem]
  type = FEProblem
  coord_type = RZ
  rz_coord_axis = Y
[]
[Executioner]
  type = Steady
[]
[Outputs]
  exodus = true
[]