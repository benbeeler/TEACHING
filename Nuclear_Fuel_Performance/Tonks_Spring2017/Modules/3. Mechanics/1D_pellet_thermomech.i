#Thermomechanics
[GlobalParams]
  displacements = 'disp_r'
[]

[Problem]
  coord_type = RZ
[]

[Mesh]
  type = GeneratedMesh
  xmax = 0.5
  nx = 100
  dim = 1
[]

[Variables]
  [./T]
    initial_condition = 300
  [../]
  [./disp_r]
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
    value = 450
    variable = T
  [../]
  [./Tdot]
    type = HeatConductionTimeDerivative
    variable = T
    density_name = 9.65 #g/cm3
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
[]

[Materials]
  [./strain]
    type = ComputeAxisymmetric1DSmallStrain
    eigenstrain_names = th_exp
  [../]
  [./th_exp]
    type = ComputeThermalExpansionEigenstrain
    stress_free_temperature = 273
    temperature = T
    eigenstrain_name = th_exp
    thermal_expansion_coeff = 11.0e-6
  [../]
  [./C]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200
    poissons_ratio = 0.345
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
  [./k_tdep]
    type = DerivativeParsedMaterial
    f_name = thermal_conductivity
    args = 'T'
    function = '1/(7.5408 + 17.692*T/1000 + 3.6142*(T/1000)^2)'
    outputs = exodus
    derivative_order = 1
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    f_name = F
    args = 'T'
    function = 'T^2/2'
  [../]
[]

[BCs]
  [./right]
    type = PresetBC
    value = 685
    variable = T
    boundary = right
  [../]
  [./left]
    type = PresetBC
    value = 0.0
    variable = disp_r
    boundary = left
  [../]
[]

[VectorPostprocessors]
  [./stress_tt]
    type = LineMaterialRankTwoSampler
    property = stress
    index_i = 2
    index_j = 2
    sort_by = x
    start = '0 0 0'
    end = '0.5 0 0'
    execute_on = 'initial TIMESTEP_END'
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
  dt = 0.5
  num_steps = 50
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
  csv = true
[]
