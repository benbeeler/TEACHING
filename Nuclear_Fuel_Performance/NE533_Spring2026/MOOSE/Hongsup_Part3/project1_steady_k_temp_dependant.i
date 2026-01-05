[Mesh]
    coord_type = RZ
    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 100
        nx = 150
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
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [diffusion]
        type = HeatConduction
        diffusion_coefficient = thermal_conductivity
        diffusion_coefficient_dT = thermal_conductivity_dT
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
    [T_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '1/(3.8+0.0217*T)'
        block = 0
    []
    [dT_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity_dT
        coupled_variables = 'T'
        expression = '-2170000/(217*T+38000)^2'
        block = 0
    []
    [T_gap]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '4.68e-4+3.81e-6*T-6.79e-10*T^2' # [W/cm-K] Chris Newman (2008)
        block = 1
    []
    [dT_gap]
        type = ParsedMaterial
        property_name = thermal_conductivity_dT
        coupled_variables = 'T'
        expression = '3.81e-6-1.358e-9*T' # [W/cm-K] Chris Newman (2008)
        block = 1
    []
    [T_cladding]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '0.1098+1.4e-4*T-7.44e-8*T^2' # [W/cm-K] Chris Newman (2008)
        block = 2
    []
    [dT_cladding]
        type = ParsedMaterial
        property_name = thermal_conductivity_dT
        coupled_variables = 'T'
        expression = '1.4e-4-1.488e-7*T' # [W/cm-K] Chris Newman (2008)
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