[Mesh]
    coord_type = RZ
    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 100
        nx = 150
        xmin = 0.0
        xmax = 0.605  
        ymin = 0.0
        ymax = 1.0    
    []
    
    [subdomain_fuel]
        type = SubdomainBoundingBoxGenerator
        input = base_mesh
        bottom_left = '0.0 0.0 0' 
        top_right = '0.5 1.0 0.0' 
        block_id = 0
    []
    
    [subdomain_gap]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_fuel
        bottom_left = '0.5 0.0 0.0' 
        top_right = '0.505 1.0 0.0' 
        block_id = 1
    []
    
    [subdomain_cladding]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_gap
        bottom_left = '0.505 0.0 0.0' 
        top_right = '0.605 1.0 0.0' 
        block_id = 2
    []
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [diffusion]
        type = HeatConduction
        diffusion_coefficient = thermal_conductivity
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
        prop_values = '0.03'  
        block = 0
    []
    [gap]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.0025564' 
        block = 1
    []
    [cladding]
       type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.17' 
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
    nl_abs_tol = 1e-10
    nl_rel_tol = 1e-10
[]

[Outputs]
    exodus = true
[]