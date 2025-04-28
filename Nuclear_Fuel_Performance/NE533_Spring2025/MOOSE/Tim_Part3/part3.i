# Densification Lecture 10 slide 19
# FP swelling Lecture 12 Slide 22 and 23

fuel_radius = '${units 0.5 cm -> m}'
gap_thickness = '${units 0.005 cm -> m}'
clad_thickness = '${units 0.1 cm -> m}'
core_height = '${units 1 cm -> m}'
core_height_segments = 1 # unitless

LHR = 35000 # W/m or 350 W/cm
volumetric_heat_production_rate = '${fparse LHR / pi / fuel_radius^2}' # W/m3

B = '${fparse 5/950}' # FIMA, picked 0.1 for 0 to converge since fills gap immediately
deltaP = 0.01 # max densification

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

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
    nx = 1
    ny = ${core_height_segments}
  []
  [cladMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = '${fparse fuel_radius + gap_thickness}'
    xmax = '${fparse fuel_radius + gap_thickness + clad_thickness/2}'
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
    top_right = '${fparse fuel_radius + gap_thickness + clad_thickness/2} ${core_height} 0'
  []
  coord_type = RZ
  rz_coord_axis = Y
[]

[Variables]
  [T]
  []
[]

[AuxVariables]
  [c]
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
#  [time_derivative]
#    type = HeatConductionTimeDerivative
#    variable = T
#  []
  [heat_source]
    type = HeatSource
    variable = T
    value = ${volumetric_heat_production_rate}
    block = 'fuel'
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    eigenstrain_names = 'thermal_expansion fp_and_densification'
    generate_output = 'vonmises_stress'
  []
[]

[BCs]
  [wall_temp]
    type = DirichletBC
    variable = T
    value = '582'
    boundary = 'right'
  []
  [left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [right_x]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0
  []
  [top_y]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  []
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [Pressure]
    [rightpull]
      boundary = right
      function = -1e7*t
    []
  []
[]

[ICs]
#  [T]
#    type = ConstantIC
#    variable = 'T'
#    value = 500  # K
#  []
  [testIC]
    type = BoundingBoxIC
    variable = T
    x1 = 0
    x2 = 0.005
    y1 = 0
    y2 = 0.01
    inside = 1000
    outside = 575
  []
[]

[Materials]
  [fuelMatCond] # From Lecture 8 slide 26-27
    type = ParsedMaterial
    property_name = 'thermal_conductivity'
    coupled_variables = T
    constant_names = 'B'
    constant_expressions = '${fparse B*950}'
#    expression = '((100)/(7.5408+17.629*T/1000+3.6142*(T/1000)^2)+(6400)/((T/1000)^(5/2))*exp((-16.45)/(T/1000)))' # W/m-K
    expression = '(1-(0.5*(1+tanh((T-1173.15)/(150)))))*((1)/( (9.592e-2)+(6.14e-3)*B-(1.4e-5)*(B^2)+((2.5e-4)-(1.81e-6)*B)*(T-273.15) ))+(0.5*(1+tanh((T-1173.15)/(150))))*((1)/( (9.592e-2)+(2.6e-3)*B+((2.5e-4)-(2.7e-7)*B)*(T-273.15) ))+(1.32e-2)*exp((1.88e-3)*(T-273.15))'
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

  [elasticityFuel] # From Lecture 5 slide 21
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 2e11
    poissons_ratio = 0.345
    block = 'fuel'
  []
  [elasticityGap] # Made small since compressible, but want solver to work
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e-10
    poissons_ratio = 0.3
    block = 'gap'
  []
  [elasticityClad] # From Lecture 5 slide 21
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 8e10
    poissons_ratio = 0.41
    block = 'clad'
  []
  [themExpansionFuel] # From Lecture 6 slide 13
    type = ComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = 1.1e-5
    stress_free_temperature = 300
    eigenstrain_name = thermal_expansion
    block = 'fuel'
  []
  [themExpansionGap] # I picked small value since this applies pressure, but not expansion
    type = ComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = 1e-10
    stress_free_temperature = 300
    eigenstrain_name = thermal_expansion
    block = 'gap'
  []
  [themExpansionClad] # From Lecture 6 slide 13
    type = ComputeThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = 7.1e-6
    stress_free_temperature = 300
    eigenstrain_name = thermal_expansion
    block = 'clad'
  []
  [fuelPrefactor]
    type = ParsedMaterial
    coupled_variables = T
    property_name = fuelPrefactor
    constant_names = 'deltaP B'
    constant_expressions = '${fparse deltaP} ${fparse B}'
    expression = 'deltaP*(exp((B*log(0.01))/(5/950*max(1,7.235-0.0086*(T-298.15))))-1)+(5.577e-2)*10.97*B+(1.96e-28)*10.97*B*(2800-T)^(11.73)*exp(-0.0162*(2800-T))*exp(-17.8*10.97*B)'
    block = 'fuel'
  []
  [otherFuelEigenstrains]
    type = ComputeVariableEigenstrain
    eigen_base = '1'
    args = c
    prefactor = fuelPrefactor
    eigenstrain_name = fp_and_densification
    block = 'fuel'
  []
  [otherPrefactor]
    type = ParsedMaterial
    coupled_variables = c
    property_name = otherPrefactor
    expression = '0'
    block = 'clad gap'
  []
  [otherCladGapEigenstrains]
    type = ComputeVariableEigenstrain
    eigen_base = '1'
    args = c
    prefactor = otherPrefactor
    eigenstrain_name = fp_and_densification
    block = 'clad gap'
  []

  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Executioner] # I tried getting this to run with burnup as t, but it couldnt get it to work
  type = Steady
#  type = Transient
#  solve_type = NEWTON
#  petsc_options_iname = '-pc_type'
#  petsc_options_value = 'lu'
#  dtmin = 1e-13
#  timestep_tolerance = 1e-10
#  end_time = 1
#  dt = 1
[]

[Outputs]
  exodus = true
[]