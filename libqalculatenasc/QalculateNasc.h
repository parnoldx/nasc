#ifndef __QALCULATENASC_H
#define __QALCULATENASC_H

#ifdef __cplusplus
extern "C" {
#endif

void new_calulator();

char* Calculator_calculate(const char* string);

char* Calculator_calculate_store_variable(const char* input, const char* variable);

void clear_variables();
void abortt();

void delete_calculator();

int get_function_size();
int get_variable_size();
char* get_function_name(int index);
char* get_function_description(int index);
char* get_function_category(int index);
char* get_function_title(int index);
char* get_function_arguments(int index);
char* get_function_arguments_list (int index) ;
char* get_variable_name(int index);
char* get_variable_category(int index);
char* get_variable_title(int index);

void load_currencies();
char* get_exchange_rates_url();
char* get_exchange_rates_filename();

#ifdef __cplusplus
}
char* convert_string (std::string str);
std::string intern_calc_wait (std::string input);
std::string intern_calc_terminate (std::string input);
std::string intern_calc (std::string input);
#endif
#endif
