[Mesh]
    [gen]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 1210
        ny = 100
        xmax = 0.605
        ymax = 1
    []
    [block1]
        type = SubdomainBoundingBoxGenerator
        input = gen
        block_id = 1
        block_name = 'pellet'
        bottom_left = '0 0 0'
        top_right = '0.5 1 0'
    []
    [block2]
        type = SubdomainBoundingBoxGenerator
        input = block1
        block_id = 2
        block_name = 'gap'
        bottom_left = '0.5 0 0'
        top_right = '0.505 1 0'
    []
    [block3]
        type = SubdomainBoundingBoxGenerator
        input = block2
        block_id = 3
        block_name = 'clad'
        bottom_left = '0.505 0 0'
        top_right = '0.605 1 0'
    []
    coord_type = RZ                 # Axisymmetric RZ
    rz_coord_axis = Y               # Which axis the symmetry is around
[]

[Variables]
    [temperature]
        initial_condition = 300 #(K)
    []
[]

[Kernels]
    [heat_conduction]
        type = ADHeatConduction
        variable = temperature
    []
    [heat_source]
        type = HeatSource
        variable = temperature
        #value = 445.6 #(W/cm3)
        function = '(350 / (pi*(0.5^2)))' #converting LHR=350 (W/cm) to volumetric heat rate (w/cm3)
        block = 'pellet'
    []
[]

[BCs]
    [left]
        type = NeumannBC
        variable = temperature
        boundary = left
        value = 0 #(K/cm)
    []
    [right]
        type = DirichletBC
        variable = temperature
        boundary = right
        value = 550 #(K)
    []
[]

[Materials]
    [pellet]
        type = ADGenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.03 #(W/cm*K)
        block = 'pellet'
    []
    [gap]
        type = ADGenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.00152 #(W/cm*K)
        block = 'gap'
    []
    [clad]
        type = ADGenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.17 #(W/cm*K)
        block = 'clad'
    []
[]

[Problem]
    type = FEProblem  # This is the "normal" type of Finite Element Problem in MOOSE
[]

[Executioner]
    type = Steady       # Steady state problem
    solve_type = NEWTON # Perform a Newton solve, uses AD to compute Jacobian terms
    petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true # Output Exodus format
[]
