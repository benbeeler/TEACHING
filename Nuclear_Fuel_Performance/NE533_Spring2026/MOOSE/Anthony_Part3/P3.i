# Geometric Parameters (cm)
fuel_thickness = 0.5
gap_thickness = 0.005
clad_thickness = 0.1
rod_z = 0.5

# Coordinates (cm)
fuel_r = '${fuel_thickness}'
gap_r = '${fparse fuel_r + gap_thickness}'
clad_r = '${fparse gap_r + clad_thickness}'

# Fission Parameters
LHR = 350 #W/cm
fission_energy = 3.28451e-11 #J/fission
NU = 2.447e22 #U/cc

[Mesh]
  coord_type = 'RZ'
  patch_update_strategy = 'iteration'
  [fuel]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 30
    ny = 30
    xmin = 0
    xmax = '${fuel_r}'
    ymin = 0
    ymax = '${rod_z}'
    boundary_name_prefix = 'fuel'
  []
  [fuel_id]
    type = SubdomainIDGenerator
    input = 'fuel'
    subdomain_id = 11
  []
  [clad]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 6
    ny = 30
    xmin = '${gap_r}'
    xmax = '${clad_r}'
    ymin = 0
    ymax = '${rod_z}'
    boundary_name_prefix = 'clad'
    boundary_id_offset = 10
  []
  [clad_id]
    type = SubdomainIDGenerator
    input = 'clad'
    subdomain_id = 13
  []
  [system]
    type = MeshCollectionGenerator
    inputs = 'fuel_id clad_id'
  []
  [clad_left_edge]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'clad_left'
    new_block_id = 10001
    new_block_name = 'clad_left_edge'
    input = 'system'
  []
  [fuel_right_edge]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'fuel_right'
    new_block_id = 10000
    new_block_name = 'fuel_right_edge'
    input = 'clad_left_edge'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  stress_free_temperature = 550
[]

[Variables]
  [T]
    initial_condition = 550
  []
  [lm]
    order = FIRST
    family = LAGRANGE
    block = 'clad_left_edge'
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
  [burnup]
    type = FunctionAux
    block = '11 10000'
    variable = 'burnup'
    function = '(((${LHR}/(pi*${fuel_thickness}^2))/${fission_energy})*t)/${NU}'
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  add_variables = true
  generate_output = 'radial_stress axial_stress hoop_stress'
  temperature = T
  use_automatic_differentiation = true
  [fuel]
    block = '11 10000'
    eigenstrain_names = 'fuel_TE_strain fuel_dens_strain fuel_sfp_strain fuel_gfp_strain'
    use_automatic_differentiation = true
  []
  [clad]
    block = '13 10001'
    eigenstrain_names = 'clad_TE_strain'
    use_automatic_differentiation = true
  []
[]

[UserObjects]
  [gap_conduction]
    type = GapFluxModelConduction
    temperature = 'T'
    boundary = 'clad_left'
    gap_conductivity_function = '16e-6*t^0.79'
    gap_conductivity_function_variable = T
  []
[]

[Constraints]
  [thermal_contact]
    type = ModularGapConductanceConstraint
    variable = 'lm'
    primary_boundary = 'fuel_right'
    primary_subdomain = 10000
    secondary_boundary = 'clad_left'
    secondary_subdomain = 10001
    secondary_variable = 'T'
    gap_flux_models = 'gap_conduction'
    gap_geometry_type = 'CYLINDER'
    use_displaced_mesh = true
  []
[]

[Contact]
  [mechanical]
    primary = 'fuel_right'
    secondary = 'clad_left'
    formulation = penalty
    penalty = 5e12
    normalize_penalty = true
  []
[]

[Kernels]
  [heat]
    type = ADHeatConduction
    variable = T
  []
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = T
  []
  [heat_src]
    type = HeatSource
    variable = T
    function = VHR
    block = '11 10000'
  []
[]

[Functions]
  [VHR]
    type = ParsedFunction
    expression = '${LHR}/(pi*${fuel_thickness}^2)'
  []
  [fuel_k]
    type = ParsedFunction
    symbol_names = 'burnup'
    symbol_values = 'burnup'
    # expression = '(1-(0.5*(1+tanh(((t-273.15)-900)/150))))*(1/(9.592e-2+6.14e-3*burnup-1.4e-5*burnup^2+(2.5e-4-1.81e-6*burnup)*(t-273.15)))+(0.5*(1+tanh(((t-273.15)-900)/150)))*(1/(9.592e-2+2.6e-3*burnup+(2.5e-4-2.7e-7*burnup)*(t-273.15)))+(1.32e-2*exp(1.88e-3*(t-273.15)))'
    expression = '1/((3.8+200*burnup)+(0.0217*t))' # W/cm-K
  []
  [clad_k]
    type = ParsedFunction
    expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100' # W/cm-K
  []
[]

[Materials]
  [fuel_therm_prop]
    type = ADHeatConductionMaterial
    block = '11 10000'
    temp = T
    min_T = 300
    # thermal_conductivity = 0.03
    thermal_conductivity_temperature_function = fuel_k
    specific_heat = 0.33
  []
  [clad_therm_prop]
    type = ADHeatConductionMaterial
    block = '13 10001'
    temp = T
    min_T = 300
    # thermal_conductivity = 0.17
    thermal_conductivity_temperature_function = clad_k
    specific_heat = 0.35
  []
  [fuel_density]
    type = ADGenericConstantMaterial
    block = '11 10000'
    prop_names = 'density'
    prop_values = '10.98'
  []
  [clad_density]
    type = ADGenericConstantMaterial
    block = '13 10001'
    prop_names = 'density'
    prop_values = '6.5'
  []
  [fuel_elasticity]
    type = ADComputeIsotropicElasticityTensor
    block = '11 10000'
    youngs_modulus = 200.0e9
    poissons_ratio = 0.345
  []
  [fuel_T_expansion]
    type = ADComputeThermalExpansionEigenstrain
    block = '11 10000'
    temperature = T
    thermal_expansion_coeff = 11e-6
    eigenstrain_name = 'fuel_TE_strain'
  []
  [fuel_dens]
    type = ADParsedMaterial
    block = '11 10000'
    property_name = 'fuel_dens'
    coupled_variables = 'T burnup'
    expression = 'if(T<1023.15, 0.01*(exp((burnup*log(0.01))/((7.235-0.0086*((T-273.15)-25))*0.005))-1), 0.01*(exp((burnup*log(0.01))/(1*0.005))-1))'
  []
  [fuel_dens_exp]
    type = ADComputeVolumetricEigenstrain
    block = '11 10000'
    eigenstrain_name = 'fuel_dens_strain'
    volumetric_materials = 'fuel_dens'
  []
  [fuel_sfp]
    type = ADParsedMaterial
    block = '11 10000'
    property_name = 'fuel_sfp'
    coupled_variables = 'burnup'
    expression = '5.577e-2*10.97*burnup'
  []
  [fuel_sfp_exp]
    type = ADComputeVolumetricEigenstrain
    block = '11 10000'
    eigenstrain_name = 'fuel_sfp_strain'
    volumetric_materials = 'fuel_sfp'
  []
  [fuel_gfp]
    type = ADParsedMaterial
    block = '11 10000'
    property_name = 'fuel_gfp'
    coupled_variables = 'T burnup'
    expression = 'if(T<2800, 1.96e-28*10.97*burnup*(2800-T)^(11.73)*exp(-0.0162*(2800-T))*exp(-17.8*10.97*burnup), 0)'
  []
  [fuel_gfp_exp]
    type = ADComputeVolumetricEigenstrain
    block = '11 10000'
    eigenstrain_name = 'fuel_gfp_strain'
    volumetric_materials = 'fuel_gfp'
  []
  [clad_elasticity]
    type = ADComputeIsotropicElasticityTensor
    block = '13 10001'
    youngs_modulus = 80.0e9
    poissons_ratio = 0.41
  []
  [clad_T_expansion]
    type = ADComputeThermalExpansionEigenstrain
    block = '13 10001'
    temperature = T
    thermal_expansion_coeff = 7.1e-6
    eigenstrain_name = 'clad_TE_strain'
  []
  [stress]
    type = ADComputeLinearElasticStress
  []
[]

[BCs]
  [Outer_Clad_Temp]
    type = ADDirichletBC
    boundary = 'clad_right'
    value = 550
    variable = 'T'
  []
  [T_Axial_Sym]
    type = ADNeumannBC
    boundary = 'fuel_top clad_top fuel_bottom clad_bottom'
    value = 0
    variable = 'T'
  []
  [S_Axial_Sym]
    type = ADDirichletBC
    boundary = 'fuel_bottom clad_bottom'
    value = 0
    variable = 'disp_y'
  []
[]

[Postprocessors]
  [fuel_cent_temp]
    type = AxisymmetricCenterlineAverageValue
    variable = 'T'
    boundary = 'fuel_left'
  []
  [fuel_surf_temp]
    type = SideAverageValue
    variable = 'T'
    boundary = 'fuel_right'
  []
  [clad_inner_temp]
    type = SideAverageValue
    variable = 'T'
    boundary = 'clad_left'
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
  [burnup]
    type = ElementAverageValue
    variable = 'burnup'
  []
  [ave_radial_stress]
    type = ElementAverageValue
    block = '11'
    variable = 'radial_stress'
  []
  [ave_axial_stress]
    type = ElementAverageValue
    block = '11'
    variable = 'axial_stress'
  []
  [ave_hoop_stress]
    type = ElementAverageValue
    block = '11'
    variable = 'hoop_stress'
  []
  [max_stress]
    type = ElementExtremeValue
    block = '11'
    variable = 'hoop_stress'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  line_search = 'NONE'
  automatic_scaling = true

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8

  nl_forced_its = 2
  nl_max_its = 10

  end_time = 1.14e8
  dtmax = 1e6

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
    file_base = P3
  []
[]