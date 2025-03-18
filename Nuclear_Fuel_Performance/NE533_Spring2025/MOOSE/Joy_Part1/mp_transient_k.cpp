# MOOSE PROJECT PART 1 input
#

[Mesh]
  coord_type = 'RZ'
  [block]
    type = GeneratedMeshGenerator
    dim = 2
	
    elem_type = QUAD4
    nx = 660  
    ny = 1 
    xmax = 0.605  # Total radius
    ymin = 0.0
    ymax = 1   # Height
  []
  [fuel]
    type = SubdomainBoundingBoxGenerator
    input = block
    block_id = 1
    bottom_left = '0 0 0'
    top_right =  '0.5 1 0'
  []
  [gap]
    type = SubdomainBoundingBoxGenerator
    input = fuel
    block_id = 2
    bottom_left = '0.5 0 0'
    top_right =  '0.505 1 0'
  []

  [cladding]
    type = SubdomainBoundingBoxGenerator
    input = gap
    block_id = 3
    bottom_left = '0.505 0 0'
    top_right = '0.605 1 0'
  []
[]

[Variables]
  [temperature]
    order = FIRST
    family = LAGRANGE
	initial_condition = 550.0
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
    function = '((350) * exp(-((t-20)^2) / 2) + (350))/(pi* (0.5)^2)'
	block = 1
  []
[]

[Materials]
  [fuel_material]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.03   # [W/cm·K] (value from table in lecture 3, slide 31)
	specific_heat = 0.33          # [J/g.K] (value from table in lecture 3, slide 31)
    block = 1
  []

  [gap_material]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.00234 # [W/cm·K] value for He-filled gap (For pure He, kgap=16x10^-6 * T^0.79 (W/cm-K))(equation from lecture 3, slide 26) 
	specific_heat = 5.1932         # [J/g.K]  
    block = 2
  []

  [cladding_material]
    type = ADHeatConductionMaterial
    thermal_conductivity = 0.17  # [W/cm·K] (value from table in lecture 3, slide 31)
	specific_heat = 0.35         # [J/g.K] (value from table in lecture 3, slide 31)
    block = 3
  []
  
  [fuel_density]
    type = ADGenericConstantMaterial
	prop_names = 'density'
	prop_values = 10.98          # [g/cm^3] (value from table in lecture 3, slide 31)
    block = 1
  []
 
  [gap_density]
    type = ADGenericConstantMaterial
	prop_names = 'density'
	prop_values = 0.1786e-3      # [g/cm^3]
    block = 2
  []
  
  [claddingl_density]
    type = ADGenericConstantMaterial
	prop_names = 'density'
	prop_values = 6.5            # [g/cm^3] (value from table in lecture 3, slide 31)
    block = 3
 []
[]

[BCs]
  [left_temperature]
    type = NeumannBC
    variable = temperature
    value = 0.0  # No heat flux at centerline
	boundary = 'left'
  []

  [outer_temperature]
    type = DirichletBC
    variable = temperature
    value = 550.0
	boundary = 'right'
  []
[]

[Executioner]
  type = Transient   # Transient
  solve_type = NEWTON
  nl_abs_tol = 1e-8
  l_max_its = 50
  start_time = 0.0
  end_time = 100.0  # Simulation up to t=100
  dt = 1.0  # Time step
  #print_frequency = 1
[]

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = temperature
    start_point = '0 1 0'
    end_point = '0.605 1 0'
    num_points = 20
    sort_by = x
  []
[]

[Postprocessors]
  [max_temperature]
    type = PointValue
    variable = temperature
	point = '0 0.5 0'
  []
[]

[Outputs]
  exodus = true
  [csv]
    type = CSV
    file_base = mp_transient_k_out
    execute_on = 'TIMESTEP_END final'
  []
[]
