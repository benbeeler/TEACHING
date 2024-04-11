[Mesh]
    [rod]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 1000
      ny = 1000
      xmin = 0
      xmax = 0.605
      ymin = 0
      ymax = 1
    []
    [fuelandgap]
        input = rod
        type = SubdomainBoundingBoxGenerator
        block_id = 1
        bottom_left = '0 0 0'
        top_right = '0.5050 1.000 0'
    []
    [fuel]
        input = fuelandgap
        type = SubdomainBoundingBoxGenerator
        block_id = 2
        bottom_left = '0 0 0'
        top_right = '0.5000 1.000 0'
    []
    coord_type = RZ
    
[]
  
[Variables]
    [temp]
      
    []
[]
  
[Functions]
    
[]
  
[Kernels]
    [diff]
      type = HeatConduction
      variable = temp
      block = '0 1 2'
    []
    [source]
      type = HeatSource
      variable = temp
      value = 445.6338407
      block = 2

    []
[]
  
[BCs]
    [left]
      type = NeumannBC
      variable = temp
      boundary = left
      value = 0

    []
    [right]
      type = DirichletBC
      variable = temp
      boundary = right
      value = 550
    []
[]
  
[Materials]
    [uotwo]
        type = HeatConductionMaterial
        block = 2
        thermal_conductivity = 0.03
        specific_heat = 0.33
    []
    [helium]
        type = HeatConductionMaterial
        block = 1
        thermal_conductivity = 0.002556
        specific_heat = 5.188
    []
    [zirc]
        type = HeatConductionMaterial
        block = 0
        thermal_conductivity = 0.17
        specific_heat = 0.35
    []
[]

  
[Problem]
    type = FEProblem
  
[]
  
[Executioner]
    type = Steady
    solve_type = 'NEWTON'
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
[]
  
[Outputs]
    exodus = true
[]