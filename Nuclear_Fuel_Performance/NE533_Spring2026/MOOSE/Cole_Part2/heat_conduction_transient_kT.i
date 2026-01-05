
[Mesh]
    [pellet]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 50
        ny = 1
        xmax = 0.5
        ymax = 1
        #block_name = 'pellet'
    []
    [pellet_id]
        type = SubdomainIDGenerator
        input = pellet
        subdomain_id = 1
    []
    [gap]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 1
        xmin = 0.5
        xmax = 0.505
        ymax = 1
        #block_name = 'gap'
    []
    [gap_id]
        type = SubdomainIDGenerator
        input = gap
        subdomain_id = 2
    []
    [clad]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 10
        ny = 1
        xmin = 0.505
        xmax = 0.605
        ymax = 1
        #block_name = 'clad'
    []
    [clad_id]
        type = SubdomainIDGenerator
        input = clad
        subdomain_id = 3
    []
    [system]
        type = StitchedMeshGenerator
        inputs = 'pellet_id gap_id clad_id'
        stitch_boundaries_pairs = 'right left; right left'
        prevent_boundary_ids_overlap = false
    []
    coord_type = RZ                 # Axisymmetric RZ
    rz_coord_axis = Y              # Which axis the symmetry is around
[]

[Variables]
    [T]
        initial_condition = 550 #(K)
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
        block = 1 #'pellet'
    []
[]

[BCs]
    [left]
        type = NeumannBC
        variable = T
        boundary = left
        #block = system
        value = 0 #(K/cm)
    []
    [right]
        type = DirichletBC
        variable = T
        boundary = right
        #block = system
        value = 550 #(K)
    []
[]

[Materials]
    [pellet_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '((100 / (7.5408 + (17.629*(T/1000)) + (3.6142*((T/1000)^2)))) + ((6400 / ((T/1000)^(5/2)))*exp(-16.35 / (T/1000))))/100' #make sure this is in W/cm*K
        block = 1 #'pellet'
    []
    [pellet_prop]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '0.33 10.98' #(J/g*K) (g/cm^3)
        #block = 'pellet'
        block = 1
    []
    [gap_prop]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '5.193 0.1785' #(J/g*K) (g/cm^3)
        #block = 'gap'
        block = 2
    []
    [gap_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '(16*10^(-6))*(T^0.79)' #W/cm*K
        block = 2 #'gap'
    []
    [clad]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity specific_heat density'
        prop_values = '0.23 0.35 6.511' #(W/cm*K) (J/g*K) (g/cm^3)
        #prop_values = 0.17 #(W/cm*K)
        block = 3 #'clad'
        #all properties are from Lecture 3 for Zr
    []
[]

[Problem]
    type = FEProblem  # This is the "normal" type of Finite Element Problem in MOOSE
[]

#[Postprocessors]
    #[CL_temp_profile]
        #type = PointValue
        #point = '0 0.5 0'
        #variable = temperature
    #[]
#[]

[Executioner]
    type = Transient      
    solve_type = 'PJFNK'
    start_time = 0.0
    end_time = 100
    dt = 1 
    nl_rel_tol = 1e-10
    nl_abs_tol = 1e-10
    l_tol = 1e-5
    petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg'
    steady_state_detection = true
[]

[Outputs]
    exodus = true # Output Exodus format
[]


