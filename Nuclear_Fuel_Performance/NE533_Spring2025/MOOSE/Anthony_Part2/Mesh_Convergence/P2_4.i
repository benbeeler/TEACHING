# ------------------------------------------

# Geometric Parameters (cm)
fuel_thickness = 0.5
gap_thickness = 0.005
clad_thickness = 0.1
rod_z = 100

# LHR Data
LHR0 = 350 # W/cm
Z0 = '${fparse rod_z / 2}' # cm

#Coolant Channel Data
mdot = 250 # g/s
c_H2O = 4.2 # J/g-K
h_H2O = 2.65 #W/cm^2-K
T_cool_in = 500 #K

# Coordinates (cm)
fuel_r = '${fuel_thickness}'
gap_r = '${fparse fuel_r + gap_thickness}'
clad_r = '${fparse gap_r + clad_thickness}'

# ------------------------------------------

[Mesh]
  coord_type = 'RZ'
  rz_coord_axis = Y
  
  [fuel_pellet]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 600
    ny = 100
    xmin = 0
    xmax = '${clad_r}'
    ymin = 0
    ymax = '${rod_z}'
  []
  [fuel]
    type = SubdomainBoundingBoxGenerator
    block_id = 11
    bottom_left = '0 0 0'
    input = 'fuel_pellet'
    top_right = '${fuel_r} ${rod_z} 0'
  []
  [gap]
    type = SubdomainBoundingBoxGenerator
    block_id = 12
    bottom_left = '${fuel_r} 0 0'
    input = 'fuel'
    top_right = '${gap_r} ${rod_z} 0'
  []
  [clad]
    type = SubdomainBoundingBoxGenerator
    block_id = 13
    bottom_left = '${gap_r} 0 0'
    input = 'gap'
    top_right = '${clad_r} ${rod_z} 0'
  []
[]

[Variables]
  [T]
  []
[]

[Kernels]
  [heat]
    type = ADHeatConduction
    variable = T
  []
  [heat_src]
    type = HeatSource
    variable = T
    function = VHR
    block = 11
  []
[]
 
[Functions]
  [VHR]
    type = ParsedFunction
    expression = '(LHR0*cos(1.2*(y/Z0-1)))/(pi*R_f^2)'
    symbol_names = 'LHR0 Z0 R_f'
    symbol_values = '${LHR0} ${Z0} ${fuel_thickness}'
  []
  [T_clad]
    type = ParsedFunction
    expression = '(LHR0*cos(1.2*(y/Z0-1)))/(2*pi*R_f*h_cool)+(((1/1.2)*((Z0*LHR0)/(mdot*c_H2O))*(sin(1.2)+sin(1.2*((y/Z0)-1))))+T_cool_in)'
    symbol_names = 'LHR0 mdot c_H2O Z0 T_cool_in R_f h_cool'
    symbol_values = '${LHR0} ${mdot} ${c_H2O} ${Z0} ${T_cool_in} ${fuel_thickness} ${h_H2O}'
  []
  [fuel_k]
    type = ParsedFunction
    expression = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100' # W/cm-K
  []
  [gap_k]
    type = ParsedFunction
    expression = '16e-6*t^0.79' # W/cm-K
  []
  [clad_k]
    type = ParsedFunction
    expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100' # W/cm-K
  []
[]

[Materials]
  [fuel_therm_prop]
    type = ADHeatConductionMaterial
    temp = T
    min_T = 500
    #thermal_conductivity = 0.03
    thermal_conductivity_temperature_function = fuel_k
    specific_heat = 0.33
    block = 11
  []
  [gap_therm_prop]
    type = ADHeatConductionMaterial
    temp = T
    min_T = 500
    #thermal_conductivity = 0.153e-2
    thermal_conductivity_temperature_function = gap_k
    specific_heat = 5.1932
    block = 12
  []
  [clad_therm_prop]
    type = ADHeatConductionMaterial
    temp = T
    min_T = 500
    #thermal_conductivity = 0.17
    thermal_conductivity_temperature_function = clad_k
    specific_heat = 0.35
    block = 13
  []
  [fuel_dens]
    type = ADGenericConstantMaterial
    block = 11
    prop_names = 'density'
    prop_values = '10.98'
  []
  [gap_dens]
    type = ADGenericConstantMaterial
    block = 12
    prop_names = 'density'
    prop_values = '0.1786e-3'
  []
  [clad_dens]
    type = ADGenericConstantMaterial
    block = 13
    prop_names = 'density'
    prop_values = '6.5'
  []
[]

[BCs]
  [Outer_Clad_Temp]
    type = FunctionDirichletBC
    boundary = 'right'
    variable = T
    function = T_clad
  []
  [Radial_Sym]
    type = ADNeumannBC
    boundary = 'left'
    variable = T
    value = 0
  []
[]

[Preconditioning]
  [fmp]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  []
[]

[Executioner]
  type = Steady
[]

[VectorPostprocessors]
  [fuel_cent_temp]
    type = LineValueSampler
    variable = T
    start_point = '0 0 0'
    end_point = '0 100 0'
    num_points = 2000
    sort_by = 'y'
  []
  [fuel_surf_temp]
    type = LineValueSampler
    variable = T
    start_point = '0.5 0 0'
    end_point = '0.5 100 0'
    num_points = 2000
    sort_by = 'y'
  []
  [clad_in_surf_temp]
    type = LineValueSampler
    variable = T
    start_point = '0.505 0 0'
    end_point = '0.505 100 0'
    num_points = 2000
    sort_by = 'y'
  []
  [clad_out_surf_temp]
    type = LineValueSampler
    variable = T
    start_point = '0.605 0 0'
    end_point = '0.605 100 0'
    num_points = 2000
    sort_by = 'y'
  []
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  [csv]
    type = CSV
    file_base = P2_4
    execute_on = final
  []
[]