[Mesh]
    coord_type = RZ
    [Base]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 50
        ny = 50
        xmin = 0
        xmax = 0.605
        ymin = 0
        ymax = 1
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
[]

[Materials]
    [thermal]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity'
        prop_values = '0.03'  # W/m-K
    []
[]

[ICs]
    [initial]
        type = ConstantIC
        variable = T
        value = 550
    []
[]

[BCs]
    [right]
        type = DirichletBC
        variable = T
        boundary = 'right'
        value = 550 # K
    []
    [left]
        type = FunctionNeumannBC
        variable = T
        boundary = 'left'
        function = LHR
    []
[]

[Functions]
    [./LHR]
        type = ParsedFunction
       expression = 350e4*exp(-((t-20)^2)/2)+350e4
    [../]
[]

[Executioner]
    type = Transient
    solve_type = NEWTON
    #nl_abs_tol = 1e-14
    petsc_options_iname = '-pc_type -sub_pc_factor_levels -ksp_gmres_restart'
    petsc_options_value = 'asm      6                     200'    
    dt = 2
    end_time = 100
[]

[Outputs]
    exodus = true
[]