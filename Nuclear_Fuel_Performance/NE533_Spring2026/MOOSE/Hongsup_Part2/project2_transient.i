[Mesh]
    coord_type = RZ
    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 250
        nx = 300
        xmin = 0.0
        xmax = 0.605  
        ymin = 0.0
        ymax = 100.0    
    []
    
    [subdomain_fuel]
        type = SubdomainBoundingBoxGenerator
        input = base_mesh
        bottom_left = '0.0 0.0 0' 
        top_right = '0.5 100.0 0.0' 
        block_id = 0
    []
    
    [subdomain_gap]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_fuel
        bottom_left = '0.5 0.0 0.0' 
        top_right = '0.505 100.0 0.0' 
        block_id = 1
    []
    
    [subdomain_cladding]
        type = SubdomainBoundingBoxGenerator
        input = subdomain_gap
        bottom_left = '0.505 0.0 0.0' 
        top_right = '0.605 100.0 0.0' 
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

[Materials]
    [T_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T'
        expression = '1/(158/T+0.019*T)' # [W/cm-K] Fink & Petri (1997)
        block = 0
    []
    [dT_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity_dT
        coupled_variables = 'T'
        expression = '(158/T^2-0.019)/(158/T+0.019*T)^2' # [W/cm-K] Fink & Petri (1997)
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
        type = ConvectiveFluxFunction
        variable = T
        boundary = 'right'
        T_infinity = axialTcool # [K]
        coefficient = 1.2 
    []
[]

[ICs]
    [initial]
        type = FunctionIC
        variable = T
        function = axialTcool
    []
[]

[Functions]
    [LHR]
        type = ParsedFunction
        expression = 350*(sin(3.141592*(y+10)/120))
    []
    [axialTcool]
        type = ParsedFunction
        expression = 500-2.1322*(cos((3.141592*y+31.41592)/120)-0.96593)
    []
[]

[Executioner]
    type = Transient
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    start_time = 0.0
    end_time = 100
    nl_abs_tol = 1e-8
    nl_rel_tol = 1e-9
    dt = 0.5
    steady_state_detection = true
[]

[Outputs]
    exodus = true
[]