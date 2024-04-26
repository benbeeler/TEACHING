

[GlobalParams]
  displacements = 'disp_x disp_y'
  block = '0 1'
[]

[Problem]
  type = FEProblem

[]

[Mesh]
  
  [rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 125
    ny = 1000
    xmax = 0.500
    ymin = 0
    ymax = 100
    boundary_name_prefix = fuel
  []

  
  [cladding_elements]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 26
    ny = 1000
    xmin = 0.505
    xmax = 0.605
    ymin = 0
    ymax = 100
    boundary_name_prefix = clad
    boundary_id_offset = 4
  []
  [cladding]
    type = SubdomainIDGenerator
    input = cladding_elements
    subdomain_id = 1
  []

  [collect_meshes]
    type = MeshCollectionGenerator
    inputs = 'rod cladding'
  []

  coord_type = RZ
  patch_update_strategy = iteration
[]

[Variables]
  # temperature field variable (first order Lagrange by default)
  [T]
    #initial_condition = 500
  []
  # temperature lagrange multipliers
  [Tlm1]
    block = 'gap_secondary_subdomain'
  []
[]
[Functions]
  [lhr]
      type = ParsedFunction
      expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)  
  []
  [Tcool]
      type = ParsedFunction
      expression = 500+13.8889*(sin(1.2)+sin(1.2*((y/50)-1)))+(L*(pi*(0.5)^2)/(2*pi*0.5*2.65))
      symbol_names = 'L'
      symbol_values = lhr
  []
  
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [source]
    type = HeatSource
    variable = T
    function = lhr
    block = 0
  []
  [dTdt]
    type = HeatConductionTimeDerivative
    variable = T
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = FINITE
    eigenstrain_names = 'thermal swelling'
    generate_output = 'vonmises_stress stress_xx strain_xx stress_yy strain_yy'
    volumetric_locking_correction = true
    temperature = T
  []
[]

[Contact]
  [gap]
    primary = clad_left
    secondary = fuel_right
    model = frictionless
    formulation = mortar
    c_normal = 1e+06
  []

[]

[Constraints]
  # thermal contact constraint
  [Tlm1]
    type = GapConductanceConstraint
    variable = Tlm1
    secondary_variable = T
    use_displaced_mesh = true
    k = 0.002556
    primary_boundary = clad_left
    primary_subdomain = gap_secondary_subdomain
    secondary_boundary = fuel_right
    secondary_subdomain = gap_primary_subdomain
  []
[]

[BCs]
  [center_axis_fix]
    type = DirichletBC
    variable = disp_x
    boundary = 'fuel_left'
    value = 0
  []
  [y_translation_fix]
    type = DirichletBC
    variable = disp_y
    boundary = 'fuel_bottom clad_bottom fuel_top clad_top'
    value = 0
  []
  [heat_center]
    type = NeumannBC
    variable = T
    boundary = 'fuel_left'
    value = 0
  []
  [cool_right]
    type = FunctionDirichletBC
    variable = T
    boundary = 'clad_right'
    function = Tcool
   []

[]

[Materials]
  [elasticityU]
      type = ComputeIsotropicElasticityTensor
      youngs_modulus = 175e5
      poissons_ratio = 0.32
      block = 0
  []
  [elasticityZr]
      type = ComputeIsotropicElasticityTensor
      youngs_modulus = 99e5
      poissons_ratio = 0.37
      block = 1
  []
  [stress]
      type = ComputeFiniteStrainElasticStress
      #block = 2
  []
  [uotwo]
      type = HeatConductionMaterial
      block = 0
      temp = T
      thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
      specific_heat = 0.33
  []

  [zirc]
      type = HeatConductionMaterial
      block = 1
      thermal_conductivity = 0.17
      specific_heat = 0.35
  []
  [uod]
      type = GenericConstantMaterial
      block = 0
      prop_names =  'density'
      prop_values = '10.98' 
  []
  [claddd]
      type = GenericConstantMaterial
      block = 1
      prop_names =  'density'
      prop_values = '6.5' 
  []
  [expansion1]
      type = ComputeThermalExpansionEigenstrain
      temperature = T
      thermal_expansion_coeff = 11e-5
      stress_free_temperature = 0
      eigenstrain_name = thermal
      block = 0
      #boundary = fuel_face
    []
  [expansion2]
      type = ComputeThermalExpansionEigenstrain
      temperature = T
      thermal_expansion_coeff = 7e-5
      stress_free_temperature = 0
      eigenstrain_name = thermal
      block = 1
  []
  [combined_swelling]
      type = ParsedMaterial
      property_name = combined_swelling
      coupled_variables = 'T'
      expression = '5.577e-2*0.059+1.96e-28*0.059*(2800-T)^(11.73)*exp(-0.0162*(2800-T))*exp(-17.8*0.059)'

  []
  [volumetric_eigenstrain]
      type = ComputeVolumetricEigenstrain
      volumetric_materials = combined_swelling
      eigenstrain_name = swelling
      args = ''
      #block = 0
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

# [Debug]
#   show_var_residual_norms = true
# []

[Executioner]
  type = Transient
  solve_type = PJFNK
  line_search = none
  automatic_scaling = true
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       nonzero              '
  snesmf_reuse_base = false
  end_time = 36
  #start_time = 0
  dt = 1
  steady_state_detection = true
  steady_state_tolerance = 1e-4
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10

  # [Predictor]
  #   type = SimplePredictor
  #   scale = 0.5
  # []
[]

[Outputs]
  exodus = true
  #print_linear_residuals = false
  #perf_graph = true
[]
