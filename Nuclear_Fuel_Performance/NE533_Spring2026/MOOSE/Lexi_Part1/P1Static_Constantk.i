[Mesh] 
  coord_type = 'RZ'
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 600
    ny = 6

    xmin = 0
    ymin = 0
    xmax = 0.605 
    ymax = 1
  []

  [subdomain1] 
    #gap
    type = SubdomainBoundingBoxGenerator
    input = gmg
    bottom_left = '0.5 0 0'
    top_right = '0.505 1 0'
    block_id = '1'
  []
  [subdomain2]
    #fuel
    type = SubdomainBoundingBoxGenerator
    input = subdomain1
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'    
    block_id = '2'
  []
[]
[Functions]
 [VHR]
 type = ParsedFunction
 expression = 350/(pi*(0.5^2)) #LHR / cross sectional area of pellet
 []
[]

[Preconditioning]
    [Precondition]
        type = SMP
        full = true
        solve_type = 'NEWTON'
    []
[]

[Variables]
  [T]
   order = FIRST
   initial_condition = 550 #K
  []
[]

[Kernels]
[heat_source]
    type= HeatSource
    variable = T
    function = VHR
    block = 2
[]
[heat]
  type = ADHeatConduction
  variable = T
[]
[]

[BCs] #could add top/bottom if desired
  [./left]
    type = NeumannBC
    variable = T
    boundary = left
    value = 0 
  [../]
  [./right]
    type = DirichletBC
    variable = T
    boundary = right
    value = 550 
  [../]
[]
[Materials]
  [./fuel]
    type = ADHeatConductionMaterial
    #thermal_conductivity_temperature_function
    thermal_conductivity = 0.03 #UO2
    block = 2
  [../]
  [./gap]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.00153 #assuming entirely He gap
    block = 1
  [../]
  [./clad]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.17 #Zr
    block = 0
  [../]
[]

[VectorPostprocessors]
  [temp_profile]
    type = LineValueSampler
    variable = T
    start_point = '0 0.5 0'
    end_point = '0.605 0.5 0'
    num_points = 500
    sort_by = 'x'
  []
[]

[Executioner]
   type = Steady
[]
[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = P1Static_ConstantK
    execute_on = final
  []
[]