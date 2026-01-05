#
# MOOSE PROJECT PART 3 - Transient Analysis: Stress, Cracking, Gap Closure
#

#[GlobalParams]
#  displacements = 'disp_r disp_z'
#[]


[Mesh]
  coord_type = 'RZ'
  
  [block]
    type = GeneratedMeshGenerator
    dim = 2
    elem_type = QUAD4
    nx = 660
    ny = 1
    xmin = 0.0
    xmax = 0.00605        # 0.605 cm → 0.00605 m
    ymin = 0.0
    ymax = 0.01           # 1.0 cm → 0.01 m
  []

  [fuel]
    type = SubdomainBoundingBoxGenerator
    input = block
    block_id = 1
    bottom_left = '0 0 0'
    top_right =  '0.005 0.01 0'   # 0.5 cm x 1.0 cm → 0.005 m x 0.01 m
  []

  [gap]
    type = SubdomainBoundingBoxGenerator
    input = fuel
    block_id = 2
    bottom_left = '0.005 0 0'
    top_right =  '0.00505 0.01 0'  # 0.505 cm → 0.00505 m
  []

  [cladding]
    type = SubdomainBoundingBoxGenerator
    input = gap
    block_id = 3
    bottom_left = '0.00505 0 0'
    top_right = '0.00605 0.01 0'   # 0.605 cm → 0.00605 m
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  displacements = 'disp_r disp_z'
  [all]
    strain = SMALL
    incremental = true
    add_variables = true
    use_automatic_differentiation = true
    generate_output = 'vonmises_stress'
	block = '1 3'
	displacements = 'disp_r disp_z'
  []
[]

[Variables]
  [temperature]
    order = FIRST
    family = LAGRANGE
    initial_condition = 550.0
  []
  
  #[burnup]
  #  order = FIRST
  #  family = LAGRANGE
  #  initial_condition = 0.0  # Burnup starts from zero
  #[]
  
  [disp_r]
    order = FIRST
    family = LAGRANGE
	block = '1 3'
  []

  [disp_z]
    order = FIRST
    family = LAGRANGE
	block = '1 3'
  []
[]

[Kernels]
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
  []
  
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = temperature
  []
  
  [heat_source]
    type = HeatSource
    variable = temperature
    function = '(((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6'
    block = 1
  []
  
  # Mechanics
  [disp_r]
    type = ADStressDivergenceRZTensors
    variable = disp_r
	component = 0
	block = '1 3'
	displacements = 'disp_r disp_z'
  []

  [disp_z]
    type = ADStressDivergenceRZTensors
    variable = disp_z
	component = 1
	block = '1 3'
	displacements = 'disp_r disp_z'
  []
  
  #[burnup_time]
  #  type = ADTimeDerivative
  #  variable = burnup
  #  block = 1
  #[]

  #[burnup_source]
  #  type = ADBodyForce
  #  variable = burnup
  #  function = burnup_temp_kth
  #  factor = 1.1e-11
  #  block = 1
  #[]
[]

[Functions]
  [burnup_temp_kth]  #Equation - NFIR model(model is a function of temperature and burnup) from lecture 8 slide 26  (W/m·K)
    type = ParsedFunction
    expression = '(1 - 0.5*(1 + tan((550 - 900)/150))) / ((9.592e-2) + (6.14e-3*((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/3.2*10^11)*t)/(2.447*10^22)) - (1.4e-5*(((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/3.2*10^11)*t)/(2.447*10^22))^2) + ((((2.5e-4 - 1.81e-6*((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/3.2*10^11)*t)/(2.447*10^22))*550)) + (0.5*(1 + tan((550 - 900)/150))) / ((9.592e-2) + (2.6e-3*(((((350) * exp(-((t-20)^2) / 2) + ((350)/(pi* (0.5)^2)))*10e6)/((3.2*10^11))*t)/(2.447*10^22))) + (((2.5e-4 - 2.7e-7*(((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/(3.2*10^11))*t)/(2.447*10^22))*550)) + (1.32e-2*exp(1.88e-3*550))'
  []
  
  [fission_product_swelling] #Equation from lecture 12 slide 22
    type = ParsedFunction
  	 expression = '(5.577*10^-2*10980*((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/3.2*10^11)*t)/(2.447*10^22))+ 1.96*10^-23*10980*(((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/(3.2*10^11))*t)/(2.447*10^22))*((2800-550)^11.73)*exp(-0.0162*(2800-550))*exp(-17.8*10980*(((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/3.2*10^11)*t)/(2.447*10^22)))'
  []
  
  [densification_function] #Equation from lecture 12 slide 20
    type = ParsedFunction
    expression = '0.01*exp((((((((((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2))*10e6)/(3.2*10^11))*t)/(2.447*10^22))*log(0.01))/(1*0.005))-1)'
  []
  
[]

[Materials]
  ### Fuel ###
  [fuel_kth]
    type = ADCoupledValueFunctionMaterial
    function = burnup_temp_kth
    prop_name = thermal_conductivity
    block = 1
  []

  
  [fuel_density]
    type = ADGenericConstantMaterial
	prop_names = 'density specific_heat'
	prop_values = '10980 330'    # density in kg/m^3 and specific heat in J/kg·K    
    block = 1
  []

  [fuel_elastic]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 2e5  #value in Pa from lecture 5 slide 21 
    poissons_ratio = 0.345  #value from lecture 5 slide 21
    block = 1
  []
  
  [stress_fuel]
	type = ADComputeLinearElasticStress
	block = 1
  []

  [fuel_expansion]
    type = ADComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 11e-6  #value in 1/K from lecture 6 slide 13
    temperature = temperature
    stress_free_temperature = 550.0
	eigenstrain_name = thermal_expansion_fuel
    block = 1
  []
  
  [volumetric_eigenstrain_swell]
    type = ComputeVolumetricEigenstrain
    volumetric_materials = fp_swelling
    eigenstrain_name = volumetric_eigenstrain_swell
  	args = ''
    block = 1
  []
  
  [fp_swelling]
    type = GenericFunctionMaterial
    prop_names = 'fp_swelling'
    prop_values = 'fission_product_swelling'
    block = 1
  []
  
  [volumetric_eigenstrain_densification]
    type = ComputeVolumetricEigenstrain
    volumetric_materials = densification
    eigenstrain_name = volumetric_eigenstrain_densification
  	args = ''
    block = 1
  []
  
  [densification]
    type = GenericFunctionMaterial
    prop_names = 'densification'
    prop_values = 'densification_function'
    block = 1
  []

  ### Gap ###
  [gap_conductivity]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.2334 # in W/m·K
    block = 2
  []
  
  [gap_density]
    type = ADGenericConstantMaterial
	prop_names = 'density'
	prop_values = '0.1786' # density in kg/m^3
    block = 2
  []

  ### Cladding ###
  [cladding_conductivity]
    type = ADHeatConductionMaterial
    thermal_conductivity = 17 # in W/m·K
    block = 3
  []
  
  [claddingl_density]
    type = ADGenericConstantMaterial
	prop_names = 'density'
	prop_values = '6500'    # density in kg/m^3      
    block = 3
  []

  [cladding_elastic] 
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = 8e4 #value in Pa from lecture 5 slide 21
    poissons_ratio = 0.41 #value from lecture 5 slide 21
    block = 3
  []
  
  [cladding_expansion]
    type = ADComputeThermalExpansionEigenstrain
    temperature = temperature
    thermal_expansion_coeff = 7.1e-6  #value in 1/K from lecture 6 slide 13 
    stress_free_temperature = 550
    eigenstrain_name = thermal_expansion_clad
    block = 3
  []
  
  [stress_clad]
    type = ADComputeLinearElasticStress
    block = 3
  [] 
[]


[BCs]
  ### Displacement BCs ###
  
  [left_disp_r]
    type = NeumannBC
    variable = disp_r
    boundary = left
    value = 0.0
  []
  
  [right_disp_r]
    type = ADFunctionDirichletBC
    variable = disp_r
    boundary = right
    function = '1e-6 * t'
  []
  
  [top_disp_z]
    type = ADFunctionDirichletBC
    variable = disp_z
    boundary = top
    function = '1e-6 * t'
  []
  
  
  ### Thermal BCs ###
  [left_temperature]
    type = NeumannBC
    variable = temperature
    boundary = left
    value = 0.0  
  []
  
  [outer_temperature]
    type = DirichletBC
    variable = temperature
    boundary = right
    value = 550.0
  []  
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  l_max_its = 50
  start_time = 0.0
  end_time = 100.0  # Simulation up to t=100
  dt = 1.0  # Time step
[]

[VectorPostprocessors]
  [disp_r_fuel_edge]
    type = LineValueSampler
    variable = disp_r
    start_point = '0.005 0.0 0'     
    end_point   = '0.005 0.01 0'
    num_points = 50
    sort_by = x
  []

  [disp_r_clad_edge]
    type = LineValueSampler
    variable = disp_r
    start_point = '0.00505 0.0 0'  
    end_point   = '0.00505 0.01 0'
    num_points = 50
    sort_by = x
  []
  
  [temperature_fuel_outer]
    type = LineValueSampler
    variable = temperature
    start_point = '0.005 0.0 0'
    end_point   = '0.005 0.01 0'
    num_points = 50
    sort_by = x
  []

  [temperature_fuel_center]
    type = LineValueSampler
    variable = temperature
    start_point = '0.0 0.0 0'
    end_point   = '0.0 0.01 0'
    num_points = 50
    sort_by = x
  []
  
    [vonmises_stress_fuel]
    type = LineValueSampler
    variable = vonmises_stress
    start_point = '0.005 0.0 0'
    end_point   = '0.005 0.01 0'
    num_points = 50
    sort_by = x
  []
[]

[Postprocessors]
  [max_disp_r]
    type = NodalExtremeValue
    variable = disp_r
    value_type = max
	block = '1 3'
  []

  [max_disp_z]
    type = NodalExtremeValue
    variable = disp_z
    value_type = max
	block = '1 3'
  []
  
  [max_temperature]
    type = NodalExtremeValue
    variable = temperature
    value_type = max
	block = '1 3'
  []

  [max_von_mises]
    type = ElementExtremeValue
    variable = vonmises_stress
    value_type = max
	block = '1 3'
  []
[]

[Outputs]
  exodus = true

  [csv]
    type = CSV
    file_base = mp3_transient_test2_out
    execute_on = 'initial timestep_end final'
  []
[]