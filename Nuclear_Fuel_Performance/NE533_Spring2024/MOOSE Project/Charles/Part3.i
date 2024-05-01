# Steady State variable k option for 2D RZ mesh with height of 100 cm
# Part 3, axially dependent coolant temperature and LHR
# On-paper work was conducted to calculate the cladding outer temperature function
# Coolant inlet temperature as boundary condition

[GlobalParams]
  displacements = 'disp_x disp_y'
  block = '1 3'
[]

[Mesh]
	# Specify the geometry of the problem
	coord_type = RZ
  rz_coord_axis = Y
  [fuel_rod]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 242 # 121
    ny = 1000 
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
  # LOWER PART IS NEW
  #[combine]
  #  type = MeshCollectionGenerator
  #  inputs = 'fuel_block clad_block'
  #[]
  # Add a set of nodes to remove rigid body modes to y-translation for the two blocks
  [pin]
    type = ExtraNodesetGenerator
    input = remove
    new_boundary = pin
    coord = '0 0 0; 0.555 0 0'
  []
[]

[Materials] # All values from Slide 27 of Lecture 3
	[fuel_TC] # Assume material is UO2, keep enrichment general
    type = HeatConductionMaterial
		block = 1
    temp = temperature
    thermal_conductivity_temperature_function = k_func # Function for k(T)
    specific_heat = 0.33 # J/g-K
  []
  #[fuel_SH]
  #  type = HeatConductionMaterial
  #	 block = 1
  #  temp = temperature
  #  specific_heat = 0.33 # J/g-K
  #[]
  [cladding_TC] # Assume cladding is Zirconium
    type = HeatConductionMaterial
    block = 3
    thermal_conductivity = 0.17 # W/cm-K
    specific_heat = 0.35 # J/g-K
  []
  #[clad_SH]
  #  type = HeatConductionMaterial
  #  block = 3
  #  specific_heat = 0.35 # J/g-K
  #[]
  [fuel_density]
    type = Density
    density = 10.98 # g/cm^3
    block = 1
  []
  [clad_density]
    type = Density
    density = 6.5 # g/cm^3
    block = 3
  []
  [eigen_strain_fuel] # thermal expansion coefficient from lecture 3 slide 27
    type = ComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal
    temperature = temperature
    thermal_expansion_coeff = 0.000012 # 1/K
    stress_free_temperature = 300 # Kelvin
    block = 1
  []
  [eigen_strain_clad] # thermal expansion coefficient from lecture 3 slide 27
    type = ComputeThermalExpansionEigenstrain
    eigenstrain_name = thermal
    temperature = temperature
    thermal_expansion_coeff = 0.000010 # 1/K
    stress_free_temperature = 300 # Kelvin
    block = 3
  []
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200.0E9 # in Pa, need to check units
    poissons_ratio = 0.345
  []
[]

[ThermalContact] # Do I need to replace with Contact or just add Contact Block?
  [fuel_gap] # Assume gap is filled with helium and k_gap from slide 22 of lecture 3 applies
    type = GapHeatTransfer
    variable = temperature
    gap_geometry_type = 'CYLINDER'
    gap_conductivity_function = gap_func
    # gap_conductivity = 0.002556 #  W/cm^2-K, calculated by hand using Lecture 3 notes
    primary = fuel_surface
    secondary = clad_surface
    quadrature = true
    emissivity_primary = 0.0 # instead of 0.4
    emissivity_secondary = 0.0
  []
[]

[Contact]
  [gap]
    primary = fuel_surface
    secondary = clad_surface
    model = frictionless
    formulation = mortar
  []
[]

# The below is causing problems. I don't know why. 
[Modules/TensorMechanics/Master]
  [all] # all stresses developed
    add_variables = true
    strain = FINITE
    eigenstrain_names = thermal
    generate_output = 'vonmises_stress'
    volumetric_locking_correction = true
    temperature = temperature
  []
[]

#[Physics]
#  [SolidMechanics]
#    [QuasiStatic]
#      [all]
#        add_variables = true
#        strain = FINITE
##        eigenstrain_names = thermal
#        automatic_eigenstrain_names = true
#        generate_output = 'vonmises_stress'
#      []
#    []
#  []
#[]

[Variables]
	[temperature] # First order lagrange for temperature
    order = FIRST
    family = LAGRANGE 
	[]
#  [Tlm]
#    # block = 3 # maybe cladding?
#    order = FIRST
#    family = LAGRANGE
#  []
[]

# Do I need the constraints block? I need it if I include Tlm following Tutorial Example

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
 # displacement BCs(fixed point)
  [center_axis_fix]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [y_translation_fix]
    type = DirichletBC
    variable = disp_y
    boundary = pin
    value = 0
  []
[]

[ICs]
  [temp_IC]
    type = ConstantIC
    variable = temperature
    boundary = left
    value = 1200 # Reasonable Guess(maybe)
  []
  [outer_IC]
    type = FunctionIC
    variable = temperature
    boundary = right
    function = T_in
  []
[]

[Functions]
  [heat_func] # Used ParsedFunction as a function of height
    # Equation taken from Lecture 3
    type = ParsedFunction
    expression = 445.6338*cos(1.2*((y/50)-1)) # LHR*\pi\*R_f^2 (t, in seconds)
  []
  [T_in] # Cladding Outer Temperature as a function of "standard" coolant dist. and constant h_cool
    type = ParsedFunction
    # Let m_dot = 0.25 kg/s. c_p = 4200 J/kg-K, taken from Lecture Notes
    # z_0 = 50 cm, T_in = 226.85 C, LHR_0 = 350
    # Equation taken from Lecture 3
    expression = 226.85+(13.88)*(sin(1.2)+sin(1.2*((y/50)-1)))+(42.0409)*cos(1.2*((y/50)-1))
  []
  [k_func] # Take equation from Slide 11 of Lecture 3. Piecewise function was calculated 
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
	type = Transient
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