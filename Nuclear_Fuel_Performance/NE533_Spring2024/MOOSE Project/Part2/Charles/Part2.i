# Steady State constant k option for 2D RZ mesh with height of 100 cm
# Part 2 of the project, axially dependent coolant temperature and LHR
# On-paper work was conducted to calculate the cladding outer temperature function

[Mesh]
	# Specify the geometry of the problem
	coord_type = RZ
  rz_coord_axis = Y
  [fuel_rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 242 # 121
    ny = 1000 # 
    ymin = 0
    xmin = 0
    ymax = 100 # Fuel Length(cm)
    xmax = 0.605 # Fuel Rod Radius(cm)
  []
  [fuel_block]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    input = fuel_rod
    top_right = '0.5 100 0'
  []
  [gap_block]
   type = SubdomainBoundingBoxGenerator
   block_id = 2
   bottom_left = '0.5 0 0'
   input = fuel_block
   top_right = '0.505 100 0'
  []
  [clad_block]
    type = SubdomainBoundingBoxGenerator
    block_id = 3
    bottom_left = '0.505 0 0'
    input = gap_block
    top_right = '0.605 100 0'
  []
  [fuel_surface_set] # primary 1, paired 2
    type = SideSetsBetweenSubdomainsGenerator
    input = clad_block
    primary_block = 1
    paired_block = 2
    new_boundary = 'fuel_surface'
  []
  [clad_surface_set] # primary 3, paired 2
    type = SideSetsBetweenSubdomainsGenerator
    input = fuel_surface_set
    primary_block = 3
    paired_block = 2
    new_boundary = 'clad_surface'
  []
  [remove]
    type = BlockDeletionGenerator
    input = clad_surface_set # fuel_block
    block = 2
  []
[]

[Materials] # All values from Slide 27 of Lecture 3
	[fuel] # Assume material is UO2, keep enrichment general
		type = HeatConductionMaterial
		block = 1
    thermal_conductivity = 0.03 # W/cm-K
    # specific_heat = 0.33 # J/g-K
  []
  [cladding] # Assume cladding is Zirconium
    type = HeatConductionMaterial
		block = 3
    thermal_conductivity = 0.17 # W/cm-K
    # specific_heat = 0.35 # J/g-K
  []
[]

[ThermalContact]
  [fuel_gap] # Assume gap is filled with helium and k_gap from slide 22 of lecture 3 applies
    type = GapHeatTransfer
    variable = temperature
    gap_geometry_type = 'CYLINDER'
    gap_conductivity = 0.002556 #  W/cm^2-K, calculated by hand using Lecture 3 notes
    primary = clad_surface
    secondary = fuel_surface
    quadrature = true
  []
[]
  
[Variables]
	[temperature] # First order lagrange for temperature
		order = FIRST
		family = LAGRANGE 
	[]
[]

[BCs]
	[surface] # on the right(3)
		type = FunctionDirichletBC
		variable = temperature
		boundary = right
		function = T_in
	[]
	[center] # on the left(1)
		type = NeumannBC
		variable = temperature
		boundary = left
		value = 0 # derivative of temperature at r = 0 is 0
	[]
[]

[ICs]
  [temp_IC]
    type = ConstantIC
    variable = temperature
    boundary = left
    value = 1200 # just a guess, should be aight I think
  []
  [outer_IC]
    type = FunctionIC
    variable = temperature
    boundary = right
    function = T_in
  []
[]

[Functions]
  [heat_func] # Used ParsedFunction as a function of height from Lecture Notes
    # Equation taken from Lecture 3
    type = ParsedFunction
    expression = 445.6338*cos(1.2*((y/50)-1)) # LHR*\pi\*R_f^2 (t, in seconds)
  []
  [T_in] # Cladding outer temperature
    type = ParsedFunction
    # Let m_dot = 0.25 kg/s. c_p = 4200 J/kg-K, taken from Lecture Notes
    # z_0 = 50 cm, T_in = 226.85 C, LHR_0 = 350
    # Equation taken from Lecture 3
    expression = 226.85+(13.88)*(sin(1.2)+sin(1.2*((y/50)-1)))+(42.0409)*cos(1.2*((y/50)-1))
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
[]