[CCode (cheader_filename = "QalculateNasc.h")]
[Compact]
public class QalculateNasc {

	[CCode (cname = "new_calculator")]
	public static void new_calculator();

	[CCode (cname = "delete_calculator")]
	public static void delete_calculator();

	[CCode (cname = "Calculator_calculate")]
	public static string calculate (string input);

	[CCode (cname = "Calculator_calculate_store_variable")]
	public static string calculate_store_variable (string input, string variable);

	[CCode (cname = "clear_variables")]
	public static void clear_variables ();

	[CCode (cname = "abort")]
	public static void abort ();

	[CCode (cname = "get_function_size")]
	public static int get_function_size ();

	[CCode (cname = "get_function_name")]
	public static string get_function_name (int index);

	[CCode (cname = "get_function_description")]
	public static string get_function_description (int index);

	[CCode (cname = "get_function_category")]
	public static string get_function_category (int index);

	[CCode (cname = "get_function_title")]
	public static string get_function_title (int index);

	[CCode (cname = "get_function_arguments")]
	public static string get_function_arguments (int index);

	[CCode (cname = "get_function_arguments_list")]
	public static string get_function_arguments_list (int index);

	[CCode (cname = "get_variable_size")]
	public static int get_variable_size ();

	[CCode (cname = "get_variable_name")]
	public static string get_variable_name (int index);

	[CCode (cname = "get_variable_category")]
	public static string get_variable_category (int index);

	[CCode (cname = "get_variable_title")]
	public static string get_variable_title (int index);

	[CCode (cname = "get_exchange_rates_url")]
	public static string get_exchange_rates_url();

	[CCode (cname = "get_exchange_rates_filename")]
	public static string get_exchange_rates_filename();

}