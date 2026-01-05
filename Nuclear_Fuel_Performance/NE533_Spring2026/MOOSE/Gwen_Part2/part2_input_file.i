[Mesh]
        coord_type = 'RZ'
        [gmg]
                type = GeneratedMeshGenerator
                dim = 2
                nx = 400
                ny = 100
                xmin = 0
                ymin = 0
                xmax = 0.605  # Fuel,Gap,Cladding
                ymax = 100 #TotalHeight
        []
        [fuel]
                type = SubdomainBoundingBoxGenerator
                block_id = 0
                bottom_left = '0 0 0'
                top_right = '0.5 100 0'
                input = 'gmg'
        []
        [gap]
                type = SubdomainBoundingBoxGenerator
                block_id = 1
                bottom_left = '0.5 0 0'
                top_right = '0.505 100 0'
                input = 'fuel'
        []
        [cladding]
                type = SubdomainBoundingBoxGenerator
                block_id = 2
                bottom_left = '0.505 0 0'
                top_right = '0.605 100 0'
                input = 'gap'    
        []
[]

[Variables]
        [T]
                order = FIRST   
                family = LAGRANGE 
        []
[]

[Functions]
        [LHR]
                type = ParsedFunction
                expression = '(350*cos(1.2*(y/50-1)))/(pi*0.5^2)'
    []
        [coolant_temp]
                type = ParsedFunction
                expression = '500 + (350 * cos(1.2 * (10 / 50 - 1))) / (2 * pi * 0.5 * 2.65) + ((1 / 1.2) * ((50 * 350) / (250 * 4.2)) * (sin(1.2) + sin(1.2 * (10 / 50 - 1))))'


  []


        [fuel_k]
                type = ParsedFunction
                expression = '(100/(7.5408+17.629*(t/1000)+3.6142*(t/1000)^2)+6400/((t/1000)^(5/2))*exp(-16.35/(t/1000)))/100'
        []
        [gap_k]
                type = ParsedFunction
                expression = '16e-6*t^0.79'
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
                function = LHR
                block = 0
        []
[]


[Materials]
        [fuel_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = fuel_k
                specific_heat = 0.33
                block = 0
        []
        [gap_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = gap_k
                specific_heat = 5.19
                block = 1
        []
        [cladding_prop]
                type = ADHeatConductionMaterial
                temp = T
                min_T = 500
                thermal_conductivity_temperature_function = cladding_k
                specific_heat = 0.35
                block = 2
        []
        [fuel_dens]
                type = ADGenericConstantMaterial
                block = 0
                prop_names = 'density'
                prop_values = '10.98'
        []
        [gap_dens]
                type = ADGenericConstantMaterial
                block = 1
                prop_names = 'density'
                prop_values = '0.1786e-3'
        []
        [cladding_dens]
                type = ADGenericConstantMaterial
                block = 2
                prop_names = 'density'
                prop_values = '6.5'
        []
[]


[BCs]
        [OC_Temp]
                type = ADFunctionDirichletBC
                boundary = 'right'
                function = coolant_temp
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

[Postprocessors]
        [centerline]
                type = PointValue
                point = '0 0.5 0'
                variable = T
        []
[]

[VectorPostprocessors]
        [clad_surface]
                type = LineValueSampler
                start_point = '0.605 0 0'
                end_point = '0.605 100 0'
                num_points = 1000
                variable = T
                sort_by = 'y'
        []
        [fuel_surface]
                type = LineValueSampler
                start_point = '0.5 0 0'
                end_point = '0.5 100 0'
                num_points = 1000
                variable = T
                sort_by = 'y'
        []
        [center_line]
                type = LineValueSampler
                start_point = '0 0 0'
                end_point = '0 100 0'
                num_points = 1000
                variable = T
                sort_by = 'y'
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
                file_base = part2
        []
[]
