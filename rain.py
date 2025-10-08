import sys

def read_input(filename):
    with open(filename, 'r') as f:
        _ = f.readline()  # αγνοει την πρωτη γραμμή 
        line = f.readline().strip() #διαβαζουμε και καθαριζουμε 2η γραμμή που περιεχει τα υψη
        numbers = line.split()
        try:
            heights = [int(num) for num in numbers]  #μετατρέπουμε κάθε νούμερο σε ακέραιο.
        except ValueError as e:
            raise ValueError(f"Invalid number in input: {e}")
    return heights

#για καθε θέση στην λίστα με τα ύψη, υπολογιζουμε το μεγιστο υψος απο αριστερά
def max_left(heights):
    lefts = []
    current = 0
    for h in heights:
        current = max(current, h)
        lefts.append(current)
    return lefts

def max_right(heights):
    return list(reversed(max_left(list(reversed(heights)))))

def water_trapped(heights):
    lefts = max_left(heights)
    rights = max_right(heights)

    total_trapped = 0
    for h, l, r in zip(heights, lefts, rights):
        water = min(l, r) - h #νερό που μπορει να παγιδευτεί
        total_trapped += max(water, 0)
    return total_trapped  #συνολικό παγιδευμένο νερό

def rain(filename):
    heights = read_input(filename)
    result = water_trapped(heights)
    print(result)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python rain.py <input_file>")
    else:
        rain(sys.argv[1])
