
[Mesh]
  [gmg]
  type = GeneratedMeshGenerator
  dim = 2
  nx = 150   # Number of divisions in x-direction
  ny = 50  # Number of divisions in y-direction
  xmin = 0.0
  xmax = 0.605  # Total width of the domain (in cm)
  ymin = 0.0
  ymax = 1.0  # Dimensions of the domain in y-direction (in cm)
  []
  
  # Define the subdomains
  
[S1]
  type = SubdomainBoundingBoxGenerator
  input = 'gmg'
  block_id = 1
  bottom_left = '0 0 0'
  top_right = '0.5 1 0'
  []

[S2]
  type = SubdomainBoundingBoxGenerator
  block_id = 2
  bottom_left = '0.5 0 0'
  top_right = '.505 1 0'
  input = 'S1'
  []

[S3]

  block_id = 3
  type = SubdomainBoundingBoxGenerator
  bottom_left = '.505 0 0'
  top_right = '.605 1 0'
  input = 'S2'

[]

[]

[Materials]
  [fuel_material]
    type = GenericConstantMaterial
    block = '1'
    prop_names = 'specific_heat thermal_conductivity density'
    prop_values = '.12 .035 10.97'
  []

  [clad_material]
    type = GenericConstantMaterial
    block = '2'
    prop_names = 'specific_heat thermal_conductivity density'
    prop_values = '.27 .19 6.52'
  []

  [gap_material]
    type = GenericConstantMaterial
    block = '3'
    prop_names = 'specific_heat thermal_conductivity density'
    prop_values = '5.191 .001514 0.0001785'
  []
[]
# Define the subdomains
    # Define the variables
      [Variables]
      [temp]
        initial_condition = 0
      []
[]
[Functions]
  [heatequation]
    type = ParsedFunction
    expression = (250*exp(-((t-20)^2)/10)+150)/(3.14159*(.5)^2)
  []
[]


# Define the kernels
    [Kernels]
      [heat_conduction]
        type = HeatConduction
        variable = temp
        block = '1 2 3'
      []
      [source]
        type = HeatSource
        variable = temp
        function = heatequation
        block = '1'
      []
      [time]
        type = SpecificHeatConductionTimeDerivative
        variable = temp
        block = '1 2 3'
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
        type = DirichletBC
        boundary = 'right'
        variable = 'temp'
        value = '550'
      []
[]

[Problem]
  type = FEProblem
[]
  
[Executioner]
  type = Transient
  start_time = 0
  end_time = 100
  dt = 1
  solve_type = 'NEWTON'
[]

[Outputs]

  exodus = true

[]
