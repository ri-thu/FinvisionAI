# main.py
# Add this import at the top of your file
from fastapi.middleware.cors import CORSMiddleware
import os
import google.generativeai as genai
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from dotenv import load_dotenv

# --- Configuration & Initialization ---

# Load environment variables from .env file
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="Financial Tools API",
    description="API for analyzing personal finances and parsing bills.",
    version="1.0.0",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)


# Configure Google Generative AI
api_key = os.getenv("GOOGLE_API_KEY")
if not api_key:
    print("Error: GOOGLE_API_KEY not found in environment variables.")
    # You might want to raise an exception or handle this more gracefully
    # depending on whether the API should run without the genai features.
else:
    try:
        genai.configure(api_key=api_key)
    except Exception as e:
        print(f"Error configuring Google Generative AI: {e}")
        # Handle configuration error

# --- Pydantic Models ---

# Model for Financial Analysis Request
class FinancialData(BaseModel):
    income: float = Field(..., gt=0, description="Monthly income")
    expenses: Dict[str, float] = Field(..., description="Dictionary of expense categories and amounts (e.g., {'Rent': 1500, 'Food': 500})")
    savings_goals: Dict[str, float] = Field(..., description="Dictionary of saving goals and target amounts (e.g., {'Emergency': 2000, 'Vacation': 1000})")
    discretionary_percentage: Optional[float] = Field(0.2, ge=0, le=1, description="Optional: Percentage of fixed expenses considered discretionary (default: 0.2 = 20%)")

# Model for Financial Analysis Response
class FinancialAnalysisResponse(BaseModel):
    analysis: str

# Model for Bill Parsing Request
class BillText(BaseModel):
    text: str = Field(..., description="The raw text extracted from the bill (e.g., via OCR)")

# Model for a single classified product
class ProductItem(BaseModel):
    name: str
    price: float
    category: str

# Model for Bill Parsing Response
class ParsedBillResponse(BaseModel):
    classified_products: List[ProductItem]
    final_amount: Optional[float] = None # Use Optional since it might not be found

# --- Financial Analysis Logic ---

async def get_financial_analysis(data: FinancialData) -> str:
    """Generates financial analysis using Google Generative AI."""
    try:
        fixed_expenses = sum(data.expenses.values())
        # Use provided percentage or default to calculate discretionary expenses
        discretionary_expenses = fixed_expenses * (data.discretionary_percentage if data.discretionary_percentage is not None else 0.2)

        prompt = f"""
        Given the following financial data:

        - Monthly Income: ${data.income:,.2f}
        - Fixed Expenses (Total from provided list): ${fixed_expenses:,.2f}
        - Estimated Discretionary Expenses (calculated as {data.discretionary_percentage*100:.0f}% of fixed): ${discretionary_expenses:,.2f}
        - Specific Fixed Expense Breakdown: {data.expenses}
        - Savings Goals: {data.savings_goals}

        Analyze the data and predict the estimated time required to achieve the savings goal(s). Provide insights and actionable advice on the following points:

        1.  **Timeline Estimation:** Calculate a potential timeline for reaching each savings goal based on current income and *total* calculated expenses (fixed + discretionary). Clearly state the assumptions made (e.g., assumes consistent income/expenses, all remaining income goes to savings proportionally or sequentially).
        2.  **Budget Optimization:** Suggest specific strategies to reduce fixed or discretionary spending to accelerate savings (e.g., "Consider negotiating rent", "Track food spending more closely", "Identify cheaper transportation options").
        3.  **Investment Options (General):** Briefly mention possible *types* of investment options suitable for surplus funds *after* establishing an emergency fund (e.g., high-yield savings accounts, index funds, ETFs). **Do not give specific financial advice.** Emphasize risk tolerance and seeking professional advice.
        4.  **Discretionary Spending Adjustment:** Provide recommendations on how to adjust discretionary spending habits without significantly impacting lifestyle, focusing on mindful spending and identifying value.

        Present the analysis clearly and concisely.
        """

        model = genai.GenerativeModel("gemini-1.5-flash") # Or your preferred model
        response = await model.generate_content_async(prompt) # Use async version
        return response.text

    except Exception as e:
        print(f"Error during Google Generative AI call: {e}")
        # Re-raise as HTTPException to send proper API error response
        raise HTTPException(status_code=500, detail=f"Failed to generate financial analysis: {e}")


# --- Bill Parsing Logic ---

# Define product categories (copied from your script)
PRODUCT_CATEGORIES = {
    "Food": [
        "BREAD", "EGGS", "COTTAGE CHEESE", "YOGURT", "TOMATOES", "BANANAS", "CHICKEN",
        "TUNA", "VEGETABLES", "FRUIT", "POTATOES", "CARROTS", "LETTUCE", "PUMPKIN", "CABBAGE",
        "ONIONS", "GARLIC", "PEAS", "APPLE", "ORANGE", "PEACH", "STRAWBERRY"
    ],
    "Beverages": [
        "MILK", "COFFEE", "JUICE", "WATER", "TEA", "SODA", "ENERGY DRINK", "SPORTS DRINK",
        "ALCOHOL", "WINE", "BEER", "COCKTAIL", "CIDER"
    ],
    "Household": [
        "TOILET PAPER", "WIPES", "CLEANER", "PAPER TOWELS", "SPONGE", "MOP", "GLOVES",
        "DISINFECTANT", "DISH SOAP", "LAUNDRY DETERGENT", "BROOM", "TRASH BAGS",
        "FABRIC SOFTENER", "AIR FRESHENER", "TISSUES", "PLASTIC WRAP", "ALUMINUM FOIL"
    ],
    # ... (include ALL other categories from your original script) ...
    "Dairy": ["CHEESE", "BUTTER", "MILK", "YOGURT", "ICE CREAM", "CREAM", "COTTAGE CHEESE", "WHIPPED CREAM", "SOUR CREAM", "EGGS"],
    "Snacks": ["CRACKERS", "COOKIES", "CHOCOLATE", "CANDY", "CANDY BAR", "CHIPS", "NUTS", "SEEDS", "CORN SNACKS", "TRAIL MIX", "PRETZELS", "POP CORN", "GUM"],
    # Add ALL categories here for completeness...
    "Others": [] # Catch-all
}

def extract_and_classify_products(text: str) -> List[ProductItem]:
    """
    Extracts products and prices, classifies them, and returns a list of ProductItem models.
    Note: This parsing logic is basic and might fail on complex bill formats.
    """
    lines = text.strip().split('\n')
    product_list = []

    for line in lines:
        line = line.strip()
        if not line:
            continue

        words = line.split()
        price_found = None
        price_index = -1

        # Try to find a numerical value (price) - rudimentary check
        for i, word in enumerate(reversed(words)):
            try:
                # Clean potential currency symbols or commas for check
                cleaned_word = word.replace('$', '').replace('€', '').replace('£', '').replace(',', '')
                price_found = float(cleaned_word)
                price_index = len(words) - 1 - i
                break # Found the last number, assume it's price
            except ValueError:
                continue # Not a number

        if price_found is not None and price_index > 0: # Ensure there's a name before price
            product_name = ' '.join(words[:price_index]).strip()
            if not product_name: # Skip if name extraction failed
                continue

            # Classify product
            product_category = "Others" # Default
            product_name_upper = product_name.upper()
            for category, keywords in PRODUCT_CATEGORIES.items():
                if any(keyword in product_name_upper for keyword in keywords):
                    product_category = category
                    break

            product_list.append(ProductItem(
                name=product_name,
                price=price_found,
                category=product_category
            ))
        # else: Line likely doesn't contain a product and price in expected format

    return product_list

def extract_final_amount_from_total(text: str) -> Optional[float]:
    """
    Extracts the final amount by searching for keywords like 'TOTAL'.
    """
    lines = text.strip().split('\n')
    total_keywords = ["AMOUNT DUE", "BALANCE DUE", "PAYMENT", "FINAL AMOUNT", "TOTAL", "DEBIT", "BALANCE"] # Added BALANCE

    for line in reversed(lines): # Check from bottom up
        line_upper = line.upper()
        words = line.split()

        # Check if any keyword is potentially present in the line
        if any(keyword in line_upper for keyword in total_keywords):
            # Search for the *last* number in that line, assuming it's the total
            for word in reversed(words):
                try:
                    # More robust cleaning for currency/commas
                    cleaned_word = ''.join(filter(lambda x: x.isdigit() or x == '.' or x == '-', word))
                    if cleaned_word and cleaned_word != '-': # Make sure it's not just a hyphen
                         final_amount = float(cleaned_word)
                         return final_amount # Return the first valid number found from the right
                except ValueError:
                    continue # Not a number
    return None # Return None if no total found

# --- API Endpoints ---

@app.post("/analyze-finances", response_model=FinancialAnalysisResponse)
async def analyze_finances_endpoint(data: FinancialData):
    """
    Accepts financial data (income, expenses, goals) and returns
    an AI-generated analysis and savings plan.
    """
    if not api_key:
         raise HTTPException(status_code=503, detail="Google API Key not configured. Service unavailable.")
    analysis_text = await get_financial_analysis(data)
    return FinancialAnalysisResponse(analysis=analysis_text)


@app.post("/parse-bill", response_model=ParsedBillResponse)
async def parse_bill_endpoint(bill_data: BillText):
    """
    Accepts raw text from a bill and attempts to extract/classify products
    and find the final total amount.
    """
    classified_products = extract_and_classify_products(bill_data.text)
    final_amount = extract_final_amount_from_total(bill_data.text)

    # Optional: Add basic validation/check if extraction seems reasonable
    if not classified_products and final_amount is None:
         # Maybe raise a warning or return a specific message if nothing was found
         print("Warning: Could not extract any products or final amount from the provided text.")


    return ParsedBillResponse(
        classified_products=classified_products,
        final_amount=final_amount
    )

@app.get("/", include_in_schema=False)
async def root():
    return {"message": "Welcome to the Financial Tools API. See /docs for details."}

# --- Run the app (for development) ---
# Use: uvicorn main:app --reload