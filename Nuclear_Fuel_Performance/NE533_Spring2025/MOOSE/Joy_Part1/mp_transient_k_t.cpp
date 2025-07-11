#
# MOOSE PROJECT PART 1 input Transient with Constant K
#

[Mesh]
  coord_type = 'RZ'
  [block]
    type = GeneratedMeshGenerator
    dim = 2
	
    elem_type = QUAD4
    nx = 650  
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
    type = HeatConduction
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
    type = ParsedMaterial
    expression = '((100 / (7.5408 + 17.692*(550/1000) + 3.6142*(550/1000)^2) + (6400 / (550/1000)^(5/2)) * exp(-16.35 / (550/1000)) ) * (1 / (1 - (2.6 - 0.5*(550/1000)) * 0.05)) )* 0.01' # [W/cm·K] (equation from lecture 3, slide 26), (Fink Model Fink, J.K.)
    property_name = thermal_conductivity
	block = 1
  []

  [gap_material]
    type = ParsedMaterial
    expression = '(16*((10)^-6)*((550)^0.79))'  # [W/cm·K] value for He-filled gap (For pure He) # (equation from lecture 3, slide 26)
    property_name = thermal_conductivity
	 block = 2
  []

  [cladding_material]
    type = ParsedMaterial
    expression = '(12.767 + (-0.54348) * (550/1000) + 8.9818 * (550/1000)^2) * 0.01' # (W/cm-K)  (SPACE NUCLEAR PROPULSION MATERIAL PROPERTY HANDBOOK) 
    property_name = thermal_conductivity
	 block = 3
  []
  
  [fuel_density]
    type = ADGenericConstantMaterial
	prop_names = 'density specific_heat'
	prop_values = '10.98 0.33'         
    block = 1
  []
 
  [gap_density]
    type = ADGenericConstantMaterial
	prop_names = 'density specific_heat'
	prop_values = '0.1786e-3 5.1932'
    block = 2
  []
  
  [claddingl_density]
    type = ADGenericConstantMaterial
	prop_names = 'density specific_heat'
	prop_values = '6.5 0.35'          
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
    file_base = mp_transient_k_t_out
    execute_on = 'TIMESTEP_END final'
  []
[]
