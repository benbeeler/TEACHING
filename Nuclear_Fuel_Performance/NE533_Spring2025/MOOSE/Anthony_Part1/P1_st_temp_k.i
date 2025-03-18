# Geometric Parameters (cm)
fuel_thickness = 0.5
gap_thickness = 0.005
clad_thickness = 0.1
rod_z = 1

# Coordinates (cm)
fuel_r = '${fuel_thickness}'
gap_r = '${fparse fuel_r + gap_thickness}'
clad_r = '${fparse gap_r + clad_thickness}'

[Mesh]
  coord_type = 'RZ'
  [fuel_pellet]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 600
    ny = 8
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
    initial_condition = 550
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
    expression = '350/(pi*${fuel_thickness}^2)'
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
    type = ADDirichletBC
    boundary = 'right'
    value = 550
    variable = T
  []
  [Radial_Sym]
    type = ADNeumannBC
    boundary = 'left'
    value = 0
    variable = T
  []
  [Axial_Sym]
    type = ADNeumannBC
    boundary = 'top bottom'
    value = 0
    variable = T
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
  time = 100
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  
  nl_rel_tol = 5e-6
  nl_abs_tol = 5e-8

  l_tol = 1e-4
  l_max_its = 100
[]

[VectorPostprocessors]
  [temperature_profile]
    type = LineValueSampler
    variable = T
    start_point = '0 0.5 0'
    end_point = '0.605 0.5 0'
    num_points = 1000
    sort_by = 'x'
  []
[]

[Outputs]
  print_linear_residuals = true
  exodus = true
  [csv]
    type = CSV
    file_base = P1_temp_k
    execute_on = final
  []
[]