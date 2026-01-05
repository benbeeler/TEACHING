[Mesh]
    coord_type = RZ
    final_generator = merge  

    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 100
        nx = 800
        xmin = 0.0
        xmax = 0.605  # 0.5 + 0.005 + 0.1 [cm]
        ymin = 0.0
        ymax = 1.0    # [cm]
    []
    
    [subdomain_fuel]
        type = SubdomainBoundingBoxGenerator
        input = base_mesh
        bottom_left = '0.0 0.0 0' # [cm]
        top_right = '0.5 1.0 0.0' # [cm]
        block_id = 0
    []
    
    [subdomain_gap]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_fuel
        bottom_left = '0.5 0.0 0.0' # [cm]
        top_right = '0.505 1.0 0.0' # [cm]
        block_id = 1
    []
    
    [subdomain_cladding]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_gap
        bottom_left = '0.505 0.0 0.0' # [cm]
        top_right = '0.605 1.0 0.0' # [cm]
        block_id = 2
    []

    [merge]
        type = CombinerGenerator
        inputs = 'subdomain_fuel subdomain_gap subdomain_cladding'
    []
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [diffusion]
        type = HeatConduction
        variable = T
    []
    [heat_source]
        type = HeatSource
        variable = T
        value = 350
        block = 0
    []
[]

[Materials]
    [fuel]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.03'  # [W/cm-K]
        block = 0
    []
    [gap]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.0025564' # [W/cm-K]
        block = 1
    []
    [cladding]
       type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.17' # [W/cm-K]
        block = 2
    []
[]

[BCs]
    [right]
        type = DirichletBC
        variable = T
        boundary = 'right'
        value = 550 # [K]
    []
[]

[Executioner]
    type = Steady
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    nl_abs_tol = 1e-9
    nl_rel_tol = 1e-7
[]

[Outputs]
    exodus = true
[]