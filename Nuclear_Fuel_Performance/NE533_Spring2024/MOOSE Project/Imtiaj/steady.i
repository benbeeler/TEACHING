
[Mesh]
  [gmg]
  type = GeneratedMeshGenerator
  dim = 2
  nx = 50   # Number of divisions in x-direction
  ny = 150   # Number of divisions in y-direction
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
    prop_names = 'thermal_conductivity'
    prop_values = '3.5'
  []

  [clad_material]
    type = GenericConstantMaterial
    block = '2'
    prop_names = 'thermal_conductivity'
    prop_values = '19' 
  []

  [gap_material]
    type = GenericConstantMaterial
    block = '3'
    prop_names = 'thermal_conductivity'
    prop_values = '.1514'
  []
[]
# Define the subdomains
    # Define the variables
[Variables]
      [temp]
        initial_condition = 500
      []
[]

# Define the kernels
    [Kernels]
      [heat_conduction]
        type = HeatConduction
        variable = temp
      []
      [source]
        type = HeatSource
        variable = temp
        value = 445.634
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
  type = Steady
  solve_type = 'PJFNK'
[]

[Outputs]

  exodus = true

[]
