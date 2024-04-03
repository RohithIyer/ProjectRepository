"""
Copyright (c) 2024 -- 
Licensed
Written by Rohith Krishnamurthy (002290948)

"""
import pandas as pd
import json

def import_csv(file_path):
    """
    Imports data from a CSV file into a pandas DataFrame and prints the number of rows and columns.
    """
    try:
        df = pd.read_csv(file_path, encoding='utf-8')
        if df.empty:
            print("The CSV file is empty.")
            return None
        else:
            print(f"Number of rows: {df.shape[0]}, Number of columns: {df.shape[1]}")
            print(df.head(10))
    except Exception as e:
        print(f"An error occurred while importing the CSV file: {e}")
    finally:
        print("Completed attempt to import CSV.")

def import_text(file_path):
    """
    Reads text from a file and returns it as a list of lines and prints the number of lines.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
            if not lines:
                print("The text file is empty.")
                return None
            else:
                print(f"Number of lines: {len(lines)}")
                for line in lines[:10]:
                    print(line.strip())
    except Exception as e:
        print(f"An error occurred while reading the text file: {e}")
    finally:
        print("Completed attempt to read text file.")

def import_json(file_path):
    """
    Loads JSON data from a file, prints the number of entries, and displays the top 10 entries.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
            if not data:
                print("The JSON file is empty.")
                return None
            else:
                print(f"Number of entries: {len(data)}")
                # Print top 10 entries
                top_10_entries = data[:10] if isinstance(data, list) else list(data.items())[:10]
                for entry in top_10_entries:
                    print(entry)
    except FileNotFoundError:
        print(f"The file {file_path} was not found.")
    except json.JSONDecodeError:
        print("The JSON file is empty or not properly formatted.")
    except Exception as e:
        print(f"An error occurred while loading the JSON file: {e}")
    finally:
        print("Completed attempt to load JSON.")

def import_excel(file_path):
    """
    Imports data from an Excel file, print the number of rows and columns, and correctly identify the headers and initial rows of data.
    """
    try:
        xls = pd.ExcelFile(file_path)
        for sheet_name in xls.sheet_names:
            df_full = pd.read_excel(xls, sheet_name=sheet_name)
            
            # Check if the entire sheet is empty
            if df_full.dropna(how='all').empty:
                print(f"The sheet '{sheet_name}' is empty.")
                continue
            
            # Find the first non-empty row for initial reading
            first_non_empty_row = df_full.notna().any(axis=1).idxmax()
            
            # Re-read the sheet starting from the first non-empty row and use it as header
            df = pd.read_excel(xls, sheet_name=sheet_name, header=first_non_empty_row)
            
            # Drop completely empty columns if any remain
            df_filtered = df.dropna(axis=1, how='all')
            
            # Adjusting row count to exclude the header
            row_count = df_filtered.shape[0]
            col_count = df_filtered.shape[1]
            
            print(f"Sheet Name: '{sheet_name}'")
            print(f"Number of rows: {row_count}, Number of columns: {col_count}")
            print(df_filtered.head(10))
            
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        print("Completed attempt to import Excel file.")


if __name__ == "__main__":
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
