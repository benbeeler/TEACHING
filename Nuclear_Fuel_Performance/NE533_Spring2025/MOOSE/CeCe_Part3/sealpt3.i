# Cecilia Harrison MOOSE Project Part 3 Due April 25th, 2025
[Mesh]
  coord_type = 'RZ'
  [fuel]
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles and rectangular prisms
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
    type = GeneratedMeshGenerator # Can generate simple lines, rectangles and rectangular prisms
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

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables]
  [temperature]
    # Adds a Linear Lagrange variable by default
    order = FIRST
    family = LAGRANGE
    initial_condition = 550.0     # K, assuming we start at a uniform temperature throughout 
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
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
    block = 1
  []
[]

# Implementing necessary solid mechanics modules for purpose of thermal expansion functions
[Physics/SolidMechanics/QuasiStatic]
  add_variables = true
  generate_output = 'stress_xx stress_yy stress_zz max_principal_stress' # stress_zz is hoop stress
  use_automatic_differentiation = true
  temperature = temperature
  [fuel_block]
    block = 1
    eigenstrain_names = 'fuel_thermal_expansion_strain densification_strain fuel_solid_strain fuel_gas_strain'
    use_automatic_differentiation = true
  []
  [clad_block]
    block = 2
    eigenstrain_names = 'clad_thermal_expansion_strain'
    use_automatic_differentiation = true
  []
[]

[Functions]
  [source]
  type = ParsedFunction
  expression = '350/(pi*.5^2)' # Watts/cm^3, LHR over area of pellet to convert to volumetric
  []
  # Now all of the thermal conductivities
  [burnup]
  type = ParsedFunction
  expression = '((1.35677e13)*t)/(2.447e22)' # find fission rate f/cm^3s
  []
  [k_fuel]
  type = ParsedFunction
  symbol_names = 'b'
  symbol_values = 'burnup'
  expression = '1/((3.8+200*b+(0.0217*t)))' # find fission rate f/cm^3s
  []
  [k_clad]
  type = ParsedFunction
  expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100'
  []
[]

[BCs]
  [temp_flux]
    type = ADNeumannBC              # Simple u=value BC
    variable = temperature        # Variable to be set
    boundary = 'fuel_top clad_top fuel_bottom clad_bottom' # Name of a sideset in the mesh
    value = 0                     # (K/s) rate of temperature change
  []
  [outer_clad_temp]
    type = ADDirichletBC
    variable = temperature
    boundary = 'clad_right'
    value = 550.0                 # (K) Gives the outer cladding temperature
  []
  [top_bottom_fix]
    type = ADDirichletBC
    boundary = 'fuel_bottom clad_bottom'
    value = 0
    variable = 'disp_y'
  []
  [clad_fix]
    type = ADDirichletBC
    boundary = 'clad_right'
    value = 0
    variable = 'disp_x'
  []
[]

[Materials]
  [fuel]
    type = ADGenericConstantMaterial
    block = '1 11'
    prop_names =  'density'
    prop_values = '10.97'         # g/cm^3
  []
  [clad]
    type = ADGenericConstantMaterial
    block = '2 21'
    prop_names =  'density'
    prop_values = '6.5'           # g/cm^3
  []
  [k_fuel]
    type = ADHeatConductionMaterial
    block = '1 11'
    thermal_conductivity_temperature_function = k_fuel
    temp = temperature
    min_T = 500
    specific_heat = 0.33          # J/(g K)
  []
  [k_clad]
    type = ADHeatConductionMaterial
    block = '2 21'
    thermal_conductivity_temperature_function = k_clad
    temp = temperature
    min_T = 500
    specific_heat = 0.35          # J/(g K)
  []
  [elasticity_fuel]
    type = ADComputeIsotropicElasticityTensor
    block = 1
    youngs_modulus = 200e9
    poissons_ratio = 0.345
  []
  [elasticity_clad]
    type = ADComputeIsotropicElasticityTensor
    block = 2
    youngs_modulus = 80e9
    poissons_ratio = 0.41
  []
  [thermal_expansion_fuel]
    type = ADComputeThermalExpansionEigenstrain
    block = 1
    thermal_expansion_coeff = 11e-6
    stress_free_temperature = 550.0
    temperature = temperature
    eigenstrain_name = 'fuel_thermal_expansion_strain'
  []
  [thermal_expansion_clad]
    type = ADComputeThermalExpansionEigenstrain
    block = 2
    thermal_expansion_coeff = 7.1e-6
    stress_free_temperature = 550.0
    temperature = temperature
    eigenstrain_name = 'clad_thermal_expansion_strain'
  []
  [stress]
    type = ADComputeLinearElasticStress
    block = '1 2'
  []
  [fuel_densification]
    type = ADParsedMaterial
    block = 1
    property_name = 'densification'
    coupled_variables = 'temperature'
    extra_symbols = 't'
    expression = 'if(temperature<1023.15, 0.01*(exp(((((2e13)*t)/(2.447e22))*log(0.01))/((7.235-0.0086*((temperature-273.15)-25))*0.005))-1), 0.01*(exp(((((2e13)*t)/(2.447e22))*log(0.01))/(1*0.005))-1))'
  []
  [fuel_densification_expansion]
    type = ADComputeVolumetricEigenstrain
    block = 1
    eigenstrain_name = 'densification_strain'
    volumetric_materials = 'densification'
  []
  [fuel_solid_fiss_products]
    type = ADParsedMaterial
    block = 1
    property_name = 'fuel_solid'
    extra_symbols = 't'
    expression = '5.577e-2*10.97*(((2e13)*t)/(2.447e22))'
  []
  [fuel_solid_fiss_products_expansion]
    type = ADComputeVolumetricEigenstrain
    block = 1
    eigenstrain_name = 'fuel_solid_strain'
    volumetric_materials = 'fuel_solid'
  []
  [fuel_gas_fiss_products]
    type = ADParsedMaterial
    block = 1
    property_name = 'fuel_gas'
    extra_symbols = 't'
    coupled_variables = 'temperature'
    expression = '1.96e-28*10.97*(((2e13)*t)/(2.447e22))*(2800-temperature)^(11.73)*exp(-0.0162*(2800-temperature))*exp(-17.8*10.97*(((2e13)*t)/(2.447e22)))'
  []
  [fuel_gas_fiss_products_expansion]
    type = ADComputeVolumetricEigenstrain
    block = 1
    eigenstrain_name = 'fuel_gas_strain'
    volumetric_materials = 'fuel_gas'
  []
[]

[UserObjects]
  [gap_cond]
    type = GapFluxModelConduction
    temperature = 'temperature'
    boundary = 'clad_left'
    gap_conductivity = 0.0023
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
    use_displaced_mesh = true
  []
[]

[Contact]
  [mechanical]
    primary = 'fuel_right'
    secondary = 'clad_left'
    model = frictionless
    formulation = penalty
    penalty = 1e13
    normalize_penalty = true
  []
[]

[Preconditioning]
  [initial]
    full = true
    type = SMP
  []
[]

[AuxVariables]
  [fuel_outer_radius]
    family = MONOMIAL
    order = CONSTANT
  []
  [clad_inner_radius]
    family = MONOMIAL
    order = CONSTANT
  []
  [burnup]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [fuel_outer_radius]
    type = FunctionAux
    variable = 'fuel_outer_radius'
    function = 'x'
    boundary = 'fuel_right'
    use_displaced_mesh = true
  []
  [clad_inner_radius]
    type = FunctionAux
    variable = 'clad_inner_radius'
    function = 'x'
    boundary = 'clad_left'
    use_displaced_mesh = true
  []
[]

[Postprocessors]
  [fuel_cent_temp]
    type = AxisymmetricCenterlineAverageValue
    variable = 'temperature'
    boundary = 'fuel_left'
  []
  [fuel_surf_temp]
    type = SideAverageValue
    variable = 'temperature'
    boundary = 'fuel_right'
  []
  [fuel_outer_r]
    type = SideAverageValue
    boundary = 'fuel_right'
    variable = 'fuel_outer_radius'
    outputs = 'none'
  []
  [clad_inner_r]
    type = SideAverageValue
    boundary = 'clad_left'
    variable = 'clad_inner_radius'
    outputs = 'none'
  []
  [gap_width]
    type = DifferencePostprocessor
    value1 = 'clad_inner_r'
    value2 = 'fuel_outer_r'
  []
  [fuel_expansion_disp]
    type = NodalExtremeValue
    variable = disp_x
    value_type = max
    boundary = 'fuel_right'
  []
  [stress_xx]
    type = SideAverageValue
    variable = stress_xx
    boundary = 'fuel_right'
  []
  [stress_yy]
    type = SideAverageValue
    variable = stress_yy
    boundary = 'fuel_right'
  []
  [stress_zz]
    type = SideAverageValue
    variable = stress_zz
    boundary = 'fuel_right'
  []
[]

[VectorPostprocessors]
  [temp_profile]
    type = LineValueSampler
    variable = temperature
    start_point = '0 0 0'
    end_point = '0.5 0 0'
    num_points = 100
    sort_by = 'x'
  []
  [s_xx_profile]
    type = LineValueSampler
    variable = stress_xx
    start_point = '0 0 0'
    end_point = '0.5 0 0'
    num_points = 100
    sort_by = 'x'
  []
  [s_yy_profile]
    type = LineValueSampler
    variable = stress_yy
    start_point = '0 0 0'
    end_point = '0.5 0 0'
    num_points = 100
    sort_by = 'x'
  []
  [s_zz_profile]
    type = LineValueSampler
    variable = stress_zz
    start_point = '0 0 0'
    end_point = '0.5 0 0'
    num_points = 100
    sort_by = 'x'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = NONE
  automatic_scaling = true
  start_time = 0
  end_time = 1e8
  dt = 1
  dtmin = 1e-4
  dtmax = 1e6
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  nl_max_its = 10
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 10
  []
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  [csv]
    type = CSV
    file_base = seal3
  []
[]
