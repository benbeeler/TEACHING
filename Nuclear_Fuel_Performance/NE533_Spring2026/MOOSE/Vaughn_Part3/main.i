
[Mesh]
#Mesh generation generates each block with subdivisions, stitches together with stitched mesh
#generator then uses subdomain generator to rename blocks with 1=fuel 2=gap 3=clad
 [right]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0
  xmax = 0.5
  ymin = 0.0
  ymax = 0.05
  nx = 10
  ny = 15
 []
 [middle]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.5
  xmax = 0.505
  ymin = 0.0
  ymax = 0.05
  nx = 30
  ny = 15
 []
 [left]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.505
  xmax = 0.605
  ymin = 0.0
  ymax = 0.05
  nx = 10
  ny = 15
 []
 [cmbn]
  type = StitchedMeshGenerator
  inputs = 'right middle left'
  show_info = True
  stitch_boundaries_pairs = 'right left;
  right left; right left'
 []
 [fuel] 
   type = SubdomainBoundingBoxGenerator
   input = cmbn
   block_id = 1
   bottom_left = '0.0 0.0 0.0'
   top_right = '0.4927 0.1 0.0'
 []
 [gap]
   type = SubdomainBoundingBoxGenerator
   input = fuel
   block_id = 2
   bottom_left = '0.4927 0.0 0.0'
   top_right = '0.505 0.1 0.0'
 []
 [clad] 
   type = SubdomainBoundingBoxGenerator
   input = gap 
   block_id = 3
   bottom_left = '0.505 0.0 0.0'
   top_right = '0.605 0.1 0.0'
 []
[]
[GlobalParams]
  displacements = 'disp_x disp_y'
  compute_strain = true
[]
#Define variables
[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]

  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]

  [./T]
    order = FIRST
    family = LAGRANGE
  [../]
[]
[Physics/SolidMechanics/QuasiStatic]
  [./fuel]

    generate_output = 'stress_xx stress_yy stress_xy'
    add_variables = true
    block = 1
    strain = FINITE
    eigenstrain_names = 'total_fuel_strains thermal_strain'
    use_automatic_differentiation = true
  [../]
  [./gap]
    add_variables = true
    block = 2
    strain = FINITE
    eigenstrain_names = 'eigenstrain'
    use_automatic_differentiation = true
  [../]
  [./clad]
    add_variables = true
    block = 3
    strain = FINITE
    use_automatic_differentiation = true
    eigenstrain_names = 'eigenstrain'
  [../]
[]
#AuxVariables to track thermal conductivity
[AuxVariables]
  [./fuel_k]
    block = 1
    order = CONSTANT  # Conductivifty is a material property
    family = MONOMIAL
  [../]
  
  [./gap_k]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./clad_k]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./beta_star]
    order = FIRST
    family = LAGRANGE
    stateful = true
  [../]

  [./beta]
    order = FIRST
    family = LAGRANGE
  [../]
  [./q]
    order = FIRST
    family = LAGRANGE
  [../]
  [./densification_factor]
    order = FIRST
    family = LAGRANGE
  [../]
  [./sfp_factor]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gfp_factor]
    order = FIRST
    family = LAGRANGE
  [../]
  [s_xx]
    order = FIRST
    family = MONOMIAL
  []
  [s_yy]
    order = FIRST
    family = MONOMIAL
  []
  [s_xy]
    order = FIRST
    family = MONOMIAL
  []
  [vonmises]
    family = MONOMIAL
    order = FIRST
  []
[]
#Define temperature dependent k functions
[Functions]
    [./q_func]
        type = ParsedFunction
        #expression = '(350)/(0.25*pi)'
        expression = '(350/(0.25*pi)) / (1 + exp(-0.5*(t-15)))'
    [../]

    [./gap_k_func]
        type = ParsedFunction
        expression = "0.0025+0.00002*x"  # Approximate helium gas k(T)
    [../]

    [./clad_k_func]
        type = ParsedFunction
        expression = "0.18-0.00002*x"  # Zircaloy-4 k(T)
    [../]
    [./densification_strain_function]
      type = ParsedFunction
      #expression = '-0.01*if(x>0.005, 1, e^(((x*log(0.01))/(if(y>750, 1, 7.235-0.0086*(y-25))*0.005)-1)))'
      expression = 'x'
    [../]
    [./fuel_k_func]
        type = ParsedFunction
        expression = 'max(0.2, 1.402 - 2.37e-4*max(x, 300) + 1.19e-7*max(x, 300)^2 + 8.37/max(x, 300) - 0.066*pow(max(y / 1.26e-12, 0.52),1e-6))'
    [../]
[]
#Define materials
[Materials]
        [./fuel_k_material]
          type = ADParsedMaterial
          block = 1
          property_name = 'thermal_conductivity'
          coupled_variables = 'T beta'
          expression = '0.01 / (0.037 + 1.2e-4*T + 300.0/T + 0.04*sqrt(beta))'
        [../]
        #[./fuel]
        #        type = ADHeatConductionMaterial
        #        block = 1
        #        temp = 'T'
        #        coupled_variables = 'T beta'
        #        thermal_conductivity = fuel_k
        #        specific_heat = 296.7
        #[../]
        [./fuel_rho]
                type = ADGenericConstantMaterial
                block = 1
                prop_names = 'density specific_heat'
                prop_values = '0.01097 296.7'
        [../]
        [./gap]
                type = ADHeatConductionMaterial
                block = 2 
                temp = T
                thermal_conductivity_temperature_function = gap_k_func
                specific_heat = 5190
        [../]
        [./gap_rho]
                type = ADGenericConstantMaterial
                block = 2
                prop_names = 'density'
                prop_values = 0.000000164
        [../]
        [./clad]
                type = ADHeatConductionMaterial
                block = 3
                temp = T
                thermal_conductivity_temperature_function = clad_k_func
                specific_heat = 2850
        [../]
        [./clad_rho]
                type = ADGenericConstantMaterial
                block = 3
                prop_names = 'density'
                prop_values = 0.00656
        [../]
        [./elastic_tensor_fuel]
          type = ADComputeIsotropicElasticityTensor
          block = 1
          youngs_modulus = 2e10
          poissons_ratio = 0.3
        [../]
        [./thermal_strain_fuel]
          type = ADComputeThermalExpansionEigenstrain
          block = 1
          stress_free_temperature = 550
          thermal_expansion_coeff = 11e-6
          temperature = T
          geometric_linear = true
          eigenstrain_name = 'thermal_strain'
        [../]

        [./fuel_strains]
          type = ADParsedMaterial
          block = 1
          property_name = fuel_strains
          coupled_variables = 'densification_factor gfp_factor sfp_factor'
          expression = 'densification_factor+gfp_factor+sfp_factor'
        [../]

        [volumetric_eigenstrain]
          block = 1
          type = ADComputeVolumetricEigenstrain
          coupled_variables = 'T beta'
          volumetric_materials = fuel_strains
          eigenstrain_name = total_fuel_strains
          execute_on = 'timestep_end'
        []


        [./stress_fuel]
          type = ADComputeFiniteStrainElasticStress
          block = 1
          eigenstrain_names = 'thermal_strain total_fuel_strains'
        [../]
      

        [./elastic_tensor_clad]
          type = ADComputeIsotropicElasticityTensor
          block = 3
          youngs_modulus = 9.6e10
          poissons_ratio = 0.3
          eigenstrain_name = 'eigenstrain'
        [../]
        [./stress_clad]
          type = ADComputeFiniteStrainElasticStress
          block = 3
          eigenstrain_names = 'eigenstrain'
        [../]
        [./thermal_strain_clad]
          type = ADComputeThermalExpansionEigenstrain
          block = 3
          stress_free_temperature = 550
          thermal_expansion_coeff = 6.6e-6
          temperature = T
          eigenstrain_name = 'eigenstrain'
          geometric_linear = true
        [../]

        [./stress_gap]
          type = ADComputeFiniteStrainElasticStress
          block = 2
          eigenstrain_names = 'eigenstrain'
        [../]

        [./elastic_tensor_gap]
          type = ADComputeIsotropicElasticityTensor
          block = 2
          youngs_modulus = 1e2
          poissons_ratio = 0.0
          eigenstrain_name = 'eigenstrain'
        [../]

        [./thermal_strain_gap]
          type = ADComputeThermalExpansionEigenstrain
          block = 2
          stress_free_temperature = 550
          thermal_expansion_coeff = 0.0
          temperature = T
          eigenstrain_name = 'eigenstrain'
          geometric_linear = true
        [../]
[]

#Define Kernels
[Kernels]
        [./heat_conduction]
                type = ADHeatConduction
                prop_names = 'thermal_conductivity'
                variable = T
        [../]
        [./time_derivative]
                type = ADHeatConductionTimeDerivative
                variable = T
        [../]
        [./heat_source]
                type = HeatSource
                variable = T
                block = 1
                function = q_func
        [../]
[]
[AuxKernels]
  [./aux_s_xx]
    type = ADRankTwoAux
    variable = s_xx
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
  [../]
  [./aux_s_yy]
    type = ADRankTwoAux
    variable = s_yy
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
  [../]
  [./aux_s_xy]
    type = ADRankTwoAux
    variable = s_xy
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
  [../]
  [vonmises_aux]
    type = ParsedAux
    variable = vonmises
    coupled_variables = 's_xx s_yy s_xy'
    function = 'sqrt(s_xx^2 - s_xx*s_yy + s_yy^2 + 3*s_xy^2)'
    args = 's_xx s_yy s_xy'
    execute_on = timestep_end
  []
  [./fuel_k_output]
    type = ADMaterialRealAux
    variable = fuel_k
    property = thermal_conductivity
    block = 1
  [../]

  [./gap_k_output]
    type = ADMaterialRealAux
    variable = gap_k
    property = thermal_conductivity
    block = 2
  [../]
  [./update_fuel_k]
    type = ParsedAux
    variable = fuel_k
    block = 1
    coupled_variables = 'beta T'
    expression = '1.402 - (2.37e-4)*T + (1.19e-7)*T^2 + (8.37/T) - 0.066*beta^0.52'
    execute_on = 'timestep_begin timestep_end'
  [../]
  [./update_densification]
    type = ParsedAux
    variable = densification_factor
    block = 1
    coupled_variables = 'beta T'
    expression = 'max(-0.01, -0.01*abs((exp((beta*log(0.01)/(if(T>150, 1, 7.235-0.0086*(T-25))*0.005)))-1)))'
    execute_on = 'timestep_begin timestep_end'

  [../]
  [./update_sfp]
    type = ParsedAux
    variable = sfp_factor
    block = 1
    coupled_variables = 'beta'
    expression = '0.05577*10.97*beta'
    execute_on = 'timestep_begin timestep_end'
  [../]
  [./update_gfp]
    type = ParsedAux
    variable = gfp_factor
    block = 1
    coupled_variables = 'beta T'
    #expression = '1.96*10^(-28)*10.97*beta*(2800-T)^11.73*e^(-0.0162*(2800-T)-17.8*beta*10.97)'
    expression = '(1.96e-28 * 10.97 * beta * pow(max(0, 2800 - T), 11.73) * exp(-0.0162 * max(0, 2800 - T) - 17.8 * beta * 10.97))'

    execute_on = 'timestep_begin timestep_end'
  [../]

  [./clad_k_output]
    type = ADMaterialRealAux
    variable = clad_k
    property = thermal_conductivity
    block = 3 
  [../]
  [./power]
    block = 1
    type = FunctionAux
    variable = q
    function = q_func
    execute_on = 'timestep_begin'
  [../]
  [./burnup_integrator]
    block = 1
    type = VariableTimeIntegrationAux
    variable = beta_star
    variable_to_integrate = q
    execute_on = 'timestep_begin'
  [../]
  [./beta_FIMA]
    block = 1
    type = ParsedAux
    variable = beta
    coupled_variables = 'beta_star'
    #function = "1.137055e-6*beta_star"
    function = "1.26e-12*beta_star"
    execute_on = 'timestep_begin timestep_end'
  [../]
[]
#Define IC to avoid divide by zero in temp function
[ICs]
  [./initial_temperature]
    type = ConstantIC
    variable = T
    value = 550
  [../]
  [./initial_displacement_x]
    type = ConstantIC
    variable = disp_x
    value = 0.0
  [../]
  [./initial_displacement_y]
    type = ConstantIC
    variable = disp_y
    value = 0.0
  [../]
[]

#Define BCs
[BCs]
        [./fixed_temp]
                type = DirichletBC
                variable = T
                boundary = right
                value = 550
        [../]
        [./centerline_flux]
                type = NeumannBC
                variable = T
                boundary = left
                value = 0
        [../]
        [./fix_x]
          type = DirichletBC
          variable = disp_x
          boundary = left
          value = 0.0
        [../]
        [./fix_y]
          type = DirichletBC
          variable = disp_y
          boundary = bottom
          value = 0.0
        [../]
        [./fix_y_top]
          type = DirichletBC
          variable = disp_y
          boundary = top
          value = 0.0
        [../]
        [./fix_x_right]
          type = DirichletBC
          variable = disp_x
          boundary = right
          value = 0.0
        [../]
[]
[Postprocessors]
  [./fuel_outer_disp]
    type = PointValue
    variable = disp_x
    point = '0.5 0.025 0' 
  [../]
  [./clad_inner_disp]
    type = PointValue
    variable = disp_x
    point = '0.505 0.025 0'
  [../]
  #[./burnup_wscm]
  #  block = 1
  #  type = PointValue
  #  variable = beta_star
  #  point = '0.5 0.025 0'
  #[../]
  [./burnup_FIMA]
    block = 1
    type = PointValue
    variable = beta
    point = '0.492 0.025 0'
  [../]
  [./heat]
    block = 1
    type = ElementExtremeValue
    value_type = max
    variable = q
  [../]
  #[./densification]
  #  block = 1
  #  type = ADMaterialTensorAverage
  #  rank_two_tensor = densification_strain
  #  eigenstrain_name = densification_strain
  #  point = '0.5 0.025 0'
  #  index_i = 0
  #  index_j = 0
  #  max_precision = 12
  #[../]
  [./total_strains]
    type = ADElementAverageMaterialProperty
    mat_prop = fuel_strains
    block = 1
  [../]
  [./avg_fuel_temp]
    block = 1
    type = ElementAverageValue
    variable = T
  [../]
  [./densification_coeff]
    block = 1
    type = ElementAverageValue
    variable = densification_factor
  [../]
  [./sfp_coeff]
    block = 1
    type = ElementAverageValue
    variable = sfp_factor
  [../]
  [./gfp_coeff]
    block = 1
    type = ElementAverageValue
    variable = gfp_factor
  [../]
  #[./min_disp_x]
  #  type = ElementExtremeValue
  #  variable = disp_x
  #  value_type = min
  #  block = 1
  #[../]
  [./thermal_coeff]
    type = ADMaterialTensorAverage
    rank_two_tensor = thermal_strain
    block = 1
    index_i = 0
    index_j = 0
  [../]
  [./fuek_k_val]
    type = ADElementAverageMaterialProperty
    mat_prop = thermal_conductivity
    block = 1
  [../]
  [./gap_width]
    type = DifferencePostprocessor
    value1 = 'fuel_outer_disp'
    value2 = 'clad_inner_disp'
  [../]
  [./original_gap]
    type = ConstantPostprocessor
    value = 0.005
  [../]
  [./remaining_gap]
    type = DifferencePostprocessor
    value1 = 'original_gap'
    value2 = 'gap_width'
  [../]
  [./max_dt_step]
    type = ScalePostprocessor
    value = remaining_gap
    scaling_factor = 5000000
  [../]
[]
[UserObjects]
  [./end_on_gap_closure]
    type = Terminator
    expression = 'fuel_outer_disp - clad_inner_disp > 0.00499'
    fail_mode = HARD
    execute_on = TIMESTEP_END
  [../]
[]
#Choose executioner and parameters
[Executioner]
  type = Transient
  #solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  #petsc_options_iname = '-pc_type'
  #petsc_options_value = 'lu'
  #petsc_options_iname = '-pc_type -pc_hypre_type'
  #petsc_options_value = 'hypre boomeramg'
  verbose = true

  solve_type = 'NEWTON'
  [./TimeIntegrator]
    type = ImplicitEuler
    # type = BDF2
    # type = CrankNicolson
    # type = ImplicitMidpoint
    # type = LStableDirk2
    # type = LStableDirk3
    # type = LStableDirk4
    # type = AStableDirk4
    #
    # Explicit methods
    # type = ExplicitEuler
    # type = ExplicitMidpoint
    # type = Heun
    # type = Ralston
  [../]
  num_steps = 100000000
  #dt = 0.1
  [./TimeStepper]
    type = IterationAdaptiveDT
    timestep_limiting_postprocessor = max_dt_step
    optimal_iterations = 5   
    cutback_factor = 0.5       
    growth_factor = 2.0        
    iteration_window = 1
    max_dt = 1      
    min_dt = 0.05
    dt = 0.1
  [../]
  start_time = 0
  end_time = 20e20
  nl_max_its = 50
  nl_abs_tol = 1e-5
  nl_rel_tol = 1e-3
[]
#Outputs
[Outputs]
    #[./exodus]
    #    type = Exodus
    #    time_step_interval = 1    
    #    show = 'T'  
    #[../]
    [./exodus]
        type = Exodus
        output_position = displaced
        show = 'T disp_x disp_y beta densification_coeff sfp_coeff gfp_coeff thermal_coeff s_xx s_yy s_xy vonmises remaining_gap fuel_k'
        execute_on = 'timestep_end'
    [../]
[]

