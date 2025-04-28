# 1. Global Parameter
[GlobalParams]
    displacements = 'disp_x disp_y'
    stress_free_temperature = 300 # [K]
[]
# 2. Mesh
[Mesh]
    coord_type = RZ
    [base_mesh]
        type = GeneratedMeshGenerator
        dim = 2
        ny = 40
        nx = 110
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
# 3. Variables
[Variables]
    [T]
    []
[]
# 4. Kernel for thermodynamics
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
        value = 350 # LHR
        block = 0
    []
[]
# 5. AuxVaraibles
[AuxVariables]
    [burnup]
    []
    [strain_xx_thermal]
        family = MONOMIAL
    []
    [strain_xx_densification]
        family = MONOMIAL
    []
    [strain_xx_sfp]
        family = MONOMIAL
    []
    [strain_xx_gfp]
        family = MONOMIAL
    []
[]
# 6. AuxKernel
[AuxKernels]
    [burnup]
        type = FunctionAux
        variable = burnup
        function = '(350/(0.7854*3.28451e-11))/((10.48*6.022e+23)/270.03)'
        execute_on = timestep_end
        block = 0
    []
    [strain_xx_thermal]
        type = RankTwoAux
        variable = strain_xx_thermal
        rank_two_tensor = thermal_eigenstrain
        index_j = 0
        index_i = 0
        execute_on = timestep_end
        block=0
    []
    [strain_xx_densification]
        type = RankTwoAux
        variable = strain_xx_densification
        rank_two_tensor = densification_eigenstrain
        index_j = 0
        index_i = 0
        execute_on = timestep_end
        block=0
    []
    [strain_xx_sfp]
        type = RankTwoAux
        variable = strain_xx_sfp
        rank_two_tensor = sfp_eigenstrain
        index_j = 0
        index_i = 0
        execute_on = timestep_end
        block=0
    []
    [strain_xx_gfp]
        type = RankTwoAux
        variable = strain_xx_gfp
        rank_two_tensor = gfp_eigenstrain
        index_j = 0
        index_i = 0
        execute_on = timestep_end
        block=0
    []
[]

# 7. Kernel for solid mechanics
[Physics/SolidMechanics/QuasiStatic]
    add_variables = true
    incremental = true
    [fuel_swelling]
        strain = SMALL
        temperature = T
        eigenstrain_names = 'thermal_eigenstrain densification_eigenstrain sfp_eigenstrain gfp_eigenstrain'
        generate_output = 'stress_xx stress_xy stress_yy stress_zz HOOP_STRESS RADIAL_STRESS VONMISES_STRESS strain_xx strain_yy strain_zz'
        block = 0
    []
    [gap_swelling]
        strain = SMALL
        temperature = T
        eigenstrain_names = thermal_eigenstrain
        generate_output = 'stress_xx stress_xy stress_yy stress_zz HOOP_STRESS RADIAL_STRESS VONMISES_STRESS strain_xx strain_yy strain_zz'
        block = 1
    []
    [cladding_swelling]
        strain = SMALL
        temperature = T
        eigenstrain_names = thermal_eigenstrain
        generate_output = 'stress_xx stress_xy stress_yy stress_zz HOOP_STRESS RADIAL_STRESS VONMISES_STRESS strain_xx strain_yy strain_zz'
        block = 2
    []
[]
# 8. Material block for thermodynamics
[Materials]
    [T_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = 'T burnup'
        expression = '1/(3.8+200*burnup+0.0217*T)'
        block = 0
    []
    [dT_fuel]
        type = ParsedMaterial
        property_name = thermal_conductivity_dT
        coupled_variables = 'T burnup'
        expression = '-2170000/(217*T+2000000*burnup+38000)^2'
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
# 9. Material block for swelling
[Materials]
    [elastic_tensor_fuel]
        type = ComputeIsotropicElasticityTensor
        poissons_ratio = 0.345 
        youngs_modulus = 2.0e+7
        block = 0 
    []
    [elastic_stress_fuel]
        type = ComputeFiniteStrainElasticStress
        block = 0
    []
    [elastic_tensor_gap]
        type = ComputeIsotropicElasticityTensor
        poissons_ratio = 0
        youngs_modulus = 1e-20
        block = 1 
    []
    [elastic_stress_gap]
        type = ComputeFiniteStrainElasticStress
        block = 1
    []
    [elastic_tensor_cladding]
        type = ComputeIsotropicElasticityTensor
        poissons_ratio = 0.41
        youngs_modulus = 8.0e6
        block = 2 
    []
    [elastic_stress_cladding]
        type = ComputeFiniteStrainElasticStress
        block = 2
    []
    [thermal_expansion_strain_fuel]
        type = ComputeThermalExpansionEigenstrain
        thermal_expansion_coeff = 12e-6 
        temperature = T
        eigenstrain_name = thermal_eigenstrain
        block = 0
    []
    [thermal_expansion_strain_gap]
        type = ComputeThermalExpansionEigenstrain
        thermal_expansion_coeff = 0
        temperature = T
        eigenstrain_name = thermal_eigenstrain
        block = 1
    []
    [thermal_expansion_strain_cladding]
        type = ComputeThermalExpansionEigenstrain
        thermal_expansion_coeff = 7e-6
        temperature = T
        eigenstrain_name = thermal_eigenstrain
        block = 2
    []
    [prefactor_densification]
        type = ParsedMaterial
        coupled_variables = 'T burnup'
        property_name = prefactor_densification
        constant_names = 'rho0 burnupD'
        constant_expressions = '0.01 0.005'
        expression = 'rho0*(exp(burnup*(-4.6052)/(if(T>=1023.15, 1.0, 7.235-0.0086*(T-298.15))*burnupD))-1)'
        block = 0
    []
    [eigen_strain_densification]
        type = ComputeVariableEigenstrain
        eigen_base = '1'
        args = ''
        prefactor = prefactor_densification 
        eigenstrain_name = densification_eigenstrain
        block = 0
    []
    [prefactor_sfp]
        type = ParsedMaterial
        coupled_variables = 'burnup'
        property_name = prefactor_sfp
        constant_names = 'rho'
        constant_expressions = '10.98'
        expression = '5.577e-2*rho*burnup'
        block = 0
    []
    [eigen_strain_sfp]
        type = ComputeVariableEigenstrain
        eigen_base = '1'
        args = ''
        prefactor = prefactor_sfp
        eigenstrain_name = sfp_eigenstrain
        block = 0
    []
    [prefactor_gfp]
        type = ParsedMaterial
        coupled_variables = 'T burnup'
        property_name = prefactor_gfp
        constant_names = 'rho'
        constant_expressions = '10.98'
        expression = '1.96e-28*rho*burnup*((2800-T)^(11.73))*exp(-0.0162*(2800-T))*exp(-17.8*rho*burnup)'
        block = 0
    []
    [eigen_strain_gfp]
        type = ComputeVariableEigenstrain
        eigen_base = '1'
        args = ''
        prefactor = prefactor_gfp
        eigenstrain_name = gfp_eigenstrain
        block = 0
    []
[]

# 10. Boundary conditions
[BCs]
    [disp_centerline_x]
        type = DirichletBC
        variable = disp_x
        boundary = left
        value = 0
    []

    [disp_right_x]
        type = DirichletBC
        variable = disp_x
        boundary = right
        value = 0
    []

    [disp_top_y]
        type = DirichletBC
        variable = disp_y
        boundary = top
        value = 0
    []

    [disp_bottom_y]
        type = DirichletBC
        variable = disp_y
        boundary = bottom
        value = 0
    []
    
    [right]
        type = ConvectiveFluxFunction
        variable = T
        boundary = right
        T_infinity = 500 # [K]
        coefficient = 1.2 
    []
[]
# 11. Initial conditions
[ICs]
    [initial]
        type = ConstantIC
        variable = T
        value = 500
    []
[]
# 12. Solver
[Executioner]
    type = Transient
    solve_type = NEWTON
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'lu'
    start_time = 0.0
    end_time = 100
    nl_abs_tol = 1e-8
    nl_rel_tol = 1e-8
    dt = 0.05
    steady_state_detection = true
[]

[Outputs]
    exodus = true
[]