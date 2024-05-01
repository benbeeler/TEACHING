
[GlobalParams]
  displacements = 'disp_x disp_y'
  block = '0 1'
[]
    



[Mesh]
  [gmg_f]
  type = GeneratedMeshGenerator
  dim = 2
  nx = 100  # Number of divisions in x-direction
  ny = 500 # Number of divisions in y-direction
  xmax = 0.500  # Total width of the domain (in cm)
  ymin = 0.0
  ymax = 100.0  # Dimensions of the domain in y-direction (in cm)
  boundary_name_prefix = fuel
  []
  

  [gmg_c]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100 # Number of divisions in x-direction
    ny = 500 # Number of divisions in y-direction
    xmin = 0.505
    xmax = 0.605  # Total width of the domain (in cm)
    ymin = 0.0
    ymax = 100  # Dimensions of the domain in y-direction (in cm)
    boundary_name_prefix = clad
    boundary_id_offset = 4
  []

  [clad_sd]
    type = SubdomainIDGenerator
    input = gmg_c
    subdomain_id = 1
  []

  [combined_meshes]
    type = MeshCollectionGenerator
    inputs = 'gmg_f clad_sd'
  []

  coord_type = RZ
  patch_update_strategy = iteration

[]




[Materials]

  [fuel_E]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 20000000
    poissons_ratio = .3
    block = 0
  []

  [clad_E]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 10000000
    poissons_ratio = .34
    block = 1
  []

  [stress]
    type = ComputeFiniteStrainElasticStress
  []

  [fuel]
    type = HeatConductionMaterial
    block = 0
    temp = T
    thermal_conductivity_temperature_function = '(1/(3.8+.0217*t))'
    specific_heat = 0.12
  []

  [clad]
    type = HeatConductionMaterial
    block = 1
    thermal_conductivity = 0.190
    specific_heat = 0.27
  []

  [fuel_p]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'density'
    prop_values = '10.97'
  []

  [clad_p]
    type = GenericConstantMaterial
    block = 1
    prop_names = 'density'
    prop_values = '6.3'
  []

  [fuel_TE]
    type = ComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = .0000105
    stress_free_temperature = 0
    eigenstrain_name = thermal
    block = 0
  []

  [clad_TE]
    type = ComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = .000062
    stress_free_temperature = 0
    eigenstrain_name = thermal
    block = 1
    
  []

  [tot_swelling]
    type = ParsedMaterial
    property_name = combined_swelling
    coupled_variables = 'T'
    expression = '5.577e-2*.059+1.96e-28*.059*(2800-T)^(11.73)*exp(-.0162*(2800-T))*exp(-17.8*.059)'
  []

  [vol_strain]
    type = ComputeVolumetricEigenstrain
    volumetric_materials = combined_swelling
    eigenstrain_name = swelling
    args = ''
  []

[]



[Variables]
  [T]
  []

  [T1]
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
    expression = 500+13.8889*(sin(1.2)+sin(1.2*((y/50)-1)))+(l*pi*.5*.5)/(2*pi*.5*2.65)
    symbol_names = 'l'
    symbol_values = lhr

  []
    
[]

# Define the kernels


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


[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        add_variables = true
        strain = FINITE
        eigenstrain_names = 'thermal swelling'
        generate_output = 'vonmises_stress stress_xx strain_xx stress_yy strain_yy'
        volumetric_locking_correction = true
        temperature = T
      []
    []
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
  [T1]
    type = GapConductanceConstraint
    variable = T1
    secondary_variable = T 
    use_displaced_mesh = true
    k = .002556
    primary_boundary = clad_left
    primary_subdomain = gap_secondary_subdomain
    secondary_boundary = fuel_right
    secondary_subdomain = gap_primary_subdomain
   []
[]


[BCs]
  [fixed_centerline]
    type = DirichletBC
    variable = disp_x
    boundary = 'fuel_left'
    value = 0
  []
      
  [y_fix]
      type = DirichletBC
      variable =  disp_y
      boundary = 'fuel_bottom clad_bottom fuel_top clad_top'
      value = 0
  []

  [cld_cool]
    type = FunctionDirichletBC
    variable = T 
    boundary = 'clad_right'
    function = Tcool
  []

  [heatc]
    type = NeumannBC
    variable = T
    boundary = 'fuel_left'
    value = 0
  []

[]

[Preconditioning]
  [pc]
    type = SMP
    full = true
  []
[]


[Problem]
  type = FEProblem
[]



[Executioner]
  type = Transient
  solve_type = PJFNK
  automatic_scaling = true
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu        nonzero             '
  snesmf_reuse_base = false
  end_time = 4
  dt = 1
  steady_state_detection = true
  steady_state_tolerance = 1e-4
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10

[]

[Outputs]

  exodus = true

[]
