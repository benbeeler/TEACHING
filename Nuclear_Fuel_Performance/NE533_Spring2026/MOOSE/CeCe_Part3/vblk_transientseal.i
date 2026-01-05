# Cecilia Harrison MOOSE Project Part 1 Due February 28th, 2025

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles and rectangular prisms
    dim = 2                       # Dimension of the mesh
    nx = 600                      # Number of elements in the x direction
    ny = 8                        # Number of elements in the y direction
    xmax = 0.6050                 # Length of test chamber
    ymax = 100.00                 # Test chamber radius
  []
  coord_type = 'RZ'
  [block1]
    type = SubdomainBoundingBoxGenerator
    block_id = 1                  # Gap
    bottom_left = '0 0 0'
    top_right = '0.505 1.000 0'
    input = 'gmg'
  []
  [block2]
    type = SubdomainBoundingBoxGenerator
    block_id = 2                  # Fuel
    bottom_left = '0 0 0'
    top_right = '.5 1 0'
    input = 'block1'
  []
[]

[Variables]
  [temperature]
    # Adds a Linear Lagrange variable by default
    order = FIRST
    family = LAGRANGE
    initial_condition = 550.0     # K, assuming we start at a uniform temperature throughout 
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
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
  []
[]

[Functions]
  [source]
  type = ParsedFunction
  expression = '(350*exp(-((t-20)^2)/2)+350)/(pi*.5^2)' # Watts/cm^3, LHR over area of pellet to convert to volumetric
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
    type = DirichletBC
    variable = temperature
    boundary = 'right'
    value = 550.0                 # (K) Gives the outer cladding temperature
  []
  [
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
    solve_type = 'NEWTON'         # PJFNK was making issues
  []
[]

[Postprocessors]
  [temp_profile]
    type = PointValue
    variable = temperature
    point = '0 0.5 0'             # mid-point of the centerline of fuel
  []
[]

[Executioner]
  type = Transient                # Transient problem
  nl_rel_tol = 1e-6
  nl_abs_tol = 5e-10              #  default was very small, this allows more reasonable space
  start_time = 0.0
  dt = 1
  num_steps = 200                 # up to t=100
[]

[Outputs]
  print_linear_residuals = 'false'
  exodus = true                   # Output Exodus format
  csv = true
[]
