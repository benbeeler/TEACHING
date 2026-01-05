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

  [./fuel] #UO2
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '0.33 10.98' # J/(g*K), g/cm^3
    temp = T
    min_T = 550
    thermal_conductivity_temperature_function = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100' # W/(cm*K) uses linear cart. coord to linearly map
    specific_heat = 0.33
    block = 2
  [../]

  [./gap] # Helium gap
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '5.1932 0.0001786' # W/(cm*K), J/(g*K), g/cm^3
    temp = T
    min_T = 550
    thermal_conductivity_temperature_function = '16e-6*(t^0.79)' # W/(cm*K)
    specific_heat = 5.1932
    block = 1
  [../]

  [./clad] # Zirconium
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '0.35 6.5' # J/(g*K), g/cm^3
    temp = T
    min_T = 550
    thermal_conductivity_temperature_function = '(8.8527 + 7.0820e-3*t + 2.5329e-6*t^2 + 2.9918e3/t)/100' # W/(cm*K)
    specific_heat = 0.35
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
   nl_rel_tol = 5e-6
   nl_abs_tol = 1e-8
   l_tol = 1e-4
   l_max_its = 100
   nl_max_its = 100
[]
[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = P1Static_VariableK
    execute_on = final
  []
[]