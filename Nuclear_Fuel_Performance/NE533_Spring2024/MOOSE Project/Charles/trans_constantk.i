# Transient constant k option for 2D RZ mesh with height of 1 cm

[Mesh]
	# Specify the geometry of the problem
	coord_type = RZ
  rz_coord_axis = Y
  [fuel_rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    ny = 4
    ymin = 0
    xmin = 0
    ymax = 1 # Fuel Length(cm)
    xmax = 0.605 # Fuel Rod Radius(cm)
  []
  [fuel_block]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    input = fuel_rod
    top_right = '0.5 1 0'
  []
  [gap_block]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '0.5 0 0'
    input = fuel_block
    top_right = '0.505 1 0'
  []
  [clad_block]
    type = SubdomainBoundingBoxGenerator
    block_id = 3
    bottom_left = '0.505 0 0'
    input = gap_block
    top_right = '0.605 1 0'
  []
[]

[Materials] # All values from Slide 27 of Lecture 3 unless noted otherwise
	[fuel] # Assume material is UO2, keep enrichment general
    type = GenericConstantMaterial
    block = 1
    prop_names = 'thermal_conductivity density specific_heat'
    prop_values = '0.03 10.98 0.33' # W/cm-K g/cm^3 J/g-K
  []
  [gap] # Assume gap is filled with helium and k_gap from slide 22 of lecture 3 applies
    type = GenericConstantMaterial
    block = 2
    prop_names = 'thermal_conductivity density specific_heat'
    prop_values = '0.002556 0.00178 5.188' # W/cm-K g/cm^3 J/g-K
	[]
  [cladding] # Assume cladding is Zirconium
    type = GenericConstantMaterial
    block = 3
    prop_names = 'thermal_conductivity density specific_heat'
    prop_values = '0.17 6.5 0.35' # W/cm-K g/cm^3 J/g-K
  []
[]

[Variables]
	[temperature] # First order lagrange for temperature
		order = FIRST
		family = LAGRANGE 
	[]    
[]

[Functions]
  [heat_func] # Used ParsedFunction as a function of time from prompt
    #type = PiecewiseLinear
    #x = '1 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 100'
    #y = '117.8 117.85 118.12 119.26 123.16 133.91 157.44 197.62 249.41 295.45 314.14 295.45 249.41 197.62 157.44 133.91 123.16 119.26 118.12 117.85 117.8 117.8'
    type = ParsedFunction
    expression = 196.34*exp(-((t-20)^2)/10)+117.8097 # W Function of time LHR*\pi\*R_f^2 (t, in seconds)
  []
[]

[BCs]
	[surface] # on the right TRYING NOT AD FOR BOTH
		type = DirichletBC
		variable = temperature
		boundary = 1
		value = 550 # Kelvin
	[]
	[center] # on the left
		type = NeumannBC
		variable = temperature
		boundary = 3
		value = 0 # derivative of temperature at r = 0 is 0
	[]
[]

[ICs]
  [temp_ic_edge]
    type = ConstantIC
    variable = temperature
    value = 550
    block = 3
  []
  [center_ic]
    type = ConstantIC
    variable = temperature
    value = 805
    block = 1
  []
[]

[Kernels]
	[heat_conduction]
		type = HeatConduction
		variable = temperature
	[]
	[heat_source]
		type = HeatSource
		variable = temperature
    function = heat_func
	[]
  [time_derivative_fuel]
    type = SpecificHeatConductionTimeDerivative
    variable = temperature
  []
[]

[Executioner]
	type = Transient
  #[TimeIntegrator]
  #  type = ExplicitEuler
  #[]
  end_time = 100 # Seconds
  dt = 1 # Seconds
	solve_type = 'PJFNK'
  #automatic_scaling = true
  #line_search = 'none'
  nl_rel_tol = 1e-6
[]

[Outputs]
	exodus = true
  print_linear_residuals = true
[]

#[Debug]
#  show_var_residual_norms = true
#[]

[Postprocessors]
  [max]
    type = ElementExtremeValue
    variable = temperature
  []
  [min]
    type = ElementExtremeValue
    variable = temperature
    value_type = min
  []
  [center]
    type = SideExtremeValue
    variable = temperature
    boundary = 3
  []
[]