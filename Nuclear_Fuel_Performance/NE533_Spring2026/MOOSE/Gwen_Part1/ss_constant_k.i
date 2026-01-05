[Mesh]
        coord_type ='RZ'
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 400
    ny = 4
    xmin = 0
    ymin = 0
    xmax = 0.605  # Fuel,Gap,Cladding
    ymax = 1 #TotalHeight
  []
  [fuel]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'
    input = 'gmg'
  []
  [gap]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '0.5 0 0'
    top_right = '0.505 1 0'
    input = 'fuel'
  []
  [cladding]
    type = SubdomainBoundingBoxGenerator
    block_id = 3
    bottom_left = '0.505 0 0'
    top_right = '0.605 1 0'
    input = 'gap'    
   []
[]


[Variables]
  [T]
    order = FIRST
  []
[]

[Functions]
   [VHR]
        type = ADParsedFunction
        expression = 350/(pi*(0.5^2))
   []
[]
 
[Preconditioning]  
    [Precon]
        type = SMP
        full = True
        solve_type = 'NEWTON'
    []
[]

[Kernels]
  [heat_con]
        type = ADHeatConduction
        variable = T
  []
  [heat_source]
        type = HeatSource
        variable = T
        function = VHR
  []
[]

[BCs]
  [left]
        type = NeumannBC
        boundary = 'left'
        variable = T
        value = 0
  []
  [right]
        type = DirichletBC
        boundary = 'right'
        variable = T
        value = 550 #Outer cladding fixed temp
  []
[]

[Materials]
  [fuel]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.03
    block = 1
  []
  [clad]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.17
    block = 3
  []
  [gap]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.15e-2
    block = 2
  []
[]

[VectorPostprocessors]
  [temperature_profile]
        type = LineValueSampler
        variable = T
        start_point = '0 0.5 0'
        end_point = '0.605 0.5 0'
        num_points = 100
        sort_by = 'x'
   []
[]

[Executioner]
  type = Steady
[]

[Outputs]
  print_linear_residuals = 'false'
  exodus = true
  [CSV]
        type = CSV
        file_base = ss_constant_k
        execute_on = final
  []
[]
