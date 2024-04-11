
[Mesh]
  [gmg]
  type = GeneratedMeshGenerator
  dim = 2
  nx = 300  # Number of divisions in x-direction
  ny = 300  # Number of divisions in y-direction
  xmin = 0.0
  xmax = 0.605  # Total width of the domain (in cm)
  ymin = 0.0
  ymax = 100  # Dimensions of the domain in y-direction (in cm)
  []
  
  # Define the subdomains
  
 [fuelwithgap]
  type = SubdomainBoundingBoxGenerator
  input = gmg
  block_id = 1
  bottom_left = '0 0 0'
  top_right = '0.505 100 0'
 []

 [fuel]
  type = SubdomainBoundingBoxGenerator
  block_id = 2
  bottom_left = '0 0 0'
  top_right = '.5 100 0'
  input = fuelwithgap
 []

 [fboundary]

  type = SideSetsBetweenSubdomainsGenerator
  primary_block = 2
  paired_block = 1
  input = fuel
  new_boundary = '10'

 []

 [cboundary]

  type = SideSetsBetweenSubdomainsGenerator
  primary_block = 0
  paired_block = 1
  input = fboundary
  new_boundary = '11'

 []

 [gap_deleted]
  type = BlockDeletionGenerator
  input = cboundary
  block = 1
 []


coord_type = RZ

[]

[Variables]

  [temp]
     
  []

[]

[Functions]

  [lhr]

    expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)
    type = ParsedFunction

  []

  [Tcool]

    expression = 500+13.89*(sin(1.2)+sin(1.2*((y/50)-1)))
    type = ParsedFunction

  []
    
[]


[ThermalContact]
  [thermal_contact]
    type = GapHeatTransfer
    variable = temp
    primary = '10'
    secondary = '11'
    emissivity_primary = 0
    emissivity_secondary = 0
    gap_conductivity = .001514
    quadrature = true
  []
[]

[Materials]

  [fuel_material]
    type = HeatConductionMaterial
    block = 2
    temp = temp
    thermal_conductivity_temperature_function = '1/(3.8+.0217*t)'
  []

  [clad_material]
    type = HeatConductionMaterial
    block = 0
    thermal_conductivity = .17
  []

[]


# Define the kernels
[Kernels]
    [heat_conduction]
       type = HeatConduction
       variable = temp
       block = '0 2'
    []
    [source]
       type = HeatSource
       variable = temp
       block = 2
       function = lhr
    []

[]

    
 [BCs]
      [left_bc]
        type = NeumannBC
        boundary = 'left'
        value = '0'
        variable = 'temp'
      []

      [right_bc]
        type = FunctionDirichletBC
        boundary = 'right'
        variable = 'temp'
        function = Tcool
      []
[]


[Problem]
  type = FEProblem
[]
  
[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  automatic_scaling = true
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'

[]

[Outputs]

  exodus = true

[]
