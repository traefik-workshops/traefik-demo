import json
import sys
import random
from datetime import datetime, timedelta
import re

def random_date(start, end):
    """Generate a random datetime between `start` and `end`"""
    delta = end - start
    int_delta = (delta.days * 24 * 60 * 60) + delta.seconds
    random_second = random.randrange(int_delta)
    return start + timedelta(seconds=random_second)

def process_data(data):
    now = datetime.utcnow()
    two_weeks = now + timedelta(weeks=2)
    
    def update_obj(obj):
        if isinstance(obj, dict):
            # Special handling for flights to ensure arrival > departure
            if 'departure_time' in obj and 'arrival_time' in obj:
                dep = random_date(now, two_weeks)
                duration = timedelta(hours=random.randint(2, 14))
                arr = dep + duration
                obj['departure_time'] = dep.strftime("%Y-%m-%dT%H:%M:%SZ")
                obj['arrival_time'] = arr.strftime("%Y-%m-%dT%H:%M:%SZ")
            
            for k, v in obj.items():
                if k in ['departure_time', 'arrival_time']:
                    continue # Already handled
                
                if isinstance(v, (dict, list)):
                    update_obj(v)
                elif isinstance(v, str):
                    # Update other date fields if they look like dates
                    # Heuristic: keys containing 'date', 'time', 'at' and value matches YYYY-MM-DD
                    if any(x in k for x in ['date', 'time', 'at']) and 'birth' not in k:
                         if re.match(r'\d{4}-\d{2}-\d{2}T', v):
                             new_date = random_date(now, two_weeks)
                             obj[k] = new_date.strftime("%Y-%m-%dT%H:%M:%SZ")
        elif isinstance(obj, list):
            for item in obj:
                update_obj(item)

    update_obj(data)
    return data

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: seed_data.py <input_file> <output_file>")
        sys.exit(1)

    try:
        with open(sys.argv[1], 'r') as f:
            data = json.load(f)
        
        processed = process_data(data)
        
        with open(sys.argv[2], 'w') as f:
            json.dump(processed, f, indent=2)
            print(f"Seeded data written to {sys.argv[2]}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
