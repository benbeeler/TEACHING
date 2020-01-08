[Problem]
  coord_type = RZ
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 0.5
  ymax = 5
  nx = 10
  ny = 50
[]

[Variables]
  [./T]
  [../]
[]

[Kernels]
  [./htcond]
    type = HeatConduction
    variable = T
    diffusion_coefficient = 0.03
  [../]
  [./Q]
    type = HeatSource
    value = 450
    variable = T
  [../]
[]

[BCs]
  [./T_right_bottom]
    type = PresetBC
    value = 685
    variable = T
    boundary = 'right bottom'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

[Outputs]
  exodus = true
[]
