"""
<Project Title>


Copyright (c) 2021 -- This is the 2021 Spring B version of the Template
Licensed
Written by <Rohith Krishnamurthy (002290948)> <---- PLEASE, WRITE YOUR NAME HERE

# you can also rely on the docstring documentation from pandas on how to format dosctrings:
# https://pandas.pydata.org/pandas-docs/stable/development/contributing_docstring.html

"""


import pandas as pd
import json

def import_csv(file_path):
    try:
        df = pd.read_csv(file_path)
        if df.empty:
            print("The CSV file is empty.")
            return None
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
        return None
    except PermissionError:
        print(f"Permission denied: {file_path}")
        return None
    except pd.errors.EmptyDataError:
        print("The CSV file is empty.")
        return None
    except UnicodeDecodeError:
        print(f"Encoding error in file {file_path}.")
        return None
    except Exception as e:
        print(f"An error occurred while importing the CSV file: {e}")
        return None
    else:
        print(df.head(10))
        return df
    finally:
        print("Completed attempt to import CSV.")

def import_text(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
            if not lines:
                print("The text file is empty.")
                return None
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
        return None
    except PermissionError:
        print(f"Permission denied: {file_path}")
        return None
    except UnicodeDecodeError:
        print(f"Encoding error in file {file_path}.")
        return None
    except Exception as e:
        print(f"An error occurred while reading the text file: {e}")
        return None
    else:
        for line in lines[:10]:
            print(line.strip())
        return lines
    finally:
        print("Completed attempt to read text file.")

def import_json(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
            if not data:
                print("The JSON file is empty.")
                return None
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
        return None
    except PermissionError:
        print(f"Permission denied: {file_path}")
        return None
    except json.JSONDecodeError:
        print("The JSON file is empty or not properly formatted.")
        return None
    except UnicodeDecodeError:
        print(f"Encoding error in file {file_path}.")
        return None
    except Exception as e:
        print(f"An error occurred while loading the JSON file: {e}")
        return None
    else:
        print(json.dumps(data, indent=4, sort_keys=True)[:1000])
        return data
    finally:
        print("Completed attempt to load JSON.")

def import_excel(file_path):
    try:
        xls = pd.ExcelFile(file_path)
        dfs = []
        for sheet_name in xls.sheet_names:
            df = pd.read_excel(xls, sheet_name)
            if df.empty:
                print(f"The sheet '{sheet_name}' is empty.")
            else:
                dfs.append(df)
        if not dfs:
            print("All sheets are empty.")
            return None
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
        return None
    except PermissionError:
        print(f"Permission denied: {file_path}")
        return None
    except ValueError:
        print(f"The file {file_path} is not a valid Excel file.")
        return None
    except Exception as e:
        print(f"An error occurred while importing the Excel file: {e}")
        return None
    else:
        for df in dfs:
            print(f"Top 10 entries from sheet:")
            print(df.head(10))
        return dfs
    finally:
        print("Completed attempt to import Excel file.")

if __name__ == "__main__":
 # File names
    csv_file = 'Neural_data.csv'
    text_file = 'network_data.txt'
    json_file = 'nested_data.json'
    excel_file = 'Excel_report.xlsx'
    
    print("CSV Data:")
    import_csv(csv_file)
    print("\nText Data:")
    import_text(text_file)
    print("\nJSON Data:")
    import_json(json_file)
    print("\nExcel Data:")
    import_excel(excel_file)
