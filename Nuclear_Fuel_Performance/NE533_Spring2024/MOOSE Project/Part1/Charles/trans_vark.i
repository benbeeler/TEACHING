# Transient k(T) option for 2D RZ mesh with height of 1 cm

[Mesh]
	# Specify the geometry of the problem
	coord_type = RZ
  rz_coord_axis = Y
  [fuel_rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    ny = 1
    ymin = 0
    xmin = 0
    ymax = 1 # 0.0025 # Fuel Length(cm)
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

[Materials] # All values from Slide 27 of Lecture 3
	[fuel] # Assume material is UO2, keep enrichment general mess with this to figure it out
		type = HeatConductionMaterial
		block = 1
    temp = temperature
    thermal_conductivity_temperature_function = k_func # Function for k(T)
  []
  [fuel_density]
    type = GenericConstantMaterial
    block = 1
    prop_names = 'density'
    prop_values = '10.98' # g/cm^3
  []
  [gap] # Assume gap is filled with helium and k_gap from slide 22 of lecture 3 applies
    type = HeatConductionMaterial
		block = 2
    temp = temperature
    thermal_conductivity_temperature_function = gap_func # Function for kg(T)
	[]
  [gap_density]
    type = GenericConstantMaterial
    block = 2
    prop_names = 'density'
    prop_values = '0.00178' # g/cm^3
  []
  [cladding] # Assume cladding is Zirconium
    type = GenericConstantMaterial
    block = 3
    prop_names = 'thermal_conductivity density specific_heat thermal_conductivity_dT'
    prop_values = '0.17 6.5 0.35 0' # W/cm-K g/cm^3 J/g-K
  []
[]

[Variables]
	[temperature] # First order lagrange for temperature
		order = FIRST
		family = LAGRANGE 
	[]
[]

[Functions]
  [k_func] # Take equation from Slide 11 of Lecture 3. piecewise function was calculated 
    type = PiecewiseLinear
    x = '600 650 700 750 800 850 900 950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600 1650 1700 1750 1800' # Temperatures
    y = '0.07825 0.06444 0.05383 0.04554 0.03894 0.03361 0.02926 0.02567 0.02266 0.02014 0.01799 0.01615 0.01457 0.01320 0.01200 0.01096 0.01003 0.00922 0.00849 0.00784 0.00726 0.00674 0.00627 0.00585 0.00547' # thermal condcutivity in W/cm-K
  []
  [gap_func]
    type = PiecewiseLinear
    x = '600 650 700 750 800 850 900 950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600 1650 1700 1750 1800' # Temperatures
    y = '0.00251 0.00267 0.00283 0.00299 0.00314 0.00330 0.00345 0.00360 0.00375 0.00390 0.00404 0.00419 0.00433 0.00447 0.00461 0.00475 0.00489 0.00503 0.00517 0.00530 0.00544 0.00557 0.00570 0.00584 0.00597'# thermal condcutivity in W/cm-K
  []
  [heat_func] # Used ParsedFunction as a function of time from prompt
    type = ParsedFunction
    expression = 196.34*exp(-((t-20)^2)/10)+117.8097 # W Function of time LHR*\pi\*R_f^2 (t, in seconds)
  []  
[]

[BCs]
	[surface] # on the right
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
    type = HeatConductionTimeDerivative
    variable = temperature
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
    value = 726
    block = 1
  []
  [gap_ic]
    type = ConstantIC
    variable = temperature
    value = 615
    block = 2
  []
[]

[Executioner]
	type = Transient
  [TimeIntegrator]
    type = ExplicitEuler
  []
  end_time = 100 # Seconds
  dt = 1 # Seconds
	solve_type = 'PJFNK'
  # automatic_scaling = true
  line_search = 'none'
  # nl_rel_tol = 1e-7
  nl_abs_tol = 1e-9
  # nl_forced_its = 2
[]

[Outputs]
	exodus = true
  # print_linear_residuals = true
[]

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