[Mesh]
    coord_type = RZ
    final_generator = merge  

    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 100
        nx = 400
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
    [time_der]
        type = TimeDerivative
        variable = T
    []
    [heat_source]
        type = HeatSource
        variable = T
        function = LHR
        block = 0
    []
[]

[Functions]
    [./LHR]
        type = ParsedFunction
       expression = 350*exp(-((t-20)^2)/2)+350
    [../]
[]

[Materials]
    [fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '0.01/(0.041+2.81e-4*T+9.88e-9*T^2)' # [W/cm-K]
        block = 0
    []
    [gap]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '2.28e-3 + 7.058e-7 * T' # [W/cm-K]
        block = 1
    []
    [cladding]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '0.1098+1.4e-4*T-7.44e-8*T^2' # [W/cm-K]
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

[ICs]
    [initial]
        type = ConstantIC
        variable = T
        value = 550
    []
[]

[Executioner]
    type = Transient
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    start_time = 0.0
    end_time = 100
    nl_abs_tol = 1e-9
    nl_rel_tol = 1e-7
    dt = 2
    steady_state_detection = true
[]

[Outputs]
    exodus = true
[]