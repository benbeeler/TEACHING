mdot = 250 #g/s-rod
Z0 = 50
LHR0 = 350 #W/cm
Cpw = 4.2 #J/g-K
Tin = 500 #K
h_cool = 2.65 #W/cm-K

[Mesh] 
coord_type = 'RZ'
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 600
    ny = 200

    xmin = 0
    ymin = 0
    xmax = 0.605 
    ymax = 100
  []

  [subdomain1] 
    #gap
    type = SubdomainBoundingBoxGenerator
    input = gmg
    bottom_left = '0.5 0 0'
    top_right = '0.505 100 0'
    block_id = '1'
  []
  [subdomain2]
    #fuel
    type = SubdomainBoundingBoxGenerator
    input = subdomain1
    bottom_left = '0 0 0'
    top_right = '0.5 100 0'    
    block_id = '2'
  []
[]
[Functions]
 [VHR]
 type = ParsedFunction
 expression = 'LHR0*cos(1.2*(y/Z0-1))/(pi*(0.5^2))' #LHR / cross sectional area of pellet
 symbol_names = 'LHR0 Z0'
 symbol_values = '${LHR0} ${Z0}'
 []
 [OuterClad]
  type = ParsedFunction
  expression = 'Tin + (LHR0*cos(1.2*(y/Z0-1)))/(2*pi*0.5*h_cool)+(((1/1.2)*((Z0*LHR0)/(mdot*Cpw))*(sin(1.2)+sin(1.2*((y/Z0)-1)))))'
  symbol_names = 'Tin Z0 LHR0 mdot Cpw h_cool'
  symbol_values = '${Tin} ${Z0} ${LHR0} ${mdot} ${Cpw} ${h_cool}'
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
  [Left]
    type = NeumannBC
    variable = T
    boundary = left
    value = 0 
  []
  [Right]
    type = FunctionDirichletBC
    variable = T
    function = OuterClad
    boundary = right
  []
[]

[Materials]

  [./fuel] #UO2
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '0.33 10.98' # J/(g*K), g/cm^3
    temp = T
    min_T = 500
    thermal_conductivity_temperature_function = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100' # W/(cm*K) uses linear cart. coord to linearly map
    specific_heat = 0.33
    block = 2
  [../]

  [./gap] # Helium gap
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '5.1932 0.0001786' # W/(cm*K), J/(g*K), g/cm^3
    temp = T
    min_T = 500
    thermal_conductivity_temperature_function = '16e-6*(t^0.79)' # W/(cm*K)
    specific_heat = 5.1932
    block = 1
  [../]

  [./clad] # Zirconium
    type = ADHeatConductionMaterial
    #prop_names = 'specific_heat density'
    #prop_values = '0.35 6.5' # J/(g*K), g/cm^3
    temp = T
    min_T = 500
    thermal_conductivity_temperature_function = '(8.8527 + 7.0820e-3*t + 2.5329e-6*t^2 + 2.9918e3/t)/100' # W/(cm*K)
    specific_heat = 0.35
    block = 0
  [../]
[]

[VectorPostprocessors]
  [CenterLine]
   type = LineValueSampler
   variable = T 
   start_point = '0 0 0'
   end_point = '0 100 0'
   num_points = 500
   sort_by = 'y'
   [] 
  [FuelSurface]
    type = LineValueSampler
    variable = T 
    start_point = '0.500 0 0'
    end_point = '0.500 100 0'
    num_points = 500
    sort_by = 'y'
  []
  [InnerCladding]
    type = LineValueSampler
    variable = T 
    start_point = '0.505 0 0'
    end_point = '0.505 100 0'
    num_points = 500
    sort_by = 'y'
  []
[]
[Executioner]
   type = Steady
[]
[Outputs]
  exodus = true
  [csv]
    type = CSV
    execute_on = final
  []
[]