	declare -a algoritmos_stats_pp_atraso=(
"wpa_sup_"
"mediana_3_"
"mediana_5_"
"mediana_7_"
"mediana_9_"
"mediana_11_"
"mediana_13_"
"mediana_15_"
"mediana_17_"
"mediana_19_"
"mediana_21_"
"mediana_23_"
"mediana_25_"
"mediana_27_"
"mediana_29_"
"mediana_31_"
"moda_3_"
"moda_4_"
"moda_5_"
"moda_6_"
"moda_7_"
"moda_8_"
"moda_9_"
"moda_10_"
"moda_11_"
"moda_12_"
"moda_13_"
"moda_14_"
"moda_15_"
"moda_16_"
"moda_17_"
"moda_18_"
"moda_19_"
"moda_20_"
"moda_21_"
"moda_22_"
"maximo_2_"
"maximo_3_"
"maximo_4_"
"maximo_5_"
"maximo_6_"
"maximo_7_"
"maximo_8_"
"maximo_9_"
"maximo_10_"
"maximo_11_"
"maximo_12_"
"maximo_13_"
"maximo_14_"
"maximo_15_"
"maximo_16_"
"maximo_17_"
"maximo_18_"
"maximo_19_"
"maximo_20_"
"maximo_21_"
"histerese_1_"
"histerese_2_"
"histerese_3_"
"histerese_4_"
"histerese_5_"
"histerese_6_"
"histerese_7_"
"histerese_8_"
"histerese_9_"
"histerese_10_"
"histerese_11_"
"histerese_12_"
"histerese_13_"
"histerese_14_"
"histerese_15_"
"histerese_16_"
"histerese_17_"
"histerese_18_"
"histerese_19_"
"histerese_20_"
"mmep_0.01_"
"mmep_0.02_"
"mmep_0.03_"
"mmep_0.04_"
"mmep_0.05_"
"mmep_0.06_"
"mmep_0.07_"
"mmep_0.08_"
"mmep_0.09_"
"mmep_0.1_"
"mmep_0.11_"
"mmep_0.12_"
"mmep_0.13_"
"mmep_0.14_"
"mmep_0.15_"
"mmep_0.16_"
"mmep_0.17_"
"mmep_0.18_"
"mmep_0.19_"
"mmep_0.2_"
"mmep_0.21_"
"mmep_0.22_"
"mmep_0.23_"
"mmep_0.24_"
"mmep_0.25_"
"mmep_0.26_"
"mmep_0.27_"
"mmep_0.28_"
"mmep_0.29_"
"mmep_0.3_"
"mmep_0.31_"
"mmep_0.32_"
"mmep_0.33_"
"mmep_0.34_"
"mmep_0.35_"
"mmep_0.36_"
"mmep_0.37_"
"mmep_0.38_"
"mmep_0.39_"
"mmep_0.4_"
"mmep_0.41_"
"mmep_0.42_"
"mmep_0.43_"
"mmep_0.44_"
"mmep_0.45_"
"mmep_0.46_"
"mmep_0.47_"
"mmep_0.48_"
"mmep_0.49_"
"mmep_0.5_"
"mmep_0.51_"
"mmep_0.52_"
"mmep_0.53_"
"mmep_0.54_"
"mmep_0.55_"
"mmep_0.56_"
"mmep_0.57_"
"mmep_0.58_"
"mmep_0.59_"
"mmep_0.6_"
"mmep_0.61_"
"mmep_0.62_"
"mmep_0.63_"
"mmep_0.64_"
"mmep_0.65_"
"mmep_0.66_"
"mmep_0.67_"
"mmep_0.68_"
"mmep_0.69_"
"mmep_0.7_"
"mmep_0.71_"
"mmep_0.72_"
"mmep_0.73_"
"mmep_0.74_"
"mmep_0.75_"
"mmep_0.76_"
"mmep_0.77_"
"mmep_0.78_"
"mmep_0.79_"
"mmep_0.8_"
"mmep_0.81_"
"mmep_0.82_"
"mmep_0.83_"
"mmep_0.84_"
"mmep_0.85_"
"mmep_0.86_"
"mmep_0.87_"
"mmep_0.88_"
"mmep_0.89_"
"mmep_0.9_"
"mmep_0.91_"
"mmep_0.92_"
"mmep_0.93_"
"mmep_0.94_"
"mmep_0.95_"
"mmep_0.96_"
"mmep_0.97_"
"mmep_0.98_"
"mmep_0.99_"
"distrnorm_0.5_4_4_4_"
"distrnorm_0.5_4_4_6_"
"distrnorm_0.5_4_4_8_"
"distrnorm_0.5_4_4_10_"
"distrnorm_0.5_5_4_4_"
"distrnorm_0.5_5_4_6_"
"distrnorm_0.5_5_4_8_"
"distrnorm_0.5_5_4_10_"
"distrnorm_0.7_4_4_4_"
"distrnorm_0.7_4_4_6_"
"distrnorm_0.7_4_4_8_"
"distrnorm_0.7_4_4_10_"
"distrnorm_0.7_5_4_4_"
"distrnorm_0.7_5_4_6_"
"distrnorm_0.7_5_4_8_"
"distrnorm_0.7_5_4_10_"
"distrnorm_1.0_4_4_4_"
"distrnorm_1.0_4_4_6_"
"distrnorm_1.0_4_4_8_"
"distrnorm_1.0_4_4_10_"
"distrnorm_1.0_5_4_4_"
"distrnorm_1.0_5_4_6_"
"distrnorm_1.0_5_4_8_"
"distrnorm_1.0_5_4_10_"
"distrnorm_1.2_4_4_4_"
"distrnorm_1.2_4_4_6_"
"distrnorm_1.2_4_4_8_"
"distrnorm_1.2_4_4_10_"
"distrnorm_1.2_5_4_4_"
"distrnorm_1.2_5_4_6_"
"distrnorm_1.2_5_4_8_"
"distrnorm_1.2_5_4_10_"
"distrnorm_1.5_4_4_4_"
"distrnorm_1.5_4_4_6_"
"distrnorm_1.5_4_4_8_"
"distrnorm_1.5_4_4_10_"
"distrnorm_1.5_5_4_4_"
"distrnorm_1.5_5_4_6_"
"distrnorm_1.5_5_4_8_"
"distrnorm_1.5_5_4_10_"
"distrnorm_0.5_4_6_4_"
"distrnorm_0.5_4_6_6_"
"distrnorm_0.5_4_6_8_"
"distrnorm_0.5_4_6_10_"
"distrnorm_0.5_5_6_4_"
"distrnorm_0.5_5_6_6_"
"distrnorm_0.5_5_6_8_"
"distrnorm_0.5_5_6_10_"
"distrnorm_0.7_4_6_4_"
"distrnorm_0.7_4_6_6_"
"distrnorm_0.7_4_6_8_"
"distrnorm_0.7_4_6_10_"
"distrnorm_0.7_5_6_4_"
"distrnorm_0.7_5_6_6_"
"distrnorm_0.7_5_6_8_"
"distrnorm_0.7_5_6_10_"
"distrnorm_1.0_4_6_4_"
"distrnorm_1.0_4_6_6_"
"distrnorm_1.0_4_6_8_"
"distrnorm_1.0_4_6_10_"
"distrnorm_1.0_5_6_4_"
"distrnorm_1.0_5_6_6_"
"distrnorm_1.0_5_6_8_"
"distrnorm_1.0_5_6_10_"
"distrnorm_1.2_4_6_4_"
"distrnorm_1.2_4_6_6_"
"distrnorm_1.2_4_6_8_"
"distrnorm_1.2_4_6_10_"
"distrnorm_1.2_5_6_4_"
"distrnorm_1.2_5_6_6_"
"distrnorm_1.2_5_6_8_"
"distrnorm_1.2_5_6_10_"
"distrnorm_1.5_4_6_4_"
"distrnorm_1.5_4_6_6_"
"distrnorm_1.5_4_6_8_"
"distrnorm_1.5_4_6_10_"
"distrnorm_1.5_5_6_4_"
"distrnorm_1.5_5_6_6_"
"distrnorm_1.5_5_6_8_"
"distrnorm_1.5_5_6_10_"
"distrnorm_0.5_4_8_4_"
"distrnorm_0.5_4_8_6_"
"distrnorm_0.5_4_8_8_"
"distrnorm_0.5_4_8_10_"
"distrnorm_0.5_5_8_4_"
"distrnorm_0.5_5_8_6_"
"distrnorm_0.5_5_8_8_"
"distrnorm_0.5_5_8_10_"
"distrnorm_0.7_4_8_4_"
"distrnorm_0.7_4_8_6_"
"distrnorm_0.7_4_8_8_"
"distrnorm_0.7_4_8_10_"
"distrnorm_0.7_5_8_4_"
"distrnorm_0.7_5_8_6_"
"distrnorm_0.7_5_8_8_"
"distrnorm_0.7_5_8_10_"
"distrnorm_1.0_4_8_4_"
"distrnorm_1.0_4_8_6_"
"distrnorm_1.0_4_8_8_"
"distrnorm_1.0_4_8_10_"
"distrnorm_1.0_5_8_4_"
"distrnorm_1.0_5_8_6_"
"distrnorm_1.0_5_8_8_"
"distrnorm_1.0_5_8_10_"
"distrnorm_1.2_4_8_4_"
"distrnorm_1.2_4_8_6_"
"distrnorm_1.2_4_8_8_"
"distrnorm_1.2_4_8_10_"
"distrnorm_1.2_5_8_4_"
"distrnorm_1.2_5_8_6_"
"distrnorm_1.2_5_8_8_"
"distrnorm_1.2_5_8_10_"
"distrnorm_1.5_4_8_4_"
"distrnorm_1.5_4_8_6_"
"distrnorm_1.5_4_8_8_"
"distrnorm_1.5_4_8_10_"
"distrnorm_1.5_5_8_4_"
"distrnorm_1.5_5_8_6_"
"distrnorm_1.5_5_8_8_"
"distrnorm_1.5_5_8_10_"
"distrnorm_0.5_4_10_4_"
"distrnorm_0.5_4_10_6_"
"distrnorm_0.5_4_10_8_"
"distrnorm_0.5_4_10_10_"
"distrnorm_0.5_5_10_4_"
"distrnorm_0.5_5_10_6_"
"distrnorm_0.5_5_10_8_"
"distrnorm_0.5_5_10_10_"
"distrnorm_0.7_4_10_4_"
"distrnorm_0.7_4_10_6_"
"distrnorm_0.7_4_10_8_"
"distrnorm_0.7_4_10_10_"
"distrnorm_0.7_5_10_4_"
"distrnorm_0.7_5_10_6_"
"distrnorm_0.7_5_10_8_"
"distrnorm_0.7_5_10_10_"
"distrnorm_1.0_4_10_4_"
"distrnorm_1.0_4_10_6_"
"distrnorm_1.0_4_10_8_"
"distrnorm_1.0_4_10_10_"
"distrnorm_1.0_5_10_4_"
"distrnorm_1.0_5_10_6_"
"distrnorm_1.0_5_10_8_"
"distrnorm_1.0_5_10_10_"
"distrnorm_1.2_4_10_4_"
"distrnorm_1.2_4_10_6_"
"distrnorm_1.2_4_10_8_"
"distrnorm_1.2_4_10_10_"
"distrnorm_1.2_5_10_4_"
"distrnorm_1.2_5_10_6_"
"distrnorm_1.2_5_10_8_"
"distrnorm_1.2_5_10_10_"
"distrnorm_1.5_4_10_4_"
"distrnorm_1.5_4_10_6_"
"distrnorm_1.5_4_10_8_"
"distrnorm_1.5_4_10_10_"
"distrnorm_1.5_5_10_4_"
"distrnorm_1.5_5_10_6_"
"distrnorm_1.5_5_10_8_"
"distrnorm_1.5_5_10_10_"
"distrnorm_0.5_4_12_4_"
"distrnorm_0.5_4_12_6_"
"distrnorm_0.5_4_12_8_"
"distrnorm_0.5_4_12_10_"
"distrnorm_0.5_5_12_4_"
"distrnorm_0.5_5_12_6_"
"distrnorm_0.5_5_12_8_"
"distrnorm_0.5_5_12_10_"
"distrnorm_0.7_4_12_4_"
"distrnorm_0.7_4_12_6_"
"distrnorm_0.7_4_12_8_"
"distrnorm_0.7_4_12_10_"
"distrnorm_0.7_5_12_4_"
"distrnorm_0.7_5_12_6_"
"distrnorm_0.7_5_12_8_"
"distrnorm_0.7_5_12_10_"
"distrnorm_1.0_4_12_4_"
"distrnorm_1.0_4_12_6_"
"distrnorm_1.0_4_12_8_"
"distrnorm_1.0_4_12_10_"
"distrnorm_1.0_5_12_4_"
"distrnorm_1.0_5_12_6_"
"distrnorm_1.0_5_12_8_"
"distrnorm_1.0_5_12_10_"
"distrnorm_1.2_4_12_4_"
"distrnorm_1.2_4_12_6_"
"distrnorm_1.2_4_12_8_"
"distrnorm_1.2_4_12_10_"
"distrnorm_1.2_5_12_4_"
"distrnorm_1.2_5_12_6_"
"distrnorm_1.2_5_12_8_"
"distrnorm_1.2_5_12_10_"
"distrnorm_1.5_4_12_4_"
"distrnorm_1.5_4_12_6_"
"distrnorm_1.5_4_12_8_"
"distrnorm_1.5_4_12_10_"
"distrnorm_1.5_5_12_4_"
"distrnorm_1.5_5_12_6_"
"distrnorm_1.5_5_12_8_"
"distrnorm_1.5_5_12_10_"
"distrnorm_0.5_4_14_4_"
"distrnorm_0.5_4_14_6_"
"distrnorm_0.5_4_14_8_"
"distrnorm_0.5_4_14_10_"
"distrnorm_0.5_5_14_4_"
"distrnorm_0.5_5_14_6_"
"distrnorm_0.5_5_14_8_"
"distrnorm_0.5_5_14_10_"
"distrnorm_0.7_4_14_4_"
"distrnorm_0.7_4_14_6_"
"distrnorm_0.7_4_14_8_"
"distrnorm_0.7_4_14_10_"
"distrnorm_0.7_5_14_4_"
"distrnorm_0.7_5_14_6_"
"distrnorm_0.7_5_14_8_"
"distrnorm_0.7_5_14_10_"
"distrnorm_1.0_4_14_4_"
"distrnorm_1.0_4_14_6_"
"distrnorm_1.0_4_14_8_"
"distrnorm_1.0_4_14_10_"
"distrnorm_1.0_5_14_4_"
"distrnorm_1.0_5_14_6_"
"distrnorm_1.0_5_14_8_"
"distrnorm_1.0_5_14_10_"
"distrnorm_1.2_4_14_4_"
"distrnorm_1.2_4_14_6_"
"distrnorm_1.2_4_14_8_"
"distrnorm_1.2_4_14_10_"
"distrnorm_1.2_5_14_4_"
"distrnorm_1.2_5_14_6_"
"distrnorm_1.2_5_14_8_"
"distrnorm_1.2_5_14_10_"
"distrnorm_1.5_4_14_4_"
"distrnorm_1.5_4_14_6_"
"distrnorm_1.5_4_14_8_"
"distrnorm_1.5_4_14_10_"
"distrnorm_1.5_5_14_4_"
"distrnorm_1.5_5_14_6_"
"distrnorm_1.5_5_14_8_"
"distrnorm_1.5_5_14_10_"
)
