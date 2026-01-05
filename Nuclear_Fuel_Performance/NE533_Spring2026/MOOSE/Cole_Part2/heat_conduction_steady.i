[Mesh]
    [pellet]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 150
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
        nx = 10
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
        nx = 100
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
    #[gen]
        #type = GeneratedMeshGenerator
        #dim = 2 #2D
        #nx = 1210 #amount of boxes x
        #ny = 100 #amount of boxes y
        #xmax = 0.605 #cm
        #ymax = 1 #cm
    #[]
    #[block1]
        #type = SubdomainBoundingBoxGenerator
        #input = gen
        #block_id = 1
        #block_name = 'pellet'
        #bottom_left = '0 0 0' 
        #top_right = '0.5 1 0' #multiple materials defined at 0.5, fuel and gap defined here
    #[]
    #[block2]
        #type = SubdomainBoundingBoxGenerator
        #input = block1
        #block_id = 2
        #block_name = 'gap'
        #bottom_left = '0.5 0 0'
        #top_right = '0.505 1 0'
    #[]
    #[block3]
        #type = SubdomainBoundingBoxGenerator
        #input = block2
        #block_id = 3
        #block_name = 'clad'
        #bottom_left = '0.505 0 0'
        #top_right = '0.605 1 0'
    #[]
    coord_type = RZ                 # Axisymmetric RZ
    rz_coord_axis = Y               # Which axis the symmetry is around
[]

[Variables]
    [temperature]
        initial_condition = 550 #(K)
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
        #block = 'pellet'
        block = 1
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
        block = 1
    []
    [gap]
        type = ADGenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.00152 #(W/cm*K)
        block = 2
    []
    [clad]
        type = ADGenericConstantMaterial
        prop_names = thermal_conductivity
        prop_values = 0.17 #(W/cm*K)
        block = 3
    []
[]

[Postprocessors]
    [CL_temp_profile]
        type = PointValue
        point = '0 0.5 0'
        variable = temperature
    []
    #[max_temp]
        #type = NodalExtremeValue
        #variable = temperature
    #[]
[]

[VectorPostprocessors]
    [temp_profile]
        type = LineValueSampler
        variable = temperature
        start_point = '0 0.5 0'
        end_point = '0.605 0.5 0'
        num_points = 100
        sort_by = 'x'
    []
[]

[Executioner]
    type = Steady       # Steady state problem
    solve_type = NEWTON # Perform a Newton solve, uses AD to compute Jacobian terms
    petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
    exodus = true # Output Exodus format
    [csv]
        type = CSV
        #file_base = 'heat_conduction_steady_out'
    [] 
[]
