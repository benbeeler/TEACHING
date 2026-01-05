[Mesh]
    [pellet]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 100
        ny = 200
        xmax = 0.5
        ymax = 100
    []
    [pellet_id]
        type = SubdomainIDGenerator
        input = pellet
        subdomain_id = 1
    []
    [gap]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 10
        ny = 200
        xmin = 0.5
        xmax = 0.505
        ymax = 100
    []
    [gap_id]
        type = SubdomainIDGenerator
        input = gap
        subdomain_id = 2
    []
    [clad]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 50
        ny = 200
        xmin = 0.505
        xmax = 0.605
        ymax = 100
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
    rz_coord_axis = Y               # Which axis the symmetry is around 
[]

[Variables]
    [T]
        initial_condition = 500 #(K)
    []
[]

[Kernels]
    [heat_conduction]
        type = HeatConduction
        variable = T
    []
    [heat_source]
        type = HeatSource
        variable = T
        function = '((350*cos(1.2*((y/50)-1))) / (pi*(0.5^2)))' #converting LHR=350 (W/cm) to volumetric heat rate (w/cm3)
        block = 1 
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
        type = FunctionDirichletBC
        variable = T
        boundary = right
        function = '((1/1.2)*((50*350)/(0.25*4200))*(sin(1.2) + sin(1.2*((y/50)-1))))+500' 
    []
[]

[Materials]
    [pellet]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '((100 / (7.5408 + (17.629*(T/1000)) + (3.6142*((T/1000)^2)))) + ((6400 / ((T/1000)^(5/2)))*exp(-16.35 / (T/1000))))/100' #make sure this is in W/cm*K
        block = 1 
    []
    [gap]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '(16*10^(-6))*(T^0.79)' #W/cm*K
        block = 2 
    []
    [clad]
        type = GenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.17 #(W/cm*K)
        block = 3 
    []
[]

#[Postprocessors]
    #[CL_temp_profile]
        #type = PointValue
        #point = '0 0.5 0'
        #variable = T
    #[]
#[]

[VectorPostprocessors]
    [CL_temp_profile]
        type = LineValueSampler
        variable = T
        start_point = '0 0 0'
        end_point = '0 100 0'
        num_points = 100
        sort_by = 'y'
    []
    [fuel_temp_profile]
        type = LineValueSampler
        variable = T
        start_point = '0.5 0 0'
        end_point = '0.5 100 0'
        num_points = 100
        sort_by = 'y'
    []
    [clad_temp_profile]
        type = LineValueSampler
        variable = T
        start_point = '0.505 0 0'
        end_point = '0.505 100 0'
        num_points = 100
        sort_by = 'y'
    []
[]

[Executioner]
    type = Transient
    solve_type = 'PJFNK'
    num_steps = 1
    nl_rel_tol = 1e-10
    nl_abs_tol = 1e-10
    l_tol = 1e-5
    #petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    #petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true # Output Exodus format
    [csv]
        type = CSV
    []
[]

