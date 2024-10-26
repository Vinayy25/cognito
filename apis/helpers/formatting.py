



def list_to_numbered_string(items):
    """
    Converts a list of strings into a single numbered string.
    
    Args:
        items (list of str): The list of strings to convert.
    
    Returns:
        str: A single string with each item numbered and separated by newlines.
    """
    numbered_string = "\n".join(f"{i+1}. {item}" for i, item in enumerate(items))
    return numbered_string