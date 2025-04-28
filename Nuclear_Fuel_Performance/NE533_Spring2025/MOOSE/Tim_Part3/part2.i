T_in = 500 # K
#m_dot_in = 1e-2 # kg/s
#press = 1.5e7 # Pa

# core parameters
fuel_radius = '${units 0.5 cm -> m}'
gap_thickness = '${units 0.005 cm -> m}'
clad_thickness = '${units 0.1 cm -> m}'
rod_dia = '${fparse 2 * (fuel_radius + gap_thickness + clad_thickness)}'
rod_pitch = '${fparse 1.326*rod_dia}' # AP1000 pitch/dia = 1.326 so scaled accordingly
#water_thickness = '${fparse (rod_pitch - rod_dia) / 2}' # minimum water centerline
core_height = 1 # m
core_height_segments = 100 # unitless
LHR = 35000 # W/m or 350 W/cm
volumetric_heat_production_rate = '${fparse LHR / pi / fuel_radius^2}' # W/m3
z_ext = 1.3 # unitless
coolant_avg_vel = '${fparse 1.264 * (2*z_ext*sin(pi/(2*z_ext))/pi)}' # 4.81 # m/s 15.8 f/s
water_density = 769 # kg/m3
water_heat_cap = 3080 # J/kg-K
water_heat_trans_coeff = 30000 # W/m2-K
deltaT = '${fparse volumetric_heat_production_rate*pi*fuel_radius^2*core_height*(2*z_ext*sin(pi/(2*z_ext))/pi) / (coolant_avg_vel * (rod_pitch^2 - pi * (rod_dia/2)^2) * water_density * water_heat_cap)}'
#A_water = '${fparse rod_pitch^2 - 0.25 *pi * rod_dia^2}'
#P_wet_rod = '${fparse 4*rod_pitch + pi * rod_dia}'
#Dh_water = '${fparse 4 * A_water / P_wet_rod}'

[Mesh]
  [fuelMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = ${fuel_radius}
    ymin = 0
    ymax = ${core_height}
    nx = 20
    ny = ${core_height_segments}
  []
  [gapMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = ${fuel_radius}
    xmax = '${fparse fuel_radius + gap_thickness}'
    ymin = 0
    ymax = ${core_height}
    nx = 20
    ny = ${core_height_segments}
  []
  [cladMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = '${fparse fuel_radius + gap_thickness}'
    xmax = '${fparse fuel_radius + gap_thickness + clad_thickness}'
    ymin = 0
    ymax = ${core_height}
    nx = 4
    ny = ${core_height_segments}
  []
  [cmbn]
    type = StitchedMeshGenerator
    inputs = 'fuelMesh gapMesh cladMesh'
    stitch_boundaries_pairs = 'right left; right left'
  []
  [fuelBlock]
    type = SubdomainBoundingBoxGenerator
    input = cmbn
    block_id = 1
    block_name = 'fuel'
    bottom_left = '0 0 0'
    top_right = '${fuel_radius} ${core_height} 0'
  []
  [gapBlock]
    type = SubdomainBoundingBoxGenerator
    input = fuelBlock
    block_id = 2
    block_name = 'gap'
    bottom_left = '${fuel_radius} 0 0'
    top_right = '${fparse fuel_radius + gap_thickness} ${core_height} 0'
  []
  [cladBlock]
    type = SubdomainBoundingBoxGenerator
    input = gapBlock
    block_id = 3
    block_name = 'clad'
    bottom_left = '${fparse fuel_radius + gap_thickness} 0 0'
    top_right = '${fparse fuel_radius + gap_thickness + clad_thickness} ${core_height} 0'
  []
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [T]
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [heat_source]
    type = HeatSource
    variable = T
    value = ${volumetric_heat_production_rate}
    block = 'fuel'
  []
[]

[Materials]
  [fuelMatCond]
    type = ParsedMaterial
    property_name = 'thermal_conductivity'
    coupled_variables = T
    expression = '((100)/(7.5408+17.629*T/1000+3.6142*(T/1000)^2)+(6400)/((T/1000)^(5/2))*exp((-16.45)/(T/1000)))' # W/m-K
    block = 'fuel'
  []
  [fuelDensityCp]
    type = GenericConstantMaterial
    prop_names = 'density specific_heat thermal_conductivity_dT'
    prop_values = '10970 260 0' # kg/m3  J/kgK
    block = 'fuel'
  []
  [gapMaterial]
    type = HeatConductionMaterial
    thermal_conductivity = 0.236 #W/mK
    specific_heat = 5190 # J/kgK
    block = 'gap'
  []
  [gapDensity]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 0.0857 # kg/m3
    block = 'gap'
  []
  [cladMaterial]
    type = HeatConductionMaterial
    thermal_conductivity = 15 # W/mK
    specific_heat = 285 # J/kgK
    block = 'clad'
  []
  [cladDensity]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6560 # kg/m3
    block = 'clad'
  []
[]

[Functions]
  [bc_func]
    type = ParsedFunction
    expression = 'LHR * cos((pi/(2*z_ext))*(2*y/core_height-1)) / ( 2 * pi * fuel_radius * water_heat_trans_coeff) + deltaT*(sin((pi/(2*z_ext))*(2*y/core_height-1))+sin(pi/(2*z_ext)))/(2*sin(pi/(2*z_ext))) + T_in'
    symbol_names = 'LHR z_ext fuel_radius water_heat_trans_coeff deltaT core_height T_in'
    symbol_values = '${LHR} ${z_ext} ${fuel_radius} ${water_heat_trans_coeff} ${deltaT} ${core_height} ${T_in}'
  []
[]

[BCs]
  [wall_temp]
    type = FunctionDirichletBC
    variable = T
    boundary = 'right'
    function = bc_func
  []
[]

[ICs]
  [T]
    type = ConstantIC
    variable = 'T'
    value = '${fparse 500+deltaT}'  # K
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu       NONZERO'
[]

[Outputs]
  exodus = true
[]
