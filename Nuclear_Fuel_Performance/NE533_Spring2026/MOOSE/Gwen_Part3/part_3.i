# constants
fuel_thick = 0.5 
gap_thick = 0.005 
clad_thick = 0.1 
rod_z = 0.5
nu = 2.447e22 
fission_energy = 3.28451e-11 
LHR = 350 
fission_energy = 3.28451e-11 
fuel_r = '${fuel_thick}'
gap_r = '${fparse fuel_r + gap_thick}'
clad_r = '${fparse gap_r + clad_thick}'

[Mesh]
  coord_type = 'RZ'
  [fuel]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 8
    xmin = 0
    xmax = '${fuel_r}'
    ymin = 0
    ymax = '${rod_z}'
    boundary_id_offset = '10'
    boundary_name_prefix = 'fuel'
  []
  [fuel_id]
    type = SubdomainIDGenerator
    input = 'fuel'
    subdomain_id = 11
  []
  [gap]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 8
    xmin = '${fuel_r}'
    xmax = '${gap_r}'
    ymin = 0
    ymax = '${rod_z}'
    boundary_id_offset = '20'
    boundary_name_prefix = 'gap'
  []
  [gap_id]
    type = SubdomainIDGenerator
    input = 'gap'
    subdomain_id = 12
  []
  [clad]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 8
    xmin = '${gap_r}'
    xmax = '${clad_r}'
    ymin = 0
    ymax = '${rod_z}'
    boundary_id_offset = '30'
    boundary_name_prefix = 'clad'
  []
  [clad_id]
    type = SubdomainIDGenerator
    input = 'clad'
    subdomain_id = 13
  []
  [system]
    type = StitchedMeshGenerator
    inputs = 'fuel_id gap_id clad_id'
    stitch_boundaries_pairs = 'fuel_right gap_left; gap_right clad_left'
  []


[]
[GlobalParams]
  displacements = 'disp_x disp_y'
  stress_free_temperature = 550
[]

[AuxVariables]
  [BU]
    family = MONOMIAL
    order = CONSTANT
  []
  [stress_xx]
    family = MONOMIAL
    order = CONSTANT
  []
  [stress_yy]
    family = MONOMIAL
    order = CONSTANT
  []
  [stress_zz]
    family = MONOMIAL
    order = CONSTANT
  []
  [gap_width]
    family = MONOMIAL
    order = CONSTANT
  []
[]


[AuxKernels]
  [BU]
    type = FunctionAux
    block = '11'
    variable = 'BU'
    function = '(((${LHR}/(pi*${fuel_thick}^2))/${fission_energy})*t)/${nu}'
  []
  [gap_width_aux]
    type = ParsedAux
    variable = gap_width
    coupled_variables = 'disp_x'
    function = '0.005 - disp_x'  
    block = 11
  []
  [stress_xx_aux]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = stress_xx
    block = 11
  []
  [stress_yy_aux]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = stress_yy
    block = 11
  []
  [stress_zz_aux]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 2
    variable = stress_zz
    block = 11
  []
[]


[Variables]
  [T]
    initial_condition = 550
  []
[]

[Functions]
  [VHR]
    type = ParsedFunction
    expression = '(${LHR}*exp(-((t-20)^2)/2)+350)/(pi*${fuel_thick}^2)'
  []
  [fuel_k]
    type = ParsedFunction
    symbol_names = 'burnup'
    symbol_values = 'burnup'
    expression = '1/((3.8+200*burnup)+(0.0217*t))' # W/cm-K
  []
  [gap_k]
    type = ParsedFunction
    expression = '16e-6*t^0.79' # W/cm-K
  []
  [clad_k]
    type = ParsedFunction
    expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100' 
  []
  [burnup]
    type = ParsedFunction
    expression = '(((${LHR}/(pi*${fuel_thick}^2))/${fission_energy})*t)/${nu}'
  []
[]

[Kernels]
  [heat]
    type = ADHeatConduction
    variable = T
  []
  [heat_src]
    type = HeatSource
    variable = T
    function = VHR
    block = 11
  []
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = T
  []
[]
[Physics/SolidMechanics/QuasiStatic]
  add_variables = true
  generate_output = 'radial_stress axial_stress hoop_stress'
  use_automatic_differentiation = true
  temperature = T
  [fuel]
    block = '11'
    eigenstrain_names = 'fuel_TE_strain fuel_swell_strain'
  []
  [gap]
    block = '12'
  []
  [clad]
    block = '13'
    eigenstrain_names = 'clad_TE_strain'
  []
[]

[Materials]
  [fuel_therm_prop]
    type = ADHeatConductionMaterial
    block = '11'
    temp = T
    min_T = 300
    thermal_conductivity_temperature_function = fuel_k
    specific_heat = 0.33
  []
  [gap_therm_prop]
    type = ADHeatConductionMaterial
    temp = T
    min_T = 500
    thermal_conductivity_temperature_function = gap_k
    specific_heat = 5.1932
    block = 12
  []
  [clad_therm_prop]
    type = ADHeatConductionMaterial
    block = '13'
    temp = T
    min_T = 300
    thermal_conductivity_temperature_function = clad_k
    specific_heat = 0.35
  []
  [fuel_density]
    type = ADGenericConstantMaterial
    block = '11'
    prop_names = 'density'
    prop_values = '10.98'
  []
  [gap_density]
    type = ADGenericConstantMaterial
    block = 12
    prop_names = 'density'
    prop_values = '0.1786e-3'
  []
  [clad_density]
    type = ADGenericConstantMaterial
    block = '13'
    prop_names = 'density'
    prop_values = '6.5'
  []
  [fuel_elasticity]
    type = ComputeIsotropicElasticityTensor
    block = '11'
    youngs_modulus = 200.0e9
    poissons_ratio = 0.345
  []
  [fuel_T_expansion]
    type = ComputeThermalExpansionEigenstrain
    block = '11'
    temperature = T
    thermal_expansion_coeff = 11e-6
    eigenstrain_name = 'fuel_TE_strain'
  []
  [fuel_total_prefactor]
    type = DerivativeParsedMaterial
    block = 11
    property_name = 'fuel_total_prefactor'
    coupled_variables = 'T BU'
    constant_names = 'c0 c1 c2'
    constant_expressions = '0.01 5.577e-2*10.97 1.96e-28*10.97'
    expression = 'if(T<1023.15, c0*(exp((BU*log(0.01))/((7.235-0.0086*(T-298.15))*0.005))-1), c0*(exp((BU*log(0.01))/(1*0.005))-1)) + c1*BU + c2*BU*(2800-T)^(11.73)*exp(-0.0162*(2800-T))*exp(-17.8*10.97*BU)'
  []
  [fuel_swell_strain]
    type = ComputeVariableEigenstrain
    eigen_base = '1 1 1 0 0 0'
    prefactor = 'fuel_total_prefactor'
    args = 'T BU'
    eigenstrain_name = 'fuel_swell_strain'
    block = '11'
  []
  [gap_elasticity]
    type = ComputeIsotropicElasticityTensor
    block = '12'
    youngs_modulus = 1
    poissons_ratio = 0.0
  []
  [clad_elasticity]
    type = ComputeIsotropicElasticityTensor
    block = '13'
    youngs_modulus = 80.0e9
    poissons_ratio = 0.41
  []
  [clad_T_expansion]
    type = ComputeThermalExpansionEigenstrain
    block = '13'
    temperature = T
    thermal_expansion_coeff = 7.1e-6
    eigenstrain_name = 'clad_TE_strain'
  []
  [stress]
    type = ComputeLinearElasticStress
    block = '11 12 13'
  []
[]

[BCs]
  [Outer_Clad_Temp]
    type = ADDirichletBC
    boundary = 'clad_right'
    value = 550
    variable = T
  []
  [Axial_Sym]
    type = ADNeumannBC
    boundary = 'fuel_top gap_top clad_top fuel_bottom gap_bottom clad_bottom'
    value = 0
    variable = T
  []
  [S_Axial_Sym]
    type = ADDirichletBC
    boundary = 'fuel_bottom gap_bottom clad_bottom'
    value = 0
    variable = 'disp_y'
  []
[]

[Postprocessors]
  [fuel_avg_burnup]
    type = ElementAverageValue
    block = 11
    variable = BU
  []
  [fuel_max_burnup]
    type = ElementExtremeValue
    block = 11
    variable = BU
    value_type = 'max'
  []
  [fuel_min_burnup]
    type = ElementExtremeValue
    block = 11
    variable = BU
    value_type = 'min'
  []

  [fuel_avg_stress_xx]
    type = ElementAverageValue
    block = 11
    variable = stress_xx
  []
  [fuel_avg_stress_yy]
    type = ElementAverageValue
    block = 11
    variable = stress_yy
  []
  [fuel_avg_stress_zz]
    type = ElementAverageValue
    block = 11
    variable = stress_zz
  []
  [fuel_max_stress_xx]
  type = ElementExtremeValue
  block = 11
  variable = stress_xx
  value_type = 'max'
[]
[fuel_max_stress_yy]
  type = ElementExtremeValue
  block = 11
  variable = stress_yy
  value_type = 'max'
[]
[fuel_max_stress_zz]
  type = ElementExtremeValue
  block = 11
  variable = stress_zz
  value_type = 'max'
[]
# Average Temperature in Fuel
[fuel_avg_temperature]
  type = ElementAverageValue
  block = 11
  variable = T
[]

[fuel_avg_disp_x]
  type = ElementAverageValue
  block = 11
  variable = disp_x
[]

[fuel_avg_disp_y]
  type = ElementAverageValue
  block = 11
  variable = disp_y
[]
[fuel_avg_gap_width]
    type = ElementAverageValue
    block = 11
    variable = gap_width
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
    file_base = part_3
    show = 'fuel_avg_burnup fuel_max_burnup fuel_min_burnup fuel_avg_stress_xx fuel_avg_stress_yy fuel_avg_stress_zz fuel_max_stress_xx fuel_max_stress_yy fuel_max_stress_zz fuel_avg_temperature fuel_avg_disp_x fuel_avg_disp_y fuel_avg_gap_width'

  []
[]

