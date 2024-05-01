 #ref:https://mooseframework.inl.gov/modules/combined/tutorials/introduction/step01.html
 #ref2:https://mooseframework.inl.gov/syntax/Physics/SolidMechanics/QuasiStatic/index.html
 
 [Mesh] 
  [fuelrod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    xmin = 0
    xmax = 0.500
    ny = 500
    ymin = 0
    ymax = 100
	boundary_name_prefix = fuel
  []
  [clad_dom]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    xmin = 0.505
    xmax = 0.605
    ny = 500
    ymin = 0
    ymax = 100
	boundary_name_prefix = clad
	boundary_id_offset = 4
  []
  [clad]
	type = SubdomainIDGenerator
	input = clad_dom
	subdomain_id = 1
  []
  [mesh_merging]
	type = MeshCollectionGenerator
	inputs = 'fuelrod clad'
  []
  
  coord_type = RZ
  patch_update_strategy = iteration
  
 []
 
 [Functions]
  #[LHR]
     #type = ParsedFunction
     #expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)
  #[]
  [coolant_temp]
	 type = ParsedFunction
	 expression = (500+14.4676*(sin(1.2)+sin(1.2*((y/50)-1)))) 
  []
 []
 
 [Variables]
  #[temp] #using T instead of temp to eradicate difficulties in the temp dependent equation
   
   
  #[]
   
   [T]
  
  
   []
  [temp_lm]
	block = 'gap_secondary_subdomain'
  []
 []
 
 [Constraints]
  [t_lm]
	type = GapConductanceConstraint
	variable = temp_lm
	secondary_variable = T
	use_displaced_mesh = true
	k = .0026 #W/cm-K
	primary_boundary = clad_left
	secondary_boundary = fuel_right
	primary_subdomain = gap_secondary_subdomain
	secondary_subdomain = gap_primary_subdomain
  []
 []
 
 [Kernels]
  [heat_source]
    type = HeatSource
    value = 445.6
    variable = T
    block = '0'
  []
  [conduction]
    type = HeatConduction
    variable = T
  []
  [timederivative_temp]
    type = HeatConductionTimeDerivative
    variable = T
  []
 []

[Materials]
  [fuelMat]
    type = HeatConductionMaterial
	temp = T
	block = '0'
    thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
	specific_heat = 0.28
  []
  #[gapMat]
    #type = HeatConductionMaterial
    #thermal_conductivity = .0026 #W/cm-K
    #block = '1'
  #[]
  [cladMat]
    type = HeatConductionMaterial
    thermal_conductivity = .1700 #W/cm-K
	specific_heat = 0.35
    block = '1'
  []
  [tensor_fuel]
    type = ComputeIsotropicElasticityTensor
	youngs_modulus = 180e5
	poissons_ratio = 0.35
	block = '0'
  []
  [tensor_clad]
	type = ComputeIsotropicElasticityTensor
	youngs_modulus = 94e5
	poissons_ratio = 0.4
	block = '1'
  []
  [stress]
	type = ComputeFiniteStrainElasticStress
  []
  [fuel_density]
    type = GenericConstantMaterial
	block = 0
	prop_names = 'density'
	prop_values = '10.98'
  []
  [clad_density]
    type = GenericConstantMaterial
	block = 1
	prop_names = 'density'
	prop_values = '0.5'
  []
  [expansion_fuel]
	type = ComputeThermalExpansionEigenstrain
	temperature = T
	thermal_expansion_coeff = 11e-5
	stress_free_temperature = 0
	eigenstrain_name = thermal
	block = 0
  []
  [expansion_clad]
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
  []
[]

[Problem]
  type = FEProblem
[]

[Physics]
 [SolidMechanics]
  [QuasiStatic]
   [all]
	add_variables = true
	temperature = T
	#strain = SMALL
	strain = FINITE
	eigenstrain_names = 'thermal swelling'
	generate_output = 'vonmises_stress stress_xx strain_xx stress_yy strain_yy'
	volumetric_locking_correction = true
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

#[ThermalContact]
 #[gap_contact]
#type = GapHeatTransfer
#emissivity_primary = 0
#emissivity_secondary = 0
#variable = T
#primary = 'fuel_with_gap'
#secondary = 'clad_with_gap'
#gap_conductivity = 0.0026
#quadrature = true
 #[]
#[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  block = '0 1'
[]	

[BCs]
  [inlet_temp]
    type = NeumannBC
    variable = T
    boundary = 'fuel_left'
    value = 0 
  []
  [outlet_temp]
    type = FunctionDirichletBC
    variable = T
    boundary = 'clad_right'
    function = coolant_temp
  []
  [left_x]
    type = DirichletBC
	variable = disp_x
	boundary = 'fuel_left'
	value = 0
  []
  [y_fix]
	type = DirichletBC
	variable = disp_y
	boundary = 'fuel_bottom clad_bottom fuel_top clad_top'
	value = 0
  []
[]

#[VectorPostprocessors]
 #[t_sampler]
  # type = LineValueSampler
   #variable = T
   #start_point = '0 51 0'
   #end_point = '0.605 51 0'
   #num_points = 20
   #sort_by = x
 #[]
#[]

[Preconditioning]
 [smp]
  type = SMP
  full = true
 []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  line_search = none
  automatic_scaling = true
  #we deal with the saddle point structure of the system by adding a small shift
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       nonzero'
  snesmf_reuse_base = false
  end_time = 30
  dt = 1
  steady_state_detection = true
  steady_state_tolerance = 1e-4
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
[]