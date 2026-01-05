LHR = 350 #W/cm
Rf = 0.5 #cm
Rg = 0.005 #cm
Rc = 0.1 #cm
fissE = 3.28451e-11 #J/fission
Ud = 2.447e22 #U at/cm^3
Z = 1 #cm

Fuel = '${Rf}'
Gap = '${fparse Rf + Rg}'
Clad = '${fparse Gap + Rc}'


[Mesh] 
  coord_type = 'RZ'
  [fuel]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 10
    xmin = 0
    xmax = '${Fuel}'
    ymin = 0
    ymax = '${Z}'
    boundary_name_prefix = 'fuel'
  []
  [fuel_id]
    type = SubdomainIDGenerator
    input = 'fuel'
    subdomain_id = 2
  []

  [clad]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 10
    xmin = '${Gap}'
    xmax = '${Clad}'
    ymin = 0
    ymax = '${Z}'
    boundary_id_offset = 4
    boundary_name_prefix = 'clad'
  []
  [clad_id]
    type = SubdomainIDGenerator
    input = 'clad'
    subdomain_id = 0
  []
  [system]
    type = MeshCollectionGenerator
    inputs = 'fuel_id clad_id'
  []
  [clad_inside]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'clad_left'
    new_block_id = 01
    new_block_name = 'clad_inside'
    input = 'system'
  []
  [fuel_outside]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'fuel_right'
    new_block_id = 21
    new_block_name = 'fuel_outside'
    input = 'clad_inside'
  []
[]

[GlobalParams]
    displacements = 'disp_x disp_y'
    stress_free_temperature = 550
[]

[Preconditioning]
    [initial]
        full = true
        type = SMP
    []
[]

[Variables]
    [T]
      initial_condition = 550
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
      block = '2 21'
      variable = 'burnup'
      function = '(((${LHR}/(pi*${Fuel}^2))/${fissE})*t)/${Ud}'
    []
[]

[Physics/SolidMechanics/QuasiStatic]
    add_variables = true
    generate_output = 'radial_stress axial_stress hoop_stress'
    use_automatic_differentiation = true
    temperature = T
    [fuel]
      block = '2 21'
      eigenstrain_names = 'f_TE_strain f_dens_strain f_sfp_strain f_gfp_strain' # strain for thermal expansion, densification, and fp (solid and gaseous)
      use_automatic_differentiation = true
    []
    [clad]
      block = '0 01'
      eigenstrain_names = 'c_TE_strain'
      use_automatic_differentiation = true
    []
  []

[ThermalContact]
    [gap_contact]
      type = GapHeatTransfer
      primary = 'fuel_right'
      secondary = 'clad_left'
      gap_conductivity = 0.153e-2
      gap_geometry_type = 'CYLINDER'
      min_gap = '1e-9'
      variable = T
      quadrature = true
    []
[]
[Contact]
    [mechanical]
      primary = 'fuel_right'
      secondary = 'clad_left'
      model = frictionless
      formulation = penalty
      penalty = 1e10
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
      block = '2 21'
    []
[]
[Functions]
    [VHR]
      type = ParsedFunction
      expression = '${LHR}/(pi*${Fuel}^2)'
    []
    [fuel_k]
      type = ParsedFunction
      symbol_names = 'burnup'
      symbol_values = 'burnup'
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
      block = '2 21'
      temp = T
      min_T = 300
      # thermal_conductivity = 0.03
      thermal_conductivity_temperature_function = fuel_k
      specific_heat = 0.33
    []
    [clad_therm_prop]
      type = ADHeatConductionMaterial
      block = '0 01'
      temp = T
      min_T = 300
      # thermal_conductivity = 0.17
      thermal_conductivity_temperature_function = clad_k
      specific_heat = 0.35
    []
    [fuel_density]
      type = ADGenericConstantMaterial
      block = '2 21'
      prop_names = 'density'
      prop_values = '10.98'
    []
    [clad_density]
      type = ADGenericConstantMaterial
      block = '0 01'
      prop_names = 'density'
      prop_values = '6.5'
    []
    [fuel_elasticity]
      type = ADComputeIsotropicElasticityTensor
      block = '2 21'
      youngs_modulus = 200.0e9
      poissons_ratio = 0.345
    []
    [fuel_T_expansion]
      type = ADComputeThermalExpansionEigenstrain
      block = '2 21'
      temperature = T
      thermal_expansion_coeff = 11e-6
      eigenstrain_name = 'f_TE_strain'
    []
    [fuel_dens]
      type = ADParsedMaterial
      block = '2 21'
      property_name = 'fuel_dens'
      coupled_variables = 'T burnup'
      expression = 'if(T<1023.15, 0.01*(exp((burnup*log(0.01))/((7.235-0.0086*((T-273.15)-25))*0.005))-1), 0.01*(exp((burnup*log(0.01))/(1*0.005))-1))'
    []
    [fuel_dens_exp]
      type = ADComputeVolumetricEigenstrain
      block = '2 21'
      eigenstrain_name = 'f_dens_strain'
      volumetric_materials = 'fuel_dens'
    []
    [fuel_sfp]
      type = ADParsedMaterial
      block = '2 21'
      property_name = 'f_sfp'
      coupled_variables = 'burnup'
      expression = '5.577e-2*10.97*burnup'
    []
    [fuel_sfp_exp]
      type = ADComputeVolumetricEigenstrain
      block = '2 21'
      eigenstrain_name = 'f_sfp_strain'
      volumetric_materials = 'f_sfp'
    []
    [fuel_gfp]
      type = ADParsedMaterial
      block = '2 21'
      property_name = 'f_gfp'
      coupled_variables = 'T burnup'
      expression = '1.96e-28*10.97*burnup*(2800-T)^(11.73)*exp(-0.0162*(2800-T))*exp(-17.8*10.97*burnup)'
    []
    [fuel_gfp_exp]
      type = ADComputeVolumetricEigenstrain
      block = '2 21'
      eigenstrain_name = 'f_gfp_strain'
      volumetric_materials = 'f_gfp'
    []
    [clad_elasticity]
      type = ADComputeIsotropicElasticityTensor
      block = '0 01'
      youngs_modulus = 80.0e9
      poissons_ratio = 0.41
    []
    [clad_T_expansion]
      type = ADComputeThermalExpansionEigenstrain
      block = '0 01'
      temperature = T
      thermal_expansion_coeff = 7.1e-6
      eigenstrain_name = 'c_TE_strain'
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
      variable = T
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
    [Radial_Stress]
      type = ElementAverageValue
      variable = radial_stress
    []
    [Axial_Stress]
      type = ElementAverageValue
      variable = axial_stress
    []
    [Hoop_Stress]
      type = ElementAverageValue
      variable = hoop_stress
    []
[]

[Executioner]
   type = Transient
   solve_type = 'NEWTON'

   automatic_scaling = true
   line_search = 'NONE'

    petsc_options_iname = '-pc_type -pc_factor_shift_type'
    petsc_options_value = 'lu NONZERO'

   start_time = 0
   end_time = 100
   dtmax = 1e5

   nl_rel_tol = 5e-6
   nl_abs_tol = 1e-4
   l_tol = 1e-4

   nl_max_its = 10
   nl_forced_its = 2


  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    optimal_iterations = 4
  []
[]

[Outputs]
    print_linear_residuals = false
    exodus = true
  [csv]
    type = CSV
    file_base = P3_1
  []
[]