# Cecilia Harrison MOOSE Project Part 3 Due April 25th, 2025 - Steady-State Heat Transfer

[Mesh]
  coord_type = 'RZ'
  [fuel]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles, and rectangular prisms
    dim = 2                       # Dimension of the mesh
    nx = 100                      # Number of elements in the x direction
    ny = 10                       # Number of elements in the y direction
    xmax = 0.5000                 # Length of test chamber
    ymax = 0.5000                 # Test chamber radius
    xmin = 0
    ymin = 0
    boundary_name_prefix = 'fuel' # in order to refer to boundaries of fuel pellet when fixing y expansion
  []
  [fuel_id]
    type = SubdomainIDGenerator
    input = 'fuel'
    subdomain_id = 1
  []
  [clad]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles, and rectangular prisms
    dim = 2                       # Dimension of the mesh
    nx = 50                       # Number of elements in the x direction
    ny = 10                       # Number of elements in the y direction
    xmax = 0.6050                 # Length of test chamber
    ymax = 0.5000                 # Test chamber radius
    xmin = 0.5050
    ymin = 0
    boundary_id_offset = 4
    boundary_name_prefix = 'clad'
  []
  [clad_id]
    type = SubdomainIDGenerator
    input = 'clad'
    subdomain_id = 2
  []
  [fuel_and_clad]
    type = MeshCollectionGenerator
    inputs = 'fuel_id clad_id'
  []
  [clad_left_edge]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'clad_left'
    new_block_id = 21
    new_block_name = 'clad_left_edge'
    input = 'fuel_and_clad'
  []
  [fuel_right_edge]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'fuel_right'
    new_block_id = 11
    new_block_name = 'fuel_right_edge'
    input = 'clad_left_edge'
  []
[]

[Variables]
  [temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 550.0     # K, assuming we start with a uniform temperature
  []
  [lagrange_multiplier]
    order = FIRST
    family = LAGRANGE
    block = 'clad_left_edge'
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
    block = 1
    function = source
  []
[]

[Functions]
  [burnup]
    type = ParsedFunction
    expression = '((1.35677e13)*t)/(2.447e22)' # find fission rate f/cm^3s
  []
  [k_fuel]
    type = ParsedFunction
    symbol_names = 'b'
    symbol_values = 'burnup'
    expression = '1/((3.8+200*b+(0.0217*t)))'  # Fuel thermal conductivity (no changes for densification)
  []
  [k_clad]
    type = ParsedFunction
    expression = '(8.8527 + 7.0820e-3*t + 2.5329e-6*t^2 + 2.9918e3*(1/t)) / 100'  # Cladding thermal conductivity
  []
  [source]
    type = ParsedFunction
    expression = '350/(pi*0.5^2)'  # LHR in watts per cm^3
  []
[]

[BCs]
  [temp_flux]
    type = ADNeumannBC              # Heat flux boundary condition
    variable = temperature        # Temperature variable to be set
    boundary = 'fuel_top clad_top fuel_bottom clad_bottom'  # Boundary names for fuel and cladding
    value = 0                     # Heat flux rate (0 implies no flux)
  []
  [outer_clad_temp]
    type = ADDirichletBC
    variable = temperature
    boundary = 'clad_right'      # Outer cladding boundary condition
    value = 550.0               # Temperature at outer cladding surface (in K)
  []
[]

[Materials]
  [fuel]
    type = ADGenericConstantMaterial
    block = '1 11'
    prop_names = 'density'
    prop_values = '10.97'         # g/cm^3, fuel density
  []
  [clad]
    type = ADGenericConstantMaterial
    block = '2 21'
    prop_names = 'density'
    prop_values = '6.5'          # g/cm^3, clad density
  []
  [fuel_conductivity]
    type = ADHeatConductionMaterial
    block = '1 11'
    thermal_conductivity_temperature_function = k_fuel
    temp = temperature
    specific_heat = 0.33         # J/(g K), fuel-specific heat
  []
  [clad_conductivity]
    type = ADHeatConductionMaterial
    block = '2 21'
    thermal_conductivity_temperature_function = k_clad
    temp = temperature
    specific_heat = 0.35         # J/(g K), clad-specific heat
  []
[]

[UserObjects]
  [gap_cond]
    type = GapFluxModelConduction
    temperature = 'temperature'
    boundary = 'clad_left'
    gap_conductivity = 0.0023   # Gap conductivity value (constant at initial gap thickness)
  []
[]

[Constraints]
  [thermal_contact]
    type = ModularGapConductanceConstraint
    variable = 'lagrange_multiplier'
    primary_boundary = 'fuel_right'
    primary_subdomain = 11
    secondary_boundary = 'clad_left'
    secondary_subdomain = 21
    secondary_variable = 'temperature'
    gap_flux_models = 'gap_cond'
    gap_geometry_type = 'CYLINDER'
    use_displaced_mesh = false  # No displacement in this case, steady-state
  []
[]

[VectorPostprocessors]
  [fuel_temp_profile]
    type = LineValueSampler
    variable = temperature
    start_point = '0 0 0'
    end_point = '0.5 0 0'
    num_points = 100
    sort_by = 'x'
  []
  [clad_temp_profile]
    type = LineValueSampler
    variable = temperature
    start_point = '0.505 0 0'
    end_point = '0.605 0 0'
    num_points = 100
    sort_by = 'x'
  []
[]

[Preconditioning]
  [initial]
    full = true
    type = SMP
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
