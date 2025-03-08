import easyocr

# Load OCR Model
reader = easyocr.Reader(['en'])

# 🔹 **Step 1: Extract Text from Image (OCR)**
def extract_text_from_image(image_path):
    print(f"📄 Processing image: {image_path}")
    text = reader.readtext(image_path, detail=0)  # Extract text without bounding box details
    extracted_text = "\n".join(text)  # Combine extracted text into lines
    print(f"📝 Extracted Text:\n{extracted_text}\n")
    return extracted_text

# 🔹 **Step 2: Extract & Classify Products from Receipt**
def extract_and_classify_products(text):
    categories = {
        "Food": ["BREAD", "EGGS", "COTTAGE CHEESE", "YOGURT", "TOMATOES", "BANANAS", "CHICKEN"],
        "Beverages": ["MILK", "COFFEE", "JUICE", "WATER", "TEA", "SODA"],
        "Household": ["TOILET PAPER", "WIPES", "CLEANER", "PAPER TOWELS"],
        "Snacks": ["CRACKERS", "COOKIES", "CHOCOLATE", "CANDY"],
        "Dairy": ["CHEESE", "BUTTER", "MILK", "YOGURT", "ICE CREAM"],
        "Frozen": ["FROZEN FOOD", "FROZEN PIZZA", "FROZEN CHICKEN"],
        "Bakery": ["BREAD", "BAGELS", "CROISSANT"],
        "Meat & Seafood": ["BEEF", "PORK", "CHICKEN", "SALMON"],
        "Produce": ["FRUIT", "VEGETABLE", "CARROTS", "PEPPER"],
        "Pharmacy": ["MEDICINE", "VITAMINS", "TOOTHPASTE"],
        "Personal Care": ["SHAMPOO", "SOAP", "DEODORANT"],
        "Pet Supplies": ["PET FOOD", "DOG FOOD"],
        "Electronics": ["LAPTOP", "PHONE", "TABLET"],
        "Health & Fitness": ["EXERCISE EQUIPMENT", "DUMBBELLS"],
        "Office Supplies": ["PAPER", "PENS", "NOTEBOOK"],
        "Baby & Kids": ["DIAPERS", "BABY FOOD"],
        "Auto Supplies": ["OIL", "CAR BATTERY"]
    }

    lines = text.strip().split('\n')
    product_list = []

    for line in lines:
        words = line.split()
        for i, word in enumerate(words):
            if word.replace('.', '', 1).isdigit():  # Check if the word is a price
                price = float(word.replace('$', '').replace(',', ''))
                product_name = ' '.join(words[:i])

                product_category = "Others"
                for category, keywords in categories.items():
                    if any(keyword in product_name.upper() for keyword in keywords):
                        product_category = category
                        break

                product_list.append({
                    "name": product_name,
                    "price": price,
                    "category": product_category
                })
    return product_list

# 🔹 **Step 3: Extract Final Bill Amount**
def extract_final_amount_from_total(text):
    lines = text.strip().split('\n')
    total_keywords = ["AMOUNT DUE", "BALANCE DUE", "PAYMENT", "FINAL AMOUNT", "TOTAL", "DEBIT"]

    for line in lines[::-1]:
        line_upper = line.upper()
        if any(keyword in line_upper for keyword in total_keywords):
            words = line.split()
            for word in words:
                if '$' in word:
                    final_amount = float(word.replace('$', '').replace(',', ''))
                    return final_amount
    return None

# 🔹 **Step 4: Process the Receipt**
def process_receipt(image_path):
    extracted_text = extract_text_from_image(image_path)
    products = extract_and_classify_products(extracted_text)
    final_amount = extract_final_amount_from_total(extracted_text)

    return extracted_text, products, final_amount

# 🔹 **Example Usage**
image_path = "/Users/ronbinoymechery/Downloads/bill1.jpg"  # Replace with actual image path
text, classified_products, final_amount = process_receipt(image_path)

# 🔹 **Print Results**
print("\n🎯 **Final Output** 🎯")
print(f"📄 Extracted Text:\n{text}\n")

print("🛒 **Classified Products:**")
for product in classified_products:
    print(f" - Product: {product['name']}, Price: ₹{product['price']}, Category: {product['category']}")

if final_amount is not None:
    print(f"\n💰 **Final Amount: ₹{final_amount}**")
else:
    print("\n❌ **Final amount not found in receipt.**")
