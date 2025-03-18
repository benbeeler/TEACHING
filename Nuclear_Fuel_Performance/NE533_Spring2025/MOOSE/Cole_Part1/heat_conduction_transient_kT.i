
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
    [T]
        initial_condition = 300 #(K)
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
        #value = 445.6 #(W/cm3)
        function = '((350*exp(-((t-20)^2)/2)+350)/(pi*(0.5^2)))'
        block = 'pellet'
    []
[]

[BCs]
    [left]
        type = NeumannBC
        variable = T
        boundary = left
        value = 0 #(K/cm)
    []
    [right]
        type = DirichletBC
        variable = T
        boundary = right
        value = 550 #(K)
    []
[]

[Materials]
    [pellet_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '(100 / (7.5408 + (17.629*(T/1000)) + (3.6142*((T/1000)^2)))) + (((6400 / ((T/1000)^(5/2))))*exp(-16.35 / (T/1000)))' #W/cm*K
        #prop_names = 'thermal_conductivity specific_heat density'
        #prop_values = '0.03 0.33 10.98' #(W/cm*K) (J/g*K) (g/cm^3)
        #prop_values = 0.03 #(W/cm*K)
        block = 'pellet'
        #all properties are from Lecture 3 for UO2
    []
    [pellet_prop]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '0.33 10.98' #(J/g*K) (g/cm^3)
        block = 'pellet'
    []
    [gap_prop]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '5.193 0.1785' #(J/g*K) (g/cm^3)
        block = 'gap'
    []
    [gap_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '(16*10^(-6))*(T^0.79)' #W/cm*K
        #prop_names = 'thermal_conductivity specific_heat density'
        #prop_values = '0.00152 5.193 0.1785' #(W/cm*K) (J/g*K) (g/cm^3)
        #prop_values = 0.00152 #(W/cm*K)
        block = 'gap'
        #all properties from periodic-table.org for He
    []
    [clad]
        type = GenericConstantMaterial
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
    dt = 1 #DO NOT MESS WITH THIS
    petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true # Output Exodus format
[]


