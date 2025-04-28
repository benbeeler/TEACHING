# Cecilia Harrison MOOSE Project Part 1 Due February 28th, 2025

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles and rectangular prisms
    dim = 2                       # Dimension of the mesh
    nx = 600                      # Number of elements in the x direction
    ny = 8                        # Number of elements in the y direction
    xmax = 0.6050                 # Length of test chamber
    ymax = 1.0000                 # Test chamber radius
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
[]

[Functions]
  [source]
  type = ParsedFunction
  expression = '350/(pi*.5^2)'   # Watts/cm^3, LHR over area of pellet to convert to volumetric
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
    value = 550                   # (K) Gives the outer cladding temperature
  []
[]

[Materials]
  [fuel]
    type = ADGenericConstantMaterial
    block = 2
    prop_names =  'thermal_conductivity specific_heat density'
    prop_values = '0.03                 0.33          10.97'     # W/(cm K), J/(g K), g/cm^3
  []
  [gap]
    type = ADGenericConstantMaterial
    block = 1
    prop_names =  'thermal_conductivity specific_heat density'
    prop_values = '0.153e-2             5.1932        0.1786e-3' # W/(cm K), J/(g K), g/cm^3
  []
  [clad]
    type = ADGenericConstantMaterial
    block = 0
    prop_names =  'thermal_conductivity specific_heat density'
    prop_values = '0.17                 0.35          6.5'       # W/(cm K), J/(g K), g/cm^3
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
  [temp_profile]
    type = LineValueSampler
    variable = temperature
    start_point = '0 0.5 0'       # centerline of fuel
    end_point = '0.605 0.5 0'
    num_points = 250
    sort_by = 'x'
  []
[]

[Executioner]
  type = Steady                   # Steady problem
  nl_rel_tol = 5e-6
  nl_abs_tol = 1e-8               # default was very small, this allows more reasonable space
  nl_max_its = 20
  l_tol = 1e-4
  l_max_its = 50
  time = 100                      # (s)
[]

[Outputs]
  print_linear_residuals = 'false'
  exodus = true                   # Output Exodus format
  csv = true
[]
