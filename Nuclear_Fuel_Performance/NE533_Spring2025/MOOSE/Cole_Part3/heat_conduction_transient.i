[Mesh]
    [gen]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 121
        ny = 1
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
    rz_coord_axis = Y              # Which axis the symmetry is around
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
    [time_derivative]
        type = ADHeatConductionTimeDerivative
        variable = temperature
    []
    [heat_source]
        type = HeatSource
        variable = temperature
        #value = 445.6 #(W/cm3)
        function = '((350*exp(-((t-20)^2)/2)+350)/(pi*(0.5^2)))'
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
        prop_names = 'thermal_conductivity specific_heat density'
        prop_values = '0.03 0.33 10.98' #(W/cm*K) (J/g*K) (g/cm^3)
        #prop_values = 0.03 #(W/cm*K)
        block = 'pellet'
        #all properties are from Lecture 3 for UO2
    []
    [gap]
        type = ADGenericConstantMaterial
        prop_names = 'thermal_conductivity specific_heat density'
        prop_values = '0.00152 5.193 0.1785' #(W/cm*K) (J/g*K) (g/cm^3) [use 5.193 next time]
        #prop_values = 0.00152 #(W/cm*K)
        block = 'gap'
        #all properties from periodic-table.org for He
    []
    [clad]
        type = ADGenericConstantMaterial
        prop_names = 'thermal_conductivity specific_heat density'
        prop_values = '0.23 0.35 6.511' #(W/cm*K) (J/g*K) (g/cm^3)
        #prop_values = 0.17 #(W/cm*K)
        block = 'clad'
        #all properties are from Lecture 3 for Zr
    []
[]

[Problem]
    type = FEProblem  # This is the "normal" type of Finite Element Problem in MOOSE
[]

[Executioner]
    type = Transient      
    solve_type = NEWTON
    start_time = 0.0
    end_time = 100
    #num_steps = 100
    dt = 5 #DO NOT MESS WITH THIS
    petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true # Output Exodus format
[]

