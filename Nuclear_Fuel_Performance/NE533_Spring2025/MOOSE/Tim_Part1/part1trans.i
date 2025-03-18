#[global]
#  radiusFuel = 0.5 # cm
#  thicknessGap = 0.005 # cm
#  thicknessClad = 0.01 # cm
#  height = 1 # cm
#  kFuel = 
#  kGap = 
#  kClad = 
#  ssLHR = 350 # W/cm2
#  transientLHR = '350*exp(-((t-20)^2)/2)+350' # W/cm2
#  transientRunTime = 100 # s
#[]

[Mesh]
  [fuelMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 0.5
    ymin = 0
    ymax = 1
    nx = 20
    ny = 1
  []
  [gapMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0.5
    xmax = 0.505
    ymin = 0
    ymax = 1
    nx = 2
    ny = 1
  []
  [cladMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0.505
    xmax = 0.515
    ymin = 0
    ymax = 1
    nx = 20
    ny = 1
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
    top_right = '0.5 1 0'
  []
  [gapBlock]
    type = SubdomainBoundingBoxGenerator
    input = fuelBlock
    block_id = 2
    block_name = 'gap'
    bottom_left = '0.5 0 0'
    top_right = '0.505 1 0'
  []
  [cladBlock]
    type = SubdomainBoundingBoxGenerator
    input = gapBlock
    block_id = 3
    block_name = 'clad'
    bottom_left = '0.505 0 0'
    top_right = '0.515 1 0'
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
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T
  []
  [heat_source]
    type = HeatSource
    variable = T
    function =  '445.63384*exp(-1*((t-20)^2)/2)+445.63384'
    block = 'fuel'
  []
[]

[Materials]
  [fuelMaterial]
    type = HeatConductionMaterial
    thermal_conductivity = 0.03
    specific_heat = 0.26 # J/gK
    block = 'fuel'
  []
  [fuelDensity]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 10.97 # g/cm3
    block = 'fuel'
  []
  [gapMaterial]
    type = HeatConductionMaterial
    thermal_conductivity = 0.00236
    specific_heat = 5.19 # J/gK
    block = 'gap'
  []
  [gapDensity]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 0.0000857 # g/cm3
    block = 'gap'
  []
  [cladMaterial]
    type = HeatConductionMaterial
    thermal_conductivity = 0.15
    specific_heat = 0.285 # J/gK
    block = 'clad'
  []
  [cladDensity]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6.56 # g/cm3
    block = 'clad'
  []
[]

[BCs]
  [t_right]
    type = DirichletBC
    variable = T
    value = '550'
    boundary = 'right'
  []
[]

[ICs]
  [T]
    type = ConstantIC
    variable = 'T'
    value = 700  # K
  []
[]

[Executioner]
  type = Transient
  end_time = 55
  dt = 0.1
[]

[Outputs]
  exodus = true
[]
