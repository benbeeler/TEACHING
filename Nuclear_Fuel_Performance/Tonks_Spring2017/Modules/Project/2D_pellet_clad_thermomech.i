#Thermomechanics
[GlobalParams]
  displacements = 'disp_x disp_y'
  order = SECOND
  family = LAGRANGE
[]

[Problem]
  coord_type = RZ
[]

[Mesh]
  type = FileMesh
  file = coarse10_rz.e
  second_order = true
[]

[Variables]
  [./T]
    initial_condition = 500
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[AuxVariables]
  [./stress_tt]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_rr]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_zz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_rz]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[Kernels]
  [./htcond]
    type = CahnHilliard
    variable = T
    f_name = F
    mob_name = thermal_conductivity
  [../]
  [./Q]
    type = HeatSource
    function = 'if(t<1e4,450.0e6*t/1e4,450.0e6)'
    variable = T
    block = 3
  [../]
  [./Tdot]
    type = HeatConductionTimeDerivative
    variable = T
    density_name = 9.65e6 #g/cm3
    specific_heat = 0.325 #J/(g K)
  [../]

  [./TensorMechanics]
  [../]
[]

[AuxKernels]
  [./stress_rr]
    type = RankTwoAux
    variable = stress_rr
    index_i = 0
    index_j = 0
    rank_two_tensor = 'stress'
  [../]
  [./stress_tt]
    type = RankTwoAux
    variable = stress_tt
    index_i = 2
    index_j = 2
    rank_two_tensor = 'stress'
  [../]
  [./stress_zz]
    type = RankTwoAux
    variable = stress_zz
    index_i = 1
    index_j = 1
    rank_two_tensor = 'stress'
  [../]
  [./stress_rz]
    type = RankTwoAux
    variable = stress_rz
    index_i = 0
    index_j = 1
    rank_two_tensor = 'stress'
  [../]
[]

[Materials]
  [./strain]
    type = ComputeAxisymmetricRZSmallStrain
    eigenstrain_names = th_exp
  [../]
  [./th_exp_fuel]
    type = ComputeThermalExpansionEigenstrain
    stress_free_temperature = 273
    temperature = T
    eigenstrain_name = th_exp
    thermal_expansion_coeff = 11.0e-6
    block = 3
  [../]
  [./th_exp_clad]
    type = ComputeThermalExpansionEigenstrain
    stress_free_temperature = 273
    temperature = T
    eigenstrain_name = th_exp
    thermal_expansion_coeff = 7.1e-6
    block = 1
  [../]
  [./C_fuel]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200
    poissons_ratio = 0.345
    block = 3
  [../]
  [./C_gap]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 80.0
    poissons_ratio = 0.41
    block = 1
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
  [./k_tdep]
    type = DerivativeParsedMaterial
    f_name = thermal_conductivity
    args = 'T'
    function = '100/(7.5408 + 17.692*T/1000 + 3.6142*(T/1000)^2)'
    outputs = exodus
    derivative_order = 1
    block = 3
  [../]
  [./k_clad]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity dthermal_conductivity/dT'
    prop_values = '17.0 0.0'
    block = 1
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    f_name = F
    args = 'T'
    function = 'T^2/2'
  [../]
[]

[BCs]
# Define boundary conditions
  [./no_x_all] # pin pellets and clad along axis of symmetry (y)
    type = DirichletBC
    variable = disp_x
    boundary = 12
    value = 0.0
  [../]
  [./no_y_clad_bottom] # pin clad bottom in the axial direction (y)
    type = DirichletBC
    variable = disp_y
    boundary = '1'
    value = 0.0
  [../]
  [./no_y_fuel_bottom] # pin fuel bottom in the axial direction (y)
    type = DirichletBC
    variable = disp_y
    boundary = '1020'
    value = 0.0
  [../]
  [./T_CO]
    type = PresetBC
    boundary = 2
    value = 500
    variable = T
  [../]
[]

[Contact]
  [./mech_contact]
    disp_x = disp_x
    disp_y = disp_y
    master = 5
    slave = 10
    system = Constraint
    formulation = kinematic
    model = frictionless
    penalty = 1e5
  [../]
[]


[ThermalContact]
  # Define thermal contact between the fuel (sideset=10) and the clad (sideset=5)
  [./thermal_contact]
    type = GapHeatTransfer
    variable = T
    master = 5
    slave = 10
    gap_conductivity = 0.25 #Some Xe
    quadrature = true

  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  dt = 2e2
  end_time = 2e4
  solve_type = 'PJFNK'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu superlu_dist'
  l_tol = 1e-4
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-9
  l_max_its = 50
  nl_max_its = 30
[]

[Outputs]
  exodus = true
  csv = true
[]
