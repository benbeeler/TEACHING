# Steady State k(T) option for 2D RZ mesh with height of 1 cm

[Mesh]
	# Specify the geometry of the problem
	coord_type = RZ
  rz_coord_axis = Y
  [fuel_rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 400
    ny = 1
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

[Materials] # All values from Slide 27 of Lecture 3
	[fuel] # Assume material is UO2, keep enrichment general
		type = HeatConductionMaterial
		block = 1
    temp = temperature
    thermal_conductivity_temperature_function = k_func # Function for k(T)
    specific_heat = 0.33 # J/g-K
  []
  [gap] # Assume gap is only helium
    type = HeatConductionMaterial
		block = 2
    temp = temperature
    thermal_conductivity_temperature_function = gap_func # Function for k(T)
	[]
  [cladding] # assume cladding is Zirconium
    type = HeatConductionMaterial
		block = 3
    thermal_conductivity = 0.17 # W/cm-K
    specific_heat = 0.35 # J/g-K
  []
  [volumetric_heat]
    type = ADGenericConstantMaterial
    prop_names = 'volumetric_heat'
    prop_values = 274.889 # Watts, this is 350 W/cm^2 (LHR)* \pi\*0.5^2 cm (pellet radius)
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
    x = '600 650 700 750 800 850 900 950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500' # Temperatures
    y = '0.07825 0.06444 0.05383 0.04554 0.03894 0.03361 0.02926 0.02567 0.02266 0.02014 0.01799 0.01615 0.01457 0.01320 0.01200 0.01096 0.01003 0.00922 0.00849' # thermal condcutivity in W/cm-K
  []
  [gap_func]
    type = PiecewiseLinear
    x = '600 650 700 750 800 850 900 950 1000 1050 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600 1650 1700 1750 1800' # Temperatures
    y = '0.00251 0.00267 0.00283 0.00299 0.00314 0.00330 0.00345 0.00360 0.00375 0.00390 0.00404 0.00419 0.00433 0.00447 0.00461 0.00475 0.00489 0.00503 0.00517 0.00530 0.00544 0.00557 0.00570 0.00584 0.00597'# thermal condcutivity in W/cm-K
  []
[]

[BCs]
	[surface] # on the right
		type = ADDirichletBC
		variable = temperature
		boundary = 1
		value = 550 # Kelvin
	[]
	[center] # on the left
		type = ADNeumannBC
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
		type = ADMatHeatSource
    #block = 1 # no heat source in gap or cladding (assume radiative heat transfer is negligeable for the time being)
		variable = temperature
    material_property = 'volumetric_heat'
	[]
[]

[Executioner]
	type = Steady
	solve_type = 'PJFNK'
[]

[Outputs]
	exodus = true
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