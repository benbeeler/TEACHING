# Steady State constant k option for 2D RZ mesh with height of 1 cm

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
    thermal_conductivity = 0.03 # W/cm-K
    specific_heat = 0.33 # J/g-K
  []
  [gap] # Assume gap is filled with helium and k_gap from slide 22 of lecture 3 applies
    type = HeatConductionMaterial
		block = 2
    thermal_conductivity = 0.002556 # W/cm-k, calculated by hand using Lecture 3 notes
	[]
  [cladding] # Assume cladding is Zirconium
    type = HeatConductionMaterial
		block = 3
    thermal_conductivity = 0.17 # W/cm-K
    specific_heat = 0.35 # J/g-K
  []
  [volumetric_heat]
    type = ADGenericConstantMaterial
    prop_names = 'volumetric_heat'
    prop_values = 274.889 # Watts, this is 350 W/cm^2 (LHR)* /pi/*0.5^2 cm (pellet radius)
  []
[]

[Variables]
	[temperature] # First order lagrange for temperature
		order = FIRST
		family = LAGRANGE 
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