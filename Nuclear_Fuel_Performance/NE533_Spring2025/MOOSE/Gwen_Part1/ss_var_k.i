[Mesh]
        coord_type = 'RZ'
        [gmg]
                type = GeneratedMeshGenerator
                dim = 2
                nx = 400
                ny = 4
                xmin = 0
                ymin = 0
                xmax = 0.605  # Fuel,Gap,Cladding
                ymax = 1 #TotalHeight
        []
        [fuel]
                type = SubdomainBoundingBoxGenerator
                block_id = 1
                bottom_left = '0 0 0'
                top_right = '0.5 1 0'
                input = 'gmg'
        []
        [gap]
                type = SubdomainBoundingBoxGenerator
                block_id = 2
                bottom_left = '0.5 0 0'
                top_right = '0.505 1 0'
                input = 'fuel'
        []
        [cladding]
                type = SubdomainBoundingBoxGenerator
                block_id = 3
                bottom_left = '0.505 0 0'
                top_right = '0.605 1 0'
                input = 'gap'    
        []
[]


[Variables]
        [T]
                order = FIRST
                initial_condition = 550
        []
[]

[Functions]
        [VHR]
                type = ParsedFunction
                expression = '350/(pi*(0.5^2))'
        []
        [fuel_k]
                type = ParsedFunction
                expression = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100'
        []
        [gap_k]
                type = ParsedFunction
                expression = '16e-6*(t^0.79)'
        []
        [cladding_k]
                type = ParsedFunction
                expression = '(8.8527+7.0820e-3*t+2.5329e-6*t^2+2.9918e3*(1/t))/100'
        []
[] 

[Kernels]
        [heat_con]
                type = ADHeatConduction
                variable = T
        []
        [heat_source]
                type = HeatSource
                variable = T
                function = VHR
                block = 1 #fuel block
        []
[]


[Materials]
        [fuel_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = fuel_k
                specific_heat = 0.33
                block = 1
        []
        [gap_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = gap_k
                specific_heat = 5.19
                block = 2
        []
        [cladding_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = cladding_k
                specific_heat = 0.35
                block = 3
        []
[]


[BCs]
        [OC_Temp]
                type = ADDirichletBC
                boundary = 'right'
                value = 550
                variable = T
        []
        [fuel_centerline_flux]
                type = ADNeumannBC
                boundary = 'left'
                value = 0
                variable = T
        []
[]

[Preconditioning]
        [fmp]
                type = SMP
                full = true
                solve_type = 'NEWTON'
        []
[]

[VectorPostprocessors]
        [temp_profile]
                type = LineValueSampler
                start_point = '0 0.5 0'
                end_point = '0.605 0.5 0'
                num_points = 500
                variable = T
                sort_by = 'x'
        []
[]

[Executioner]
        type = Steady
[]

[Outputs]
        print_linear_residuals = true
        exodus = true
        [CSV]
                type = CSV
                file_base = ss_var_k2
        []
[]
