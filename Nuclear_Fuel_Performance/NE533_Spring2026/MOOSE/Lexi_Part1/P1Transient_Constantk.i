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
    expression = (350*exp(-((t-20)^2)/2)+350)/(pi*(0.5^2)) #LHR / cross sectional area of pellet
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
[time_derivative]
  type = ADHeatConductionTimeDerivative
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
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.03 0.33 10.98' #W/(cm*K), J/(g*K), g/cm^3
    block = 2
  [../]
  [./gap] #assuming entirely He gap
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.153e-2 5.1932 0.1786e-3' #W/(cm*K), J/(g*K), g/cm^3
    block = 1
  [../]
  [./clad] #Zr
    type = ADGenericConstantMaterial
    prop_names = 'thermal_conductivity specific_heat density'
    prop_values = '0.17 0.35 6.5' #W/(cm*K), J/(g*K), g/cm^3
    block = 0
  [../]
[]

[Postprocessors] #point value
  [CL_temp_profile]
    type = PointValue
    point = '0 0.5 0'
    variable = T
  []
[]

[Executioner]
   type = Transient
   start_time = 0
   dt = 1
   end_time = 100
   nl_rel_tol = 5e-6 #relative tolerance comparing residuals, if they are this small, then converged
   nl_abs_tol = 1e-8 #absolute tolerance converges if at that tolerance it is equal. order of magnitude of residual
   nl_max_its = 20
   l_tol = 1e-4 #linear tolerance, lower tolerances, better solutions, but may take longer to run/divergence
   l_max_its = 50 #add this to set number of linear iterations to minimize residual loss
[]
[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = P1Transient_ConstantK_temp_profile
  []
[]