# Cecilia Harrison MOOSE Project Part 2 Due March 28th, 2025

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles and rectangular prisms
    dim = 2                       # Dimension of the mesh
    nx = 625                      # Number of elements in the x direction
    ny = 50                       # Number of elements in the y direction
    xmax = 0.6050                 # Length of test chamber
    ymax = 100.00                 # Test chamber radius
  []
  coord_type = 'RZ'
  rz_coord_axis = 'Y'             # Centered around the y-axis
  [block1]
    type = SubdomainBoundingBoxGenerator
    block_id = 1                  # Gap
    bottom_left = '0 0 0'
    top_right = '0.505 100 0'
    input = 'gmg'
  []
  [block2]
    type = SubdomainBoundingBoxGenerator
    block_id = 2                  # Fuel
    bottom_left = '0 0 0'
    top_right = '0.5 100 0'
    input = 'block1'
  []
[]

[Variables]
  [temperature]
    # Adds a Linear Lagrange variable by default
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
  []
  [heat_source]
    type = HeatSource
    variable = temperature
    block = 2
    function = source
  []
[]

[Functions]
  [source]
  type = ParsedFunction
  expression = '350*cos(1.2*(y/50-1))/(pi*0.5^2)' # Watts/cm^3, LHR over area of pellet to convert to volumetric
  []
  [coolant_temp]
  type = ParsedFunction
  expression = '500+1/250/4.2*350*50/1.2*(sin(1.2)+sin(1.2*(y/50-1)))+(350*cos(1.2*(y/50-1)))/(2*pi*.5*2.65)'
  []
  # Now all of the thermal conductivities
  [k_fuel]
  type = ParsedFunction
  expression = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100'
  []
  [k_gap]
  type = ParsedFunction
  expression = '16e-6*t^0.79'
  []
  [k_clad]
  type = ParsedFunction
  expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100'
  []
[]

[BCs]
  [left]
    type = NeumannBC              # Simple u=value BC
    variable = temperature        # Variable to be set
    boundary = 'left'             # Name of a sideset in the mesh
    value = 0                     # (K/s) rate of temperature change
  []
  [right]
    type = FunctionDirichletBC
    variable = temperature
    boundary = 'right'
    function = coolant_temp       # (K) Gives the outer cladding temperature
  []
[]

[Materials]
  [fuel]
    type = ADGenericConstantMaterial
    block = 2
    prop_names =  'density'
    prop_values = '10.97'         # g/cm^3
  []
  [gap]
    type = ADGenericConstantMaterial
    block = 1
    prop_names =  'density'
    prop_values = '0.1786e-3'     # g/cm^3
  []
  [clad]
    type = ADGenericConstantMaterial
    block = 0
    prop_names =  'density'
    prop_values = '6.5'           # g/cm^3
  []
  [k_fuel]
    type = ADHeatConductionMaterial
    block = 2
    thermal_conductivity_temperature_function = k_fuel
    temp = temperature
    min_T = 500
    specific_heat = 0.33          # J/(g K)
  []
  [k_gap]
    type = ADHeatConductionMaterial
    block = 1
    thermal_conductivity_temperature_function = k_gap
    temp = temperature
    min_T = 500
    specific_heat = 5.1932        # J/(g K)
  []
  [k_clad]
    type = ADHeatConductionMaterial
    block = 0
    thermal_conductivity_temperature_function = k_clad
    temp = temperature
    min_T = 500
    specific_heat = 0.35          # J/(g K)
  []
[]

[Preconditioning]
  [initial]
    full = true
    type = SMP
    solve_type = 'NEWTON'         
  []
[]

[VectorPostprocessors]
  [outer_clad_surface]
    type = LineValueSampler
    variable = temperature
    start_point = '0.605 0 0'     # cladding surface temperature profile
    end_point = '0.605 100 0'
    num_points = 200
    sort_by = 'y'
  []
  [inner_clad_surface]
    type = LineValueSampler
    variable = temperature
    start_point = '0.505 0 0'     # cladding surface temperature profile
    end_point = '0.505 100 0'
    num_points = 200
    sort_by = 'y'
  []
  [fuel_surface]
    type = LineValueSampler
    variable = temperature
    start_point = '0.5 0 0'       # fuel surface temperature profile
    end_point = '0.5 100 0'
    num_points = 200
    sort_by = 'y'
  []
  [centerline]
    type = LineValueSampler
    variable = temperature
    start_point = '0 0 0'         # fuel centerline temperature profile
    end_point = '0 100 0'
    num_points = 200
    sort_by = 'y'
  []
  [radial]
    type = LineValueSampler
    variable = temperature
    start_point = '0 50 0'       # radial temperature profile
    end_point = '0.605 50 0'
    num_points = 250
    sort_by = 'x'
  []
[]

[Executioner]
  type = Steady                   # Steady problem
[]

[Outputs]
  print_linear_residuals = 'false'
  exodus = true                   # Output Exodus format
  csv = true
[]
